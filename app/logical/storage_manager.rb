# StorageManager is an abstract superclass that defines a simple interface for
# storing files on local or remote backends. All image files stored by Danbooru
# are handled by a StorageManager.
#
# A StorageManager has methods for saving, deleting, and opening files, and for
# generates URLs for images.
#
# @abstract
# @see StorageManager::Local
# @see StorageManager::SFTP
class StorageManager
  class Error < StandardError; end

  attr_reader :base_url, :base_dir, :tagged_filenames

  # Initialize a storage manager object.
  # @param base_url [String] the base URL where images are stored (ex: "https://cdn.donmai.us/")
  # @param base_dir [String] the base directory where images are stored (ex: "/var/www/danbooru/public/images")
  # @param tagged_filenames [Boolean] whether image URLs can include tags
  def initialize(base_url:, base_dir:, tagged_filenames: Danbooru.config.enable_seo_post_urls)
    @base_url = base_url.chomp("/")
    @base_dir = base_dir
    @tagged_filenames = tagged_filenames
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
  # @return [MediaFile] the image file
  def open(path)
    raise NotImplementedError, "open not implemented"
  end

  def file_url(path)
    File.join(base_url, path)
  end

  def full_path(path)
    File.join(base_dir, path)
  end
end
