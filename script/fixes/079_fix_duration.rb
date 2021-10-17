#!/usr/bin/env ruby

require_relative "../../config/environment"

tags = ENV.fetch("TAGS", "animated")
posts = Post.system_tag_match(tags)
posts = posts.joins(:media_asset).where(media_asset: { duration: nil })

posts.find_each do |post|
  media_file = MediaFile.open(post.file(:original), frame_data: post.pixiv_ugoira_frame_data&.data)
  post.media_asset.update!(duration: media_file.duration)
  puts "id=#{post.id}, md5=#{post.md5}, ext=#{post.file_ext}, duration=#{post.media_asset.duration}"
rescue StandardError => e
  puts "error[id=#{post.id}]: #{e}"
end
