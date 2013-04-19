#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

Post.select("id, score, up_score, down_score, fav_count").find_each do |post|
  post.update_column(:score, post.up_score + post.down_score + post.fav_count)
end

Comment.find_each do |comment|
  if !Post.exists?("id = #{comment.post_id}")
    comment.destroy
  end
end

User.where("name like ? or name like ?", "\\_%", "%\\_").each do |user|
  puts "#{user.id}\t#{user.name}\t#{user.level}\t#{user.email}\t#{user.last_logged_in_at}"
end ; true