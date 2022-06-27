# frozen_string_literal: true

# A component for showing a thumbnail preview for a media asset.
# XXX This is mostly duplicated from PostPreviewComponent.
class MediaAssetPreviewComponent < ApplicationComponent
  DEFAULT_SIZE = 180

  attr_reader :media_asset, :size, :link_target, :classes, :inner_classes, :html, :save_data
  delegate :duration_to_hhmmss, :sound_icon, to: :helpers

  renders_one :header
  renders_one :missing_image
  renders_one :footer

  # @param media_asset [MediaAsset] The media asset to show the thumbnail for.
  # @param size [String] The size of the thumbnail. One of 150, 180, 225, 270, or 360.
  # @param link_target [ApplicationRecord] What the thumbnail links to (default: the media asset).
  # @param save_data [Boolean] If true, save data by not serving higher quality thumbnails
  #   on 2x pixel density displays. Default: false.
  def initialize(media_asset:, size: DEFAULT_SIZE, link_target: media_asset, classes: [], inner_classes: [], html: {}, save_data: CurrentUser.save_data)
    super
    @media_asset = media_asset
    @size = size.presence&.to_i || DEFAULT_SIZE
    @link_target = link_target
    @classes = classes
    @inner_classes = inner_classes
    @html = html
    @save_data = save_data
  end

  def variant
    case size
    when 150, 180
      media_asset.variant("180x180")
    when 225, 270, 360
      media_asset.variant("360x360")
    when 540, 720
      media_asset.variant("720x720")
    else
      raise NotImplementedError
    end
  end
end
