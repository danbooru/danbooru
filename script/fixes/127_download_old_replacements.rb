#!/usr/bin/env ruby

require_relative "base"

FIX = ENV.fetch("FIX", "false").truthy?
COND = ENV.fetch("COND", "TRUE")
WORKERS = ENV.fetch("WORKERS", 5).to_i

def download(replacement, md5)
  # url = "https://b2.donmai.us/file/danbooru/original/#{md5[0..1]}/#{md5[2..3}/#{md5}.jpg"
  # image_url = url if Danbooru::Http.head(url)&.status == 200

  url = "https://gelbooru.com/index.php?page=post&s=list&md5=#{md5}"
  image_url = Source::Extractor.find(url).image_urls.first

  upload = Upload.create!(uploader: User.system, source: image_url) if FIX && image_url.present?
  Timeout.timeout(30) { sleep 1 until upload.reload.is_finished? } if upload

  puts ({ replacement: replacement.id, upload: upload&.id, md5: md5, image_url:, duration: (upload.updated_at - upload.created_at if upload) }).to_json
rescue Timeout::Error
  puts ({ error: "upload timed out", replacement: replacement.id, upload: upload&.id, image_url:, }).to_json
end

PostReplacement.where(COND).parallel_find_each(in_processes: WORKERS) do |replacement|
  old_media_asset = MediaAsset.active.find_by(md5: replacement.old_md5)
  new_media_asset = MediaAsset.active.find_by(md5: replacement.md5)

  download(replacement, replacement.old_md5) if old_media_asset.nil? && replacement.old_md5.present?
  download(replacement, replacement.md5) if new_media_asset.nil? && replacement.md5.present?
end
