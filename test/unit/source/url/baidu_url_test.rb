require "test_helper"

module Source::Tests::URL
  class BaiduUrlTest < ActiveSupport::TestCase
    context "Baidu URLs" do
      should be_profile_url(
        "http://hi.baidu.com/new/mocaorz",
        "http://hi.baidu.com/longbb1127/home",
      )
    end

    should parse_url("http://hi.baidu.com/new/mocaorz").into(site_name: "Baidu")
  end
end
