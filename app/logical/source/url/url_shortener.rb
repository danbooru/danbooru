# frozen_string_literal: true

# @see Source::Extractor::URLShortener
class Source::URL::URLShortener < Source::URL
  site "Amazon", url: "https://amazon.com", domains: %w[amzn.asia amzn.to]
  site "Bitly", url: "https://bit.ly", domains: %w[bit.ly j.mp]
  site "Cuttly", url: "https://cutt.ly", domains: %w[cutt.ly]
  site "Dlvr.it", url: "https://dlvr.it", domains: %w[dlvr.it]
  site "Href.li", url: "https://href.li", domains: %w[href.li]
  site "Is.gd", url: "https://is.gd", domains: %w[is.gd]
  site "Mailchimp", url: "https://mailchimp.com", domains: %w[eepurl.com]
  site "Hootsuite", url: "https://www.hootsuite.com", domains: %w[ow.ly]
  site "PicSee", url: "https://picsee.io", domains: %w[pse.is]
  site "Reurl", url: "https://reurl.cc", domains: %w[reurl.cc]
  site "ShortURL.at", url: "https://shorturl.at", domains: %w[shorturl.at]
  site "Sketchfab", url: "https://sketchfab.com", domains: %w[skfb.ly]
  site "T.ly", url: "https://t.ly", domains: %w[t.ly]
  site "Tiny.cc", url: "https://tiny.cc", domains: %w[tiny.cc]
  site "TinyURL", url: "https://tinyurl.com", domains: %w[tinyurl.com]
  site "Unsafelink", url: "https://unsafelink.com", domains: %w[unsafelink.com]
  site "WordPress", url: "https://wordpress.com", domains: %w[wp.me]
  site "X.gd", url: "https://x.gd", domains: %w[x.gd]

  attr_reader :redirect_url

  def self.match?(url)
    # https://amzn.asia/bGjatHL / https://amzn.asia/d/j0P2N9X
    # https://amzn.to/2oaTatI
    # https://bit.ly/4aAVa4y
    # https://bit.ly/4aAVa4y+ (trick: you can add '+' to the end to see where the link goes)
    # https://cutt.ly/GfQ2szk
    # https://dlvr.it/SWKqJ0
    # https://eepurl.com/j5st
    # https://href.li/?https://www.google.com
    # https://j.mp/cKV0uf
    # https://is.gd/UeUnvf
    # https://pse.is/4b4tda
    # https://reurl.cc/E2zlnA
    # https://shorturl.at/uMS23
    # https://skfb.ly/GXzZ
    # https://t.ly/x8f4j
    # https://tiny.cc/6ut5vz
    # https://tinyurl.com/3avx9w4r
    # https://wp.me/p32Sjo-oJ
    # https://x.gd/uysub
    # https://unsafelink.com/https://x.com/horuhara/status/1839132898785636671?t=RtemijMNpG1bdpziXac6-Q&s=19
    case [url.subdomain, url.domain, *url.path_segments]
    in _, "amzn.asia" | "amzn.to" | "bit.ly" | "j.mp" | "cutt.ly" | "dlvr.it" | "eepurl.com" | "href.li" | "is.gd" | "pse.is" | "reurl.cc" | "shorturl.at" | "skfb.ly" | "t.ly" | "tiny.cc" | "tinyurl.com" | "wp.me" | "x.gd" | "unsafelink.com", *_rest
      true

    # http://ow.ly/WmrYu
    # http://ow.ly/i/3oHVc (not a redirect)
    # http://ow.ly/user/coppelion_anime (not a redirect)
    in _, "ow.ly", id unless id.in?(%w[i user])
      true

    else
      false
    end
  end

  def source_site
    sites = Source::Site.find_by_domain(domain)
    sites.sole if sites.one?
  end

  def site_name
    source_site&.name
  end

  def parse
  end
end
