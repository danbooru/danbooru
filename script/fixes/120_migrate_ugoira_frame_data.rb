#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  MediaMetadata.joins(:media_asset).where(media_asset: { file_ext: "zip" }).find_each do |meta|
    frame_data = PixivUgoiraFrameData.find_by(md5: meta.media_asset.md5)

    if frame_data.nil?
      puts "Missing frame data: #{meta.media_asset.md5}"
      next
    elsif meta.metadata["Ugoira:FrameDelays"] == frame_data.frame_delays
      next
    end

    json = meta.metadata.as_json.merge("Ugoira:FrameDelays" => frame_data.frame_delays)
    meta.update!(metadata: json) if ENV.fetch("FIX", "false").truthy?

    puts meta.as_json
  end
end
