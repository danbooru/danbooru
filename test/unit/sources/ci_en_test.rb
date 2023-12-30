require 'test_helper'

module Sources
  class CiEnTest < ActiveSupport::TestCase
    def setup
      skip "ci_en_session cookie not set" unless Danbooru.config.ci_en_session_cookie.present?
    end

    context "An all-ages article url" do
      strategy_should_work(
        "https://ci-en.net/creator/492/article/1004190",
        page_url: "https://ci-en.net/creator/492/article/1004190",
        image_urls: [
          %r!https://media\.ci-en\.jp/private/attachment/creator/00000492/fb4e76d52cebb915acf048ad2eb1a0a58cea4269a4e79194fde6624726e1f771/upload/83_pixiv_s\.jpg!,
        ],
        media_files: [
          { file_size: 463_147 },
        ],
        profile_urls: [
          "https://ci-en.net/creator/492",
        ],
        artist_name: "ミックス ステーション",
        tag_name: "cien_492",
        tags: ["キック", "バトルメイド", "リクエスト"],
        dtext_artist_commentary_title: "戦うバトルメイド！",
        dtext_artist_commentary_desc: <<~EOS.chomp
          カラーラフリクエストで描いたキックするバトルメイドです。関連のあるキャラ退魔シスターをメインにしたCG集もあります。
          退魔シスターAuxesia(アウクセシアー)
          <https://www.dlsite.com/home/work/=/product_id/RJ322647.html>
          Twitterです。
          <https://twitter.com/YadogenMix>
          フォローしていただけたら幸いです。
        EOS
      )
    end

    context "An R18 article url" do
      strategy_should_work(
        "https://ci-en.dlsite.com/creator/12924/article/733140",
        page_url: "https://ci-en.net/creator/12924/article/733140",
        image_urls: [
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/89d0417b09c3aafda23e7a02931d60fb179ee0f1a0f77d245797accd2979371d/upload/main_378b7bcd-3a89-4f98-b51e-4188ad802509\.jpg!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/b06a35213c77ef64d72a19fbf0981097d1151393e855bd271688ffe1af1df2ed/video-web\.mp4!,
        ],
        media_files: [
          { file_size: 85_171 },
          { file_size: 4_015_039 },
        ],
        profile_urls: [
          "https://ci-en.net/creator/12924",
        ],
        artist_name: "あまちゃ/おぽぽわーるど",
        tag_name: "cien_12924",
        tags: ["動画", "アニメ", "ゲーム", "R-18"],
        dtext_artist_commentary_title: "ショートストーリー付きR-18動画ゲーム制作のお知らせ",
        dtext_artist_commentary_desc: <<~EOS.chomp
          h1. R-18動画制作のお知らせ
          初めまして、あまちゃと申します。
          この度、新しくLIVE2Dを使った動画やゲームの制作を始めることとなりまして、活動報告の場としてCi-enを始めました。
          現在、イラストレーターのJIMA先生と共同でR-18動画の制作を開始しておりまして、そちらの進捗を紹介します。
          h2. 内容について
          
          
          ・JIMA先生が描かれるキャラクター、「あくまっこちゃん」をテーマにしたR-18動画の制作
          ・アプリ形式で動画を切り替えるシステム
          ・アドベンチャー形式のショートストーリー主にこちらを制作しております！
          JIMA先生の美麗で煽情的なイラストをLIVE2DでよりHに皆様にお届けできればと思いますのでご期待ください！
          また、ショートストーリーについてもJIMA先生監修のもと、制作しております。
          ここでしか見られない「あくまっこちゃん」のキャラクターを是非お楽しみに！
          
          完成後はDLsite等で販売の予定となります。（2023年今冬のリリースを目標）
          ※ゲーム形式の制作をするのは初めてなこともあり作業が遅延しがちになっています。気長に完成をお待ちください。
          h2. 制作中動画を少しだけ特別公開！
          こんな感じの動画を色々なシチュエーションで制作中となります。
          動画化するイラストについては下記のファンサイトで先行公開中です！
          じま (JIMA)
          【FANBOX】<https://b0o367po.fanbox.cc/posts>
          【fantia】<https://fantia.jp/fanclubs/84283>
        EOS
      )
    end

    context "A self-introduction article" do
      strategy_should_work(
        "https://ci-en.dlsite.com/creator/15496",
        page_url: "https://ci-en.net/creator/15496",
        image_urls: [
          %r!https://media\.ci-en\.jp/private/attachment/creator/00015496/763e7e9d7b6180b3b5a96cec735ecfabe993b7b4b4202bd411a471d3b7452a56/upload/1\.png!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00015496/101ddf6e8874c70b7075b2449cdc106fe66a9a797890f32350bd75d4a6954e5e/upload/05\.jpg!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00015496/181d03ba9346bedde4e541204fd628464931837f47dbea269ba3fed02e3fc21b/upload/%EF%BC%90%EF%BC%91\.jpg!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00015496/775b1249e43702ef746bba5bd2404352844e16d3a45b2de96fb86e8931d1f493/upload/%EF%BC%90%EF%BC%92\.jpg!,
        ],
        media_files: [
          { file_size: 8_432_538 },
          { file_size: 1_056_744 },
          { file_size: 906_897 },
          { file_size: 650_843 },
        ],
        profile_urls: [
          "https://ci-en.net/creator/15496",
        ],
        artist_name: "るりり",
        tag_name: "cien_15496",
        tags: [],
      )
    end

    should "Parse Ci-En URLs correctly" do
      assert(Source::URL.image_url?("https://media.ci-en.jp/private/attachment/creator/00011019/62a643d6423c18ec1be16826d687cefb47d8304de928a07c6389f8188dfe6710/image-800.jpg?px-time=1700517240&px-hash=eb626eafb7e5733c96fb0891188848dac10cb84c"))
      assert(Source::URL.image_url?("https://media.ci-en.jp/private/attachment/creator/00011019/62a643d6423c18ec1be16826d687cefb47d8304de928a07c6389f8188dfe6710/upload/%E3%81%B0%E3%81%AB%E3%81%A3%E3%81%A1A.jpg?px-time=1700517240&px-hash=eb626eafb7e5733c96fb0891188848dac10cb84c"))

      assert(Source::URL.page_url?("https://ci-en.jp/creator/922/article/23700"))
      assert(Source::URL.page_url?("https://ci-en.net/creator/11019/article/921762"))
      assert(Source::URL.page_url?("https://ci-en.dlsite.com/creator/5290/article/998146"))
      assert_not(Source::URL.profile_url?("https://ci-en.jp/creator/922/article/23700"))
      assert_not(Source::URL.profile_url?("https://ci-en.net/creator/11019/article/921762"))
      assert_not(Source::URL.profile_url?("https://ci-en.dlsite.com/creator/5290/article/998146"))
      assert_equal("https://ci-en.net/creator/922/article/23700", Source::URL.page_url("https://ci-en.jp/creator/922/article/23700"))
      assert_equal("https://ci-en.net/creator/5290/article/998146", Source::URL.page_url("https://ci-en.dlsite.com/creator/5290/article/998146"))

      assert(Source::URL.page_url?("https://ci-en.jp/creator/922"))
      assert(Source::URL.page_url?("https://ci-en.net/creator/11019"))
      assert(Source::URL.page_url?("https://ci-en.dlsite.com/creator/5290"))
      assert(Source::URL.profile_url?("https://ci-en.jp/creator/922"))
      assert(Source::URL.profile_url?("https://ci-en.net/creator/11019"))
      assert(Source::URL.profile_url?("https://ci-en.dlsite.com/creator/5290"))
      assert_equal("https://ci-en.net/creator/5290", Source::URL.page_url("https://ci-en.dlsite.com/creator/5290"))
      assert_equal("https://ci-en.net/creator/5290", Source::URL.profile_url("https://ci-en.dlsite.com/creator/5290"))
      assert_equal("https://ci-en.net/creator/922", Source::URL.page_url("https://ci-en.jp/creator/922"))
      assert_equal("https://ci-en.net/creator/922", Source::URL.profile_url("https://ci-en.jp/creator/922"))

      assert(Source::URL.page_url?("https://ci-en.net/creator/11019/article/"))
      assert(Source::URL.profile_url?("https://ci-en.net/creator/11019/article/"))

      assert_not(Source::URL.profile_url?("https://ci-en.net/creator"))

      assert_equal("11019", Source::URL.parse("https://ci-en.net/creator/11019/article/921762").creator_id)
      assert_equal("921762", Source::URL.parse("https://ci-en.net/creator/11019/article/921762").article_id)

      assert_equal("11019", Source::URL.parse("https://ci-en.net/creator/11019").creator_id)
      assert_nil(Source::URL.parse("https://ci-en.net/creator/11019").article_id)
    end
  end
end
