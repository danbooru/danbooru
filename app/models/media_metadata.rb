# MediaMetadata represents the EXIF and other metadata associated with a
# MediaAsset (an uploaded image or video file). The `metadata` field contains a
# JSON hash of the file's metadata as returned by ExifTool.
#
# @see ExifTool
# @see https://exiftool.org/TagNames/index.html
class MediaMetadata < ApplicationRecord
  self.table_name = "media_metadata"

  attribute :id
  attribute :created_at
  attribute :updated_at
  attribute :media_asset_id
  attribute :metadata
  belongs_to :media_asset

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :media_asset, :metadata)
    q = q.apply_default_order(params)
    q
  end

  def file=(file_or_path)
    self.metadata = MediaFile.open(file_or_path).metadata
  end
end
