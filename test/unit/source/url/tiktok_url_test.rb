require "test_helper"

module Source::Tests::URL
  class TiktokUrlTest < ActiveSupport::TestCase
    context "TikTok URLs" do
      should be_page_url(
        "https://www.tiktok.com/@ashshae0/video/7618903378113924373",
        "https://www.tiktok.com/@pyromannce/photo/7584709238878915858?_r=1&_t=ZS-93TCD3c5ooM",
      )

      should be_profile_url(
        "https://www.tiktok.com/@h.panda_12",
      )

      should be_bad_link(
        "https://p16-common-sign.tiktokcdn-us.com/tos-useast5-i-photomode-tx/c997051aa88446328e44de163d83a30c~tplv-photomode-image.jpeg?dr=9616&x-expires=1774238400&x-signature=mnDyZBX35%2BTC4y8Uvno95%2FiewDU%3D&t=4d5b0474&ps=13740610&shp=81f88b70&shcp=9b759fb9&idc=useast5&ftpl=1",
      )

      should be_bad_source(
        "https://vt.tiktok.com/ZSa9V7ert/",
        "https://www.tiktok.com/t/ZSa9V7ert/",
      )

      should parse_url("https://www.tiktok.com/@ajmarekart?_t=ZM-8wmxRtoZXjq&_r=1").into(
        profile_url: "https://www.tiktok.com/@ajmarekart",
      )

      should parse_url("https://www.tiktok.com/@lenn0n__?").into(
        profile_url: "https://www.tiktok.com/@lenn0n__",
      )

      should parse_url("https://www.tiktok.com/@h.panda_12").into(
        profile_url: "https://www.tiktok.com/@h.panda_12",
      )

      should parse_url("https://www.tiktok.com/@ashshae0/video/7618903378113924373").into(
        page_url: "https://www.tiktok.com/@ashshae0/video/7618903378113924373",
      )

      should parse_url("https://www.tiktok.com/@pyromannce/photo/7584709238878915858?_r=1&_t=ZS-93TCD3c5ooM").into(
        page_url: "https://www.tiktok.com/@pyromannce/photo/7584709238878915858",
      )

      should parse_url("https://www.tiktok.com/@ajmarekart?_t=ZM-8wmxRtoZXjq&_r=1").into(site_name: "TikTok")
    end
  end
end
