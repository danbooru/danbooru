#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

User.where("post_upload_count > 0").find_each do |user|
  puts "fixing upload count for #{user.name}"
  User.where(id: user.id).update_all("post_upload_count = (select count(*) from posts where uploader_id = users.id)")
end

User.where("note_update_count > 0").find_each do |user|
  puts "fixing note count for #{user.name}"
  User.where(id: user.id).update_all("note_update_count = (select count(*) from note_versions where updater_id = users.id)")
end

User.where("post_update_count > 0").find_each do |user|
  puts "fixing update count for #{user.name}"
  User.where(id: user.id).update_all("post_update_count = (select count(*) from post_versions where updater_id = users.id)")
end
