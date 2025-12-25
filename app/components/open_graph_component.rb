# frozen_string_literal: true

# Render Open Graph metatags for an image or video.
#
# @see https://ogp.me/
# @see https://www.opengraph.xyz/
# @see https://developers.facebook.com/docs/sharing/webmasters/
# @see https://developers.facebook.com/tools/debug/
# @see https://developer.twitter.com/en/docs/twitter-for-websites/cards/guides/getting-started
# @see https://developers.google.com/search/docs/appearance/structured-data
# @see https://search.google.com/test/rich-results
# @see https://validator.schema.org/
class OpenGraphComponent < ApplicationComponent
  extend Memoist

  attr_reader :media_asset, :current_user

  delegate :json_ld_tag, :page_title, :meta_description, to: :helpers
  delegate :is_image?, :is_video?, :is_ugoira?, :image_width, :image_height, :file_size, :mime_type, :variant, :has_variant?, to: :media_asset

  def initialize(media_asset:, current_user:)
    @media_asset = media_asset
    @current_user = current_user
  end

  memoize def video_url
    if is_video?
      variant("original").file_url
    elsif is_ugoira?
      variant("sample").file_url
    end
  end

  memoize def image_url
    if is_image?
      variant("original").file_url
    elsif is_video? || is_ugoira?
      variant("720x720").file_url
    end
  end

  # https://developer.twitter.com/en/docs/twitter-for-websites/cards/overview/summary-card-with-large-image
  #
  # Images for this Card support an aspect ratio of 2:1 with minimum dimensions of 300x157 or maximum of 4096x4096
  # pixels. Images must be less than 5MB in size. JPG, PNG, WEBP and GIF formats are supported. Only the first frame of
  # an animated GIF will be used. SVG is not supported.
  memoize def twitter_image_url
    if is_image? && file_size < 5.megabytes && image_width <= 4096 && image_height <= 4096
      variant("original").file_url
    elsif has_variant?("720x720")
      variant("720x720").file_url
    end
  end

  # https://developers.google.com/search/docs/data-types/video#video-object
  def json_ld_video_data
    json_ld_tag({
      "@context": "https://schema.org",
      "@type": "VideoObject",
      name: page_title,
      description: meta_description,
      uploadDate: (media_asset.post || media_asset).created_at.iso8601,
      duration: media_asset.duration.ceil.seconds.iso8601,
      thumbnailUrl: image_url,
      contentUrl: video_url,
    })
  end
end
