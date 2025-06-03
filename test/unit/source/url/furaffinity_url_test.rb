require "test_helper"

module Source::Tests::URL
  class FuraffinityUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://d.furaffinity.net/art/iwbitu/1650222955/1650222955.iwbitu_yubi.jpg",
        ],
        page_urls: [
          "https://www.furaffinity.net/view/46821705/",
          "https://www.furaffinity.net/full/46821705/",
        ],
        profile_urls: [
          "https://www.furaffinity.net/user/iwbitu",
          "https://www.furaffinity.net/gallery/iwbitu",
          "https://www.furaffinity.net/gallery/iwbitu/folder/133763/Regular-commissions",
          "https://www.furaffinity.net/stats/duskmoor/submissions/",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://fxraffinity.net/view/1234",
                             page_url: "https://www.furaffinity.net/view/1234",)

      url_parser_should_work("https://fxfuraffinity.net/view/1234",
                             page_url: "https://www.furaffinity.net/view/1234",)

      url_parser_should_work("https://vxfuraffinity.net/view/1234",
                             page_url: "https://www.furaffinity.net/view/1234",)

      url_parser_should_work("https://xfuraffinity.net/view/1234",
                             page_url: "https://www.furaffinity.net/view/1234",)
    end
  end
end
