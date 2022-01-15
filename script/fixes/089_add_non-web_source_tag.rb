#!/usr/bin/env ruby

require_relative "base"

CurrentUser.scoped(User.system) do
  Post.system_tag_match("-source:none -source:http://* -source:https://* -non-web_source").find_each do |post|
    puts "post ##{post.id}: adding non-web_source"
    post.save!
  end

  Post.system_tag_match("source:none non-web_source").find_each do |post|
    puts "post ##{post.id}: removing non-web_source"
    post.save!
  end

  Post.system_tag_match("source:http://* non-web_source").find_each do |post|
    puts "post ##{post.id}: removing non-web_source"
    post.save!
  end

  Post.system_tag_match("source:https://* non-web_source").find_each do |post|
    puts "post ##{post.id}: removing non-web_source"
    post.save!
  end
end
