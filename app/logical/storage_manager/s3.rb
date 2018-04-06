class StorageManager::S3 < StorageManager
  # https://docs.aws.amazon.com/sdkforruby/api/Aws/S3/Client.html#initialize-instance_method
  DEFAULT_S3_OPTIONS = {
    region: Danbooru.config.aws_region,
    credentials: Danbooru.config.aws_credentials,
    logger: Rails.logger,
  }

  # https://docs.aws.amazon.com/sdkforruby/api/Aws/S3/Client.html#put_object-instance_method
  DEFAULT_PUT_OPTIONS = {
    acl: "public-read",
    storage_class: "STANDARD", # STANDARD, STANDARD_IA, REDUCED_REDUNDANCY
    cache_control: "public, max-age=#{1.year.to_i}",
    #content_type: "image/jpeg" # XXX should set content type
  }

  attr_reader :bucket, :client, :s3_options

  def initialize(bucket, client: nil, s3_options: {}, **options)
    @bucket = bucket
    @s3_options = DEFAULT_S3_OPTIONS.merge(s3_options)
    @client = client || Aws::S3::Client.new(**@s3_options)
    super(**options)
  end

  def key(path)
    path.sub(/^.+?data\//, "")
  end

  def store(io, path)
    data = io.read
    base64_md5 = Digest::MD5.base64digest(data)
    client.put_object(bucket: bucket, key: key(path), body: data, content_md5: base64_md5, **DEFAULT_PUT_OPTIONS)
  end

  def delete(path)
    client.delete_object(bucket: bucket, key: key(path))
  rescue Aws::S3::Errors::NoSuchKey
    # ignore
  end

  def open(path)
    file = Tempfile.new(binmode: true)
    client.get_object(bucket: bucket, key: key(path), response_target: file)
    file
  end
end
