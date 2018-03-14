class StorageManager::Local < StorageManager
  DEFAULT_PERMISSIONS = 0644

  def store(io, dest_path)
    temp_path = dest_path + "-" + SecureRandom.uuid + ".tmp"

    FileUtils.mkdir_p(File.dirname(temp_path))
    bytes_copied = IO.copy_stream(io, temp_path)
    raise Error, "store failed: #{bytes_copied}/#{io.size} bytes copied" if bytes_copied != io.size

    FileUtils.chmod(DEFAULT_PERMISSIONS, temp_path)
    File.rename(temp_path, dest_path)
  rescue StandardError => e
    FileUtils.rm_f(temp_path)
    raise Error, e
  end

  def delete(path)
    FileUtils.rm_f(path)
  end

  def open(path)
    File.open(path, "r", binmode: true)
  end
end
