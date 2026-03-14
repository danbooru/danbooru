require "test_helper"

module Source::Tests::URL
  class PrivatterUrlTest < ActiveSupport::TestCase
    context "Privatter URLs" do
      should be_image_url(
        "https://d2pqhom6oey9wx.cloudfront.net/img_original/6501563076473624f29c22.png",
      )

      should be_page_url(
        "https://privatter.net/p/8037485/",
        "https://privatter.net/i/29851",
      )

      should be_profile_url(
        "https://privatter.net/u/yakko_ss",
        "https://privatter.net/u/GLK_Sier",
      )
    end
  end
end
