# frozen_string_literal: true

# A component for showing a thumbnail preview for a media asset.
# XXX This is mostly duplicated from PostPreviewComponent.
class MediaAssetPreviewComponent < ApplicationComponent
  DEFAULT_SIZE = 180

  attr_reader :media_asset, :size, :fit, :link_target, :shrink_to_fit, :save_data
  delegate :duration_to_hhmmss, :sound_icon, to: :helpers

  renders_one :footer

  # @param media_asset [MediaAsset] The media asset to show the thumbnail for.
  # @param size [String] The size of the thumbnail. One of 150, 180, 225, 270, or 360.
  # @param link_target [ApplicationRecord] What the thumbnail links to (default: the media asset).
  # @param shrink_to_fit [Boolean] If true, allow the thumbnail to shrink to fit the containing element.
  #   If false, make the thumbnail a fixed width and height.
  # @param save_data [Boolean] If true, save data by not serving higher quality thumbnails
  #   on 2x pixel density displays. Default: false.
  def initialize(media_asset:, size: DEFAULT_SIZE, link_target: media_asset, shrink_to_fit: true, save_data: CurrentUser.save_data)
    super
    @media_asset = media_asset
    @size = size.presence&.to_i || DEFAULT_SIZE
    @link_target = link_target
    @save_data = save_data
    @shrink_to_fit = shrink_to_fit
  end

  def variant
    case size
    when 150, 180
      media_asset.variant("180x180")
    when 225, 270, 360
      media_asset.variant("360x360")
    when 720
      media_asset.variant("720x720")
    else
      raise NotImplementedError
    end
  end
end
