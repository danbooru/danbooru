#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

# This should be run on both servers to rename the file locally
Post.where("id in (?)", Pool.find(203).post_id_array).find_each do |post|
  correct_md5 = Digest::MD5.file(post.file_path).hexdigest

  if post.is_image?
    if post.has_large?
      FileUtils.mv(post.large_path, post.large_path.sub(post.md5, correct_md5))
    end

    FileUtils.mv(post.real_preview_file_path, post.real_preview_file_path.sub(post.md5, correct_md5))
    FileUtils.mv(post.ssd_preview_file_path, post.ssd_preview_file_path.sub(post.md5, correct_md5))
  end

  FileUtils.mv(post.file_path, post.file_path.sub(post.md5, correct_md5))
end
