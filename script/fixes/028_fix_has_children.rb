#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

CurrentUser.user = User.admins.first
CurrentUser.ip_addr = "127.0.0.1"

CurrentUser.without_safe_mode do
  Post.update_all("has_children = false", "has_children = true")
  Post.update_all("has_children = true", "exists (select 1 from posts _ where _.parent_id = posts.id limit 1)")
end
