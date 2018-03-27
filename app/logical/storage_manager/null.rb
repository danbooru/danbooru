class StorageManager::Null < StorageManager
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
