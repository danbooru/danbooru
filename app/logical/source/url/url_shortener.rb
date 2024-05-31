# frozen_string_literal: true

# @see Source::Extractor::URLShortener
class Source::URL::URLShortener < Source::URL
  attr_reader :redirect_url

  def self.match?(url)
    # https://0rz.tw/Gwl0j
    # https://amzn.asia/bGjatHL / https://amzn.asia/d/j0P2N9X
    # https://amzn.to/2oaTatI
    # https://bit.ly/4aAVa4y
    # https://bit.ly/4aAVa4y+ (trick: you can add '+' to the end to see where the link goes)
    # https://cutt.ly/GfQ2szk
    # https://dlvr.it/SWKqJ0
    # https://eepurl.com/j5st
    # https://forms.gle/CK6UER39rK5qKnnT8
    # https://j.mp/cKV0uf
    # https://photos.app.goo.gl/eHfTwV866X4Vf7Zt5 (Google Photos share link)
    # https://images.app.goo.gl/5uBga7TuPKHxyyR1A (Google Images share link)
    # https://is.gd/UeUnvf
    # https://naver.me/FABhCw8Z
    # https://pin.it/4A1N0Rd5W
    # https://posty.pe/343rpc
    # https://pse.is/4b4tda
    # https://reurl.cc/E2zlnA
    # https://shorturl.at/uMS23
    # https://skfb.ly/GXzZ
    # https://t.ly/x8f4j
    # https://t.cn/A6pONxY1
    # https://t.co/Dxn7CuVErW
    # https://tiny.cc/6ut5vz
    # https://tinyurl.com/3avx9w4r
    # https://tmblr.co/ZdPV4t2OHwdv5
    # https://wp.me/p32Sjo-oJ
    # https://x.gd/uysub
    # https://xhslink.com/WNd9gI
    # https://hoyo.link/80GCFBAL?q=25tufAgwB8N
    # https://hoyo.link/aifgFBAL
    url.domain.in?(%w[0rz.tw amzn.asia amzn.to bit.ly j.mp cutt.ly dlvr.it eepurl.com forms.gle goo.gl hoyo.link is.gd naver.me pin.it posty.pe pse.is reurl.cc shorturl.at skfb.ly t.ly tiny.cc tinyurl.com tmblr.co t.cn t.co wp.me x.gd xhslink.com]) ||

    # https://pic.twitter.com/Dxn7CuVErW
    # https://pic.x.com/Dxn7CuVErW
    url.host.in?(%w[pic.twitter.com pic.x.com]) ||

    # http://ow.ly/WmrYu
    # http://ow.ly/i/3oHVc (not a redirect)
    # http://ow.ly/user/coppelion_anime (not a redirect)
    (url.domain == "ow.ly" && !url.path_segments.first&.in?(%w[i user]))
  end

  def site_name
    case [subdomain, domain]
    in _, "amzn.asia" | "amzn.to"
      "Amazon"
    in _, "bit.ly" | "j.mp"
      "Bitly"
    in _, "twitter.com" | "t.co"
      "Twitter"
    in _, "hoyo.link"
      "Hoyolab"
    in _, "eepurl.com"
      "Mailchimp"
    in _, "naver.me"
      "Naver"
    in _, "pin.it"
      "Pinterest"
    in _, "posty.pe"
      "Postype"
    in _, "goo.gl" | "forms.gle"
      "Google"
    in _, "skfb.ly"
      "Sketchfab"
    in _, "tinyurl.com"
      "TinyURL"
    in _, "tmblr.co"
      "Tumblr"
    in _, "t.cn"
      "Weibo"
    in _, "xhslink.com"
      "Xiaohongshu"
    else # ow.ly, is.gd, etc
      host.capitalize
    end
  end

  def parse
  end
end
