# frozen_string_literal: true

class MediaAsset < ApplicationRecord
  class Error < StandardError; end

  VARIANTS = %i[preview 180x180 360x360 720x720 sample original]
  MAX_VIDEO_DURATION = 140 # 2:20
  MAX_IMAGE_RESOLUTION = Danbooru.config.max_image_resolution
  MAX_IMAGE_WIDTH = Danbooru.config.max_image_width
  MAX_IMAGE_HEIGHT = Danbooru.config.max_image_height
  ENABLE_SEO_POST_URLS = Danbooru.config.enable_seo_post_urls
  LARGE_IMAGE_WIDTH = Danbooru.config.large_image_width
  STORAGE_SERVICE = Danbooru.config.storage_manager

  has_one :post, foreign_key: :md5, primary_key: :md5
  has_one :media_metadata, dependent: :destroy
  has_one :pixiv_ugoira_frame_data, class_name: "PixivUgoiraFrameData", foreign_key: :md5, primary_key: :md5

  delegate :metadata, to: :media_metadata
  delegate :is_non_repeating_animation?, :is_greyscale?, :is_rotated?, to: :metadata

  # Processing: The asset's files are currently being resized and distributed to the backend servers.
  # Active: The asset has been successfully uploaded and is ready to use.
  # Deleted: The asset's files have been deleted by moving them to a trash folder. They can be undeleted
  #          by moving them out of the trash folder. (Not implemented yet).
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

  validates :md5, uniqueness: { conditions: -> { where(status: [:processing, :active]) } }
  validates :file_ext, inclusion: { in: %w[jpg png gif mp4 webm swf zip], message: "Not an image or video" }
  validates :file_size, numericality: { less_than_or_equal_to: Danbooru.config.max_file_size }
  validates :duration, numericality: { less_than_or_equal_to: MAX_VIDEO_DURATION, message: "must be less than #{MAX_VIDEO_DURATION} seconds", allow_nil: true }, on: :create # XXX should allow admins to bypass
  validate :validate_resolution, on: :create

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

    def delete_file!
      storage_service.delete(file_path)
      backup_storage_service.delete(file_path)
    end

    def open_file
      file = storage_service.open(file_path)
      frame_data = media_asset.pixiv_ugoira_frame_data&.data if media_asset.is_ugoira?
      MediaFile.open(file, frame_data: frame_data, strict: false)
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
      def search(params)
        q = search_attributes(params, :id, :created_at, :updated_at, :md5, :file_ext, :file_size, :image_width, :image_height)

        if params[:metadata].present?
          q = q.joins(:media_metadata).merge(MediaMetadata.search(metadata: params[:metadata]))
        end

        q.apply_default_order(params)
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
      def upload!(media_file)
        raise Error, "File is corrupt" if media_file.is_corrupt?

        media_asset = create!(file: media_file, status: :processing)
        media_asset.distribute_files!(media_file)
        media_asset.update!(status: :active)
        media_asset

      # If the file has already been uploaded, then the `create!` call will raise one of these errors.
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
        raise if e.is_a?(ActiveRecord::RecordInvalid) && !e.record.errors.of_kind?(:md5, :taken)

        media_asset = find_by!(md5: media_file.md5, status: [:processing, :active])

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
    end

    def file=(file_or_path)
      media_file = file_or_path.is_a?(MediaFile) ? file_or_path : MediaFile.open(file_or_path)

      self.md5 = media_file.md5
      self.file_ext = media_file.file_ext
      self.file_size = media_file.file_size
      self.image_width = media_file.width
      self.image_height = media_file.height
      self.duration = media_file.duration
      self.media_metadata = MediaMetadata.new(file: media_file)
      self.pixiv_ugoira_frame_data = PixivUgoiraFrameData.new(data: media_file.frame_data, content_type: "image/jpeg") if is_ugoira?
    end

    def expunge!
      delete_files!
      update!(status: :expunged)
    rescue
      update!(status: :failed)
      raise
    end

    def delete_files!
      variants.each(&:delete_file!)
    end

    def distribute_files!(media_file)
      variants.each do |variant|
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

  concerning :ValidationMethods do
    def validate_resolution
      resolution = image_width * image_height

      if resolution > MAX_IMAGE_RESOLUTION
        errors.add(:base, "Image resolution is too large (resolution: #{(resolution / 1_000_000.0).round(1)} megapixels (#{image_width}x#{image_height}); max: #{MAX_IMAGE_RESOLUTION / 1_000_000} megapixels)")
      elsif image_width > MAX_IMAGE_WIDTH
        errors.add(:image_width, "is too large (width: #{image_width}; max width: #{MAX_IMAGE_WIDTH})")
      elsif image_height > MAX_IMAGE_HEIGHT
        errors.add(:image_height, "is too large (height: #{image_height}; max height: #{MAX_IMAGE_HEIGHT})")
      end
    end
  end
end
