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
    last_id = AmazonBackup.last_id

    Post.where("id > ?", last_id).limit(1000).order("id").each do |post|
      AWS::S3::Base.establish_connection!(
        :access_key_id => Danbooru.config.amazon_s3_access_key_id,
        :secret_access_key => Danbooru.config.amazon_s3_secret_access_key,
        :server => "s3.amazonaws.com"
      )

      if File.exists?(post.file_path)
        base64_md5 = Base64.encode64(Digest::MD5.digest(File.read(post.file_path)))
        AWS::S3::S3Object.store(File.basename(post.file_path), open(post.file_path, "rb"), Danbooru.config.amazon_s3_bucket_name, "Content-MD5" => base64_md5)
      end

      if post.has_preview? && File.exists?(post.preview_file_path)
        AWS::S3::S3Object.store("preview/#{post.md5}.jpg", open(post.preview_file_path, "rb"), Danbooru.config.amazon_s3_bucket_name)
      end

      if File.exists?(post.large_file_path)
        AWS::S3::S3Object.store("large/#{post.md5}.jpg", open(post.large_file_path, "rb"), Danbooru.config.amazon_s3_bucket_name)
      end

      AmazonBackup.update_id(post.id)
    end
  rescue Exception => x
    # probably some network error, retry next time
  end
end
