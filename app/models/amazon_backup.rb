require 'base64'
require 'digest/md5'

class AmazonBackup < ActiveRecord::Base
  attr_accessible :last_id
  
  def self.last_id
    first.last_id
  end

  def self.update_id(new_id)
    first.update_column(:last_id, new_id)
  end

  def self.execute
    return false unless Danbooru.config.aws_s3_enabled?
    
    last_id = AmazonBackup.last_id
    credentials = Aws::Credentials.new(Danbooru.config.aws_access_key_id, Danbooru.config.aws_secret_access_key)
    Aws.config.update({
      region: "us-east-1",
      credentials: credentials
    })
    client = Aws::S3::Client.new
    bucket = Danbooru.config.aws_s3_bucket_name

    Post.where("id > ?", last_id).limit(1000).order("id").each do |post|
      if File.exists?(post.file_path)
        base64_md5 = Digest::MD5.base64digest(File.read(post.file_path))
        key = File.basename(post.file_path)
        body = open(post.file_path, "rb")
        client.put_object(bucket: bucket, key: key, body: body, content_md5: base64_md5)
      end

      if post.has_preview? && File.exists?(post.preview_file_path)
        key = "preview/#{post.md5}.jpg"
        body = open(post.preview_file_path, "rb")
        client.put_object(bucket: bucket, key: key, body: body)
      end

      if File.exists?(post.large_file_path)
        key = "large/#{post.md5}.#{post.large_file_ext}"
        body = open(post.large_file_path, "rb")
        client.put_object(bucket: bucket, key: key, body: body)
      end

      AmazonBackup.update_id(post.id)
    end
  rescue Exception => x
    # probably some network error, retry next time
  end
end
