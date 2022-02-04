# frozen_string_literal: true

# A StorageManager that stores files on the local filesystem.
class StorageManager::Local < StorageManager
  DEFAULT_PERMISSIONS = 0o644

  attr_reader :base_dir

  # @param base_url [String] the base directory where files are stored (ex: "/home/danbooru/public/data")
  def initialize(base_dir: nil, **options)
    @base_dir = base_dir.to_s
    super(**options)
  end

  def store(src_file, dest_path)
    temp_path = full_path(dest_path) + "-" + SecureRandom.uuid + ".tmp"

    FileUtils.mkdir_p(File.dirname(temp_path))
    bytes_copied = IO.copy_stream(src_file.path, temp_path)
    raise Error, "store failed: #{bytes_copied}/#{src_file.size} bytes copied" if bytes_copied != src_file.size

    FileUtils.chmod(DEFAULT_PERMISSIONS, temp_path)
    File.rename(temp_path, full_path(dest_path))
  rescue StandardError => e
    FileUtils.rm_f(temp_path)
    raise Error, e
  end

  def delete(path)
    FileUtils.rm_f(full_path(path))
  end

  def open(path)
    File.open(full_path(path), "r", binmode: true)
  end

  protected

  def full_path(path)
    File.join(base_dir, path)
  end
end
