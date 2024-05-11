# frozen_string_literal: true

# @see Source::Extractor::URLShortener
class Source::URL::URLShortener < Source::URL
  attr_reader :redirect_url

  def self.match?(url)
    # https://http://amzn.to/2oaTatI
    # https://bit.ly/4aAVa4y
    # https://bit.ly/4aAVa4y+ (trick: you can add '+' to the end to see where the link goes)
    # https://cutt.ly/GfQ2szk
    # https://j.mp/cKV0uf
    # https://photos.app.goo.gl/eHfTwV866X4Vf7Zt5 (Google Photos share link)
    # https://images.app.goo.gl/5uBga7TuPKHxyyR1A (Google Images share link)
    # https://is.gd/UeUnvf
    # https://t.ly/x8f4j
    # https://tiny.cc/6ut5vz
    # https://tinyurl.com/3avx9w4r
    # https://t.co/Dxn7CuVErW
    # https://wp.me/p32Sjo-oJ
    url.domain.in?(%w[amzn.to bit.ly j.mp cutt.ly goo.gl is.gd pin.it t.ly tiny.cc tinyurl.com t.co wp.me]) ||

    # https://pic.twitter.com/Dxn7CuVErW
    url.host.in?(%w[pic.twitter.com]) ||

    # http://ow.ly/WmrYu
    # http://ow.ly/i/3oHVc (not a redirect)
    # http://ow.ly/user/coppelion_anime (not a redirect)
    (url.domain == "ow.ly" && !url.path_segments.first&.in?(%w[i user]))
  end

  def site_name
    case [subdomain, domain]
    in _, "amzn.to"
      "Amazon"
    in _, "bit.ly" | "j.mp"
      "Bitly"
    in _, "twitter.com" | "t.co"
      "Twitter"
    in _, "pin.it"
      "Pinterest"
    in _, "goo.gl"
      "Google"
    in _, "tinyurl.com"
      "TinyURL"
    else # ow.ly, is.gd, etc
      host.capitalize
    end
  end

  def parse
    case [subdomain, domain, *path_segments]
    # https://pin.it/4A1N0Rd5W
    in _, "pin.it", id
      @redirect_url = "https://api.pinterest.com/url_shortener/#{id}/redirect/"

    else
      @redirect_url = Addressable::URI.new(scheme: "https", host:, path:).to_s
    end
  end
end
