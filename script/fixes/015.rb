#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

Pool.find_each do |pool|
  if pool.versions.count == 0
    pool.create_version(true)
  end
end

ForumTopic.find_each do |topic|
  last = topic.posts.last
  topic.update_column(:updater_id, last.creator_id) if topic.updater_id != last.creator_id
  topic.update_column(:updated_at, last.updated_at) if topic.updated_at != last.updated_at
end

admin = User.admins.first

CurrentUser.scoped(admin, "127.0.0.1") do
  Post.where("created_at >= ?", "2013-02-01").find_each do |post|
    if post.tag_string != post.versions.last.tag_string
      post.create_version(true)
    end
  end
end
