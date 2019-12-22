#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

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

PoolVersion.where("post_ids like '% 10 %' and post_ids like '% 12 %' and post_ids like '% 13 %' and post_ids like '% 14 %'").find_each do |pool_version|
  cleaned_post_ids = pool_version.post_ids.scan(/(\d+) \d+/).join(" ")
  pool_version.update_column(:post_ids, cleaned_post_ids)
end; true
