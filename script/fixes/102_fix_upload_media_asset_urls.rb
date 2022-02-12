#!/usr/bin/env ruby

require_relative "base"

UploadMediaAsset.includes(:upload, :media_asset).where(source_url: "").find_each do |uma|
  upload = uma.upload

  if upload.source_strategy.present?
    source_url = uma.upload.source_strategy.image_url
    page_url = uma.upload.source_strategy.page_url
  else
    file_ext = uma.media_asset.file_ext
    source_url = "file://unknown.#{file_ext}"
  end

  raise "No source url for #{page_url}" if source_url.blank?

  uma.update_columns(source_url: source_url, page_url: page_url)
  puts ({ upload_id: uma.upload.id, upload_media_asset_id: uma.id, source_url: source_url, page_url: page_url }).to_json
rescue Exception => e
  puts ({ upload_id: uma.upload.id, upload_media_asset_id: uma.id, error: e.message }).to_json
end
