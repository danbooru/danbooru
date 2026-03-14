require "test_helper"

module Source::Tests::URL
  class BaiduUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        profile_urls: [
          "http://hi.baidu.com/new/mocaorz",
          "http://hi.baidu.com/longbb1127/home",
        ],
      )
    end
  end
end
