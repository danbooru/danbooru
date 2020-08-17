class Upload < ApplicationRecord
  class Error < StandardError; end

  class FileValidator < ActiveModel::Validator
    def validate(record)
      validate_file_ext(record)
      validate_integrity(record)
      validate_md5_uniqueness(record)
      validate_video_duration(record)
      validate_resolution(record)
    end

    def validate_file_ext(record)
      if record.file_ext == "bin"
        record.errors[:file_ext] << "is invalid (only JPEG, PNG, GIF, SWF, MP4, and WebM files are allowed"
      end
    end

    def validate_integrity(record)
      if record.media_file.is_corrupt?
        record.errors[:file] << "is corrupted"
      end
    end

    def validate_md5_uniqueness(record)
      if record.md5.nil?
        return
      end

      md5_post = Post.find_by_md5(record.md5)

      if md5_post.nil?
        return
      end

      if record.replaced_post && record.replaced_post == md5_post
        return
      end

      record.errors[:md5] << "duplicate: #{md5_post.id}"
    end

    def validate_resolution(record)
      resolution = record.image_width.to_i * record.image_height.to_i

      if resolution > Danbooru.config.max_image_resolution
        record.errors[:base] << "image resolution is too large (resolution: #{(resolution / 1_000_000.0).round(1)} megapixels (#{record.image_width}x#{record.image_height}); max: #{Danbooru.config.max_image_resolution / 1_000_000} megapixels)"
      elsif record.image_width > Danbooru.config.max_image_width
        record.errors[:image_width] << "is too large (width: #{record.image_width}; max width: #{Danbooru.config.max_image_width})"
      elsif record.image_height > Danbooru.config.max_image_height
        record.errors[:image_height] << "is too large (height: #{record.image_height}; max height: #{Danbooru.config.max_image_height})"
      end
    end

    def validate_video_duration(record)
      if !record.uploader.is_admin? && record.media_file.is_video? && record.media_file.duration > 120
        record.errors[:base] << "video must not be longer than 2 minutes"
      end
    end
  end

  attr_accessor :as_pending, :replaced_post, :file
  belongs_to :uploader, :class_name => "User"
  belongs_to :post, optional: true

  before_validation :initialize_attributes, on: :create
  before_validation :assign_rating_from_tags
  # validates :source, format: { with: /\Ahttps?/ }, if: ->(record) {record.file.blank?}, on: :create
  validates :rating, inclusion: { in: %w(q e s) }, allow_nil: true
  validates :md5, confirmation: true, if: ->(rec) { rec.md5_confirmation.present? }
  validates_with FileValidator, on: :file
  serialize :context, JSON

  after_destroy_commit :delete_files

  scope :pending, -> { where(status: "pending") }
  scope :preprocessed, -> { where(status: "preprocessed") }
  scope :completed, -> { where(status: "completed") }
  scope :uploaded_by, ->(user_id) { where(uploader_id: user_id) }

  def initialize_attributes
    self.uploader_id = CurrentUser.id
    self.uploader_ip_addr = CurrentUser.ip_addr
    self.server = Socket.gethostname
  end

  def self.prune!
    completed.where("created_at < ?", 1.hour.ago).lock.destroy_all
    preprocessed.where("created_at < ?", 1.day.ago).lock.destroy_all
    where("created_at < ?", 3.days.ago).lock.destroy_all
  end

  def self.visible(user)
    if user.is_admin?
      all
    elsif user.is_member?
      completed.or(where(uploader: user))
    else
      completed
    end
  end

  concerning :FileMethods do
    def media_file
      @media_file ||= MediaFile.open(file, frame_data: context.to_h.dig("ugoira", "frame_data"))
    end

    def delete_files
      # md5 is blank if the upload errored out before downloading the file.
      if is_completed? || md5.blank? || Upload.where(md5: md5).exists? || Post.where(md5: md5).exists?
        return
      end

      DanbooruLogger.info("Uploads: Deleting files for upload md5=#{md5}")
      Danbooru.config.storage_manager.delete_file(nil, md5, file_ext, :original)
      Danbooru.config.storage_manager.delete_file(nil, md5, file_ext, :large)
      Danbooru.config.storage_manager.delete_file(nil, md5, file_ext, :preview)
      Danbooru.config.backup_storage_manager.delete_file(nil, md5, file_ext, :original)
      Danbooru.config.backup_storage_manager.delete_file(nil, md5, file_ext, :large)
      Danbooru.config.backup_storage_manager.delete_file(nil, md5, file_ext, :preview)
    end
  end

  concerning :StatusMethods do
    def is_pending?
      status == "pending"
    end

    def is_processing?
      status == "processing"
    end

    def is_completed?
      status == "completed"
    end

    def is_preprocessed?
      status == "preprocessed"
    end

    def is_preprocessing?
      status == "preprocessing"
    end

    def is_duplicate?
      status.match?(/duplicate: \d+/)
    end

    def is_errored?
      status.match?(/error:/)
    end

    def sanitized_status
      if is_errored?
        status.sub(/DETAIL:.+/m, "...")
      else
        status
      end
    end

    def duplicate_post_id
      @duplicate_post_id ||= status[/duplicate: (\d+)/, 1]
    end
  end

  concerning :SourceMethods do
    def source=(source)
      source = source.unicode_normalize(:nfc)

      # percent encode unicode characters in urls
      if source =~ %r!\Ahttps?://!i
        source = Addressable::URI.normalized_encode(source) rescue source
      end

      super(source)
    end

    def source_url
      return nil unless source =~ %r!\Ahttps?://!i
      Addressable::URI.heuristic_parse(source) rescue nil
    end
  end

  def self.search(params)
    q = super

    q = q.search_attributes(params, :source, :rating, :parent_id, :server, :md5, :server, :file_ext, :file_size, :image_width, :image_height, :referer_url)

    if params[:source_matches].present?
      q = q.where_like(:source, params[:source_matches])
    end

    if params[:has_post].to_s.truthy?
      q = q.where.not(post_id: nil)
    elsif params[:has_post].to_s.falsy?
      q = q.where(post_id: nil)
    end

    if params[:status].present?
      q = q.where_like(:status, params[:status])
    end

    if params[:backtrace].present?
      q = q.where_like(:backtrace, params[:backtrace])
    end

    if params[:tag_string].present?
      q = q.where_like(:tag_string, params[:tag_string])
    end

    q.apply_default_order(params)
  end

  def assign_rating_from_tags
    if rating = PostQueryBuilder.new(tag_string).find_metatag(:rating)
      self.rating = rating.downcase.first
    end
  end

  def upload_as_pending?
    as_pending.to_s.truthy?
  end

  def has_commentary?
    artist_commentary_title.present? || artist_commentary_desc.present? || translated_commentary_title.present? || translated_commentary_desc.present?
  end

  def self.searchable_includes
    [:uploader, :post]
  end

  def self.available_includes
    [:uploader, :post]
  end
end
