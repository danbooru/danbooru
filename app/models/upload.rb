# frozen_string_literal: true

class Upload < ApplicationRecord
  extend Memoist
  class Error < StandardError; end

  # The list of allowed archive file types.
  ARCHIVE_FILE_TYPES = %i[zip rar 7z]

  # The maximum number of files allowed per upload.
  MAX_FILES_PER_UPLOAD = 100

  # The maximum number of 'pending' or 'processing' media assets a single user can have at once.
  MAX_QUEUED_ASSETS = 250

  attr_accessor :files

  belongs_to :uploader, class_name: "User"
  has_many :upload_media_assets, dependent: :destroy
  has_many :media_assets, through: :upload_media_assets
  has_many :posts, through: :media_assets

  normalize :source, :normalize_source

  validates :source, format: { with: %r{\Ahttps?://}i, message: "is not a valid URL" }, if: -> { source.present? }
  validates :referer_url, format: { with: %r{\Ahttps?://}i, message: "is not a valid URL" }, if: -> { referer_url.present? }
  validates :status, inclusion: { in: %w[pending processing completed error] }
  validate :validate_file_and_source, on: :create
  validate :validate_archive_files, on: :create
  validate :validate_uploader_is_not_limited, on: :create

  after_create :async_process_upload!

  scope :pending, -> { where(status: "pending") }
  scope :processing, -> { where(status: "processing") }
  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "error") }
  scope :expired, -> { processing.where(created_at: ..4.hours.ago) }

  def self.visible(user)
    if user.is_admin?
      all
    else
      where(uploader: user)
    end
  end

  def self.prune!
    expired.update_all(status: "error", error: "Stuck processing for more than 4 hours")
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

    def is_errored?
      status == "error"
    end

    def is_finished?
      is_completed? || is_errored?
    end
  end

  concerning :ValidationMethods do
    def validate_file_and_source
      if files.present? && source.present?
        errors.add(:base, "Can't give both a file and a source")
      elsif files.blank? && source.blank?
        errors.add(:base, "No file or source given")
      end
    end

    def validate_uploader_is_not_limited
      queued_asset_count = uploader.upload_media_assets.unfinished.count

      if queued_asset_count > MAX_QUEUED_ASSETS
        errors.add(:base, "You have too many images queued for upload (queued: #{queued_asset_count}; limit: #{MAX_QUEUED_ASSETS}). Try again later.")
      end
    end

    def validate_archive_files
      return unless files.present?

      archive_files.each do |archive, filename|
        if !archive.file_ext.in?(ARCHIVE_FILE_TYPES)
          errors.add(:base, "'#{filename}' is not a supported file type")
        elsif archive.exists? { |_, count| count > MAX_FILES_PER_UPLOAD }
          # XXX Potential zip bomb containing thousands of files; don't process it any further.
          errors.add(:base, "'#{filename}' contains too many files (max #{MAX_FILES_PER_UPLOAD} files per upload)")
          next
        elsif archive.uncompressed_size > MediaAsset::MAX_FILE_SIZE
          errors.add(:base, "'#{filename}' is too large (uncompressed size: #{archive.uncompressed_size.to_fs(:human_size)}; max size: #{MediaAsset::MAX_FILE_SIZE.to_fs(:human_size)})")
        elsif entry = archive.entries.find { |entry| entry.pathname.starts_with?("/") }
          errors.add(:base, "'#{entry.pathname_utf8}' in '#{filename}' can't start with '/'")
        elsif entry = archive.entries.find { |entry| entry.directory_traversal? }
          errors.add(:base, "'#{entry.pathname_utf8}' in '#{filename}' can't contain '..' components")
        elsif entry = archive.entries.find { |entry| !entry.file? && !entry.directory? }
          errors.add(:base, "'#{entry.pathname_utf8}' in '#{filename}' isn't a regular file")
        end
      end

      total_files = archive_files.map(&:first).sum(&:file_count) + (files.size - archive_files.size)
      if total_files > MAX_FILES_PER_UPLOAD
        errors.add(:base, "Can't upload more than #{MAX_FILES_PER_UPLOAD} files at a time (total: #{total_files})")
      end
    end
  end

  concerning :SourceMethods do
    class_methods do
      # percent-encode unicode characters in the URL
      def normalize_source(url)
        Danbooru::URL.parse(url)&.to_normalized_s.presence || url
      end
    end
  end

  def self.ai_tags_match(tag_string, score_range: (50..))
    upload_media_assets = AITagQuery.search(tag_string, relation: UploadMediaAsset.all, foreign_key: :media_asset_id, score_range: score_range)
    where(upload_media_assets.where("upload_media_assets.upload_id = uploads.id").arel.exists)
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :source, :referer_url, :status, :media_asset_count, :uploader, :upload_media_assets, :media_assets, :posts], current_user: current_user)

    if params[:ai_tags_match].present?
      min_score = params.fetch(:min_score, 50).to_i
      q = q.ai_tags_match(params[:ai_tags_match], score_range: (min_score..))
    end

    if params[:is_posted].to_s.truthy?
      q = q.where.not(id: Upload.where.missing(:posts))
    elsif params[:is_posted].to_s.falsy?
      q = q.where(id: Upload.where.missing(:posts))
    end

    case params[:order]
    when "id", "id_desc"
      q = q.order(id: :desc)
    when "id_asc"
      q = q.order(id: :asc)
    else
      q = q.apply_default_order(params)
    end

    q
  end

  def async_process_upload!
    if files.present?
      process_upload!
    elsif source.present?
      ProcessUploadJob.perform_later(self)
    else
      raise "No file or source given" # Should never happen
    end
  end

  def process_upload!
    update!(status: "processing")

    if files.present?
      process_file_upload!
    elsif source.present?
      process_source_upload!
    else
      raise Error, "No file or source given" # Should never happen
    end
  rescue Exception => e
    update!(status: "error", error: e.message)
  end

  def process_source_upload!
    page_url = source_extractor.page_url
    image_urls = source_extractor.image_urls

    if image_urls.empty?
      raise Error, "#{source} doesn't contain any images"
    end

    upload_media_assets = image_urls.map do |image_url|
      UploadMediaAsset.new(upload: self, source_url: image_url, page_url: page_url, media_asset: nil)
    end

    transaction do
      update!(media_asset_count: upload_media_assets.size)
      upload_media_assets.each(&:save!)
    end
  end

  def process_file_upload!
    tmpdirs = []

    upload_media_assets = uploaded_files.flat_map do |file, original_filename|
      if file.is_a?(Danbooru::Archive)
        tmpdir, filenames = file.extract!
        tmpdirs << tmpdir

        Danbooru.natural_sort(filenames).map do |filename|
          name = "file://#{original_filename}/#{Pathname.new(filename).relative_path_from(tmpdir)}" # "file://foo.zip/foo/1.jpg"
          UploadMediaAsset.new(upload: self, file: filename, source_url: name)
        end
      else
        UploadMediaAsset.new(upload: self, file: file, source_url: "file://#{original_filename}")
      end
    end

    transaction do
      update!(media_asset_count: upload_media_assets.size)
      upload_media_assets.each(&:save!)
    end
  ensure
    tmpdirs.each { |tmpdir| FileUtils.rm_rf(tmpdir) }
  end

  # The list of files uploaded from disk, with their filenames.
  def uploaded_files
    files.map do |_index, file|
      if FileTypeDetector.new(file.tempfile).file_ext.in?(ARCHIVE_FILE_TYPES)
        [Danbooru::Archive.open!(file.tempfile), file.original_filename]
      else
        [MediaFile.open(file.tempfile), file.original_filename]
      end
    end
  end

  # The list of archive files uploaded from disk, with their filenames.
  def archive_files
    uploaded_files.select do |file, original_filename|
      file.is_a?(Danbooru::Archive)
    end
  end

  def source_extractor
    return nil if source.blank?
    Source::Extractor.find(source, referer_url)
  end

  def self.available_includes
    [:uploader, :upload_media_assets, :media_assets, :posts]
  end

  memoize :source_extractor, :archive_files, :uploaded_files
end
