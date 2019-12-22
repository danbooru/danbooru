#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

Note.update_all("x = 0", "x < 0")
Note.update_all("y = 0", "y < 0")
Note.update_all("x = 0", "x > (select _.image_width from posts _ where _.id = notes.post_id limit 1)")
Note.update_all("y = 0", "y > (select _.image_height from posts _ where _.id = notes.post_id limit 1)")

# Note.where("x = 0").find_each do |note|
#   note.update_column(:x, note.versions.last.x) if note.versions.last.x > 0
# end

# Note.where("y = 0").find_each do |note|
#   note.update_column(:y, note.versions.last.y) if note.versions.last.y > 0
# end

Post.where("created_at >= '2013-02-01'").select("id, score, up_score, down_score").find_each do |post|
  fav_count = Favorite.where("post_id = #{post.id}").joins("join users on favorites.user_id = users.id").where("users.level >= ?", User::Levels::GOLD).count
  revised_score = post.up_score + post.down_score + fav_count
  puts "#{post.id}: #{post.score} -> #{revised_score}" if post.score != revised_score
  post.update_column(:score, revised_score)
end; true

Post.where("is_deleted = true and created_at >= '2013-02-01'").find_each do |post|
  if post.flags.empty?
    post.flags.create!(:reason => "Unapproved in three days", :is_resolved => true)
  end
end
