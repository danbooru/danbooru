# frozen_string_literal: true

class Source::URL::Lofter < Source::URL
  RESERVED_SUBDOMAINS = %w[www.lofter.com i.lofter.com]

  attr_reader :username, :work_id, :unescaped_tag

  def self.match?(url)
    url.domain.in?(%w[lofter.com 127.net lf127.net 126.net])
  end

  def parse
    case [host, *path_segments]

    # https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJSzFCWFlnUWgzb01DcUdpT1lreG5yQjJVMkhGS09HNGR3PT0.png?imageView&thumbnail=1680x0&quality=96&stripmeta=0
    # https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJSzFCWFlnUWgzb01DcUdpT1lreG5yQjJVMkhGS09HNGR3PT0.png
    # http://imglf0.nosdn.127.net/img/cHl3bXNZdDRaaHBnNWJuN1Y4OXBqR01CeVBZSVNmU2FWZWtHc1h4ZTZiUGxlRzMwZnFDM1JnPT0.jpg (404)
    in /127\.net$/, "img", _
      nil

    # https://vodm2lzexwq.vod.126.net/vodm2lzexwq/Pc5jg1nL_3039990631_sd.mp4?resId=254486990bfa2cd7aa860229db639341_3039990631_1&sign=4j02HTHXqNfhaF%2B%2FO14Ny%2F9SMNZj%2FIjpJDCqXfYa4aM%3D
    in /vod\.126\.net$/, *rest
      nil

    # https://www.lofter.com/front/blog/home-page/noshiqian
    in "www.lofter.com", "front", "blog", "home-page", username
      @username = username

    # http://www.lofter.com/app/xiaokonggedmx
    # http://www.lofter.com/blog/semblance
    in "www.lofter.com", ("app" | "blog"), username
      @username = username

    # https://gengar563.lofter.com/post/1e82da8c_1c98dae1b
    in /^([a-z0-9-]+)\.lofter\.com$/, "post", work_id unless host.in?(RESERVED_SUBDOMAINS)
      @username = $1
      @work_id = work_id

    # http://gengar563.lofter.com
    in /^([a-z0-9-]+)\.lofter\.com$/, *rest unless host.in?(RESERVED_SUBDOMAINS)
      @username = $1

    else
      nil
    end
  end

  def image_url?
    url.domain.in?(%w[lf127.net 127.net 126.net])
  end

  def full_image_url
    return nil unless image_url?
    return "#{site}#{path}" unless url.host.match(/vod\.126\.net$/)
    original_url
  end

  def page_url
    "https://#{username}.lofter.com/post/#{work_id}" if username.present? && work_id.present?
  end

  def profile_url
    "https://#{username}.lofter.com" if username.present?
  end
end
