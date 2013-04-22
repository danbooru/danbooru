#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

Comment.find_each do |comment|
  if !Post.exists?("id = #{comment.post_id}")
    puts "deleting comment #{comment.id}"
    comment.destroy
  end
end ; true

Ban.find_each do |ban|
  puts "updating ban for user #{ban.user.id}"
  ban.user.update_attribute(:is_banned, true)
end ; true

ArtistVersion.update_all "is_banned = false"

Artist.find_each do |artist|
  if artist.is_banned?
    puts "updating artist #{artist.id}"
    artist.versions.last.update_column(:is_banned, true)
  end
end ; true

Post.find_each do |post|
  puts "updating post #{post.id}"
  post.update_column(:fav_count, Favorite.where("post_id = #{post.id}").count)
end ; true

User.find_each do |user|
  puts "updating user #{user.id}"
  user.update_column(:favorite_count, Favorite.for_user(user).where("user_id = ?", user.id).count)
end ; true


# Post.select("id, score, up_score, down_score, fav_count").find_each do |post|
#   post.update_column(:score, post.up_score + post.down_score)
# end ; true

