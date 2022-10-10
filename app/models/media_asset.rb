# frozen_string_literal: true

class MediaAsset < ApplicationRecord
  class Error < StandardError; end

  FILE_TYPES = %w[jpg png gif mp4 webm swf zip]
  FILE_KEY_LENGTH = 9
  VARIANTS = %i[preview 180x180 360x360 720x720 sample original]
  MAX_FILE_SIZE = Danbooru.config.max_file_size.to_i
  MAX_VIDEO_DURATION = Danbooru.config.max_video_duration.to_i
  MAX_IMAGE_RESOLUTION = Danbooru.config.max_image_resolution
  MAX_IMAGE_WIDTH = Danbooru.config.max_image_width
  MAX_IMAGE_HEIGHT = Danbooru.config.max_image_height
  ENABLE_SEO_POST_URLS = Danbooru.config.enable_seo_post_urls
  LARGE_IMAGE_WIDTH = Danbooru.config.large_image_width
  STORAGE_SERVICE = Danbooru.config.storage_manager

  has_one :post, foreign_key: :md5, primary_key: :md5
  has_one :media_metadata, dependent: :destroy
  has_many :upload_media_assets, dependent: :destroy
  has_many :uploads, through: :upload_media_assets
  has_many :uploaders, through: :uploads, class_name: "User", foreign_key: :uploader_id
  has_many :ai_tags

  delegate :frame_delays, :metadata, to: :media_metadata
  delegate :is_non_repeating_animation?, :is_greyscale?, :is_rotated?, :is_ai_generated?, to: :metadata

  scope :public_only, -> { where(is_public: true) }
  scope :private_only, -> { where(is_public: false) }
  scope :without_ai_tags, -> { where.not(AITag.where("ai_tags.media_asset_id = media_assets.id").select(1).arel.exists) }

  # Processing: The asset's files are currently being resized and distributed to the backend servers.
  # Active: The asset has been successfully uploaded and is ready to use.
  # Deleted: The asset's files have been deleted by moving them to a trash folder. They can be undeleted by moving them out of the trash folder.
  # Expunged: The asset's files have been permanently deleted.
  # Failed: The asset failed to upload. The asset may be in a partially uploaded state, with some
  #         files missing or incompletely transferred.
  enum status: {
    processing: 100,
    active: 200,
    deleted: 300,
    expunged: 400,
    failed: 500,
  }

  validates :md5, uniqueness: { conditions: -> { where(status: [:processing, :active]) } }, if: :md5_changed?
  validates :file_ext, inclusion: { in: FILE_TYPES, message: "File is not an image or video" }
  validates :file_key, length: { is: FILE_KEY_LENGTH }, uniqueness: true, if: :file_key_changed?

  before_create :initialize_file_key

  class Variant
    extend Memoist

    attr_reader :media_asset, :variant
    delegate :md5, :storage_service, :backup_storage_service, to: :media_asset

    def initialize(media_asset, variant)
      @media_asset = media_asset
      @variant = variant.to_sym

      raise ArgumentError, "asset doesn't have #{@variant} variant" unless Variant.exists?(@media_asset, @variant)
    end

    def store_file!(original_file)
      file = convert_file(original_file)
      storage_service.store(file, file_path)
      backup_storage_service.store(file, file_path)
    end

    def trash_file!
      storage_service.move(file_path, "/trash/#{file_path}")
      backup_storage_service.move(file_path, "/trash/#{file_path}")
    end

    def delete_file!
      storage_service.delete(file_path)
      backup_storage_service.delete(file_path)
    end

    def open_file
      file = storage_service.open(file_path)
      frame_delays = media_asset.frame_delays if media_asset.is_ugoira?
      MediaFile.open(file, frame_delays: frame_delays, strict: false)
    end

    def convert_file(media_file)
      case variant
      in :preview
        media_file.preview(width, height, format: :jpeg, quality: 85)
      in :"180x180"
        media_file.preview(width, height, format: :jpeg, quality: 85)
      in :"360x360"
        media_file.preview(width, height, format: :jpeg, quality: 85)
      in :"720x720"
        media_file.preview(width, height, format: :webp, quality: 75)
      in :sample if media_asset.is_ugoira?
        media_file.convert
      in :sample if media_asset.is_static_image?
        media_file.preview(width, height, format: :jpeg, quality: 85)
      in :original
        media_file
      end
    end

    def file_url(slug = "")
      storage_service.file_url(file_path(slug))
    end

    def file_path(slug = "")
      if variant.in?(%i[preview 180x180 360x360 720x720]) && media_asset.is_flash?
        "/images/download-preview.png"
      else
        slug = "__#{slug}__" if slug.present?
        slug = nil if !ENABLE_SEO_POST_URLS
        "/#{variant}/#{md5[0..1]}/#{md5[2..3]}/#{slug}#{file_name}"
      end
    end

    # The file name of this variant.
    def file_name
      case variant
      when :sample
        "sample-#{md5}.#{file_ext}"
      else
        "#{md5}.#{file_ext}"
      end
    end

    # The file extension of this variant.
    def file_ext
      case variant
      when :preview, :"180x180", :"360x360"
        "jpg"
      when :"720x720"
        "webp"
      when :sample
        media_asset.is_ugoira? ? "webm" : "jpg"
      when :original
        media_asset.file_ext
      end
    end

    def max_dimensions
      case variant
      when :preview
        [150, 150]
      when :"180x180"
        [180, 180]
      when :"360x360"
        [360, 360]
      when :"720x720"
        [720, 720]
      when :sample
        [850, nil]
      when :original
        [nil, nil]
      end
    end

    def dimensions
      MediaFile.scale_dimensions(media_asset.image_width, media_asset.image_height, max_dimensions[0], max_dimensions[1])
    end

    def width
      dimensions[0]
    end

    def height
      dimensions[1]
    end

    def self.exists?(media_asset, variant)
      case variant
      when :preview
        true
      when :"180x180"
        true
      when :"360x360"
        true
      when :"720x720"
        true
      when :sample
        media_asset.is_ugoira? || (media_asset.is_static_image? && media_asset.image_width > LARGE_IMAGE_WIDTH)
      when :original
        true
      end
    end

    memoize :file_name, :file_ext, :max_dimensions, :dimensions
  end

  concerning :SearchMethods do
    class_methods do
      def ai_tags_match(tag_string, score_range: (50..))
        AITagQuery.search(tag_string, relation: self, score_range: score_range)
      end

      def search(params, current_user)
        q = search_attributes(params, [:id, :created_at, :updated_at, :status, :md5, :file_ext, :file_size, :image_width, :image_height, :file_key, :is_public], current_user: current_user)

        if params[:metadata].present?
          q = q.joins(:media_metadata).merge(MediaMetadata.search({ metadata: params[:metadata] }, current_user))
        end

        if params[:ai_tags_match].present?
          min_score = params.fetch(:min_score, 50).to_i
          q = q.ai_tags_match(params[:ai_tags_match], score_range: (min_score..))
        end

        if params[:is_posted].to_s.truthy?
          #q = q.where.associated(:post)
          q = q.where(Post.where("posts.md5 = media_assets.md5").arel.exists)
        elsif params[:is_posted].to_s.falsy?
          #q = q.where.missing(:post)
          q = q.where.not(Post.where("posts.md5 = media_assets.md5").arel.exists)
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
    end
  end

  concerning :FileMethods do
    class_methods do
      # Upload a file to Danbooru. Resize and distribute it then return a MediaAsset.
      #
      # If the file has already been uploaded to Danbooru, then return the
      # existing MediaAsset. If someone else is uploading the same file at the
      # same time, wait until they're finished and return the existing
      # MediaAsset. If distributing the file fails, then mark the MediaAsset as
      # failed and raise an exception.
      #
      # This can't be called inside a transaction because the transaction will
      # fail if there's a RecordNotUnique error when the asset already exists.
      def upload!(media_file, &block)
        media_file = MediaFile.open(media_file) unless media_file.is_a?(MediaFile)

        media_asset = create!(file: media_file, status: :processing)
        yield media_asset if block_given?

        # XXX should do this in parallel with thumbnail generation.
        # XXX shouldn't generate thumbnail twice (very slow for ugoira)
        media_asset.update!(ai_tags: media_file.preview(360, 360).ai_tags)
        media_asset.update!(media_metadata: MediaMetadata.new(file: media_file))

        media_asset.distribute_files!(media_file)
        media_asset.update!(status: :active)
        media_asset

      # If the file has already been uploaded, then the `create!` call will raise one of these errors.
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
        raise if e.is_a?(ActiveRecord::RecordInvalid) && !e.record.errors.of_kind?(:md5, :taken)

        media_asset = find_by!(md5: media_file.md5, status: [:processing, :active])
        yield media_asset if block_given?

        # XXX If the asset is still being processed by another thread, wait up
        # to 30 seconds for it to finish.
        if media_asset.processing? && media_asset.created_at > 5.minutes.ago
          30.times do
            break if !media_asset.processing?
            sleep 1
            media_asset.reload
          end
        end

        # If the asset is stuck in the processing state, or if a processing asset moved to the
        # failed state, then mark the asset as failed so the user can try the upload again later.
        if !media_asset.active?
          media_asset.update!(status: :failed)
          raise Error, "Upload failed, try again (timed out while waiting for file to be processed)"
        end

        media_asset
      rescue Exception
        # If resizing or distributing the file to the backend servers failed, then mark the asset as
        # failed so the user can try the upload again later.
        media_asset&.update!(status: :failed)
        raise
      end

      def validate_media_file!(media_file, uploader)
        if !media_file.file_ext.to_s.in?(FILE_TYPES)
          raise Error, "File is not an image or video"
        elsif media_file.is_corrupt?
          raise Error, "File is corrupt"
        elsif media_file.file_size > MAX_FILE_SIZE
          raise Error, "File size too large (size: #{media_file.file_size.to_formatted_s(:human_size)}; max size: #{MAX_FILE_SIZE.to_formatted_s(:human_size)})"
        elsif media_file.resolution > MAX_IMAGE_RESOLUTION
          raise Error, "Image resolution is too large (resolution: #{(media_file.resolution / 1_000_000.0).round(1)} megapixels (#{media_file.width}x#{media_file.height}); max: #{MAX_IMAGE_RESOLUTION / 1_000_000} megapixels)"
        elsif media_file.width > MAX_IMAGE_WIDTH
          raise Error, "Image width is too large (width: #{media_file.width}; max width: #{MAX_IMAGE_WIDTH})"
        elsif media_file.height > MAX_IMAGE_HEIGHT
          raise Error, "Image height is too large (height: #{media_file.height}; max height: #{MAX_IMAGE_HEIGHT})"
        elsif media_file.duration.to_i > MAX_VIDEO_DURATION && !uploader.is_admin?
          raise Error, "Duration must be less than #{MAX_VIDEO_DURATION} seconds"
        end
      end
    end

    def file=(file_or_path)
      media_file = file_or_path.is_a?(MediaFile) ? file_or_path : MediaFile.open(file_or_path)

      self.md5 = media_file.md5
      self.file_ext = media_file.file_ext
      self.file_size = media_file.file_size
      self.image_width = media_file.width
      self.image_height = media_file.height
      self.duration = media_file.duration
    end

    def regenerate_ai_tags!
      with_lock do
        ai_tags.each(&:destroy!)
        update!(ai_tags: variant(:"360x360").open_file.ai_tags)
      end
    end

    def expunge!
      delete_files!
      update!(status: :expunged)
    rescue
      update!(status: :failed)
      raise
    end

    def trash!
      variants.each(&:trash_file!)
      update!(status: :deleted)
    rescue
      update!(status: :failed)
      raise
    end

    def delete_files!
      variants.each(&:delete_file!)
    end

    def distribute_files!(media_file)
      Parallel.each(variants, in_threads: Etc.nprocessors) do |variant|
        variant.store_file!(media_file)
      end
    end

    def storage_service
      STORAGE_SERVICE
    end

    def backup_storage_service
      Danbooru.config.backup_storage_manager
    end
  end

  concerning :VariantMethods do
    def variant(type)
      Variant.new(self, type)
    end

    def has_variant?(variant)
      Variant.exists?(self, variant)
    end

    def variants
      VARIANTS.select { |v| has_variant?(v) }.map { |v| variant(v) }
    end
  end

  concerning :FileTypeMethods do
    def is_image?
      file_ext.in?(%w[jpg png gif])
    end

    def is_static_image?
      is_image? && !is_animated?
    end

    def is_video?
      file_ext.in?(%w[webm mp4])
    end

    def is_ugoira?
      file_ext == "zip"
    end

    def is_flash?
      file_ext == "swf"
    end

    def is_animated?
      duration.present?
    end

    def is_animated_gif?
      is_animated? && file_ext == "gif"
    end

    def is_animated_png?
      is_animated? && file_ext == "png"
    end
  end

  def self.generate_file_key
    loop do
      key = SecureRandom.send(:choose, [*"0".."9", *"A".."Z", *"a".."z"], FILE_KEY_LENGTH) # base62
      return key unless MediaAsset.exists?(file_key: key)
    end
  end

  def initialize_file_key
    self.file_key = MediaAsset.generate_file_key
  end

  def self.available_includes
    %i[post media_metadata ai_tags]
  end
end
