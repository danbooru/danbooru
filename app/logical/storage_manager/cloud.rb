class StorageManager::Cloud < StorageManager
  attr_reader :bucket, :client, :fog_options

  def initialize(bucket, client: nil, fog_options: {}, **options)
    @bucket = bucket
    @fog_options = fog_options
    @client = client || Fog::Storage.new(**fog_options)
    super(**options)
  end

  def store(io, path)
    io.rewind # XXX caller should be responsible for this.
    data = io.read
    client.put_object(bucket, key(path), data)
  end

  def delete(path)
    client.delete_object(bucket, key(path))
  end

  def open(path)
    file = Tempfile.new(binmode: true)
    response = client.get_object(bucket, key(path))
    file.write(response.body)
    file.rewind
    file
  end

  def key(path)
    path.delete_prefix("/")
  end
end
