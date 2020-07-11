class UploadService
  module Utils
    module_function

    def distribute_files(file, record, type, original_post_id: nil)
      # need to do this for hybrid storage manager
      post = Post.new
      post.id = original_post_id if original_post_id.present?
      post.md5 = record.md5
      post.file_ext = record.file_ext
      [Danbooru.config.storage_manager, Danbooru.config.backup_storage_manager].each do |sm|
        sm.store_file(file, post, type)
      end
    end

    def is_downloadable?(source)
      source =~ /^https?:\/\//
    end

    def generate_resizes(media_file)
      preview_file = media_file.preview(Danbooru.config.small_image_width, Danbooru.config.small_image_width)
      crop_file = media_file.crop(Danbooru.config.small_image_width, Danbooru.config.small_image_width)

      if media_file.is_ugoira?
        sample_file = media_file.convert
      elsif media_file.is_image? && media_file.width > Danbooru.config.large_image_width
        sample_file = media_file.preview(Danbooru.config.large_image_width, media_file.height)
      else
        sample_file = nil
      end

      [preview_file, crop_file, sample_file]
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

      preview_file, crop_file, sample_file = Utils.generate_resizes(media_file)

      begin
        Utils.distribute_files(file, upload, :original, original_post_id: original_post_id)
        Utils.distribute_files(sample_file, upload, :large, original_post_id: original_post_id) if sample_file.present?
        Utils.distribute_files(preview_file, upload, :preview, original_post_id: original_post_id) if preview_file.present?
        Utils.distribute_files(crop_file, upload, :crop, original_post_id: original_post_id) if crop_file.present?
      ensure
        preview_file.try(:close!)
        crop_file.try(:close!)
        sample_file.try(:close!)
      end
    end

    def automatic_tags(media_file)
      tags = []
      tags << "video_with_sound" if media_file.has_audio?
      tags << "animated_gif" if media_file.file_ext == :gif && media_file.is_animated?
      tags << "animated_png" if media_file.file_ext == :png && media_file.is_animated?
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
