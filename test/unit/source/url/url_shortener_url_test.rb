require "test_helper"

module Source::Tests::URL
  class UrlShortenerUrlTest < ActiveSupport::TestCase
    context "UrlShortener URLs" do
      should be_bad_source(
        "https://amzn.asia/bGjatHL",
        "https://amzn.asia/d/j0P2N9X",
        "https://amzn.to/2oaTatI",
        "https://bit.ly/4aAVa4y",
        "https://bit.ly/4aAVa4y+",
        "https://cutt.ly/GfQ2szk",
        "https://dlvr.it/SWKqJ0",
        "https://eepurl.com/j5st",
        "https://href.li/?https://www.google.com",
        "http://j.mp/cKV0uf",
        "https://is.gd/UeUnvf",
        "https://pse.is/4b4tda",
        "https://reurl.cc/E2zlnA",
        "https://shorturl.at/uMS23",
        "https://skfb.ly/GXzZ",
        "https://t.ly/x8f4j",
        "https://tiny.cc/6ut5vz",
        "https://tinyurl.com/3avx9w4r",
        "https://wp.me/p32Sjo-oJ",
        "https://x.gd/uysub",
        "https://unsafelink.com/https://x.com/horuhara/status/1839132898785636671?t=RtemijMNpG1bdpziXac6-Q&s=19",
        "http://ow.ly/WmrYu",
        "https://t.co/Dxn7CuVErW",
        "https://pic.twitter.com/Dxn7CuVErW",
      )

      should_not be_bad_source(
        "http://ow.ly/i/3oHVc",
        "http://ow.ly/user/coppelion_anime",
      )

      should parse_url("https://amzn.asia/bGjatHL").into(site_name: "Amazon")
      should parse_url("https://bit.ly/4aAVa4y").into(site_name: "Bitly")
      should parse_url("https://cutt.ly/GfQ2szk").into(site_name: "Cuttly")
      should parse_url("https://dlvr.it/SWKqJ0").into(site_name: "Dlvr.it")
      should parse_url("https://href.li/?https://www.google.com").into(site_name: "Href.li")
      should parse_url("https://is.gd/UeUnvf").into(site_name: "Is.gd")
      should parse_url("https://eepurl.com/j5st").into(site_name: "Mailchimp")
      should parse_url("http://ow.ly/WmrYu").into(site_name: "Hootsuite")
      should parse_url("https://pse.is/4b4tda").into(site_name: "PicSee")
      should parse_url("https://reurl.cc/E2zlnA").into(site_name: "Reurl")
      should parse_url("https://shorturl.at/uMS23").into(site_name: "ShortURL.at")
      should parse_url("https://skfb.ly/GXzZ").into(site_name: "Sketchfab")
      should parse_url("https://t.ly/x8f4j").into(site_name: "T.ly")
      should parse_url("https://tiny.cc/6ut5vz").into(site_name: "Tiny.cc")
      should parse_url("https://tinyurl.com/3avx9w4r").into(site_name: "TinyURL")
      should parse_url("https://unsafelink.com/https://x.com/horuhara/status/1839132898785636671?t=RtemijMNpG1bdpziXac6-Q&s=19").into(site_name: "Unsafelink")
      should parse_url("https://wp.me/p32Sjo-oJ").into(site_name: "WordPress")
      should parse_url("https://x.gd/uysub").into(site_name: "X.gd")
    end
  end
end
