# frozen_string_literal: true

class UgoiraComponent < ApplicationComponent
  delegate :play_icon, :pause_icon, :expand_icon, :minimize_icon, :gear_icon, :check_icon, to: :helpers

  attr_reader :media_asset, :default_quality, :html_options

  def initialize(media_asset, default_quality: :original, html: {})
    super
    @media_asset = media_asset
    @default_quality = default_quality.to_s.inquiry
    @html_options = html
  end

  def frame_delays
    media_asset.media_metadata.metadata["Ugoira:FrameDelays"]
  end
end
