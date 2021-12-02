# StorageManager is an abstract superclass that defines a simple interface for
# storing files on local or remote backends. All image files stored by Danbooru
# are handled by a StorageManager.
#
# A StorageManager has methods for saving, deleting, and opening files, and for
# generating URLs for files.
#
# @abstract
# @see StorageManager::Local
# @see StorageManager::Mirror
# @see StorageManager::Rclone
class StorageManager
  class Error < StandardError; end

  attr_reader :base_url

  # Initialize a storage manager object.
  #
  # @param base_url [String, nil] the base URL where files are served from (ex:
  # "https://cdn.donmai.us"), or nil if the files don't have an URL (they're
  # stored in a publicly inaccessible location).
  def initialize(base_url: nil)
    @base_url = base_url
  end

  # Store the given file at the given path. If a file already exists at that
  # location it should be overwritten atomically. Either the file is fully
  # written, or an error is raised and the original file is left unchanged. The
  # file should never be in a partially written state.
  #
  # @param io [IO] a file (or a readable IO object)
  # @param path [String] the remote path where the file should be stored
  def store(io, path)
    raise NotImplementedError, "store not implemented"
  end

  # Delete the file at the given path. If the file doesn't exist, no error
  # should be raised.
  # @param path [String] the remote path of the file to be deleted
  def delete(path)
    raise NotImplementedError, "delete not implemented"
  end

  # Return a readonly copy of the file located at the given path.
  # @param path [String] the remote path of the file to open
  # @return [File] the file
  def open(path)
    raise NotImplementedError, "open not implemented"
  end

  # Return the full URL of the file at the given path, or nil if the file
  # doesn't have an URL.
  # @return [String, nil] the file URL
  def file_url(path)
    return nil if base_dir.nil?
    File.join(base_url, path)
  end
end
