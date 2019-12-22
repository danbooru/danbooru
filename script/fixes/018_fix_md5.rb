#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

Post.where("id in (?)", Pool.find(203).post_id_array).find_each do |post|
  correct_md5 = Digest::MD5.file(post.file_path).hexdigest
  post.update_attribute(:md5, correct_md5)
end
