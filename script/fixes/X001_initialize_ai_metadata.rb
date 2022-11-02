#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  CurrentUser.scoped(User.system) do
    Post.anon_tag_match("exif:PNG:Comment or exif:PNG:Parameters -has:metadata").order("id asc").each do |post|
      metadata = post.create_ai_metadata
      metadata.save!
      puts metadata.to_json
    end
  end
end
