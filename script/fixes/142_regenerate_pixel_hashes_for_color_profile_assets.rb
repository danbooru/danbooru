#!/usr/bin/env ruby

# Regenerate the pixel hash for every media asset with an embedded color
# profile, or a JPEG Adobe APP14 color transform marker.

require_relative "base"

CurrentUser.user = User.system
condition = ENV.fetch("COND", "TRUE")
fix = ENV.fetch("FIX", "false").truthy?

METADATA_KEYS = ["ICC_Profile:ProfileDescription", "Adobe:ColorTransform"].freeze

MediaAsset.active
          .joins(:media_metadata)
          .where("media_metadata.metadata ?| array[:keys]", keys: METADATA_KEYS)
          .where(condition)
          .parallel_find_each(order: :asc) do |asset|
  variant = asset.variant(:original)
  media_file = variant.open_file

  if media_file.nil?
    puts ({ id: asset.id, error: "file doesn't exist", path: variant.file_path }).to_json
    next
  end

  old_pixel_hash = asset.pixel_hash
  new_pixel_hash = media_file.pixel_hash
  media_file.close

  needs_fix = old_pixel_hash != new_pixel_hash
  puts ({ id: asset.id, old_pixel_hash: old_pixel_hash, new_pixel_hash: new_pixel_hash, needs_fix: needs_fix }).to_json

  next unless fix && needs_fix

  asset.pixel_hash = new_pixel_hash

  asset.save!
end
