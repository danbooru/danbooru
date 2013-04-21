#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

Comment.find_each do |comment|
  if !Post.exists?("id = #{comment.post_id}")
    comment.destroy
  end
end ; true

Post.find_each do |post|
  post.update_column(:fav_count, Favorite.where("post_id = #{post.id}").count)
end

Post.select("id, score, up_score, down_score, fav_count").find_each do |post|
  post.update_column(:score, post.up_score + post.down_score)
end ; true
