#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

CurrentUser.user = User.admins.first
CurrentUser.ip_addr = "127.0.0.1"

CurrentUser.without_safe_mode do
  Post.tag_match("pool:any").find_each do |post|
    post.reload
    post.set_pool_category_pseudo_tags
    Post.where(:id => post.id).update_all(:pool_string => post.pool_string)
  end
end
