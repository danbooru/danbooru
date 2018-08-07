namespace :images do
  desc "Distribute posts to all servers via SFTP"
  task :distribute, [:min_id, :max_id] => :environment do |t, args|
    min_id = args[:min_id]
    max_id = args[:max_id]
    lsm = StorageManager::Local.new(base_url: "https://danbooru.donmai.us/data", base_dir: "/var/www/danbooru2/shared/data", hierarchical: false)
    sftpsm = StorageManager::SFTP.new(*Danbooru.config.all_server_hosts, base_url: "https://danbooru.donmai.us/data")

    Post.where("id between ? and ?", min_id, max_id).find_each do |post|
      sftpsm.store_file(lsm.open_file(post, :original), post, :original)
      sftpsm.store_file(lsm.open_file(post, :large), post, :large) if post.has_large?
      sftpsm.store_file(lsm.open_file(post, :preview), post, :preview) if post.has_preview?
    end
  end

  desc "Reset S3 + Storage Class"
  task :reset_s3, [:min_id, :max_id] => :environment do |t, args|
    min_id = args[:min_id] # 1
    max_id = args[:max_id] # 50_000

    credentials = Aws::Credentials.new(Danbooru.config.aws_access_key_id, Danbooru.config.aws_secret_access_key)
    Aws.config.update({
      region: "us-east-1",
      credentials: credentials
    })
    client = Aws::S3::Client.new
    bucket = Danbooru.config.aws_s3_bucket_name

    Post.where("id >= ? and id <= ?", min_id, max_id).find_each do |post|
      key = File.basename(post.file_path)
      begin
        client.copy_object(bucket: bucket, key: key, acl: "public-read", storage_class: "STANDARD", copy_source: "/#{bucket}/#{key}", metadata_directive: "COPY")
        puts "copied #{post.id}"
      rescue Aws::S3::Errors::InvalidObjectState
        puts "invalid state #{post.id}"
      rescue Aws::S3::Errors::NoSuchKey
        puts "missing #{post.id}"
      end
    end
  end

  desc "restore from glacier"
  task :restore_glacier, [:min_id, :max_id] => :environment do |t, args|
    min_id = args[:min_id] # 10_001
    max_id = args[:max_id] # 50_000

    credentials = Aws::Credentials.new(Danbooru.config.aws_access_key_id, Danbooru.config.aws_secret_access_key)
    Aws.config.update({
      region: "us-east-1",
      credentials: credentials
    })
    client = Aws::S3::Client.new
    bucket = Danbooru.config.aws_s3_bucket_name

    Post.where("id >= ? and id <= ?", min_id, max_id).find_each do |post|
      key = "preview/" + File.basename(post.preview_file_path)
      begin
        client.restore_object(
          bucket: bucket,
          key: key,
          restore_request: {
            days: 1,
            glacier_job_parameters: {
              tier: "Bulk"
            }
          }
        )
        puts "restored #{post.id}"
      rescue Aws::S3::Errors::InvalidObjectState
        puts "already glaciered #{post.id}"
      rescue Aws::S3::Errors::NoSuchKey
        puts "missing #{post.id}"
      rescue Aws::S3::Errors::RestoreAlreadyInProgress
        puts "already restoring #{post.id}"
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
      response = PixivApiClient.new.work(illust_id)
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
      raise "Usage: regen id=n"
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
    
  desc "Generate thumbnail-sized images of posts"
  task :generate_preview => :environment do
    width = 150
    post_id = ENV["id"]

    if post_id !~ /\d+/
      raise "Usage: generate_preview id=n"
    end

    Post.where(id: post_id).find_each do |post|
      if post.is_image?
        puts "resizing preview #{post.id}"
        DanbooruImageResizer.resize(post.file_path, post.preview_file_path, width, width, 90)
      end
    end
  end
  
  desc "Generate large-sized images of posts"
  task :generate_large => :environment do
    post_id = ENV["id"]

    if post_id !~ /\d+/
      raise "Usage: generate_large id=n"
    end

    Post.where(id: post_id).find_each do |post|
      if post.is_image? && post.has_large?
        puts "resizing large #{post.id}"
        DanbooruImageResizer.resize(post.file_path, post.large_file_path, Danbooru.config.large_image_width, nil, 90)
        post.distribute_files
      end
    end
  end
end

