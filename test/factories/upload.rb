require 'fileutils'

Factory.define(:upload) do |f|
  f.rating "s"
  f.uploader {|x| x.association(:user)}
  f.uploader_ip_addr "127.0.0.1"
  f.tag_string "special"
  f.status "pending"
end

Factory.define(:downloadable_upload, :parent => :upload) do |f|
  f.source "http://www.google.com/intl/en_ALL/images/logo.gif"
end

Factory.define(:uploaded_jpg_upload, :parent => :upload) do |f|
  f.file_path do
    FileUtils.cp("#{Rails.root}/test/files/test.jpg", "#{Rails.root}/tmp")
    "#{Rails.root}/tmp/test.jpg"
  end
end

Factory.define(:uploaded_large_jpg_upload, :parent => :upload) do |f|
  f.file_ext "jpg"
  f.content_type "image/jpeg"
  f.file_path do
    FileUtils.cp("#{Rails.root}/test/files/test-large.jpg", "#{Rails.root}/tmp")
    "#{Rails.root}/tmp/test-large.jpg"
  end
end

Factory.define(:uploaded_png_upload, :parent => :upload) do |f|
  f.file_path do
    FileUtils.cp("#{Rails.root}/test/files/test.png", "#{Rails.root}/tmp")
    "#{Rails.root}/tmp/test.png"
  end
end

Factory.define(:uploaded_gif_upload, :parent => :upload) do |f|
  f.file_path do
    FileUtils.cp("#{Rails.root}/test/files/test.gif", "#{Rails.root}/tmp")
    "#{Rails.root}/tmp/test.gif"
  end
end
