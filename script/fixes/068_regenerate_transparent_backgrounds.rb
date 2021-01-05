#!/usr/bin/env ruby

require_relative "../../config/environment"

Post.system_tag_match("transparent_background id:<=1361925").find_each do |post|
  post.regenerate_later!("resizes", User.system)
end
