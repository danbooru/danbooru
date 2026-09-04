require "test_helper"

module Source::Tests::Extractor
  class XfolioExtractorTest < ActiveSupport::ExtractorTestCase
    setup { skip "xfolio_session cookie not configured" unless Source::Extractor::Xfolio.enabled? }

    context "A https://xfolio.jp/portfolio/:artist_name/works/:work_id url" do
      strategy_should_work(
        "https://xfolio.jp/en/portfolio/chiyo/works/290949",
        image_urls: %w[https://xfolio.jp/user_asset.php?id=1404207&work_id=290949&work_image_id=1404207&type=work_image],
        media_files: [{ file_size: 876_232 }],
        page_url: "https://xfolio.jp/portfolio/chiyo/works/290949",
        profile_url: "https://xfolio.jp/portfolio/chiyo",
        profile_urls: %w[https://xfolio.jp/portfolio/chiyo],
        display_name: "チヨ",
        username: "chiyo",
        published_at: nil,
        updated_at: nil,
        tags: [
          ["イラスト", "https://xfolio.jp/search?words=\"%E3%82%A4%E3%83%A9%E3%82%B9%E3%83%88\" in:カテゴリ&creator_code_from=chiyo&tab=illust"],
          ["チヨ", "https://xfolio.jp/search?words=\"%E3%83%81%E3%83%A8\" in:クリエイター&creator_code_from=chiyo&tab=illust"],
          ["一次創作", "https://xfolio.jp/search?words=\"%E4%B8%80%E6%AC%A1%E5%89%B5%E4%BD%9C\" in:その他&creator_code_from=chiyo&tab=illust"],
          ["オリジナル", "https://xfolio.jp/search?words=\"%E3%82%AA%E3%83%AA%E3%82%B8%E3%83%8A%E3%83%AB\" in:その他&creator_code_from=chiyo&tab=illust"],
          ["風景", "https://xfolio.jp/search?words=\"%E9%A2%A8%E6%99%AF\" in:その他&creator_code_from=chiyo&tab=illust"],
          ["背景", "https://xfolio.jp/search?words=\"%E8%83%8C%E6%99%AF\" in:その他&creator_code_from=chiyo&tab=illust"],
          ["夏", "https://xfolio.jp/search?words=\"%E5%A4%8F\" in:その他&creator_code_from=chiyo&tab=illust"],
        ],
        dtext_artist_commentary_title: "納涼",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A xfolio post with bot check enabled" do
      setup { skip "This post requires a captcha." }

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
        username: "riku_mochiduki",
      )
    end
  end
end
