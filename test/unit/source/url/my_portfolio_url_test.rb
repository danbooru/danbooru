require "test_helper"

module Source::Tests::URL
  class MyPortfolioUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://cdn.myportfolio.com/86bfb012-1d8f-427f-bbbb-287c3b8c0057/2a0c99c7-d94d-4812-87b4-1690d7a13983_car_202x158.png?h=e698f363e29b0f60d61181c64016a99a",
          "https://cdn.myportfolio.com/86bfb012-1d8f-427f-bbbb-287c3b8c0057/bb0394ab-0ffd-414b-9748-2a8a751c645a_rw_1200.png?h=fdde829a19fbd8534d6f85d3914f419c",
          "https://pro2-bar-s3-cdn-cf6.myportfolio.com/59753a162c5d8748646b051378da184f/77f237b4-25e9-46ed-b8ef-2b3709c92491.jpg?h=021034439a138a0920b78342343cb37e",
          "https://pro2-bar-s3-cdn-cf6.myportfolio.com/ea94248a8ad87a031cf807d40eb5ac83/af57cb30368b3d3b3576fe81.jpg?h=d656289b0092beab1297ad678ef12647",
        ],
        page_urls: [
          "https://sekigahara023.myportfolio.com/eaapexlegends5",
        ],
        profile_urls: [
          "https://sekigahara023.myportfolio.com/",
        ],
      )

      should_not_find_false_positives(
        page_urls: [
          "https://sekigahara023.myportfolio.com/",
        ],
      )
    end
  end
end
