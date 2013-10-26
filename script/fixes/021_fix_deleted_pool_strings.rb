#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

CurrentUser.user = User.admins.first
CurrentUser.ip_addr = "127.0.0.1"

CurrentUser.without_safe_mode do
  Pool.deleted.where("post_count > 0").find_each do |pool|
    Post.where("id in (?)", pool.post_id_array).tag_match("-pool:#{pool.id}").find_each do |post|
      post.add_pool!(pool, true)
    end
  end
end
