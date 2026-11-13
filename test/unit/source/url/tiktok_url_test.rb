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

      should be_image_url(
        "https://v16-webapp-prime.tiktok.com/video/tos/alisg/tos-alisg-ve-0068c800-sg/oMAQ7FPCfdpFDyzCjfcC4WIeA4EBDWJEXTT4Ii/?a=1988&bti=ODszNWYuMDE6&&bt=981&ft=WcSzINTYVQ9wUh~yN6W.CJkHgQ7ohdxwiiavX.8fQF_4&mime_type=video_mp4&rc=ZjNmaWdpaWhlZzs5Z2k2N0BpM3EzcXg5cmp2OTMzODczNEAtLmIyYC40XjMxX181XjU2YSNlcjRoMmRrY3FhLS1kMWBzcw%3D%3D&expire=1794761549&l=20261113165212C7C8B26CF81FE88FBF91&ply_type=2&policy=2&signature=4c62d7d23aec94c84d7e6b028d958588&tk=tt_chain_token&btag=e000b8000",
      )

      should be_bad_link(
        "https://v16-webapp-prime.tiktok.com/video/tos/alisg/tos-alisg-ve-0068c800-sg/oMAQ7FPCfdpFDyzCjfcC4WIeA4EBDWJEXTT4Ii/?a=1988&bti=ODszNWYuMDE6&&bt=981&ft=WcSzINTYVQ9wUh~yN6W.CJkHgQ7ohdxwiiavX.8fQF_4&mime_type=video_mp4&rc=ZjNmaWdpaWhlZzs5Z2k2N0BpM3EzcXg5cmp2OTMzODczNEAtLmIyYC40XjMxX181XjU2YSNlcjRoMmRrY3FhLS1kMWBzcw%3D%3D&expire=1794761549&l=20261113165212C7C8B26CF81FE88FBF91&ply_type=2&policy=2&signature=4c62d7d23aec94c84d7e6b028d958588&tk=tt_chain_token&btag=e000b8000",
        "https://p16-common-sign.tiktokcdn-eu.com/tos-alisg-i-photomode-sg/4b98327ecb5144aca24a24ef5c12dc19~tplv-photomode-image.jpeg?dr=10375&x-expires=1794754800&x-signature=qn4E1Ly06W3ri8Ijz4pcaRUOfHQ%3D&t=4d5b0474&ps=13740610&shp=81f88b70&shcp=9b759fb9&idc=useast2b&ftpl=1",
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

      should parse_url("https://www.tiktok.com/@/photo/7584709238878915858?_r=1&_d=abc&u_code=123&share_item_id=7584709238878915858").into(
        page_url: "https://www.tiktok.com/@/photo/7584709238878915858",
        profile_url: nil,
      )

      should parse_url("https://www.tiktok.com/@ajmarekart?_t=ZM-8wmxRtoZXjq&_r=1").into(site_name: "TikTok")
    end
  end
end
