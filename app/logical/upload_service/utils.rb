# frozen_string_literal: true

class UploadService
  module Utils
    module_function

    def is_downloadable?(source)
      source =~ %r{\Ahttps?://}
    end

    def process_file(upload, file)
      media_file = MediaFile.open(file)

      upload.file = media_file
      upload.file_ext = media_file.file_ext.to_s
      upload.file_size = media_file.file_size
      upload.md5 = media_file.md5
      upload.image_width = media_file.width
      upload.image_height = media_file.height

      upload.validate!(:file)

      MediaAsset.upload!(media_file)
    end

    def get_file_for_upload(source_url, referer_url, file)
      return MediaFile.open(file) if file.present?
      raise "No file or source URL provided" if source_url.blank?

      strategy = Sources::Strategies.find(source_url, referer_url)
      raise NotImplementedError, "No login credentials configured for #{strategy.site_name}." unless strategy.class.enabled?

      strategy.download_file!
    end
  end
end
