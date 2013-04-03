#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

1.upto(2) do |i|
  Post.where("source like ?", "http://i#{i}.pixiv.net%").find_each do |post|
    post.parse_pixiv_id
    post.update_column(:pixiv_id, post.pixiv_id) if post.pixiv_id.present?
  end
end

Post.where("source like ?", "http://www.pixiv.net%").find_each do |post|
  post.parse_pixiv_id
  post.update_column(:pixiv_id, post.pixiv_id) if post.pixiv_id.present?
end

Post.where("source like ?", "http://img%.pixiv.net/img/%").find_each do |post|
  post.parse_pixiv_id
  post.update_column(:pixiv_id, post.pixiv_id) if post.pixiv_id.present?
end
