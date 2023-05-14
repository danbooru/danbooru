#!/usr/bin/env ruby

require_relative "../../config/environment"

MediaAsset.active.where.not(file_ext: "swf").parallel_find_each do |media_asset|
  media_file = media_asset.variant(:original).open_file
  media_asset.variant("180x180").store_file!(media_file)
  media_asset.variant("360x360").store_file!(media_file)
  media_asset.variant("720x720").store_file!(media_file)
  puts "id=#{media_asset.id}"
rescue StandardError => e
  STDERR.puts "id=#{media_asset.id} status=FAILED e='#{e}'"
ensure
  media_file&.close
end
