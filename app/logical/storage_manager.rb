class StorageManager
  class Error < StandardError; end

  DEFAULT_BASE_DIR = "#{Rails.root}/public/data"

  attr_reader :base_url, :base_dir, :hierarchical, :tagged_filenames, :original_subdir

  def initialize(base_url: default_base_url, base_dir: DEFAULT_BASE_DIR, hierarchical: false, tagged_filenames: Danbooru.config.enable_seo_post_urls, original_subdir: "")
    @base_url = base_url.chomp("/")
    @base_dir = base_dir
    @hierarchical = hierarchical
    @tagged_filenames = tagged_filenames
    @original_subdir = original_subdir
  end

  def default_base_url
    "#{CurrentUser.root_url}/data"
  end

  # Store the given file at the given path. If a file already exists at that
  # location it should be overwritten atomically. Either the file is fully
  # written, or an error is raised and the original file is left unchanged. The
  # file should never be in a partially written state.
  def store(io, path)
    raise NotImplementedError, "store not implemented"
  end

  # Delete the file at the given path. If the file doesn't exist, no error
  # should be raised.
  def delete(path)
    raise NotImplementedError, "delete not implemented"
  end

  # Return a readonly copy of the file located at the given path.
  def open(path)
    raise NotImplementedError, "open not implemented"
  end

  def store_file(io, post, type)
    store(io, file_path(post.md5, post.file_ext, type))
  end

  def delete_file(post_id, md5, file_ext, type)
    delete(file_path(md5, file_ext, type))
  end

  def open_file(post, type)
    self.open(file_path(post.md5, post.file_ext, type))
  end

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
      "#{base_url}/#{original_subdir}#{subdir}#{seo_tags}#{post.md5}.#{post.file_ext}"
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
      "#{base_dir}/preview/#{subdir}#{file}"
    when :crop
      "#{base_dir}/crop/#{subdir}#{file}"
    when :large
      "#{base_dir}/sample/#{subdir}#{file}"
    when :original
      "#{base_dir}/#{original_subdir}#{subdir}#{file}"
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
    if hierarchical
      "#{md5[0..1]}/#{md5[2..3]}/"
    else
      ""
    end
  end

  def seo_tags(post)
    return "" if !tagged_filenames

    tags = post.presenter.humanized_essential_tag_string.gsub(/[^a-z0-9]+/, "_").gsub(/(?:^_+)|(?:_+$)/, "").gsub(/_{2,}/, "_")
    "__#{tags}__"
  end
end
