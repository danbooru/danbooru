require "danbooru_image_resizer/danbooru_image_resizer"
require "tmpdir"

class Upload < ActiveRecord::Base
  class Error < Exception ; end

  attr_accessor :file, :image_width, :image_height, :file_ext, :md5, :file_size, :as_pending
  belongs_to :uploader, :class_name => "User"
  belongs_to :post
  before_validation :initialize_uploader, :on => :create
  before_validation :initialize_status, :on => :create
  before_create :convert_cgi_file
  after_destroy :delete_temp_file
  validate :uploader_is_not_limited, :on => :create
  validate :file_or_source_is_present, :on => :create
  attr_accessible :file, :image_width, :image_height, :file_ext, :md5, :file_size, :as_pending, :source, :file_path, :content_type, :rating, :tag_string, :status, :backtrace, :post_id, :md5_confirmation

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
      if md5_post
        raise "duplicate: #{md5_post.id}"
      end
    end

    def validate_file_exists
      unless file_path && File.exists?(file_path)
        raise "file does not exist"
      end
    end

    def validate_file_content_type
      unless is_valid_content_type?
        raise "invalid content type (only JPEG, PNG, GIF, and SWF files are allowed)"
      end
    end

    def validate_md5_confirmation
      if !md5_confirmation.blank? && md5_confirmation != md5
        raise "md5 mismatch"
      end
    end
  end

  module ConversionMethods
    def process!(force = false)
      return if !force && status =~ /processing|completed|error/

      CurrentUser.scoped(uploader, uploader_ip_addr) do
        update_attribute(:status, "processing")
        if is_downloadable?
          download_from_source(temp_file_path)
        end
        validate_file_exists
        self.content_type = file_header_to_content_type(file_path)
        self.file_ext = content_type_to_file_ext(content_type)
        validate_file_content_type
        calculate_hash(file_path)
        validate_md5_uniqueness
        validate_md5_confirmation
        calculate_file_size(file_path)
        if has_dimensions?
          calculate_dimensions(file_path)
        end
        generate_resizes(file_path)
        move_file
        post = convert_to_post
        post.distribute_files
        if post.save
          CurrentUser.increment!(:post_upload_count)
          update_attributes(:status => "completed", :post_id => post.id)
        else
          update_attribute(:status, "error: " + post.errors.full_messages.join(", "))
        end
      end
    rescue Exception => x
      update_attributes(:status => "error: #{x.class} - #{x.message}", :backtrace => x.backtrace.join("\n"))
    ensure
      delete_temp_file
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

        if !uploader.is_contributor? || upload_as_pending?
          p.is_pending = true
        end
      end
    end
  end

  module FileMethods
    def delete_temp_file
      FileUtils.rm_f(temp_file_path)
    end

    def move_file
      FileUtils.mv(file_path, md5_file_path)
    end

    def calculate_file_size(source_path)
      self.file_size = File.size(source_path)
    end

    # Calculates the MD5 based on whatever is in temp_file_path
    def calculate_hash(source_path)
      self.md5 = Digest::MD5.file(source_path).hexdigest
    end

    def is_image?
      ["jpg", "gif", "png"].include?(file_ext)
    end
  end

  module ResizerMethods
    def generate_resizes(source_path)
      if is_image?
        generate_resize_for(Danbooru.config.small_image_width, Danbooru.config.small_image_width, source_path, 85)
        generate_resize_for(Danbooru.config.large_image_width, nil, source_path) if image_width > Danbooru.config.large_image_width
      end
    end

    def generate_resize_for(width, height, source_path, quality = 90)
      unless File.exists?(source_path)
        raise Error.new("file not found")
      end

      Danbooru.resize(source_path, resized_file_path_for(width), width, height, quality)
    end
  end

  module DimensionMethods
    # Figures out the dimensions of the image.
    def calculate_dimensions(file_path)
      File.open(file_path, "rb") do |file|
        image_size = ImageSpec.new(file)
        self.image_width = image_size.width
        self.image_height = image_size.height
      end
    end

    # Does this file have image dimensions?
    def has_dimensions?
      %w(jpg gif png swf).include?(file_ext)
    end
  end

  module ContentTypeMethods
    def is_valid_content_type?
      file_ext =~ /jpg|gif|png|swf/
    end

    def content_type_to_file_ext(content_type)
      case content_type
      when "image/jpeg"
        "jpg"

      when "image/gif"
        "gif"

      when "image/png"
        "png"

      when "application/x-shockwave-flash"
        "swf"

      else
        "bin"
      end
    end

    def file_header_to_content_type(source_path)
      case File.read(source_path, 10)
      when /^\xff\xd8/n
        "image/jpeg"

      when /^GIF87a/, /^GIF89a/
        "image/gif"

      when /^\x89PNG\r\n\x1a\n/n
        "image/png"

      when /^CWS/, /^FWS/, /^ZWS/
        "application/x-shockwave-flash"

      else
        "application/octet-stream"
      end
    end
  end

  module FilePathMethods
    def md5_file_path
      prefix = Rails.env == "test" ? "test." : ""
      "#{Rails.root}/public/data/#{prefix}#{md5}.#{file_ext}"
    end

    def resized_file_path_for(width)
      prefix = Rails.env == "test" ? "test." : ""

      case width
      when Danbooru.config.small_image_width
        "#{Rails.root}/public/data/preview/#{prefix}#{md5}.jpg"

      when Danbooru.config.large_image_width
        "#{Rails.root}/public/data/sample/#{Danbooru.config.large_image_prefix}#{prefix}#{md5}.jpg"
      end
    end

    def temp_file_path
      @temp_file_path ||= File.join(Rails.root, "tmp", "upload_#{Time.now.to_f}.#{Process.pid}")
    end
  end

  module DownloaderMethods
    # Determines whether the source is downloadable
    def is_downloadable?
      source =~ /^https?:\/\// && file_path.blank?
    end

    # Downloads the file to destination_path
    def download_from_source(destination_path)
      download = Downloads::File.new(source, destination_path)
      download.download!
      self.file_path = destination_path
      self.source = download.source
    end
  end

  module CgiFileMethods
    def convert_cgi_file
      return if file.blank? || file.size == 0

      self.file_path = temp_file_path

      if file.respond_to?(:tempfile) && file.tempfile
        FileUtils.cp(file.tempfile.path, file_path)
      else
        File.open(file_path, 'wb') do |out|
          out.write(file.read)
        end
      end
      FileUtils.chmod(0664, file_path)
    end
  end

  module StatusMethods
    def initialize_status
      self.status = "pending"
    end

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
    def initialize_uploader
      self.uploader_id = CurrentUser.user.id
      self.uploader_ip_addr = CurrentUser.ip_addr
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
      q = where("true")
      return q if params.blank?

      if params[:uploader_id].present?
        q = q.uploaded_by(params[:uploader_id].to_i)
      end

      if params[:uploader_name].present?
        q = q.where("uploader_id = (select _.id from users _ where lower(_.name) = ?)", params[:uploader_name].mb_chars.downcase)
      end

      if params[:source].present?
        q = q.where("source = ?", params[:source])
      end

      q
    end
  end

  module ApiMethods
    def serializable_hash(options = {})
      options ||= {}
      options[:except] ||= []
      options[:except] += hidden_attributes
      unless options[:builder]
        options[:methods] ||= []
        options[:methods] += [:uploader_name]
      end
      hash = super(options)
      hash
    end

    def to_xml(options = {}, &block)
      options ||= {}
      options[:methods] ||= []
      options[:methods] += [:uploader_name]
      super(options, &block)
    end
  end

  include ConversionMethods
  include ValidationMethods
  include FileMethods
  include ResizerMethods
  include DimensionMethods
  include ContentTypeMethods
  include DownloaderMethods
  include FilePathMethods
  include CgiFileMethods
  include StatusMethods
  include UploaderMethods
  extend SearchMethods
  include ApiMethods

  def uploader_name
    User.id_to_name(uploader_id)
  end

  def presenter
    @presenter ||= UploadPresenter.new(self)
  end

  def upload_as_pending?
    as_pending == "1"
  end
end
