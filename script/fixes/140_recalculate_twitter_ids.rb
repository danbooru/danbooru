#!/usr/bin/env ruby

require_relative "base"

Post.where("source LIKE ? OR source LIKE ?", "%twitter.com/%/status/%", "%x.com/%/status/%").find_each do |post|
  twitter_id = post.source[/status\/(\d+)/, 1]
  next unless twitter_id

  post.update_column(:twitter_id, twitter_id.to_i)
end
