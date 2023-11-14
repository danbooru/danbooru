#!/usr/bin/env ruby

require_relative "base"

MediaAsset.where(file_key: nil).parallel_find_each do |asset|
  asset.update_columns(file_key: MediaAsset.generate_file_key)
  puts "id=#{asset.id} file_key=#{asset.file_key}"
end
