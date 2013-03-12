#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

Post.where("created_at > '2013-02-01'").find_each do |post|
  puts "Fixing #{post.id}"
  post.reload
  post.set_tag_counts
  post.update_column(:tag_count, post.tag_count)
  post.update_column(:tag_count_general, post.tag_count_general)
  post.update_column(:tag_count_artist, post.tag_count_artist)
  post.update_column(:tag_count_copyright, post.tag_count_copyright)
  post.update_column(:tag_count_character, post.tag_count_character)
end
