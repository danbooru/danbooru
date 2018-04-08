class StorageManager::Hybrid < StorageManager
  attr_reader :submanager

  def initialize(&block)
    @submanager = block
  end

  def store_file(io, post, type)
    submanager[post.id, post.md5, post.file_ext, type].store_file(io, post, type)
  end

  def delete_file(post_id, md5, file_ext, type)
    submanager[post_id, md5, file_ext, type].delete_file(post_id, md5, file_ext, type)
  end

  def open_file(post, type)
    submanager[post.id, post.md5, post.file_ext, type].open_file(post, type)
  end

  def file_url(post, type, **options)
    submanager[post.id, post.md5, post.file_ext, type].file_url(post, type, **options)
  end
end
