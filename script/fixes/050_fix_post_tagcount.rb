#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

CurrentUser.user = User.system
CurrentUser.ip_addr = "127.0.0.1"

Post.without_timeout do
  Post.where("updated_at > ? ", Date.parse("2017-11-12")).find_each do |post|
    Post.fix_post_counts(post)
  end
end

Tag.without_timeout do
  Tag.where(category: Tag.categories.meta).find_each do |tag|
    Post.raw_tag_match(tag.name).where("true").find_each do |post|
      Post.fix_post_counts(post)
    end
  end
end
