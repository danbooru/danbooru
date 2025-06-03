require "test_helper"

module Source::Tests::URL
  class InkbunnyUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://nl.ib.metapix.net/files/preview/4816/4816665_DAGASI_1890.12.jpg",
          "https://nl.ib.metapix.net/files/full/4816/4816665_DAGASI_1890.12.png",
        ],
        page_urls: [
          "https://inkbunny.net/s/3200751",
        ],
        profile_urls: [
          "https://inkbunny.net/DAGASI",
          "https://inkbunny.net/user.php?user_id=152800",
        ],
      )

      should_not_find_false_positives(
        profile_urls: [
          "https://inkbunny.net/index.php",
          "https://inkbunny.net/user.php",
          "https://inkbunny.net/profile.php",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://inkbunny.net/s/3200751", page_url: "https://inkbunny.net/s/3200751")
      url_parser_should_work("https://inkbunny.net/s/3200751-p1-", page_url: "https://inkbunny.net/s/3200751")
      url_parser_should_work("https://inkbunny.net/submissionview.php?id=3200751", page_url: "https://inkbunny.net/s/3200751")

      url_parser_should_work("https://inkbunny.net/DAGASI", username: "DAGASI", user_id: nil)
      url_parser_should_work("https://inkbunny.net/user.php?user_id=152800", username: nil, user_id: 152_800)
    end
  end
end
