# frozen_string_literal: true

# This component is used to render a ugoira. It provides controls for playing the ugoira and for switching between the
# webm sample and the original ugoira.
class UgoiraComponent < ApplicationComponent
  delegate :play_icon, :pause_icon, :expand_icon, :minimize_icon, :gear_icon, :check_icon, to: :helpers

  attr_reader :media_asset, :default_quality, :html_options

  # @param media_asset [MediaAsset] The media asset to be displayed.
  # @param default_quality [Symbol] `:original` to display the original ugoira file by default, or `:sample` to display the webm sample.
  # @param html [Hash] HTML options for the <div class="ugoira-container"> element.
  def initialize(media_asset, default_quality: :original, html: {})
    super
    @media_asset = media_asset
    @default_quality = default_quality.to_s.inquiry
    @html_options = html
  end

  def frame_delays
    media_asset.media_metadata.metadata["Ugoira:FrameDelays"]
  end

  def frame_offsets
    media_asset.media_metadata.metadata["Ugoira:FrameOffsets"]
  end
end
