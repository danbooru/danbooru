# frozen_string_literal: true

# @see Source::Extractor::URLShortener
class Source::URL::URLShortener < Source::URL
  site "URL Shortener"

  attr_reader :redirect_url

  def self.match?(url)
    # https://amzn.asia/bGjatHL / https://amzn.asia/d/j0P2N9X
    # https://amzn.to/2oaTatI
    # https://b23.tv/h5v55co
    # https://bit.ly/4aAVa4y
    # https://bit.ly/4aAVa4y+ (trick: you can add '+' to the end to see where the link goes)
    # https://bili2233.cn/h5v55co
    # https://cutt.ly/GfQ2szk
    # https://dlvr.it/SWKqJ0
    # https://eepurl.com/j5st
    # https://forms.gle/CK6UER39rK5qKnnT8
    # https://href.li/?https://www.google.com
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
    case [url.subdomain, url.domain, *url.path_segments]
    in _, "amzn.asia" | "amzn.to" | "b23.tv" | "bit.ly" | "bili2233.cn" | "j.mp" | "cutt.ly" | "dlvr.it" | "eepurl.com" | "forms.gle" | "goo.gl" | "href.li" | "hoyo.link" | "is.gd" | "naver.me" | "pin.it" | "posty.pe" | "pse.is" | "reurl.cc" | "shorturl.at" | "skfb.ly" | "t.ly" | "tiny.cc" | "tinyurl.com" | "tmblr.co" | "t.cn" | "t.co" | "wp.me" | "x.gd" | "xhslink.com", *_rest
      true

    # https://pic.twitter.com/Dxn7CuVErW
    # https://pic.x.com/Dxn7CuVErW
    in "pic", ("twitter.com" | "x.com"), id
      true

    # http://ow.ly/WmrYu
    # http://ow.ly/i/3oHVc (not a redirect)
    # http://ow.ly/user/coppelion_anime (not a redirect)
    in _, "ow.ly", id unless id.in?(%w[i user])
      true

    # https://unsafelink.com/https://x.com/horuhara/status/1839132898785636671?t=RtemijMNpG1bdpziXac6-Q&s=19
    in _, "unsafelink.com", *_rest
      true

    # https://www.deviantart.com/users/outgoing?https://www.google.com
    in _, "deviantart.com", "users", "outgoing"
      true

    # https://weibo.cn/sinaurl?u=https%3A%2F%2Fwww.google.com
    in _, ("weibo.com" | "weibo.cn"), "sinaurl"
      true

    # https://www.pixiv.net/jump.php?https%3A%2F%2Fwww.google.com
    in _, "pixiv.net", "jump.php"
      true

    # https://piapro.jp/jump/?url=https%3A%2F%2Fwww.google.com
    in _, "piapro.jp", "jump"
      true

    # https://vk.com/away.php?to=https%3A%2F%2Fwww.google.com
    in _, "vk.com", "away.php"
      true

    # https://nijie.info/jump.php?https%3A%2F%2Fwww.google.com
    in _, "nijie.info", "jump.php"
      true

    else
      false
    end
  end

  def site_name
    case [subdomain, domain]
    in _, "amzn.asia" | "amzn.to"
      "Amazon"
    in _, "b23.tv" | "bili2233.cn"
      "Bilibili"
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
    in _, "deviantart.com"
      "DeviantArt"
    in _, "weibo.com" | "weibo.cn"
      "Weibo"
    in _, "pixiv.net"
      "Pixiv"
    in _, "piapro.jp"
      "Piapro"
    in _, "vk.com"
      "VK"
    in _, "nijie.info"
      "Nijie"
    in _, "xhslink.com"
      "Xiaohongshu"
    else # ow.ly, is.gd, etc
      host.capitalize
    end
  end

  def parse
  end
end
