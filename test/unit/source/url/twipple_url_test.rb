require "test_helper"

module Source::Tests::URL
  class TwippleUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        page_urls: [
          "http://p.twpl.jp/show/orig/mI2c3",
        ],
        profile_urls: [
          "http://twpl.jp/swacoro",
        ],
      )
    end
  end
end
