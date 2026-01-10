require "test_helper"

module Source::Tests::Extractor
  class FanboxExtractorTest < ActiveSupport::TestCase
    context "A free Pixiv Fanbox post" do
      strategy_should_work(
        "https://yanmi0308.fanbox.cc/posts/1141325",
        image_urls: %w[
          https://downloads.fanbox.cc/images/post/1141325/q7GaJ0A9J5Uz8kvEAUizHJoN.png
          https://downloads.fanbox.cc/images/post/1141325/LMJz0sAig5h9D3rPZGCEGniZ.png
          https://downloads.fanbox.cc/images/post/1141325/dRSz380Uf3N8s4pT2ADEXBco.png
          https://downloads.fanbox.cc/images/post/1141325/h48L2mbm39qqNUB1abLAvzvg.png
        ],
        artist_commentary_title: "栗山やんみ（デザイン）",
        artist_commentary_desc: "˗ˋˏ Special Thanks ˎˊ˗   (敬称略)\n\n🎨キャラクターデザイン\n特急みかん  https://twitter.com/tokkyuumikan\n\n🤖3Dモデリング\n（仮）  https://twitter.com/Admiral_TMP\n\n⚙プログラミング\n神無月ユズカ  https://twitter.com/Kannaduki_Yzk\n\n🎧OP・EDミュージック\n卓球少年  https://twitter.com/takkyuu_s\n\n📻BGM\nC  https://twitter.com/nica2c\n\n🖌ロゴデザイン\nてづかもり  https://twitter.com/tezkamori\n\n🎨SDキャラクター\nAZU。  https://twitter.com/tokitou_aaa",
        page_url: "https://yanmi0308.fanbox.cc/posts/1141325",
        profile_url: "https://yanmi0308.fanbox.cc",
        display_name: "栗山やんみ",
        username: "yanmi0308",
        media_files: [
          { file_size: 431_225 },
          { file_size: 753_048 },
          { file_size: 589_327 },
          { file_size: 178_739 },
        ],
        tags: [
          ["栗山やんみ", "https://fanbox.cc/tags/栗山やんみ"], ["VTuber", "https://fanbox.cc/tags/VTuber"], ["三面図", "https://fanbox.cc/tags/三面図"],
          ["イラスト", "https://fanbox.cc/tags/イラスト"], ["ロゴデザイン", "https://fanbox.cc/tags/ロゴデザイン"], ["モデリング", "https://fanbox.cc/tags/モデリング"],
        ],
      )
    end

    context "A free Pixiv Fanbox post with embedded pics" do
      strategy_should_work(
        "https://chanxco.fanbox.cc/posts/209386",
        image_urls: %w[
          https://downloads.fanbox.cc/images/post/209386/Q8rZ0iMHpcmJDACEzNGjTj9E.jpeg
          https://downloads.fanbox.cc/images/post/209386/8dRNHXkFqAwSt31W2Bg8fSdL.jpeg
          https://downloads.fanbox.cc/images/post/209386/AGGWF0JxytFcNL2ybPKBaqp7.jpeg
        ],
        artist_commentary_title: "水着BBちゃん＋アラフィフ＋ライダーさん",
        artist_commentary_desc: "今週のらくがきまとめ\n\nhttps://downloads.fanbox.cc/images/post/209386/Q8rZ0iMHpcmJDACEzNGjTj9E.jpeg\n水着BBちゃん\n第一再臨もなかなかセクシー\nhttps://downloads.fanbox.cc/images/post/209386/8dRNHXkFqAwSt31W2Bg8fSdL.jpeg\nアラフィフ\n男キャラも描いていこうと練習中\n新宿での軽いキャラも好き\nhttps://downloads.fanbox.cc/images/post/209386/AGGWF0JxytFcNL2ybPKBaqp7.jpeg\nライダーさん\nつい眼鏡も描いてしまう\n\n＃FGO\n",
        page_url: "https://chanxco.fanbox.cc/posts/209386",
        profile_url: "https://chanxco.fanbox.cc",
        display_name: "CHANxCO",
        username: "chanxco",
        media_files: [
          { file_size: 245_678 },
          { file_size: 320_056 },
          { file_size: 666_681 },
        ],
      )
    end

    context "A Pixiv Fanbox sample" do
      strategy_should_work(
        "https://downloads.fanbox.cc/images/post/209386/w/1200/8dRNHXkFqAwSt31W2Bg8fSdL.jpeg",
        image_urls: ["https://downloads.fanbox.cc/images/post/209386/8dRNHXkFqAwSt31W2Bg8fSdL.jpeg"],
        artist_commentary_title: "水着BBちゃん＋アラフィフ＋ライダーさん",
        artist_commentary_desc: "今週のらくがきまとめ\n\nhttps://downloads.fanbox.cc/images/post/209386/Q8rZ0iMHpcmJDACEzNGjTj9E.jpeg\n水着BBちゃん\n第一再臨もなかなかセクシー\nhttps://downloads.fanbox.cc/images/post/209386/8dRNHXkFqAwSt31W2Bg8fSdL.jpeg\nアラフィフ\n男キャラも描いていこうと練習中\n新宿での軽いキャラも好き\nhttps://downloads.fanbox.cc/images/post/209386/AGGWF0JxytFcNL2ybPKBaqp7.jpeg\nライダーさん\nつい眼鏡も描いてしまう\n\n＃FGO\n",
        page_url: "https://chanxco.fanbox.cc/posts/209386",
        profile_url: "https://chanxco.fanbox.cc",
        media_files: [{ file_size: 320_056 }],
        display_name: "CHANxCO",
        username: "chanxco",
      )
    end

    context "An age-restricted Fanbox post" do
      strategy_should_work(
        "https://mfr.fanbox.cc/posts/1306390",
        image_urls: ["https://downloads.fanbox.cc/images/post/1306390/VOXblkyvltL5fRhMoR7RdSkk.png"],
        artist_commentary_desc: "これからセックスしまーす♪と言ってるシーン(･ω･｀)\nhttps://downloads.fanbox.cc/images/post/1306390/VOXblkyvltL5fRhMoR7RdSkk.png\n※海苔強化して再アップしました( 'A`;)\n",
        profile_url: "https://mfr.fanbox.cc",
        display_name: "もふりる",
        username: "mfr",
      )
    end

    context "A fanbox post with multiple videos attached as files" do
      strategy_should_work(
        "https://gomeifuku.fanbox.cc/posts/3975317",
        image_urls: [
          "https://downloads.fanbox.cc/files/post/3975317/eatOUYGtAR2jESVVWkeK57px.mp4",
          "https://downloads.fanbox.cc/files/post/3975317/hbydNywJEmIlUeL5lTQfQjJi.mp4",
        ],
        display_name: "懈怠の心",
        username: "gomeifuku",
      )
    end

    context "A fanbox post with a single embedded video" do
      strategy_should_work(
        "https://hisha.fanbox.cc/posts/7268460",
        image_urls: %w[https://downloads.fanbox.cc/files/post/7268460/33CriopgBCfntPh4CQIupnFo.mp4],
        media_files: [{ file_size: 12_112_390 }],
        page_url: "https://hisha.fanbox.cc/posts/7268460",
        profile_urls: %w[https://hisha.fanbox.cc],
        display_name: "飛者",
        username: "hisha",
        tags: [
          ["タイムラプス", "https://fanbox.cc/tags/タイムラプス"],
          ["全体公開", "https://fanbox.cc/tags/全体公開"],
        ],
        dtext_artist_commentary_title: "さとり タイムラプス",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          あけましておめでとうございます～
          今年もぼちぼち頑張っていきますよー
        EOS
      )
    end

    context "A cover image" do
      strategy_should_work(
        "https://pixiv.pximg.net/c/1620x580_90_a2_g5/fanbox/public/images/creator/23800170/cover/bT4hCcuzXuoh2JWQbBXINlVV.jpeg",
        media_files: [{ file_size: 747_660 }],
        profile_url: "https://hisha.fanbox.cc",
        display_name: "飛者",
        username: "hisha",
      )
    end

    context "A post in the old pixiv format" do
      strategy_should_work(
        "https://www.pixiv.net/fanbox/creator/1539728/post/319269",
        image_urls: %w[https://downloads.fanbox.cc/images/post/319269/4NB24h1Zde4wjspQiw8Y1HGm.jpeg],
        media_files: [{ file_size: 2_023_770 }],
        page_url: "https://intokuinfo.fanbox.cc/posts/319269",
        profile_urls: %w[https://intokuinfo.fanbox.cc],
        display_name: "遠藤弘土",
        username: "intokuinfo",
        tags: [],
        dtext_artist_commentary_title: "【みんな向け】落書きその２　ドラクエ１１のベロニカ　支援者向け高解像度版（横1920 縦1080）",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          間が空いちゃって済みません！商業の方、無事に終わりまして、シュクラの方を詰めてました。
          すげーわかりやすくいうと、余剰なエッチな気をある地区に集めて、それを男たちに憑依させてエッチして解消するのがシュノン
          みたいな感じです！明日からはモノクロでチマチマあげられると思います！コーランも合わせて薦めます！

          明日から挽回したいと思いますので、明日も更新する感じでオナシャス！
        EOS
      )
    end

    context "A dead profile picture in the old pixiv format" do
      strategy_should_work(
        "https://pixiv.pximg.net/c/400x400_90_a2_g5/fanbox/public/images/creator/29999491/profile/Ew6fOhLGPvmUcwU6FyH8JAMX.jpeg",
        image_urls: %w[https://pixiv.pximg.net/c/400x400_90_a2_g5/fanbox/public/images/creator/29999491/profile/Ew6fOhLGPvmUcwU6FyH8JAMX.jpeg], # 404
        page_url: "https://verdey1104.fanbox.cc",
        profile_urls: %w[https://verdey1104.fanbox.cc],
        display_name: "Verdey",
        username: "verdey1104",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    # These posts are still accessible in the API even though the HTML returns an error.
    context "An 'access is restricted for this user' Fanbox post" do
      strategy_should_work(
        "https://eclipsehake.fanbox.cc/posts/4246830",
        page_url: "https://eclipsehake.fanbox.cc/posts/4246830",
        profile_url: "https://eclipsehake.fanbox.cc",
        image_urls: ["https://downloads.fanbox.cc/images/post/4246830/XUW76l3mT1yxkjbMTVeMow4w.jpeg"],
        display_name: "北白 中三",
        username: "eclipsehake",
        artist_commentary_title: "シアリュ―",
        artist_commentary_desc: <<~EOS.chomp,
          🐉👻♂

          臆病な性格 / 物音に敏感

          175cm　享年20歳

          旅パ会社の期待の新人。享年20歳(推定)のアンデッド。生前の記憶が殆ど無く彷徨っていた所をスカウトされ就職。霊符で式神的なモノを呼び出して戦う。お人好しで頼まれ事は断れないタイプ。
        EOS
        tags: [],
      )
    end

    context "A Fanbox post with missing imageIds" do
      strategy_should_work(
        "https://www.fanbox.cc/@asdkd123/posts/10274875",
        image_urls: %w[
          https://downloads.fanbox.cc/images/post/10274875/N7wxp4ikGcGKavDI2WFAvR5D.png
          https://downloads.fanbox.cc/images/post/10274875/jIIOsS079oyxTpmESgQNX3Rf.png
          https://downloads.fanbox.cc/images/post/10274875/xDqYK8sBjY2VIWCsyQMCTvxJ.png
        ],
        media_files: [
          { file_size: 8_804_311 },
          { file_size: 8_845_871 },
          { file_size: 8_921_414 },
        ],
        page_url: "https://asdkd123.fanbox.cc/posts/10274875",
        profile_urls: %w[https://asdkd123.fanbox.cc],
        display_name: "asdkd123",
        username: "asdkd123",
        tags: [
          ["Uma", "https://fanbox.cc/tags/Uma"],
          ["全体公開", "https://fanbox.cc/tags/全体公開"],
        ],
        dtext_artist_commentary_title: "ファル子〇ー2025.7.24",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          https://downloads.fanbox.cc/images/post/10274875/N7wxp4ikGcGKavDI2WFAvR5D.png

          https://downloads.fanbox.cc/images/post/10274875/jIIOsS079oyxTpmESgQNX3Rf.png

          https://downloads.fanbox.cc/images/post/10274875/xDqYK8sBjY2VIWCsyQMCTvxJ.png
        EOS
      )
    end

    context "A deleted Fanbox post" do
      strategy_should_work(
        "https://wakura081.fanbox.cc/posts/4923490",
        page_url: "https://wakura081.fanbox.cc/posts/4923490",
        profile_url: "https://wakura081.fanbox.cc",
        image_urls: [],
        display_name: "わくら",
        username: "wakura081",
        artist_commentary_title: nil,
        artist_commentary_desc: nil,
        tags: [],
      )
    end
  end
end
