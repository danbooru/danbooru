#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

Post.where(:file_ext => "swf").find_each do |post|
  image_spec = ImageSpec.new(post.file_path)
  post.image_width = image_spec.width
  post.image_height = image_spec.height
  post.update_column(:image_width, post.image_width)
  post.update_column(:image_height, post.image_height)
end
