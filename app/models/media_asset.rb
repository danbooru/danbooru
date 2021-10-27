class MediaAsset < ApplicationRecord
  has_one :media_metadata, dependent: :destroy
  has_one :pixiv_ugoira_frame_data, class_name: "PixivUgoiraFrameData", foreign_key: :md5, primary_key: :md5

  delegate :metadata, to: :media_metadata
  delegate :is_non_repeating_animation?, :is_greyscale?, :is_rotated?, to: :metadata

  enum status: {
    processing: 100,
    active: 200,
    deleted: 300,
    expunged: 400,
    failed: 500,
  }

  validates :md5, uniqueness: { conditions: -> { where(status: [:processing, :active]) } }

  class Variant
    attr_reader :media_asset, :variant
    delegate :md5, :storage_service, :backup_storage_service, to: :media_asset

    def initialize(media_asset, variant)
      @media_asset = media_asset
      @variant = variant

      raise ArgumentError, "asset doesn't have #{variant} variant" unless Variant.exists?(media_asset, variant)
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
      MediaFile.open(file, frame_data: frame_data)
    end

    def convert_file(media_file)
      case variant
      in :preview
        media_file.preview(Danbooru.config.small_image_width, Danbooru.config.small_image_width)
      in :crop
        media_file.crop(Danbooru.config.small_image_width, Danbooru.config.small_image_width)
      in :sample if media_asset.is_ugoira?
        media_file.convert
      in :sample if media_asset.is_static_image? && media_asset.image_width > Danbooru.config.large_image_width
        media_file.preview(Danbooru.config.large_image_width, media_asset.image_height)
      in :original
        media_file
      end
    end

    def file_url(slug = "")
      storage_service.file_url(file_path(slug))
    end

    def file_path(slug = "")
      if variant.in?(%i[preview crop]) && media_asset.is_flash?
        "/images/download-preview.png"
      else
        slug = "__#{slug}__" if slug.present?
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
      when :preview
        "jpg"
      when :crop
        "jpg"
      when :sample
        media_asset.is_ugoira? ? "webm" : "jpg"
      when :original
        media_asset.file_ext
      end
    end

    def self.exists?(media_asset, variant)
      case variant
      when :preview
        true
      when :crop
        true
      when :sample
        media_asset.is_ugoira? || (media_asset.is_static_image? && media_asset.image_width > Danbooru.config.large_image_width)
      when :original
        true
      end
    end
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
        if media_asset.processing?
          30.times do
            break if !media_asset.processing?
            sleep 1
            media_asset.reload
          end

          # If the asset is still processing after 30 seconds, or if it moved
          # from the processing state to the failed state, then fail.
          raise "Upload failed" if !media_asset.active?
        end

        media_asset
      rescue Exception
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
      Danbooru.config.storage_manager
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
      %i[preview crop sample original].select { |v| has_variant?(v) }.map { |v| variant(v) }
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
end
