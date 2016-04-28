require 'danbooru_image_resizer/danbooru_image_resizer'

namespace :images do
  desc "Redownload an image from Pixiv"
  task :download_pixiv => :environment do
    post_id = ENV["id"]

    if post_id !~ /\d+/
      raise "Usage: regen_img.rb POST_ID"
    end

    post = Post.find(post_id)
    post.source =~ /(\d{5,})/
    if illust_id = $1
      response = PixivApiClient.new.works(illust_id)
      upload = Upload.new
      upload.source = response.pages.first
      upload.file_ext = post.file_ext
      upload.image_width = post.image_width
      upload.image_height = post.image_height
      upload.md5 = post.md5
      upload.download_from_source(post.file_path)
      post.distribute_files
    end
  end

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
    upload.md5 = post.md5
    upload.generate_resizes(post.file_path)
    post.distribute_files
  end
  
  desc "Finds advertisement images that don't exist"
  task :find_missing_ads => :environment do
    Advertisement.where("status = 'active'").each do |ad|
      if !File.exists?(ad.image_path)
        puts ad.image_path
      end
    end
  end
  
  desc "Generate thumbnail-sized images of posts"
  task :generate_preview => :environment do
    Post.where("image_width > ?", Danbooru.config.small_image_width).find_each do |post|
      if post.is_image? && !File.exists?(post.preview_file_path)
        puts "resizing preview #{post.id}"
        Danbooru.resize(post.file_path, post.preview_file_path, Danbooru.config.small_image_width, Danbooru.config.small_image_width, 90)
      end
    end
  end
  
  desc "Generate large-sized images of posts"
  task :generate_large => :environment do
    Post.where("image_width > ?", Danbooru.config.large_image_width).find_each do |post|
      if post.is_image? && !File.exists?(post.large_file_path)
        puts "resizing large #{post.id}"
        Danbooru.resize(post.file_path, post.large_file_path, Danbooru.config.large_image_width, nil, 90)
        post.distribute_files
      end
    end
  end
end

