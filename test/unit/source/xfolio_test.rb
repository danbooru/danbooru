require 'test_helper'

module Sources
  class XfolioTest < ActiveSupport::TestCase
    context "A https://xfolio.jp/portfolio/:artist_name/works/:work_id url" do
      strategy_should_work(
        "https://xfolio.jp/portfolio/ben1shoga/works/237599",
        page_url: "https://xfolio.jp/portfolio/ben1shoga/works/237599",
        image_urls: [
          "https://xfolio.jp/user_asset.php?id=1128032&work_id=237599&work_image_id=1128032&type=work_image",
        ],
        media_files: [
          { file_size: 1_971_870 },
        ],
        profile_url: "https://xfolio.jp/portfolio/ben1shoga",
        profile_urls: [
          "https://xfolio.jp/portfolio/ben1shoga",
        ],
        artist_name: "くれない",
        username: "ben1shoga",
        tags: ["くれない", "イラスト", "ブルアカ二次創作", "ブルーアーカイブ", "ミドリ(ブルーアーカイブ)", "モモイ(ブルーアーカイブ)", "二次創作"],
        artist_commentary_title: "モモミドビキニ！",
        dtext_artist_commentary_desc: "ビキニだ！モモミドだ！",
      )
    end

    context "A https://xfolio.jp/fullscale_image?image_id=:image_id&work_id=:work_id url" do
      strategy_should_work(
        "https://xfolio.jp/fullscale_image?image_id=1128032&work_id=237599",
        image_urls: [
          "https://xfolio.jp/user_asset.php?id=1128032&work_id=237599&work_image_id=1128032&type=work_image",
        ],
        media_files: [
          { file_size: 1_971_870 },
        ],
      )
    end

    context "A https://xfolio.jp/user_asset.php?id=:image_id&work_id=:work_id&work_image_id=:image_id&type=work_image url" do
      strategy_should_work(
        "https://xfolio.jp/user_asset.php?id=1128032&work_id=237599&work_image_id=1128032&type=work_image",
        image_urls: [
          "https://xfolio.jp/user_asset.php?id=1128032&work_id=237599&work_image_id=1128032&type=work_image",
        ],
        media_files: [
          { file_size: 1_971_870 },
        ],
      )
    end

    context "A work without full image available" do
      strategy_should_work(
        "https://xfolio.jp/portfolio/riku_mochiduki/works/329367",
        media_files: [
          { file_size: 79_118 },
        ],
        display_name: "望月りく",
        username: "riku_mochiduki"
      )
    end

    should "Parse Xfolio URLs correctly" do
      assert(Source::URL.image_url?("https://xfolio.jp/user_asset.php?id=1128032&work_id=237599&work_image_id=1128032&type=work_image"))

      assert(Source::URL.page_url?("https://xfolio.jp/portfolio/ben1shoga/works/237599"))
      assert_equal("https://xfolio.jp/portfolio/ben1shoga/works/237599", Source::URL.page_url("https://xfolio.jp/en/portfolio/ben1shoga/works/237599"))

      assert(Source::URL.profile_url?("https://xfolio.jp/portfolio/ben1shoga"))
      assert_equal("https://xfolio.jp/portfolio/ben1shoga", Source::URL.profile_url("https://xfolio.jp/en/portfolio/ben1shoga"))
      assert_equal("https://xfolio.jp/portfolio/ben1shoga", Source::URL.profile_url("https://xfolio.jp/portfolio/ben1shoga/works"))
      assert_equal("https://xfolio.jp/portfolio/ben1shoga", Source::URL.profile_url("https://xfolio.jp/en/portfolio/ben1shoga/works"))

      assert_not(Source::URL.profile_url?("https://xfolio.jp/"))
      assert_not(Source::URL.profile_url?("https://xfolio.jp/en"))
      assert_not(Source::URL.profile_url?("https://xfolio.jp/portfolio"))
      assert_not(Source::URL.profile_url?("https://xfolio.jp/en/portfolio"))

      assert_equal("ben1shoga", Source::URL.parse("https://xfolio.jp/portfolio/ben1shoga").username)
      assert_equal("237599", Source::URL.parse("https://xfolio.jp/portfolio/ben1shoga/works/237599").work_id)
    end
  end
end
