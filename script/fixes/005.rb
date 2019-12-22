#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

Post.where("image_width > 850").find_each do |post|
  if !post.is_image?
    next
  end

  if !File.exist?(post.file_path)
    puts "NOT FOUND: #{post.id}"
    next
  end

  if File.size(post.file_path) == 0
    puts "NOT FOUND: #{post.id}"
    next
  end

  resize = false

  if !File.exist?(post.large_file_path)
    puts "LARGE NOT FOUND: #{post.id}"
    resize = true
  end

  if File.size(post.large_file_path) == 0
    puts "LARGE NOT FOUND: #{post.id}"
    resize = true
  end

  if !resize
    File.open(post.large_file_path, "r") do |file|
      image_size = ImageSize.new(file)

      if (image_size.width - post.large_image_width).abs > 5
        puts "MISMATCH: #{post.id}: #{image_size.width} != #{post.large_image_width}"
        resize = true
      end
    end
  end

  if resize
    puts "RESIZING #{post.id}"
    upload = Upload.new
    upload.file_ext = post.file_ext
    upload.image_width = post.image_width
    upload.image_height = post.image_height
    upload.md5 = post.md5
    begin
      upload.generate_resizes(post.file_path)
      post.distribute_files
    rescue Magick::ImageMagickError
      puts "RESIZE ERROR #{post.id}"
    end
  end
end
