require "test_helper"

module Source::Tests::Extractor
  class ForiioExtractorTest < ActiveSupport::ExtractorTestCase
    context "A Foriio post with a single image" do
      strategy_should_work(
        "https://www.foriio.com/works/364622",
        image_urls: %w[https://img.foriio.com/images/r/im_AT9deWzUD-NWfS8237_Cm4JuoWaq9gc-xQnT7-cTcDS_WJ5xqb4?w=10000&fit=max],
        media_files: [{ file_size: 419_793 }],
        page_url: "https://www.foriio.com/works/364622",
        profile_url: "https://www.foriio.com/mokoxmoko2",
        profile_urls: %w[https://www.foriio.com/mokoxmoko2 https://twitter.com/gumaguma_m],
        display_name: "moko",
        username: "mokoxmoko2",
        other_names: ["moko", "mokoxmoko2"],
        dtext_artist_commentary_title: "221004 2",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A Foriio post with multiple images" do
      strategy_should_work(
        "https://www.foriio.com/works/698354",
        image_urls: %w[
          https://img.foriio.com/images/r/im_AQq-p4wjfmaQBX5DuPNHZT-UwhPEpSK5pyrlGcpm-Rsl0u9bLDY?w=10000&fit=max
          https://img.foriio.com/images/r/im_AUkXLry-qE-AqPHveAQFK0zn1XE-_3USHYP7t9sWuaSRFo_Ojls?w=10000&fit=max
          https://img.foriio.com/images/r/im_AQc3elaEWkM3DitTtgewkNIRyPaWHJXc2ZxgSFZQdkBaFZFe3RU?w=10000&fit=max
        ],
        media_files: [
          { file_size: 156_873 },
          { file_size: 286_139 },
          { file_size: 641_547 },
        ],
        page_url: "https://www.foriio.com/works/698354",
        profile_urls: %w[https://www.foriio.com/yumenkmc https://twitter.com/yumenkmc],
        display_name: "𝗇𝖾𝗄𝗈𝗆𝗈🐾",
        username: "yumenkmc",
        tags: [],
        dtext_artist_commentary_title: "おどロボ / 海茶 feat. 琴葉姉妹 with ずんだもん - MV用イラスト・ドットアニメーション",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          海茶さんの「おどロボ / 琴葉姉妹 with ずんだもん」のMV用イラストとピクセルアートを制作させていただきました。

          ボカコレ2023夏 ルーキーランキング1位作品

          N⇢
          https://www.nicovideo.jp/watch/sm42574301

          Y⇢
          https://youtu.be/D_UC0WJmLnc
        EOS
      )
    end

    context "A R-18 Foriio post" do
      strategy_should_work(
        "https://www.foriio.com/works/508125",
        image_urls: %w[
          https://img.foriio.com/images/r/im_AbEYqgtQNMUa1SoezBQI2jFqb3Tl4vzM-v2ooZbrXMFB9vkdeNg?w=10000&fit=max
          https://img.foriio.com/images/r/im_AdMWQ_hXAlPwTZCcGi7Binv8xxijSYNQ1yczOzNzmNAM7_YP4oA?w=10000&fit=max
        ],
        media_files: [
          { file_size: 214_821 },
          { file_size: 230_371 },
        ],
        page_url: "https://www.foriio.com/works/508125",
        profile_url: "https://www.foriio.com/piyu-ruru",
        profile_urls: %w[https://www.foriio.com/piyu-ruru https://twitter.com/piyu_ruru],
        display_name: "ぴゆるる",
        username: "piyu-ruru",
        other_names: ["ぴゆるる", "piyu-ruru"],
        dtext_artist_commentary_title: "●●★●●●●● / Sample",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Skeb向けサンプル① / 脱ぎ差分

          Sample for NSFW Skeb requests①
          take off difference
        EOS
      )
    end

    context "A deleted Foriio post" do
      strategy_should_work(
        "https://www.foriio.com/works/275072",
        image_urls: [],
        page_url: "https://www.foriio.com/works/275072",
        profile_url: nil,
        profile_urls: %w[],
        display_name: nil,
        username: nil,
        other_names: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end
  end
end
