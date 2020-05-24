namespace :images do
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
