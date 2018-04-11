require "tmpdir"

class Upload < ApplicationRecord
  class Error < Exception ; end

  attr_accessor :file, :image_width, :image_height, :file_ext, :md5, 
    :file_size, :as_pending, :artist_commentary_title, 
    :artist_commentary_desc, :include_artist_commentary,
    :referer_url, :downloaded_source, :replaced_post
  belongs_to :uploader, :class_name => "User"

  belongs_to :post, optional: true

  before_validation :initialize_attributes
  validate :uploader_is_not_limited, :on => :create
  validate :file_or_source_is_present, :on => :create
  validate :rating_given

  def initialize_attributes
    self.uploader_id = CurrentUser.user.id
    self.uploader_ip_addr = CurrentUser.ip_addr
    self.server = Danbooru.config.server_host
  end

  module ValidationMethods
    def uploader_is_not_limited
      if !uploader.can_upload?
        self.errors.add(:uploader, uploader.upload_limited_reason)
        return false
      else
        return true
      end
    end

    def file_or_source_is_present
      if file.blank? && source.blank?
        self.errors.add(:base, "Must choose file or specify source")
        return false
      else
        return true
      end
    end

    # Because uploads are processed serially, there's no race condition here.
    def validate_md5_uniqueness
      md5_post = Post.find_by_md5(md5)

      if md5_post && replaced_post
        raise "duplicate: #{md5_post.id}" if replaced_post != md5_post
      elsif md5_post
        raise "duplicate: #{md5_post.id}"
      end
    end

    def validate_file_content_type
      unless is_valid_content_type?
        raise "invalid content type (only JPEG, PNG, GIF, SWF, MP4, and WebM files are allowed)"
      end

      if is_ugoira? && ugoira_service.empty?
        raise "missing frame data for ugoira"
      end
    end

    def validate_md5_confirmation
      if !md5_confirmation.blank? && md5_confirmation != md5
        raise "md5 mismatch"
      end
    end

    def validate_dimensions
      resolution = image_width * image_height

      if resolution > Danbooru.config.max_image_resolution
        raise "image resolution is too large (resolution: #{(resolution / 1_000_000.0).round(1)} megapixels (#{image_width}x#{image_height}); max: #{Danbooru.config.max_image_resolution / 1_000_000} megapixels)"
      elsif image_width > Danbooru.config.max_image_width
        raise "image width is too large (width: #{image_width}; max width: #{Danbooru.config.max_image_width})"
      elsif image_height > Danbooru.config.max_image_height
        raise "image height is too large (height: #{image_height}; max height: #{Danbooru.config.max_image_height})"
      end
    end

    def rating_given
      if rating.present?
        return true
      elsif tag_string =~ /(?:\s|^)rating:([qse])/i
        self.rating = $1.downcase
        return true
      else
        self.errors.add(:base, "Must specify a rating")
        return false
      end
    end

    def automatic_tags
      return "" unless Danbooru.config.enable_dimension_autotagging

      tags = []
      tags << "video_with_sound" if is_video_with_audio?
      tags << "animated_gif" if is_animated_gif?
      tags << "animated_png" if is_animated_png?
      tags.join(" ")
    end

    def validate_video_duration
      unless uploader.is_admin?
        if is_video? && video.duration > 120
          raise "video must not be longer than 2 minutes"
        end
      end
    end
  end

  module ConversionMethods
    def process_upload
      begin
        update_attribute(:status, "processing")

        self.source = source.to_s.strip
        if is_downloadable?
          self.downloaded_source, self.source, self.file = download_from_source(source, referer_url)
        elsif self.file.respond_to?(:tempfile)
          self.file = self.file.tempfile
        end

        self.file_ext = file_header_to_file_ext(file)
        self.file_size = file.size
        self.md5 = Digest::MD5.file(file.path).hexdigest

        validate_file_content_type
        validate_md5_uniqueness
        validate_md5_confirmation
        validate_video_duration

        self.tag_string = "#{tag_string} #{automatic_tags}"
        self.image_width, self.image_height = calculate_dimensions
        validate_dimensions

        save
      end
    end

    def create_post_from_upload
      post = convert_to_post
      distribute_files(post)

      if post.save
        create_artist_commentary(post) if include_artist_commentary?
        ugoira_service.save_frame_data(post) if is_ugoira?
        notify_cropper(post)
        update_attributes(:status => "completed", :post_id => post.id)
      else
        update_attribute(:status, "error: " + post.errors.full_messages.join(", "))
      end

      post
    end

    def distribute_files(post)
      preview_file, sample_file = generate_resizes
      post.distribute_files(file, sample_file, preview_file)
    ensure
      preview_file.try(:close!)
      sample_file.try(:close!)
    end

    def process!(force = false)
      @tries ||= 0
      return if !force && status =~ /processing|completed|error/

      process_upload
      post = create_post_from_upload

    rescue Timeout::Error, Net::HTTP::Persistent::Error => x
      if @tries > 3
        update_attributes(:status => "error: #{x.class} - #{x.message}", :backtrace => x.backtrace.join("\n"))
      else
        @tries += 1
        retry
      end
      nil

    rescue Exception => x
      update_attributes(:status => "error: #{x.class} - #{x.message}", :backtrace => x.backtrace.join("\n"))
      nil

    ensure
      file.try(:close!)
    end

    def ugoira_service
      @ugoira_service ||= PixivUgoiraService.new
    end

    def convert_to_post
      Post.new.tap do |p|
        p.tag_string = tag_string
        p.md5 = md5
        p.file_ext = file_ext
        p.image_width = image_width
        p.image_height = image_height
        p.rating = rating
        p.source = source
        p.file_size = file_size
        p.uploader_id = uploader_id
        p.uploader_ip_addr = uploader_ip_addr
        p.parent_id = parent_id

        if !uploader.can_upload_free? || upload_as_pending?
          p.is_pending = true
        end
      end
    end

    def notify_cropper(post)
      if ImageCropper.enabled?
        # ImageCropper.notify(post)
      end
    end
  end

  module FileMethods
    def is_image?
      %w(jpg gif png).include?(file_ext)
    end

    def is_flash?
      %w(swf).include?(file_ext)
    end

    def is_video?
      %w(webm mp4).include?(file_ext)
    end

    def is_video_with_audio?
      is_video? && video.audio_channels.present?
    end

    def is_ugoira?
      %w(zip).include?(file_ext)
    end

    def is_animated_gif?
      return false if file_ext != "gif"

      # Check whether the gif has multiple frames by trying to load the second frame.
      result = Vips::Image.gifload(file.path, page: 1) rescue $ERROR_INFO
      if result.is_a?(Vips::Image)
        true
      elsif result.is_a?(Vips::Error) && result.message =~ /too few frames in GIF file/
        false
      else
        raise result
      end
    end

    def is_animated_png?
      file_ext == "png" && APNGInspector.new(file.path).inspect!.animated?
    end
  end

  module ResizerMethods
    def generate_resizes
      if is_video?
        preview_file = generate_video_preview_for(video, Danbooru.config.small_image_width, Danbooru.config.small_image_width)
      elsif is_ugoira?
        preview_file = PixivUgoiraConverter.generate_preview(file)
        sample_file = PixivUgoiraConverter.generate_webm(file, ugoira_service.frame_data)
      elsif is_image?
        preview_file = DanbooruImageResizer.resize(file, Danbooru.config.small_image_width, Danbooru.config.small_image_width, 85)

        if image_width > Danbooru.config.large_image_width
          sample_file = DanbooruImageResizer.resize(file, Danbooru.config.large_image_width, image_height, 90)
        end
      end

      [preview_file, sample_file]
    end

    def generate_video_preview_for(video, width, height)
      dimension_ratio = video.width.to_f / video.height
      if dimension_ratio > 1
        height = (width / dimension_ratio).to_i
      else
        width = (height * dimension_ratio).to_i
      end

      output_file = Tempfile.new(binmode: true)
      video.screenshot(output_file.path, {:seek_time => 0, :resolution => "#{width}x#{height}"})
      output_file
    end
  end

  module DimensionMethods
    # Figures out the dimensions of the image.
    def calculate_dimensions
      if is_video?
        [video.width, video.height]
      elsif is_ugoira?
        ugoira_service.calculate_dimensions(file.path)
        [ugoira_service.width, ugoira_service.height]
      else
        image_size = ImageSpec.new(file.path)
        [image_size.width, image_size.height]
      end
    end
  end

  module ContentTypeMethods
    def is_valid_content_type?
      file_ext =~ /jpg|gif|png|swf|webm|mp4|zip/
    end

    def file_header_to_file_ext(file)
      case File.read(file.path, 16)
      when /^\xff\xd8/n
        "jpg"
      when /^GIF87a/, /^GIF89a/
        "gif"
      when /^\x89PNG\r\n\x1a\n/n
        "png"
      when /^CWS/, /^FWS/, /^ZWS/
        "swf"
      when /^\x1a\x45\xdf\xa3/n
        "webm"
      when /^....ftyp(?:isom|3gp5|mp42|MSNV|avc1)/
        "mp4"
      when /^PK\x03\x04/
        "zip"
      else
        "bin"
      end
    end
  end

  module DownloaderMethods
    # Determines whether the source is downloadable
    def is_downloadable?
      source =~ /^https?:\/\// && file.blank?
    end

    def download_from_source(source, referer_url = nil)
      download = Downloads::File.new(source, referer_url: referer_url)
      file = download.download!
      ugoira_service.load(download.data)

      [download.downloaded_source, download.source, file]
    end
  end

  module StatusMethods
    def is_pending?
      status == "pending"
    end

    def is_processing?
      status == "processing"
    end

    def is_completed?
      status == "completed"
    end

    def is_duplicate?
      status =~ /duplicate/
    end

    def duplicate_post_id
      @duplicate_post_id ||= status[/duplicate: (\d+)/, 1]
    end
  end

  module UploaderMethods
    def uploader_name
      User.id_to_name(uploader_id)
    end
  end

  module VideoMethods
    def video
      @video ||= FFMPEG::Movie.new(file.path)
    end
  end

  module SearchMethods
    def uploaded_by(user_id)
      where("uploader_id = ?", user_id)
    end

    def pending
      where(:status => "pending")
    end

    def search(params)
      q = super

      if params[:uploader_id].present?
        q = q.uploaded_by(params[:uploader_id].to_i)
      end

      if params[:uploader_name].present?
        q = q.where("uploader_id = (select _.id from users _ where lower(_.name) = ?)", params[:uploader_name].mb_chars.downcase)
      end

      if params[:source].present?
        q = q.where("source = ?", params[:source])
      end

      q.apply_default_order(params)
    end
  end

  module ApiMethods
    def method_attributes
      super + [:uploader_name]
    end
  end

  module ArtistCommentaryMethods
    def create_artist_commentary(post)
      post.create_artist_commentary(
        :original_title => artist_commentary_title,
        :original_description => artist_commentary_desc
      )
    end
  end

  include ConversionMethods
  include ValidationMethods
  include FileMethods
  include ResizerMethods
  include DimensionMethods
  include ContentTypeMethods
  include DownloaderMethods
  include StatusMethods
  include UploaderMethods
  include VideoMethods
  extend SearchMethods
  include ApiMethods
  include ArtistCommentaryMethods

  def presenter
    @presenter ||= UploadPresenter.new(self)
  end

  def upload_as_pending?
    as_pending == "1"
  end

  def include_artist_commentary?
    include_artist_commentary == "1"
  end
end
