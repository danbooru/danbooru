# frozen_string_literal: true

# @see Source::URL::Xiaohongshu
# @see https://github.com/NanmiCoder/MediaCrawler/blob/main/media_platform/xhs/client.py
# @see https://github.com/JoeanAmier/XHS-Downloader
class Source::Extractor::Xiaohongshu < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    elsif note[:type] == "video"
      key = note.dig(:video, :consumer, :originVideoKey)
      video_url = "https://sns-video-bd.xhscdn.com/#{key}" if key.present?
      [video_url].compact
    else
      note["imageList"].to_a.pluck("urlDefault").map do |url|
        Source::URL.parse(url).try(:full_image_url) || url
      end
    end
  end

  def page_url
    page_url_from_api || page_url_from_parsed_urls
  end

  def page_url_from_api
    url = if user_id.present? && post_id.present?
      "https://www.xiaohongshu.com/user/profile/#{user_id}/#{post_id}"
    elsif post_id.present?
      "https://www.xiaohongshu.com/explore/#{post_id}"
    end

    xsec_token = parsed_url.xsec_token || parsed_referer&.xsec_token
    if url.present? && xsec_token.present?
      url += "?xsec_token=#{xsec_token}"
    end
  end

  def page_url_from_parsed_urls
    parsed_url.page_url || parsed_referer&.page_url
  end

  def profile_url
    "https://www.xiaohongshu.com/user/profile/#{user_id}" if user_id.present?
  end

  def display_name
    note.dig("user", "nickname")
  end

  def tags
    note["tagList"].to_a.pluck("name").map do |tag|
      [tag, "https://www.xiaohongshu.com/search_result/?keyword=#{Danbooru::URL.escape(tag)}"]
    end
  end

  def artist_commentary_title
    page&.at('#detail-title')&.text&.strip
  end

  def artist_commentary_desc
    page&.at('#detail-desc')&.to_html&.gsub("\n", "<br>")
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: "https://www.xiaohongshu.com")&.strip
  end

  def post_id
    parsed_url.post_id || parsed_referer&.post_id
  end

  def user_id
    parsed_url.user_id || parsed_referer&.user_id || note.dig("user", "userId")
  end

  memoize def note
    page_json.dig("note", "noteDetailMap", post_id, "note") || {}
  end

  memoize def page
    http.cache(1.minute).parsed_get(page_url_from_parsed_urls)
  end

  memoize def page_json
    page&.at('script[text()*="__INITIAL_STATE__"]')&.text&.slice(/{.*}/)&.gsub("undefined", "null")&.parse_json || {}
  end

  def http_downloader
    # http://sns-webpic-qc.xhs.cdn.com URLs fail with a spoofed referer. Ex: http://sns-webpic-qc.xhscdn.com/202405210748/f4ece3f93e230347cacc53e8628c35be/spectrum/1040g0k030p06mpo4k0005ovbk4n9t3fq5ms4iu0!nd_dft_wlteh_jpg_3
    super.disable_feature(:spoof_referrer)
  end
end
