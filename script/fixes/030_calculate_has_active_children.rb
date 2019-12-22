#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

CurrentUser.user = User.admins.first
CurrentUser.ip_addr = "127.0.0.1"

execute_sql("UPDATE posts SET has_active_children = true WHERE id IN (SELECT p.parent_id FROM posts p WHERE p.parent_id IS NOT NULL AND p.is_deleted = FALSE)")
execute_sql("UPDATE posts SET has_active_children = false WHERE has_active_children IS NULL")

execute_sql("ALTER TABLE posts ALTER COLUMN has_active_children SET NOT NULL")
