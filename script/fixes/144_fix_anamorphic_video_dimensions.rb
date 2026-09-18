#!/usr/bin/env ruby

# Fix dimensions and samples of MP4/WebM videos with a non-square pixel aspect ratio (PAR).

require_relative "base"

ActiveRecord::Base.logger = nil # silence SQL query logging so it doesn't drown out the puts below
CurrentUser.user = User.system
condition = ENV.fetch("COND", "TRUE")
fix = ENV.fetch("FIX", "false").truthy?

MediaAsset.active
          .where(file_ext: %w[mp4 webm])
          .joins(:media_metadata)
          .where(<<~SQL.squish)
            EXISTS (
              SELECT 1 FROM jsonb_each_text(media_metadata.metadata) AS tags(name, value)
              WHERE tags.name LIKE 'Track%:PixelAspectRatio' AND tags.value != '1:1'
            )
          SQL
          .where(condition)
          .parallel_find_each(order: :asc) do |asset|
  variant = asset.variant(:original)
  media_file = variant.open_file

  if media_file.nil?
    puts ({ id: asset.id, error: "file doesn't exist", path: variant.file_path }).to_json
    next
  end

  # Setting `file` recalculates the width and height (among other things, though only the width and height
  # should actually change here).
  asset.file = media_file
  asset.post.assign_attributes(image_width: asset.image_width, image_height: asset.image_height) if asset.post.present?

  needs_fix = asset.changed?
  puts ({ id: asset.id, needs_fix: needs_fix, **asset.changes }).to_json

  if fix && needs_fix
    # regenerate_files! writes to external storage and can't be made transactional, so it runs after the DB
    # changes commit. This way we never write new files for a DB change that didn't actually persist.
    ApplicationRecord.transaction do
      asset.post.save! if asset.post&.changed?
      asset.save!
    end

    asset.regenerate_files!(media_file)
  end

  media_file.close
end
