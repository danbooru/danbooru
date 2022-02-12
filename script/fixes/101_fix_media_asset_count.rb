#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  # Fix uploads that have a non-zero media_asset_count but no media assets.
  records = Upload.where("media_asset_count != 0").where.not(id: UploadMediaAsset.select(:upload_id).distinct)
  puts "Fixing #{records.size} records"
  records.update_all(media_asset_count: 0)
end

with_confirmation do
  # Fix uploads that have a media_asset_count inconsistent with the upload_media_assets table.
  records = Upload.find_by_sql(<<~SQL.squish)
    UPDATE uploads
    SET media_asset_count = true_count
    FROM (
      SELECT upload_id, COUNT(*) AS true_count
      FROM upload_media_assets
      GROUP BY upload_id
    ) true_counts
    WHERE uploads.id = upload_id AND uploads.media_asset_count != true_count
    RETURNING uploads.*
  SQL

  puts "Fixing #{records.size} records"
end
