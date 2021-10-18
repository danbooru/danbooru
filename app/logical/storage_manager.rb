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

  # Store or replace the given file belonging to the given post.
  # @param io [IO] the file to store
  # @param post [Post] the post the image belongs to
  # @param type [Symbol] the image variant to store (:preview, :crop, :large, :original)
  def store_file(io, post, type)
    store(io, file_path(post.md5, post.file_ext, type))
  end

  # Delete the file belonging to the given post.
  # @param post_id [Integer] the post's id
  # @param md5 [String] the post's md5
  # @param file_ext [String] the post's file extension
  # @param type [Symbol] the image variant to delete (:preview, :crop, :large, :original)
  def delete_file(post_id, md5, file_ext, type)
    delete(file_path(md5, file_ext, type))
  end

  # Return a readonly copy of the image belonging to the given post.
  # @param post [Post] the post
  # @param type [Symbol] the image variant to open (:preview, :crop, :large, :original)
  # @return [MediaFile] the image file
  def open_file(post, type)
    self.open(file_path(post.md5, post.file_ext, type))
  end

  # Generate the image URL for the given post.
  # @param post [Post] the post
  # @param type [Symbol] the post's image variant (:preview, :crop, :large, :original)
  # @param tagged_filename [Boolean] whether the URL should contain the post's tags
  # @return [String] the image URL
  def file_url(post, type, tagged_filenames: false)
    subdir = subdir_for(post.md5)
    file = file_name(post.md5, post.file_ext, type)
    seo_tags = seo_tags(post) if tagged_filenames

    if type == :preview && !post.has_preview?
      "#{root_url}/images/download-preview.png"
    elsif type == :preview
      "#{base_url}/preview/#{subdir}#{file}"
    elsif type == :crop
      "#{base_url}/crop/#{subdir}#{file}"
    elsif type == :large && post.has_large?
      "#{base_url}/sample/#{subdir}#{seo_tags}#{file}"
    else
      "#{base_url}/original/#{subdir}#{seo_tags}#{post.md5}.#{post.file_ext}"
    end
  end

  def root_url
    origin = Addressable::URI.parse(base_url).origin
    origin = "" if origin == "null" # base_url was relative
    origin
  end

  def file_path(post_or_md5, file_ext, type)
    md5 = post_or_md5.is_a?(String) ? post_or_md5 : post_or_md5.md5
    subdir = subdir_for(md5)
    file = file_name(md5, file_ext, type)

    case type
    when :preview
      "/preview/#{subdir}#{file}"
    when :crop
      "/crop/#{subdir}#{file}"
    when :large
      "/sample/#{subdir}#{file}"
    when :original
      "/original/#{subdir}#{file}"
    end
  end

  def file_name(md5, file_ext, type)
    large_file_ext = (file_ext == "zip") ? "webm" : "jpg"

    case type
    when :preview
      "#{md5}.jpg"
    when :crop
      "#{md5}.jpg"
    when :large
      "sample-#{md5}.#{large_file_ext}"
    when :original
      "#{md5}.#{file_ext}"
    end
  end

  def subdir_for(md5)
    "#{md5[0..1]}/#{md5[2..3]}/"
  end

  # Generate the tags in the image URL.
  def seo_tags(post)
    return "" if !tagged_filenames

    tags = post.presenter.humanized_essential_tag_string.gsub(/[^a-z0-9]+/, "_").gsub(/(?:^_+)|(?:_+$)/, "").gsub(/_{2,}/, "_")
    "__#{tags}__"
  end

  def full_path(path)
    File.join(base_dir, path)
  end
end
