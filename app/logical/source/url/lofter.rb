# frozen_string_literal: true

# Image URLs
#
# # sample
# * https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJSzFCWFlnUWgzb01DcUdpT1lreG5yQjJVMkhGS09HNGR3PT0.png?imageView&thumbnail=1680x0&quality=96&stripmeta=0
#
# # full size
# * https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJSzFCWFlnUWgzb01DcUdpT1lreG5yQjJVMkhGS09HNGR3PT0.png
# * http://imglf0.nosdn.127.net/img/cHl3bXNZdDRaaHBnNWJuN1Y4OXBqR01CeVBZSVNmU2FWZWtHc1h4ZTZiUGxlRzMwZnFDM1JnPT0.jpg (404)
#
# Page URLs
#
# * https://gengar563.lofter.com/post/1e82da8c_1c98dae1b
# * https://yuli031458.lofter.com/post/3163d871_1cbdc5f6d (different theme/css selectors)
# * https://ssucrose.lofter.com/post/1d30f3e4_1cc58e9f0 (another different theme)
# * https://zuodaoxing.lofter.com/post/30b9c9c3_1cd15b686 (another theme)
#
# Profile URLs
#
# * http://gengar563.lofter.com
#
# Non-profile URLs
#
# * https://i.lofter.com
# * https://www.lofter.com
#
class Source::URL::Lofter < Source::URL
  RESERVED_SUBDOMAINS = %w[www.lofter.com i.lofter.com]

  attr_reader :username, :work_id

  def self.match?(url)
    url.domain.in?(%w[lofter.com 127.net lf127.net])
  end

  def parse
    case [host, *path_segments]

    # https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJSzFCWFlnUWgzb01DcUdpT1lreG5yQjJVMkhGS09HNGR3PT0.png?imageView&thumbnail=1680x0&quality=96&stripmeta=0
    # https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJSzFCWFlnUWgzb01DcUdpT1lreG5yQjJVMkhGS09HNGR3PT0.png
    # http://imglf0.nosdn.127.net/img/cHl3bXNZdDRaaHBnNWJuN1Y4OXBqR01CeVBZSVNmU2FWZWtHc1h4ZTZiUGxlRzMwZnFDM1JnPT0.jpg (404)
    in /127\.net$/, "img", filename
      @filename = filename

    # https://gengar563.lofter.com/post/1e82da8c_1c98dae1b
    in /^([a-z0-9-]+)\.lofter\.com$/, "post", work_id unless host.in?(RESERVED_SUBDOMAINS)
      @username = $1
      @work_id = work_id

    # http://gengar563.lofter.com
    in /^([a-z0-9-]+)\.lofter\.com$/, *rest unless host.in?(RESERVED_SUBDOMAINS)
      @username = $1

    else
    end
  end

  def image_url?
    url.domain.in?(%w[lf127.net 127.net])
  end

  def full_image_url
    "#{site}#{path}" if image_url?
  end
end
