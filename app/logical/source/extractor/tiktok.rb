# frozen_string_literal: true

# TikTok has no public API, and its web API (/api/item/detail) requires signed requests, so we read the post data
# embedded in the HTML page instead.
#
# @see Source::URL::Tiktok
class Source::Extractor::Tiktok < Source::Extractor
  def image_urls
    if parsed_url.image_url?
      [url]
    else
      images = item.dig(:imagePost, :images).to_a.filter_map { |image| image.dig(:imageURL, :urlList, 0) }
      images.presence || [video_url(item)].compact_blank
    end
  end

  def page_url
    if item[:imagePost].present?
      "https://www.tiktok.com/@#{username}/photo/#{post_id}"
    elsif item.present?
      "https://www.tiktok.com/@#{username}/video/#{post_id}"
    else
      parsed_url.page_url || parsed_referer&.page_url
    end
  end

  def profile_url
    "https://www.tiktok.com/@#{username}" if username.present?
  end

  def username
    item.dig(:author, :uniqueId) || parsed_url.username || parsed_referer&.username
  end

  def display_name
    item.dig(:author, :nickname)
  end

  def published_at
    Time.zone.at(item[:createTime].to_i) if item[:createTime].present?
  end

  def tags
    item[:textExtra].to_a.pluck(:hashtagName).compact_blank.uniq.map do |tag|
      [tag, "https://www.tiktok.com/tag/#{Danbooru::URL.escape(tag)}"]
    end
  end

  def artist_commentary_title
    item.dig(:imagePost, :title)
  end

  def artist_commentary_desc
    item[:desc]
  end

  def dtext_artist_commentary_desc
    DText.from_plaintext(artist_commentary_desc)
  end

  def post_id
    parsed_url.work_id || parsed_referer&.work_id
  end

  # Photo pages (/@user/photo/:id) don't include the post data, but video pages do, even for photo posts.
  def page_data_url
    "https://www.tiktok.com/@#{parsed_url.username || parsed_referer&.username}/video/#{post_id}" if post_id.present?
  end

  memoize def page
    parsed_get(page_data_url)
  end

  memoize def item(page = self.page)
    json = page&.at("#__UNIVERSAL_DATA_FOR_REHYDRATION__")&.text&.parse_json || {}
    json.dig(:__DEFAULT_SCOPE__, :"webapp.video-detail", :itemInfo, :itemStruct) || {}
  end

  def video_url(item)
    return nil if item[:imagePost].present?

    # `playAddr` is the web player's default version, which isn't always the highest resolution.
    # `bitrateInfo` lists all available versions.
    largest_video = item.dig(:video, :bitrateInfo).to_a.max_by { |video| [video.dig(:PlayAddr, :Width).to_i * video.dig(:PlayAddr, :Height).to_i, video[:Bitrate].to_i] }
    largest_video&.dig(:PlayAddr, :UrlList, 0) || item.dig(:video, :playAddr)
  end

  # Video URLs only work with the tt_chain_token cookie set by the page request that returned them. The cookie is kept
  # in the HTTP session, so we download the video URL from our own page request instead of the given URL.
  def download_file!(download_url)
    return super unless Source::URL.parse(download_url).try(:video_url?)

    begin
      super(video_url(item))
    rescue Danbooru::Http::DownloadError => e
      raise unless e.response&.status == 403

      # TikTok sometimes sets a token that doesn't work. If that happens, fetch the page again without the token to get
      # a new token and a new video URL.
      new_page = http.cookies(tt_chain_token: "").parsed_get(page_data_url)
      super(video_url(item(new_page)))
    end
  end
end
