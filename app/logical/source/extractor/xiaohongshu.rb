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
      note["imageList"].to_a.flat_map do |image|
        if image["stream"].present?
          image.dig(:stream, :h264).to_a.pluck("masterUrl")
        else
          Source::URL.parse(image["url"]).try(:full_image_url) || image["url"]
        end
      end
    end
  end

  def page_url
    parsed_url.page_url || parsed_referer&.page_url
  end

  def profile_url
    "https://www.xiaohongshu.com/user/profile/#{user_id}" if user_id.present?
  end

  def display_name
    note.dig("user", "nickName")
  end

  def tags
    note["tagList"].to_a.pluck("name").map do |tag|
      [tag, "https://www.xiaohongshu.com/search_result?keyword=#{Danbooru::URL.escape(tag)}"]
    end
  end

  def artist_commentary_title
    note[:title]
  end

  # Hashtags look like `#明日方舟终末地[话题]#` in the description.
  def artist_commentary_desc
    CGI.escapeHTML(note[:desc].to_s).gsub(/#([^#\[\]\n]+)\[话题\]#/) do
      %{<a href="https://www.xiaohongshu.com/search_result?keyword=#{Danbooru::URL.escape(CGI.unescapeHTML($1))}">##{$1}</a>}
    end.gsub("\n", "<br>")
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc)&.strip
  end

  def post_id
    parsed_url.post_id || parsed_referer&.post_id
  end

  def user_id
    parsed_url.user_id || parsed_referer&.user_id || note.dig("user", "userId")
  end

  memoize def note
    note = page_json.dig("noteData", "data", "noteData") || {}
    (note[:noteId] == post_id) ? note : {}
  end

  memoize def page
    return nil if page_url.blank?

    url = Danbooru::URL.parse(page_url).with(host: "www.rednote.com").to_s
    parsed_get(url)
  end

  memoize def page_json
    page&.at('script[text()*="__INITIAL_STATE__"]')&.text&.slice(/{.*}/)&.gsub("undefined", "null")&.gsub(/new Set\((\[.*?\])\)/, '\1')&.parse_json || {}
  end

  def http
    # The mobile site works without cookies. The desktop site requires a login and sends logged in accounts to a captcha.
    super.headers("User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1")
  end

  def http_downloader
    # http://sns-webpic-qc.xhs.cdn.com URLs fail with a spoofed referer. Ex: http://sns-webpic-qc.xhscdn.com/202405210748/f4ece3f93e230347cacc53e8628c35be/spectrum/1040g0k030p06mpo4k0005ovbk4n9t3fq5ms4iu0!nd_dft_wlteh_jpg_3
    # ci.xiaohongshu.com randomly drops connections.
    super.disable_feature(:spoof_referrer).use(:retriable)
  end
end
