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
          カラーラフリクエストで描いたキックするバトルメイドです。

          関連のあるキャラ退魔シスターをメインにしたCG集もあります。
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
          %r!https://media\.ci-en\.jp/public/article_cover/creator/00012924/e3325a27a31c22516c8b717e729fcc09a89c3d8485af6f1af3013917d3181290/image-1280-c\.jpg!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/89d0417b09c3aafda23e7a02931d60fb179ee0f1a0f77d245797accd2979371d/upload/main_378b7bcd-3a89-4f98-b51e-4188ad802509\.jpg!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/b06a35213c77ef64d72a19fbf0981097d1151393e855bd271688ffe1af1df2ed/video-web\.mp4!,
        ],
        media_files: [
          { file_size: 126_100 },
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
          ・アドベンチャー形式のショートストーリー

          主にこちらを制作しております！

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

    context "An article with images and videos" do
      strategy_should_work(
        "https://ci-en.dlsite.com/creator/12924/article/1031385",
        page_url: "https://ci-en.net/creator/12924/article/1031385",
        image_urls: [
          %r!https://media\.ci-en\.jp/public/article_cover/creator/00012924/3ed655ddd544fd230e1c0444078f7a5c5953ef45a68db108295b607f9f4e4196/image-1280-c\.jpg!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/6e26c981273ebe6c7c7cb4ee00f4fd9b795d044876839f26a9892db3970a617a/upload/%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%BC%E3%83%B3%E3%82%B7%E3%83%A7%E3%83%83%E3%83%88%202023-11-11%20144943\.png!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/0ce345937988e41e0027c6376db82584d48fd8050c3262e125505e665399ecef/upload/%E3%82%AD%E3%83%A3%E3%83%A9%E7%B4%B9%E4%BB%8B%E7%94%A8%E3%82%B7%E3%82%A8%E3%83%B3\.png!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/46dfe232c372cdf3665726657a7842011960156b2654d521d13d05a43a2ddd07/upload/%E6%AD%A9%E3%81%8D%E3%83%89%E3%83%83%E3%83%882\.png!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/c0e7cee13990f34c993ac81a0d404e18ae3f956223e23ff8464e946b090deac2/upload/%E7%9D%80%E6%9B%BF%E3%81%881\.png!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/84ed22e5b9fdcebcdd4277e38eb3e1846c386009e137f8940dafb589fe2178b4/upload/%E3%82%AD%E3%83%A3%E3%83%A9%E7%B4%B9%E4%BB%8B%E7%94%A8%E3%82%A2%E3%83%AA%E3%82%B9%E7%84%A1%E4%BF%AE%E6%AD%A3\.png!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/d4b6c0fce1c229d9d2d236577817273595d8214d5dea99fba1319e02d971e067/upload/%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%BC%E3%83%B3%E3%82%B7%E3%83%A7%E3%83%83%E3%83%88%202023-12-17%20170228\.png!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/e0b3f618e3302434cd873140ed6afdcfa72f22907da994938d91cdbe2d7bba72/upload/%E3%82%A8%E3%83%AD%E3%83%89%E3%83%83%E3%83%88\.png!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/19f0db879cebbd78ddd8a4292088d0b0bd6bfe1af900081e89ae29c144f9e8a5/video-web\.mp4!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/b19e10a566e91bcf1e57ffbc02146e532f18fb1e76f6db0f34635513ce4260c0/upload/%E3%82%AD%E3%83%A3%E3%83%A9%E7%B4%B9%E4%BB%8B%E7%94%A8%E3%82%B7%E3%83%A3%E3%83%AB%E3%83%AD%E3%83%83%E3%83%88_%E7%84%A1%E4%BF%AE%E6%AD%A3\.png!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/a0cf83f3ccab6b340be9b4b3b0f951a1c0aa29f924e4159a2c88fe9d9d9ed3b2/upload/bandicam%202023-12-24%2021-31-01-029\.jpg!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/caaace96f152728a39341e4edf6af299ce2582bdd8eac280f0994095d86b0507/upload/bandicam%202023-12-24%2021-31-42-255\.jpg!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/8c5a1242338c79bf2412b9d6442ed1f2ff9a1b20332a45d3681b29c5a2e499c0/upload/bandicam%202023-12-24%2021-31-55-221\.jpg!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/81c4b559021dca6835e6e54029e9bf0f5262aa6e58210dbdeb493f1c3928ec8f/upload/bandicam%202023-12-24%2021-32-06-796\.jpg!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/4731c3978225ddd2da5b347a1e8d05b127dcd8c05d3397abb4e1f6516e80dd07/upload/bandicam%202023-12-24%2021-35-54-698\.jpg!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/58ac85fa305191ee8cc3361ff4fcb79e391bdad2333cae16684d15355d5e875d/upload/bandicam%202023-12-24%2021-36-06-038\.jpg!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/0432ce59d558108f64cb2b3c873e307d0ceb522d336cf26d61a2092d938a2df4/upload/bandicam%202023-12-24%2021-36-16-202\.jpg!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/79d1408d98d4660e49ba8735a222bfe796f91f6d820623c8f32cf5f15d7c36a7/upload/bandicam%202023-12-24%2021-36-22-697\.jpg!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/3264f4ef1ca1a81f8c9b7b6478b04544981d1fbd379f240392c22ba5fd6f5261/upload/%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%BC%E3%83%B3%E3%82%B7%E3%83%A7%E3%83%83%E3%83%88%202023-12-25%20000405\.png!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/239d41991099961ba18f737dbfbc0858fd226c78b76d89fb4ccb60cc0619633f/upload/%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%BC%E3%83%B3%E3%82%B7%E3%83%A7%E3%83%83%E3%83%88%202023-12-25%20000524\.png!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00012924/eeaf3644cf557bdd2a847599dbc26b9264292ffba8b8b0077bd95947a086b62c/upload/%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%BC%E3%83%B3%E3%82%B7%E3%83%A7%E3%83%83%E3%83%88%202023-12-24%20230929\.png!,
        ],
        profile_urls: [
          "https://ci-en.net/creator/12924",
        ],
        artist_name: "あまちゃ/おぽぽわーるど",
        tag_name: "cien_12924",
        tags: %w[r-18 つるぺた ゲーム]
      )
    end

    context "A self-introduction article" do
      strategy_should_work(
        "https://ci-en.dlsite.com/creator/15496",
        page_url: "https://ci-en.net/creator/15496",
        image_urls: [
          %r!https://media\.ci-en\.jp/public/cover/creator/00015496/d9abf3b919895d05a86253172e675dd5307ae7c6667313c20ddc39ab79bdd09f/image-990-c\.jpg!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00015496/763e7e9d7b6180b3b5a96cec735ecfabe993b7b4b4202bd411a471d3b7452a56/upload/1\.png!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00015496/3fa9791b911ba5b829cfe522d1ad0283893aa3d19c43de4663ea5bb9e4ff440b/upload/1\.jpg!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00015496/177e0028ad18cf14d6e7b651f8f6db4c2c7e93914a76dc079ffb1865c4102ee6/upload/2\.jpg!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00015496/775b1249e43702ef746bba5bd2404352844e16d3a45b2de96fb86e8931d1f493/upload/%EF%BC%90%EF%BC%92\.jpg!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00015496/5cf725ab76a4256d5fcb22582f6e2f0343af6e5445b2ca7649ad11024cb0a416/upload/3\.jpg!,
          %r!https://media\.ci-en\.jp/private/attachment/creator/00015496/2799747b90b7f03a61b25e88688de0ef6bfe0ce20b953380eabb7a9fcd05c041/upload/4\.jpg!,
        ],
        media_files: [
          { file_size: 40_080 },
          { file_size: 8_432_538 },
          { file_size: 1_234_094 },
          { file_size: 1_068_671 },
          { file_size: 650_843 },
          { file_size: 552_952 },
          { file_size: 480_569 },
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

      assert_equal("11019", Source::URL.parse("https://media.ci-en.jp/private/attachment/creator/00011019/62a643d6423c18ec1be16826d687cefb47d8304de928a07c6389f8188dfe6710/image-web.jpg?px-time=1703968668&px-hash=9497dce5fa56c5081413ad1126e06d6f44f0ab3e").creator_id)
      assert_equal("11019", Source::URL.parse("https://media.ci-en.jp/public/cover/creator/00011019/ae96c79d7626c8127bfe9823111601d3b566977d19c3aa0409de4ef838f8dc12/image-990-c.jpg").creator_id)

      assert_not(Source::URL.page_url?("https://media.ci-en.jp/private/attachment/creator/00011019/62a643d6423c18ec1be16826d687cefb47d8304de928a07c6389f8188dfe6710/image-web.jpg?px-time=1703968668&px-hash=9497dce5fa56c5081413ad1126e06d6f44f0ab3e"))
      assert_not(Source::URL.page_url?("https://media.ci-en.jp/public/cover/creator/00011019/ae96c79d7626c8127bfe9823111601d3b566977d19c3aa0409de4ef838f8dc12/image-990-c.jpg"))
    end
  end
end
