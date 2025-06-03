require "test_helper"

module Source::Tests::URL
  class XfolioUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://xfolio.jp/user_asset.php?id=1128032&work_id=237599&work_image_id=1128032&type=work_image",
        ],
        page_urls: [
          "https://xfolio.jp/portfolio/ben1shoga/works/237599",
        ],
        profile_urls: [
          "https://xfolio.jp/portfolio/ben1shoga",
        ],
      )

      should_not_find_false_positives(
        profile_urls: [
          "https://xfolio.jp/",
          "https://xfolio.jp/en",
          "https://xfolio.jp/portfolio",
          "https://xfolio.jp/en/portfolio",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://xfolio.jp/en/portfolio/ben1shoga/works/237599",
                             page_url: "https://xfolio.jp/portfolio/ben1shoga/works/237599",)

      url_parser_should_work("https://xfolio.jp/en/portfolio/ben1shoga",
                             profile_url: "https://xfolio.jp/portfolio/ben1shoga",)

      url_parser_should_work("https://xfolio.jp/portfolio/ben1shoga/works",
                             profile_url: "https://xfolio.jp/portfolio/ben1shoga",)

      url_parser_should_work("https://xfolio.jp/en/portfolio/ben1shoga/works",
                             profile_url: "https://xfolio.jp/portfolio/ben1shoga",)

      url_parser_should_work("https://xfolio.jp/portfolio/ben1shoga", username: "ben1shoga")
      url_parser_should_work("https://xfolio.jp/portfolio/ben1shoga/works/237599",
                             username: "ben1shoga",
                             work_id: "237599",)
    end
  end
end
