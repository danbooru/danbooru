#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

CurrentUser.user = User.admins.first
CurrentUser.ip_addr = "127.0.0.1"

CurrentUser.without_safe_mode do
  Post.tag_match("ugoira").where("file_ext = ? AND (image_width > ? OR image_height > ?)", "zip", 1920, 1080).find_each do |post|
    ugoira_service = PixivUgoiraService.new
    ugoira_service.calculate_dimensions(post.file_path)
    post.update_column(:image_width, ugoira_service.width)
    post.update_column(:image_height, ugoira_service.height)
  end
end
