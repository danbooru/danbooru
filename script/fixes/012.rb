#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

Post.where("is_deleted = true").find_each do |post|
  parent_id = ActiveRecord::Base.connection.select_value("select parent_id from post_versions where post_id = #{post.id} order by updated_at desc limit 1")
  if parent_id
    post.update_column(:parent_id, parent_id)
    ActiveRecord::Base.connection.execute("update posts set has_children = true where id = #{parent_id}")
  end
end

Post.raw_tag_match("transparent_background").find_each do |post|
  upload = Upload.new
  upload.file_ext = post.file_ext
  upload.image_width = post.image_width
  upload.image_height = post.image_height
  upload.md5 = post.md5
  upload.generate_resizes(post.file_path)
  post.distribute_files
end
