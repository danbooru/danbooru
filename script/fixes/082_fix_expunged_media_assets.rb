#!/usr/bin/env ruby

require_relative "../../config/environment"

assets = MediaAsset.active

assets.parallel_each do |asset|
  asset.variant(:original).open_file
rescue
  puts "id=#{asset.id} md5=#{asset.md5} file_ext=#{asset.file_ext} status=expunged"
  asset.update!(status: :expunged)
end
