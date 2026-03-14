require "test_helper"

module Source::Tests::URL
  class FuraffinityUrlTest < ActiveSupport::TestCase
    context "Furaffinity URLs" do
      should be_image_url(
        "https://d.furaffinity.net/art/iwbitu/1650222955/1650222955.iwbitu_yubi.jpg",
      )

      should be_page_url(
        "https://www.furaffinity.net/view/46821705/",
        "https://www.furaffinity.net/full/46821705/",
      )

      should be_profile_url(
        "https://www.furaffinity.net/user/iwbitu",
        "https://www.furaffinity.net/gallery/iwbitu",
        "https://www.furaffinity.net/gallery/iwbitu/folder/133763/Regular-commissions",
        "https://www.furaffinity.net/stats/duskmoor/submissions/",
      )

      should parse_url("https://fxraffinity.net/view/1234").into(
        page_url: "https://www.furaffinity.net/view/1234",
      )

      should parse_url("https://fxfuraffinity.net/view/1234").into(
        page_url: "https://www.furaffinity.net/view/1234",
      )

      should parse_url("https://vxfuraffinity.net/view/1234").into(
        page_url: "https://www.furaffinity.net/view/1234",
      )

      should parse_url("https://xfuraffinity.net/view/1234").into(
        page_url: "https://www.furaffinity.net/view/1234",
      )
    end
  end
end
