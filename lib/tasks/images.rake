namespace :images do
  desc "Backup images"
  task :backup => :environment do
    CurrentUser.user = User.system
    sm = Danbooru.config.backup_storage_manager
    tags = ENV["BACKUP_TAGS"]
    posts = Post.tag_match(tags)

    posts.find_each do |post|
      sm.store_file(post.file(:preview), post, :preview) if post.has_preview?
      sm.store_file(post.file(:crop), post, :crop) if post.has_cropped?
      sm.store_file(post.file(:sample), post, :sample) if post.has_large?
      sm.store_file(post.file(:original), post, :original)
    end
  end
end
