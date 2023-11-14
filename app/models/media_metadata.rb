# frozen_string_literal: true

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

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :media_asset, :metadata], current_user: current_user)
    q.apply_default_order(params)
  end

  def file=(file_or_path)
    self.metadata = MediaFile.open(file_or_path).metadata
  end

  def metadata
    ExifTool::Metadata.new(self[:metadata])
  end

  def frame_delays
    metadata["Ugoira:FrameDelays"].to_a
  end

  def self.available_includes
    [:media_asset]
  end
end
