#!/usr/bin/env ruby

require_relative "base"

CurrentUser.user = User.system
fix = ENV.fetch("FIX", "false").truthy?

Post.where_regex(:source, "^https?://").where(source_name: nil, source_id: nil).find_each do |post|
  post.parse_source_id
  if post.changed?
    puts ({
      id: post.id,
      source: post.source,
      source_name: post.source_name,
      source_id: post.source_id,
    })
    post.save! if fix
  end
end
