#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

Post.select("id, score, up_score, down_score, fav_count").find_each do |post|
  post.update_column(:score, post.up_score - post.down_score + post.fav_count)
end
