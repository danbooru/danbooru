require "test_helper"

module Source::Tests::URL
  class XfolioUrlTest < ActiveSupport::TestCase
    context "Xfolio URLs" do
      should be_image_url(
        "https://xfolio.jp/user_asset.php?id=1128032&work_id=237599&work_image_id=1128032&type=work_image",
      )

      should be_page_url(
        "https://xfolio.jp/portfolio/ben1shoga/works/237599",
      )

      should be_profile_url(
        "https://xfolio.jp/portfolio/ben1shoga",
      )

      should_not be_profile_url(
        "https://xfolio.jp/",
        "https://xfolio.jp/en",
        "https://xfolio.jp/portfolio",
        "https://xfolio.jp/en/portfolio",
      )

      should parse_url("https://xfolio.jp/en/portfolio/ben1shoga/works/237599").into(
        page_url: "https://xfolio.jp/portfolio/ben1shoga/works/237599",
      )

      should parse_url("https://xfolio.jp/en/portfolio/ben1shoga").into(
        profile_url: "https://xfolio.jp/portfolio/ben1shoga",
      )

      should parse_url("https://xfolio.jp/portfolio/ben1shoga/works").into(
        profile_url: "https://xfolio.jp/portfolio/ben1shoga",
      )

      should parse_url("https://xfolio.jp/en/portfolio/ben1shoga/works").into(
        profile_url: "https://xfolio.jp/portfolio/ben1shoga",
      )

      should parse_url("https://xfolio.jp/portfolio/ben1shoga").into(
        username: "ben1shoga",
      )

      should parse_url("https://xfolio.jp/portfolio/ben1shoga/works/237599").into(
        username: "ben1shoga",
        work_id: "237599",
      )
    end

    should parse_url("https://xfolio.jp/user_asset.php?id=1128032&work_id=237599&work_image_id=1128032&type=work_image").into(site_name: "Xfolio")
  end
end
