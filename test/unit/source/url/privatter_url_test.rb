require "test_helper"

module Source::Tests::URL
  class PrivatterUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://d2pqhom6oey9wx.cloudfront.net/img_original/6501563076473624f29c22.png",
        ],
        page_urls: [
          "https://privatter.net/p/8037485/",
          "https://privatter.net/i/29851",
        ],
        profile_urls: [
          "https://privatter.net/u/yakko_ss",
          "https://privatter.net/u/GLK_Sier",
        ],
      )
    end
  end
end
