# donmai.us specific

require 'base64'
require 'digest/md5'

class AmazonBackup < ApplicationRecord
  def self.last_id
    first.last_id
  end

  def self.update_id(new_id)
    first.update_column(:last_id, new_id)
  end

  def self.restore_from_glacier(min_id = 1_431_595, max_id = 2_000_000)
    credentials = Aws::Credentials.new(Danbooru.config.aws_access_key_id, Danbooru.config.aws_secret_access_key)
    Aws.config.update({
      region: "us-east-1",
      credentials: credentials
    })
    client = Aws::S3::Client.new
    bucket = Danbooru.config.aws_s3_bucket_name

    f = lambda do |key|
      begin
        client.restore_object(
          bucket: bucket,
          key: key,
          restore_request: {
            days: 7,
            glacier_job_parameters: {
              tier: "Bulk"
            }
          }
        )
      rescue Aws::S3::Errors::InternalError
        puts "  internal error...retrying"
        sleep 30
        retry
      rescue Aws::S3::Errors::InvalidObjectState
        puts "  already restored #{key}"
      rescue Aws::S3::Errors::NoSuchKey
        puts "  missing #{key}"
        file_path = "/var/www/danbooru2/shared/data/#{key}"

        if File.exists?(file_path)
          base64_md5 = Digest::MD5.base64digest(File.read(file_path))
          body = open(file_path, "rb")
          client.put_object(bucket: bucket, key: key, body: body, content_md5: base64_md5, acl: "public-read")
          puts "  uploaded"
        end
      rescue Aws::S3::Errors::RestoreAlreadyInProgress
        puts "  already restoring #{key}"
      end
    end

    Post.where("id >= ? and id <= ?", min_id, max_id).find_each do |post|
      if post.has_large?
        puts "large:#{post.id}"
        key = "sample/" + File.basename(post.large_file_path)
        f.call(key)
      end

      if post.has_preview?
        puts "preview:#{post.id}"
        key = "preview/" + File.basename(post.preview_file_path)
        f.call(key)
      end

      puts "#{post.id}"
      key = File.basename(post.file_path)
      f.call(key)
    end
  end

  def self.copy_to_standard(min_id = 1_191_247, max_id = 2_000_000)
    credentials = Aws::Credentials.new(Danbooru.config.aws_access_key_id, Danbooru.config.aws_secret_access_key)
    Aws.config.update({
      region: "us-east-1",
      credentials: credentials
    })
    client = Aws::S3::Client.new
    bucket = Danbooru.config.aws_s3_bucket_name

    f = lambda do |key|
      begin
        client.copy_object(bucket: bucket, key: key, acl: "public-read", storage_class: "STANDARD", copy_source: "/#{bucket}/#{key}", metadata_directive: "COPY")
        puts "  copied #{key}"
      rescue Aws::S3::Errors::InternalError
        puts "  internal error...retrying"
        sleep 30
        retry
      rescue Aws::S3::Errors::InvalidObjectState
        puts "  invalid state #{key}"
      rescue Aws::S3::Errors::NoSuchKey
        puts "  missing #{key}"
      end
    end

    Post.where("id >= ? and id <= ?", min_id, max_id).find_each do |post|
      next unless post.has_preview?

      if post.has_preview?
        puts "preview:#{post.id}"
        key = "preview/" + File.basename(post.preview_file_path)
        f.call(key)
      end

      if post.has_large?
        puts "large:#{post.id}"
        key = "sample/" + File.basename(post.large_file_path)
        f.call(key)
      end

      puts "#{post.id}"
      key = File.basename(post.file_path)
      f.call(key)
    end
  end

  def self.execute
    return false unless Danbooru.config.aws_s3_enabled?
    
    last_id = AmazonBackup.last_id
    credentials = Aws::Credentials.new(Danbooru.config.aws_access_key_id, Danbooru.config.aws_secret_access_key)
    Aws.config.update({
      region: "us-east-1",
      credentials: credentials
    })
    logger = Logger.new(STDOUT)
    client = Aws::S3::Client.new(logger: logger)
    bucket = Danbooru.config.aws_s3_bucket_name

    Post.where("id > ?", last_id).limit(1000).order("id").each do |post|
      if File.exists?(post.file_path)
        base64_md5 = Digest::MD5.base64digest(File.read(post.file_path))
        key = File.basename(post.file_path)
        body = open(post.file_path, "rb")
        client.put_object(bucket: bucket, key: key, body: body, content_md5: base64_md5, acl: "public-read")
      end

      if post.has_preview? && File.exists?(post.preview_file_path)
        key = "preview/#{post.md5}.jpg"
        body = open(post.preview_file_path, "rb")
        client.put_object(bucket: bucket, key: key, body: body, acl: "public-read")
      end

      if File.exists?(post.large_file_path)
        key = "sample/#{Danbooru.config.large_image_prefix}#{post.md5}.#{post.large_file_ext}"
        body = open(post.large_file_path, "rb")
        client.put_object(bucket: bucket, key: key, body: body, acl: "public-read")
      end

      AmazonBackup.update_id(post.id)
    end
  rescue Exception => x
    # probably some network error, retry next time
  end
end
