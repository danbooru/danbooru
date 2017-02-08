require 'danbooru_image_resizer/danbooru_image_resizer'

namespace :images do
  desc "Enable CDN"
  task :enable_cdn, [:min_id, :max_id] => :environment do |t, args|
    CurrentUser.scoped(User.admins.first, "127.0.0.1") do
      credentials = Aws::Credentials.new(Danbooru.config.aws_access_key_id, Danbooru.config.aws_secret_access_key)
      Aws.config.update({
        region: "us-east-1",
        credentials: credentials
      })
      client = Aws::S3::Client.new
      bucket = Danbooru.config.aws_s3_bucket_name

      Post.where("id >= ? and id <= ?", args[:min_id], args[:max_id]).find_each do |post|
        post.cdn_hosted = true
        post.save
        key = File.basename(post.file_path)
        client.copy_object(bucket: bucket, key: key, acl: "public-read", storage_class: "STANDARD", copy_source: "/#{bucket}/#{key}", metadata_directive: "COPY")
        # client.put_object(bucket: bucket, key: key, body: body, content_md5: base64_md5, acl: "public-read", storage_class: "STANDARD")
      end
    end
  end

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

