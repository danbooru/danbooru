# frozen_string_literal: true

# A component for showing a full-sized image or video for a media asset.
class MediaAssetComponent < ApplicationComponent
  attr_reader :media_asset

  delegate :image_width, :image_height, :variant, :is_image?, :is_video?, :is_ugoira?, :is_flash?, to: :media_asset

  def initialize(media_asset:)
    super
    @media_asset = media_asset
  end
end
