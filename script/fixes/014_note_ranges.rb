#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

Note.update_all("x = 0", "x < 0")
Note.update_all("y = 0", "y < 0")
Note.update_all("x = 0", "x > (select _.image_width from posts _ where _.id = notes.id limit 1)")
Note.update_all("y = 0", "y > (select _.image_height from posts _ where _.id = notes.id limit 1)")

Post.where("created_at >= '2013-02-01'").select("id, score, up_score, down_score").find_each do |post|
  fav_count = 
  post.update_column(:score, post.up_score + post.down_score)
end ; true
