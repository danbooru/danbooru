require 'danbooru_image_resizer/danbooru_image_resizer'

namespace :images do
  desc "Regenerates all images for a post id"
  task :regen => :environment do
    post_id = ENV["id"]

    if post_id !~ /\d+/
      raise "Usage: regen_img.rb POST_ID"
    end

    post = Post.find(post_id)
    upload = Upload.new
    upload.file_ext = post.file_ext
    upload.image_width = post.image_width
    upload.image_height = post.image_height
    upload.generate_resizes(post.file_path)
    post.distribute_files
  end
  
  desc "Generate thumbnail-sized images of posts"
  task :generate_preview => :environment do
    Post.where("image_width > ?", Danbooru.config.small_image_width).find_each do |post|
      if post.is_image?
        puts "resizing preview #{post.id}"
        Danbooru.resize(post.file_path, post.preview_file_path, Danbooru.config.small_image_width, Danbooru.config.small_image_width, 90)
      end
    end
  end
  
  desc "Generate large-sized images of posts"
  task :generate_large => :environment do
    Post.where("image_width > ?", Danbooru.config.large_image_width).find_each do |post|
      if post.is_image?
        puts "resizing large #{post.id}"
        Danbooru.resize(post.file_path, post.large_file_path, Danbooru.config.large_image_width, nil, 90)
      end
    end
  end
  
  desc "Distribute large posts to other servers"
  task :distribute_large => :environment do
    Post.where("image_width > ?", Danbooru.config.large_image_width).find_each do |post|
      if post.is_image?
        puts "distributing large #{post.id}"
        RemoteFileManager.new(post.large_file_path).distribute
      end
    end
  end
end

