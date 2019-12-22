#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

CurrentUser.user = User.admins.first
CurrentUser.ip_addr = "127.0.0.1"

Post.where("file_size = 0").find_each do |post|
  post.expunge!
end

Post.where("file_size = 8").find_each do |post|
  if File.read(post.file_path) == "danbooru"
    post.expunge!
  end
end
