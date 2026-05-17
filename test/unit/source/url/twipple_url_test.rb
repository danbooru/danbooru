require "test_helper"

module Source::Tests::URL
  class TwippleUrlTest < ActiveSupport::TestCase
    context "Twipple URLs" do
      should be_page_url(
        "http://p.twpl.jp/show/orig/mI2c3",
      )

      should be_profile_url(
        "http://twpl.jp/swacoro",
      )
    end

    should parse_url("http://p.twpl.jp/show/orig/mI2c3").into(site_name: "Twipple")
  end
end
