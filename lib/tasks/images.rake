require "find"

namespace :images do
  task manifest: :environment do
    root = ENV.fetch("DIR", Rails.root.join("public/data/original"))

    paths = Find.find(root).lazy
    paths = paths.reject { |path| File.directory?(path) }

    paths.each do |path|
      file = MediaFile.open(path)

      hash = {
        path: File.absolute_path(path),
        name: File.basename(path, ".*"),
        md5: file.md5,
        size: file.file_size,
        ext: file.file_ext,
        w: file.width,
        h: file.height,
      }

      puts hash.to_json
    rescue StandardError => e
      hash = {
        path: File.absolute_path(path),
        name: File.basename(path, ".*"),
        md5: file&.md5,
        size: file&.file_size,
        error: e.message,
      }

      puts hash.to_json
    end
  end

  task populate_media_metadata: :environment do
    sm = StorageManager::Local.new(base_url: "/", base_dir: ENV.fetch("DIR", Rails.root.join("public/data")))

    MediaMetadata.joins(:media_asset).where(metadata: {}).find_each do |metadata|
      asset = metadata.media_asset
      file = sm.open(sm.file_path(asset.md5, asset.file_ext, :original))
      media_file = MediaFile.open(file)

      metadata.update!(metadata: media_file.metadata)
      puts "metadata[id=#{metadata.id}, md5=#{asset.md5}]: #{media_file.metadata.count}"
    rescue StandardError => e
      puts "error[id=#{metadata.id}]: #{e}"
    end
  end

  desc "Backup images"
  task :backup => :environment do
    CurrentUser.user = User.system
    sm = Danbooru.config.backup_storage_manager
    tags = ENV["BACKUP_TAGS"]
    posts = Post.system_tag_match(tags)

    posts.find_each do |post|
      sm.store_file(post.file(:preview), post, :preview) if post.has_preview?
      sm.store_file(post.file(:crop), post, :crop) if post.has_cropped?
      sm.store_file(post.file(:sample), post, :sample) if post.has_large?
      sm.store_file(post.file(:original), post, :original)
    end
  end

  desc "Regenerate thumbnails and samples"
  task :regen => :environment do
    tags = ENV["TAGS"]

    Post.system_tag_match(tags).find_each do |post|
      original_file = MediaFile.open(post.file(:original))
      preview_file, crop_file, sample_file = UploadService::Utils.generate_resizes(original_file)

      line = ""
      line << "post ##{post.id}: "
      line << "preview=#{preview_file.width}x#{preview_file.height}:#{preview_file.file_size.to_s(:human_size)} " if preview_file.present?
      line << "crop=#{crop_file.width}x#{crop_file.height}:#{crop_file.file_size.to_s(:human_size)} " if crop_file.present?
      line << "sample=#{sample_file.width}x#{sample_file.height}:#{sample_file.file_size.to_s(:human_size)} " if sample_file.present?
      puts line

      UploadService::Utils.distribute_files(preview_file, post, :preview) if preview_file.present?
      UploadService::Utils.distribute_files(crop_file, post, :crop) if crop_file.present?
      UploadService::Utils.distribute_files(sample_file, post, :large) if sample_file.present?
    end
  end
end
