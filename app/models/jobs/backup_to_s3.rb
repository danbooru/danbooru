module Jobs
  class BackupToS3 < Struct.new(:last_id)
    def perform
      Post.find(:all, :conditions => ["id > ?", last_id], :limit => 200, :order => "id").each do |post|
        AWS::S3::Base.establish_connection!(:access_key_id => CONFIG["amazon_s3_access_key_id"], :secret_access_key => CONFIG["amazon_s3_secret_access_key"])
        if File.exists?(post.file_path)
          base64_md5 = Base64.encode64(Digest::MD5.digest(File.read(post.file_path)))
          AWS::S3::S3Object.store(post.file_name, open(post.file_path, "rb"), CONFIG["amazon_s3_bucket_name"], "Content-MD5" => base64_md5)
        end

        if post.image? && File.exists?(post.preview_path)
          AWS::S3::S3Object.store("preview/#{post.md5}.jpg", open(post.preview_path, "rb"), CONFIG["amazon_s3_bucket_name"])
        end

        if File.exists?(post.sample_path)
          AWS::S3::S3Object.store("sample/" + CONFIG["sample_filename_prefix"] + "#{post.md5}.jpg", open(post.sample_path, "rb"), CONFIG["amazon_s3_bucket_name"])
        end
        
        self.last_id = post.id
      end

      Delayed::Job.enqueue(BackupToS3.new(last_id))
    rescue Exception => x
      # probably some network error, retry next time
    end
  end
end