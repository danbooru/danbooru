#!/usr/bin/env ruby

# Fix the width, height, pixel hash, and metadata of PNGs with a real EXIF orientation flag. These used to be
# calculated from the unrotated image; they're now calculated from the rotated image. This also regenerates the
# thumbnail and sample files for these assets, since those were generated from the unrotated image too.
#
# See MediaFile::Image#open_png.

require_relative "base"

CurrentUser.user = User.system
condition = ENV.fetch("COND", "TRUE")
fix = ENV.fetch("FIX", "false").truthy?

MediaAsset.active
          .where(file_ext: "png")
          .joins(:media_metadata)
          .where("media_metadata.metadata->>'IFD0:Orientation' IS NOT NULL")
          .where.not("media_metadata.metadata->>'IFD0:Orientation' = ?", "Horizontal (normal)")
          .where(condition)
          .parallel_find_each(order: :asc) do |asset|
  variant = asset.variant(:original)
  media_file = variant.open_file

  if media_file.nil?
    puts ({ id: asset.id, error: "file doesn't exist", path: variant.file_path }).to_json
    next
  end

  # Setting `file` recalculates the width, height, pixel hash, and metadata.
  asset.file = media_file
  asset.media_metadata.file = media_file
  asset.post.assign_attributes(image_width: asset.image_width, image_height: asset.image_height) if asset.post.present?

  needs_fix = asset.changed? || asset.media_metadata.changed?
  puts ({ id: asset.id, needs_fix: needs_fix, **asset.changes }).to_json

  if fix && needs_fix
    # regenerate_files! writes to external storage and can't be made transactional, so it runs after the DB
    # changes commit. This way we never write new files for a DB change that didn't actually persist.
    ApplicationRecord.transaction do
      asset.post.save! if asset.post&.changed?
      asset.save!
      asset.media_metadata.save!
    end

    asset.regenerate_files!(media_file)
  end

  media_file.close
end
