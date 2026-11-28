# frozen_string_literal: true

# Douyin's web API refuses post requests unless they're signed with the `UIFID` cookie, a visitor ID that Douyin's
# Javascript generates in the browser. Logging in isn't required. The browser also adds an `a_bogus` signature, but the
# API doesn't require it.
#
# @see Source::URL::Douyin
class Source::Extractor::Douyin < Source::Extractor
  # The salt used to sign API requests. It comes from the string table of Douyin's security SDK (runtime_bundler_34.js
  # on lf-security.bytegoofy.com). See the security SDK test in douyin_extractor_test.rb for how to find a new one.
  SIGNATURE_SALT = "A96D855A08C0A9707F8BEF0D9A527E4E"

  def self.enabled?
    SiteCredential.for_site("Douyin").present?
  end

  def image_urls
    if parsed_url.image_url?
      [url]
    elsif aweme[:images].present?
      # Each image has a .webp and a .jpeg version of the same size. Ex:
      # https://p3-pc-sign.douyinpic.com/tos-cn-i-0813c000-ce/oAzkAGWIuALZJzpeBg7pkOValG7fqAzeIQxFAl~tplv-dy-aweme-images-v2:3000:3000:q75.jpeg?lk3s=138a59ce&x-expires=1798444800&x-signature=...
      aweme[:images].filter_map do |image|
        image[:url_list].to_a.find { |url| Source::URL.parse(url)&.file_ext == "jpeg" } || image[:url_list]&.first
      end
    else
      [video_url].compact
    end
  end

  # The largest H.264 MP4 version of the video. The `/aweme/v1/play/` URL redirects to a CDN URL that expires after a
  # few hours. Ex:
  #
  # https://www.douyin.com/aweme/v1/play/?video_id=v1e00fgi0000d1mfe5vog65vhen11m4g&line=0&file_id=c91511bc740e4ffb9e77e92f50164e1f&sign=26f6b5b6d115ff53471a76094882d490&is_play_url=1&source=PackSourceEnum_AWEME_DETAIL&biz_sign=NRPI1l
  # => https://v3-dy-o.zjcdn.com/ce51eb8e8016fee747b9d21dec57fee0/6b0aa6cb/video/tos/cn/tos-cn-ve-15c000-ce/osveHhA1wIrgFW1hASgDIeQae4DUcFT4sGf2sL/?a=6383&br=428&...
  def video_url
    versions = aweme.dig(:video, :bit_rate).to_a.select { |version| version[:format] == "mp4" && version[:is_h265] == 0 }
    largest = versions.max_by { |version| [version.dig(:play_addr, :width).to_i * version.dig(:play_addr, :height).to_i, version[:bit_rate].to_i] }
    urls = (largest || aweme[:video])&.dig(:play_addr, :url_list).to_a

    urls.find { |url| Source::URL.parse(url).try(:video_url?) } || urls.first
  end

  def page_url
    if aweme[:images].present?
      "https://www.douyin.com/note/#{post_id}"
    elsif aweme.present?
      "https://www.douyin.com/video/#{post_id}"
    else
      parsed_url.page_url || parsed_referer&.page_url
    end
  end

  def profile_url
    if sec_uid.present?
      "https://www.douyin.com/user/#{sec_uid}"
    else
      parsed_url.profile_url || parsed_referer&.profile_url
    end
  end

  def sec_uid
    aweme.dig(:author, :sec_uid)
  end

  # The user's Douyin ID (抖音号). Users who haven't picked one have a numeric ID instead.
  def username
    aweme.dig(:author, :unique_id).presence || aweme.dig(:author, :short_id).presence
  end

  def display_name
    aweme.dig(:author, :nickname)
  end

  def published_at
    Time.zone.at(aweme[:create_time].to_i) if aweme[:create_time].present?
  end

  def tags
    aweme[:text_extra].to_a.select { |tag| tag[:hashtag_name].present? }.map do |tag|
      [tag[:hashtag_name], "https://www.douyin.com/hashtag/#{tag[:hashtag_id]}"]
    end.uniq
  end

  def artist_commentary_title
    aweme[:item_title]
  end

  def artist_commentary_desc
    aweme[:desc]
  end

  def dtext_artist_commentary_desc
    DText.from_plaintext(artist_commentary_desc)
  end

  def post_id
    parsed_url.post_id || parsed_referer&.post_id
  end

  memoize def aweme
    return {} if post_id.blank? || credentials[:uifid].blank?

    params = { device_platform: "webapp", aid: 6383, aweme_id: post_id, uifid: credentials[:uifid], timestamp: Time.zone.now.to_i }
    query = URI.encode_www_form(params)
    signature = Digest::MD5.hexdigest("#{credentials[:uifid]}_#{params[:timestamp]}_#{SIGNATURE_SALT}_#{query}")

    url = "https://www.douyin.com/aweme/v1/web/aweme/detail/?#{query}&x-secsdk-web-signature=#{signature}"
    # Only send the cookies to the API, not when downloading files, which doesn't need them.
    cookies = { UIFID: credentials[:uifid], ttwid: credentials[:ttwid], s_v_web_id: credentials[:s_v_web_id] }
    response = http.cookies(cookies).cache(1.minute, key: "douyin-aweme-detail:#{post_id}").get(url)

    # Douyin returns 403 when the UIFID is missing or wrong, and a 200 with an empty body when the other cookies are.
    # Deleted posts return `{"aweme_detail": null, "filter_detail": {...}}`.
    if response.status == 403 || (response.status == 200 && response.body.to_s.empty?)
      site_credential&.error!(:expired)
      {}
    elsif response.status == 200
      update_credentials!(response)
      response.parse&.dig(:aweme_detail) || {}
    else
      {}
    end
  end

  def http
    super.headers(Referer: "https://www.douyin.com/")
  end
end
