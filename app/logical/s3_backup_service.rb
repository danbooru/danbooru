class S3BackupService < BackupService
  attr_reader :client, :bucket

  def initialize(client: nil, bucket: Danbooru.config.aws_s3_bucket_name)
    @credentials = Aws::Credentials.new(Danbooru.config.aws_access_key_id, Danbooru.config.aws_secret_access_key)
    @client = client || Aws::S3::Client.new(credentials: @credentials, region: "us-east-1", logger: Logger.new(STDOUT))
    @bucket = bucket
  end

  def backup(file_path, type: nil, **options)
    keys = s3_keys(file_path, type)
    keys.each do |key|
      upload_to_s3(key, file_path)
    end
  end

  def delete(file_path, type: nil)
    keys = s3_keys(file_path, type)
    keys.each do |key|
      delete_from_s3(key)
    end
  end

protected
  def s3_keys(file_path, type)
    name = File.basename(file_path)

    case type
    when :original
      [name]
    when :preview
      ["preview/#{name}"]
    when :large
      ["sample/#{name}"]
    else
      raise ArgumentError.new("Unknown type: #{type}")
    end
  end

  def delete_from_s3(key)
    client.delete_object(bucket: bucket, key: key)
  rescue Aws::S3::Errors::NoSuchKey
    # ignore
  end

  def upload_to_s3(key, file_path)
    File.open(file_path, "rb") do |body|
      base64_md5 = Digest::MD5.base64digest(File.read(file_path))
      client.put_object(acl: "public-read", bucket: bucket, key: key, body: body, content_md5: base64_md5)
    end
  end
end
