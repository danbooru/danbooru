# frozen_string_literal: true

class UgoiraComponent < ApplicationComponent
  delegate :play_icon, :pause_icon, :expand_icon, :minimize_icon, to: :helpers

  attr_reader :media_asset, :file_url, :html_options

  def initialize(media_asset, file_url:, html: {})
    super
    @media_asset = media_asset
    @file_url = file_url
    @html_options = html
  end

  def frame_delays
    media_asset.media_metadata.metadata["Ugoira:FrameDelays"]
  end
end
