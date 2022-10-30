#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  condition = ENV.fetch("COND", "TRUE")
  fix = ENV.fetch("FIX", "false").truthy?

  MediaAsset.active.where(condition).find_each do |asset|
    variant = asset.variant(:original)
    media_file = variant.open_file

    if media_file.nil?
      puts ({ id: asset.id, error: "file doesn't exist", path: variant.file_path }).to_json
      next
    end

    # Setting `file` updates the metadata if it's different.
    asset.file = media_file
    asset.media_metadata.file = media_file

    old = asset.media_metadata.metadata_was.to_h
    new = asset.media_metadata.metadata.to_h
    metadata_changes = { added_metadata: (new.to_a - old.to_a).to_h, removed_metadata: (old.to_a - new.to_a).to_h }.compact_blank
    puts ({ id: asset.id, **asset.changes, **metadata_changes }).to_json

    if fix
      asset.save! if asset.changed?
      asset.media_metadata.save! if asset.media_metadata.changed?
    end

    media_file.close
  end
end
