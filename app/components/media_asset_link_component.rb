# frozen_string_literal: true

# A component for showing a link to a media asset.
class MediaAssetLinkComponent < ApplicationComponent
  attr_reader :media_asset, :classes

  delegate :image_width, :image_height, :duration, :file_ext, :file_size, to: :media_asset

  delegate :number_to_human_size, :duration_to_hhmmss, to: :helpers

  def initialize(media_asset:, classes: nil)
    super
    @media_asset = media_asset
    @classes = classes
  end
end
