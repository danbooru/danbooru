# frozen_string_literal: true

# This component is used to render a video or ugoira. It provides controls for playing the video and for switching between
# the media asset's variants.
class VideoComponent < ApplicationComponent
  delegate :play_icon, :pause_icon, :expand_icon, :minimize_icon, :gear_icon, :check_icon,
           :volume_high_icon, :volume_medium_icon, :volume_low_icon, :sound_off_icon, :no_sound_icon, to: :helpers

  attr_reader :media_asset, :default_quality, :variants, :autoplay, :muted, :start_time, :tagged_filenames, :html_options

  # @param media_asset [MediaAsset] The media asset to be displayed.
  # @param default_quality [Symbol] `:original` to display the original file by default, or `:sample` to display the sample.
  # @param autoplay [Boolean] Whether the video should play by default.
  # @param muted [Boolean] Whether the video should be muted by default.
  # @param start_time [Float] The time (in seconds) at which the video should start playing. By default, the video will start from the beginning.
  # @param tagged_filenames [Boolean] Whether to include the post's tags in the video filenames.
  # @param html [Hash] HTML options for the <div class="video-component"> element.
  def initialize(media_asset, default_quality: :original, autoplay: true, muted: false, start_time: 0, tagged_filenames: false, html: {}) # rubocop:disable Metrics/ParameterLists
    super
    @media_asset = media_asset
    @variants = [:sample, :full, :original].select { |q| media_asset.has_variant?(q) }
    @default_quality = default_quality.to_sym
    @default_quality = :original unless @variants.include?(@default_quality)
    @autoplay = autoplay
    @muted = muted
    @start_time = start_time
    @tagged_filenames = tagged_filenames
    @html_options = html
  end

  # @return [String] The URL of the variant, with the post's tags in the filename if `tagged_filenames` is true.
  def file_url(variant)
    slug = media_asset.post&.seo_tags if tagged_filenames
    variant.file_url(slug.to_s)
  end

  def frame_delays
    media_asset.media_metadata.metadata["Ugoira:FrameDelays"]
  end

  def frame_offsets
    media_asset.media_metadata.metadata["Ugoira:FrameOffsets"]
  end

  def variant_name(variant)
    if variant == :sample && media_asset.is_ugoira?
      "WebM"
    else
      variant.to_s.titleize
    end
  end
end
