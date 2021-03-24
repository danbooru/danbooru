class StorageManager::Null < StorageManager
  def initialize(base_url: "/", base_dir: "/")
    super
  end

  def store(io, path)
    # no-op
  end

  def delete(path)
    # no-op
  end

  def open(path)
    # no-op
  end
end
