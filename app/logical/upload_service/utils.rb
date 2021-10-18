class UploadService
  module Utils
    module_function

    def is_downloadable?(source)
      source =~ %r{\Ahttps?://}
    end

    def process_file(upload, file, original_post_id: nil)
      upload.file = file
      media_file = upload.media_file

      upload.file_ext = media_file.file_ext.to_s
      upload.file_size = media_file.file_size
      upload.md5 = media_file.md5
      upload.image_width = media_file.width
      upload.image_height = media_file.height

      upload.validate!(:file)
      upload.tag_string = "#{upload.tag_string} #{Utils.automatic_tags(media_file)}"

      MediaAsset.upload!(media_file)
    end

    def automatic_tags(media_file)
      tags = []
      tags << "sound" if media_file.has_audio?
      tags.join(" ")
    end

    def get_file_for_upload(upload, file: nil)
      return file if file.present?
      raise "No file or source URL provided" if upload.source_url.blank?

      strategy = Sources::Strategies.find(upload.source_url, upload.referer_url)
      raise NotImplementedError, "No login credentials configured for #{strategy.site_name}." unless strategy.class.enabled?

      file = strategy.download_file!

      if strategy.data[:ugoira_frame_data].present?
        upload.context = {
          "ugoira" => {
            "frame_data" => strategy.data[:ugoira_frame_data],
            "content_type" => "image/jpeg"
          }
        }
      end

      file
    end
  end
end
