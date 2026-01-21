require "test_helper"

module Source::Tests::Extractor
  class CiEnExtractorTest < ActiveSupport::ExtractorTestCase
    def setup
      skip "ci_en_session cookie not set" unless Source::Extractor::CiEn.enabled?
    end

    context "An all-ages article url" do
      strategy_should_work(
        "https://ci-en.net/creator/492/article/1004190",
        image_urls: [%r{https://media.ci-en.jp/private/attachment/creator/00000492/fb4e76d52cebb915acf048ad2eb1a0a58cea4269a4e79194fde6624726e1f771/upload/83_pixiv_s.jpg}],
        media_files: [{ file_size: 463_147 }],
        page_url: "https://ci-en.net/creator/492/article/1004190",
        profile_urls: %w[https://ci-en.net/creator/492],
        display_name: "ミックス ステーション",
        username: nil,
        tags: %w[リクエスト バトルメイド キック],
        dtext_artist_commentary_title: "戦うバトルメイド！",
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
          %r{https://media\.ci-en\.jp/public/article_cover/creator/00012924/e3325a27a31c22516c8b717e729fcc09a89c3d8485af6f1af3013917d3181290/image-1280-c\.jpg},
          %r{https://media\.ci-en\.jp/private/attachment/creator/00012924/89d0417b09c3aafda23e7a02931d60fb179ee0f1a0f77d245797accd2979371d/upload/main_378b7bcd-3a89-4f98-b51e-4188ad802509\.jpg},
          %r{https://media\.ci-en\.jp/private/attachment/creator/00012924/b06a35213c77ef64d72a19fbf0981097d1151393e855bd271688ffe1af1df2ed/video-web\.mp4},
        ],
        media_files: [
          { file_size: 126_100 },
          { file_size: 85_171 },
          { file_size: 4_015_039 },
        ],
        profile_urls: [
          "https://ci-en.net/creator/12924",
        ],
        display_name: "あまちゃ/おぽぽわーるど",
        username: nil,
        tags: ["動画", "アニメ", "ゲーム", "R-18"],
        dtext_artist_commentary_title: "ショートストーリー付きR-18動画ゲーム制作のお知らせ",
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        image_urls: [
          "https://media.ci-en.jp/public/article_cover/creator/00012924/3ed655ddd544fd230e1c0444078f7a5c5953ef45a68db108295b607f9f4e4196/image-1280-c.jpg",
          %r{https://media.ci-en.jp/private/attachment/creator/00012924/6e26c981273ebe6c7c7cb4ee00f4fd9b795d044876839f26a9892db3970a617a/upload/%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%BC%E3%83%B3%E3%82%B7%E3%83%A7%E3%83%83%E3%83%88%202023-11-11%20144943.png},
          %r{https://media.ci-en.jp/private/attachment/creator/00012924/0ce345937988e41e0027c6376db82584d48fd8050c3262e125505e665399ecef/upload/%E3%82%AD%E3%83%A3%E3%83%A9%E7%B4%B9%E4%BB%8B%E7%94%A8%E3%82%B7%E3%82%A8%E3%83%B3.png},
          %r{https://media.ci-en.jp/private/attachment/creator/00012924/46dfe232c372cdf3665726657a7842011960156b2654d521d13d05a43a2ddd07/upload/%E6%AD%A9%E3%81%8D%E3%83%89%E3%83%83%E3%83%882.png},
          %r{https://media.ci-en.jp/private/attachment/creator/00012924/c0e7cee13990f34c993ac81a0d404e18ae3f956223e23ff8464e946b090deac2/upload/%E7%9D%80%E6%9B%BF%E3%81%881.png},
          %r{https://media.ci-en.jp/private/attachment/creator/00012924/84ed22e5b9fdcebcdd4277e38eb3e1846c386009e137f8940dafb589fe2178b4/upload/%E3%82%AD%E3%83%A3%E3%83%A9%E7%B4%B9%E4%BB%8B%E7%94%A8%E3%82%A2%E3%83%AA%E3%82%B9%E7%84%A1%E4%BF%AE%E6%AD%A3.png},
          %r{https://media.ci-en.jp/private/attachment/creator/00012924/d4b6c0fce1c229d9d2d236577817273595d8214d5dea99fba1319e02d971e067/upload/%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%BC%E3%83%B3%E3%82%B7%E3%83%A7%E3%83%83%E3%83%88%202023-12-17%20170228.png},
          %r{https://media.ci-en.jp/private/attachment/creator/00012924/e0b3f618e3302434cd873140ed6afdcfa72f22907da994938d91cdbe2d7bba72/upload/%E3%82%A8%E3%83%AD%E3%83%89%E3%83%83%E3%83%88.png},
          %r{https://media.ci-en.jp/private/attachment/creator/00012924/19f0db879cebbd78ddd8a4292088d0b0bd6bfe1af900081e89ae29c144f9e8a5/video-web.mp4},
          %r{https://media.ci-en.jp/private/attachment/creator/00012924/b19e10a566e91bcf1e57ffbc02146e532f18fb1e76f6db0f34635513ce4260c0/upload/%E3%82%AD%E3%83%A3%E3%83%A9%E7%B4%B9%E4%BB%8B%E7%94%A8%E3%82%B7%E3%83%A3%E3%83%AB%E3%83%AD%E3%83%83%E3%83%88_%E7%84%A1%E4%BF%AE%E6%AD%A3.png},
          %r{https://media.ci-en.jp/private/attachment/creator/00012924/a0cf83f3ccab6b340be9b4b3b0f951a1c0aa29f924e4159a2c88fe9d9d9ed3b2/upload/bandicam%202023-12-24%2021-31-01-029.jpg},
          %r{https://media.ci-en.jp/private/attachment/creator/00012924/caaace96f152728a39341e4edf6af299ce2582bdd8eac280f0994095d86b0507/upload/bandicam%202023-12-24%2021-31-42-255.jpg},
          %r{https://media.ci-en.jp/private/attachment/creator/00012924/8c5a1242338c79bf2412b9d6442ed1f2ff9a1b20332a45d3681b29c5a2e499c0/upload/bandicam%202023-12-24%2021-31-55-221.jpg},
          %r{https://media.ci-en.jp/private/attachment/creator/00012924/81c4b559021dca6835e6e54029e9bf0f5262aa6e58210dbdeb493f1c3928ec8f/upload/bandicam%202023-12-24%2021-32-06-796.jpg},
          %r{https://media.ci-en.jp/private/attachment/creator/00012924/4731c3978225ddd2da5b347a1e8d05b127dcd8c05d3397abb4e1f6516e80dd07/upload/bandicam%202023-12-24%2021-35-54-698.jpg},
          %r{https://media.ci-en.jp/private/attachment/creator/00012924/58ac85fa305191ee8cc3361ff4fcb79e391bdad2333cae16684d15355d5e875d/upload/bandicam%202023-12-24%2021-36-06-038.jpg},
          %r{https://media.ci-en.jp/private/attachment/creator/00012924/0432ce59d558108f64cb2b3c873e307d0ceb522d336cf26d61a2092d938a2df4/upload/bandicam%202023-12-24%2021-36-16-202.jpg},
          %r{https://media.ci-en.jp/private/attachment/creator/00012924/79d1408d98d4660e49ba8735a222bfe796f91f6d820623c8f32cf5f15d7c36a7/upload/bandicam%202023-12-24%2021-36-22-697.jpg},
          %r{https://media.ci-en.jp/private/attachment/creator/00012924/3264f4ef1ca1a81f8c9b7b6478b04544981d1fbd379f240392c22ba5fd6f5261/upload/%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%BC%E3%83%B3%E3%82%B7%E3%83%A7%E3%83%83%E3%83%88%202023-12-25%20000405.png},
          %r{https://media.ci-en.jp/private/attachment/creator/00012924/239d41991099961ba18f737dbfbc0858fd226c78b76d89fb4ccb60cc0619633f/upload/%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%BC%E3%83%B3%E3%82%B7%E3%83%A7%E3%83%83%E3%83%88%202023-12-25%20000524.png},
          %r{https://media.ci-en.jp/private/attachment/creator/00012924/eeaf3644cf557bdd2a847599dbc26b9264292ffba8b8b0077bd95947a086b62c/upload/%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%BC%E3%83%B3%E3%82%B7%E3%83%A7%E3%83%83%E3%83%88%202023-12-24%20230929.png},
        ],
        media_files: [
          { file_size: 254_675 },
          { file_size: 1_166_737 },
          { file_size: 1_423_789 },
          { file_size: 80_670 },
          { file_size: 1_077_230 },
          { file_size: 2_035_538 },
          { file_size: 49_037 },
          { file_size: 43_521 },
          { file_size: 22_064_996 },
          { file_size: 2_466_979 },
          { file_size: 441_890 },
          { file_size: 454_921 },
          { file_size: 493_590 },
          { file_size: 506_178 },
          { file_size: 531_739 },
          { file_size: 527_532 },
          { file_size: 509_285 },
          { file_size: 517_688 },
          { file_size: 199_043 },
          { file_size: 201_687 },
          { file_size: 22_551 },
        ],
        page_url: "https://ci-en.net/creator/12924/article/1031385",
        profile_urls: %w[https://ci-en.net/creator/12924],
        display_name: "あまちゃ/おぽぽわーるど",
        username: nil,
        tags: [
          ["ゲーム", "https://ci-en.dlsite.com/creator/12924/article/tag?name=%E3%82%B2%E3%83%BC%E3%83%A0"],
          ["つるぺた", "https://ci-en.dlsite.com/creator/12924/article/tag?name=%E3%81%A4%E3%82%8B%E3%81%BA%E3%81%9F"],
          ["R-18", "https://ci-en.dlsite.com/creator/12924/article/tag?name=R-18"],
        ],
        dtext_artist_commentary_title: "ロリハーレムRPG（仮）制作進捗報告⑥",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          h1. 三人目のヒロイン制作、ゲーム内シナリオ制作進行中

          お疲れ様です。あまちゃです。

          メリークリスマス！今年もきましたね、クリスマス…！
          とか気合入っていそうなことを言いましたが、私はもう寒くて眠くてこの休日は食べて寝てを繰り返すだけの休日になってしまいました。
          （この記事はさっき起きて慌てて書いています。）

          今年もあと一週間を残すのみ…1年たつのが本当に早く感じます…

          という事で今週の制作報告です。
          ・三人目のヒロイン制作（立ち絵＆ドット）

          ↓まずはこの記事が初めてという方向けに、ゲーム概要（更新する度少しずつ増えます）

          h2. ロリハーレム孕ませRPG

          魔物によっていろいろとピンチになっちゃっている街を
          [b]狩人として魔物を狩ったり、街の人のお願いを聞いたり、ついでに女の子を孕ませて人口問題解決！[/b]
          と、これまたいろいろな方法で街を救っちゃおう、みたいなゲームです。

          h2. ゲーム概要

          女の子との交流画面イメージ
          まだまだ開発中で、UIとかも凝らしたいですがこんな感じです

          進行度や調教によって「好きなもの」の内容が変わっちゃうやつです。
          ↓詳細記事はコチラ↓
          <https://ci-en.dlsite.com/creator/12924/article/999769>

          h2. ヒロイン紹介

          [b]【マリア】[/b]
          純情ちょろいんMシスター

          ↓詳細記事はコチラ↓
          <https://ci-en.dlsite.com/creator/12924/article/1005195>

          「マリアのお礼、お気に召していただけましたか…？」

          街に貢献してくれた狩人様（主人公）にお礼をするマリアちゃんです。
          （マリアちゃんは「男は下着を見せれば喜ぶ」と刷り込まれています。）

          [b]【アリス】[/b]
          活発元気っこな家庭派シスター

          ↓詳細記事はコチラ↓
          <https://ci-en.dlsite.com/creator/12924/article/1025797>

          h2. ドットHシーン制作

          ドットのエッチシーンっていいですよね…
          皆さんはドットアニメのエッチと１枚絵のエッチシーンとどちらが好みですか？
          良かったらコメントにご意見をいただけると嬉しいです。
          ↓詳細記事はコチラ↓
          <https://ci-en.dlsite.com/creator/12924/article/1009866>

          h2. 子作りえっちモード制作

          主に4つの機能を使ってエッチができます。
          ・服の切り替え
          ・ポーズの変更
          ・挿入コマンド
          ・愛撫コマンド
          実際のプレイイメージはこんな感じです。

          ↓詳細記事はコチラ↓
          <https://ci-en.dlsite.com/creator/12924/article/1020668>

          h1. ★今週の進捗★

          h2. ヒロイン紹介

          [b]【シャルロット】[/b]
          街の復興に努める領主兼お姫様

          本作3番目のヒロイン、シャルロットちゃんです。
          街に主人公を呼んだ張本人で、街の偉い人です。

          1国のお姫様でありつつ、国を治める勉強も兼ねて街の領主を務めています。
          マリアとアリスより少しお姉さん位の年齢ですが、しっかりと領主をやっているすごい人。

          ストーリーは大まかにシャルロットにガイドされながら進行します。

          マリアに「男は下着を見せれば喜ぶ」と吹き込んだ張本人です。
          必要であればそういうことも武器にしちゃいます。

          頼りにしていますよ、狩人様♪

          シャルロットちゃん、服装がシスター組より複雑なのでドットが大変だった…

          h2. おわり

          今週はシャルロットちゃんの立ち絵＆ドット制作報告のみとなります。
          残りのヒロインは2人です！
          先に言ってしまうと、スラムに住んでいる姉妹が登場します。
          こちらも報告をお楽しみにしていてください！

          それでは。

          h2. おまけ

          フォローしていただいている方向けに3人のボテ腹立ち絵公開しました。
          クリスマスはロリボテ腹を見て癒されよう…
        EOS
      )
    end

    context "A self-introduction article" do
      strategy_should_work(
        "https://ci-en.dlsite.com/creator/15496",
        image_urls: [
          %r{https://media\.ci-en\.jp/public/cover/creator/00015496/d9abf3b919895d05a86253172e675dd5307ae7c6667313c20ddc39ab79bdd09f/image-990-c\.jpg},
          %r{https://media\.ci-en\.jp/private/attachment/creator/00015496/763e7e9d7b6180b3b5a96cec735ecfabe993b7b4b4202bd411a471d3b7452a56/upload/1\.png},
          %r{https://media\.ci-en\.jp/private/attachment/creator/00015496/3fa9791b911ba5b829cfe522d1ad0283893aa3d19c43de4663ea5bb9e4ff440b/upload/1\.jpg},
          %r{https://media\.ci-en\.jp/private/attachment/creator/00015496/177e0028ad18cf14d6e7b651f8f6db4c2c7e93914a76dc079ffb1865c4102ee6/upload/2\.jpg},
          %r{https://media\.ci-en\.jp/private/attachment/creator/00015496/775b1249e43702ef746bba5bd2404352844e16d3a45b2de96fb86e8931d1f493/upload/%EF%BC%90%EF%BC%92\.jpg},
          %r{https://media\.ci-en\.jp/private/attachment/creator/00015496/5cf725ab76a4256d5fcb22582f6e2f0343af6e5445b2ca7649ad11024cb0a416/upload/3\.jpg},
          %r{https://media\.ci-en\.jp/private/attachment/creator/00015496/2799747b90b7f03a61b25e88688de0ef6bfe0ce20b953380eabb7a9fcd05c041/upload/4\.jpg},
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
        page_url: "https://ci-en.net/creator/15496",
        profile_urls: %w[https://ci-en.net/creator/15496],
        display_name: "るりり",
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          h1. こんにちは！

          ci-enにはゲーム制作やアップデート作業の進捗を公開しています。
          ここには自己紹介や作っているゲームの一部を公開します。
          ※進捗記録は開発途中のもので、予告なく変更する場合がございます。

          h2. プロフィール

          るりりと申します！

          販売開始しました！
          <https://www.dlsite.com/maniax/dlaf/=/t/s/link/work/aid/roriruri6/id/RJ01076970.html>

          今までイラストを描いて過ごしておりましたが、昨年からツクールを始め、ゲーム制作にも奮闘している日々を過ごしております。

          h2. Ci-enでの活動

          Ci-enにはゲーム制作の進捗を公開していきます。

          h3. 作っているゲームに関して

          居候してきたニートちゃんと過ごす、シミュレーションゲームを作っています。

          ２４時間、ニートちゃんと一緒に生活し、お話しして仲良くなったり、スキンシップをとったりするゲームです。おさわり要素もあったりします。
          引きこもって無知なニートちゃんに人生の楽しさを教えていく要素も入れれたらなぁと思っています。

          アップデート作業も鋭意更新中です！

          h2. 最後に

          頑張ってゲームを作ってまいりますので、御興味がありましたら、どうぞよろしくお願いいたします！
        EOS
      )
    end
  end
end
