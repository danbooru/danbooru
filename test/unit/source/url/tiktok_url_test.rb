require "test_helper"

module Source::Tests::URL
  class TiktokUrlTest < ActiveSupport::TestCase
    context "TikTok URLs" do
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
    end

    should parse_url("https://www.tiktok.com/@ajmarekart?_t=ZM-8wmxRtoZXjq&_r=1").into(site_name: "TikTok")
  end
end
