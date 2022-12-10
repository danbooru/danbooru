# frozen_string_literal: true

# A component for showing a full-sized image or video for a media asset.
class MediaAssetComponent < ApplicationComponent
  attr_reader :media_asset, :current_user, :outer_classes, :inner_classes, :dynamic_height, :scroll_on_zoom

  delegate :image_width, :image_height, :variant, :is_image?, :is_video?, :is_ugoira?, :is_flash?, to: :media_asset

  renders_one :header
  renders_one :footer

  def initialize(media_asset:, current_user:, outer_classes: "", inner_classes: "", dynamic_height: false, scroll_on_zoom: false)
    super
    @media_asset = media_asset
    @current_user = current_user
    @outer_classes = outer_classes
    @inner_classes = inner_classes
    @dynamic_height = dynamic_height
    @scroll_on_zoom = scroll_on_zoom
  end
end
