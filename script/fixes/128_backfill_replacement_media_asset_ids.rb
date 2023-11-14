#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  fix = ENV.fetch("FIX", "false").truthy?
  cond = ENV.fetch("COND", "TRUE")

  replacements = PostReplacement.where("(media_asset_id IS NULL AND md5 IS NOT NULL) OR (old_media_asset_id IS NULL AND old_md5 IS NOT NULL)").where(cond)

  replacements.find_each do |replacement|
    new_media_asset = MediaAsset.active.find_by(md5: replacement.md5)
    old_media_asset = MediaAsset.active.find_by(md5: replacement.old_md5)

    replacement.media_asset = new_media_asset if replacement.media_asset.nil?
    replacement.old_media_asset = old_media_asset if replacement.old_media_asset.nil?

    puts ({ replacement: replacement.id, md5: replacement.md5, old_md5: replacement.old_md5, changes: replacement.changes, }).to_json
    replacement.save!(touch: false) if fix && replacement.changed?
  end
end
