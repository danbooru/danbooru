require 'test_helper'

module Sources
  class FanboxTest < ActiveSupport::TestCase
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
        download_size: 431_225,
        tags: [
          ["栗山やんみ", "https://fanbox.cc/tags/栗山やんみ"], ["VTuber", "https://fanbox.cc/tags/VTuber"], ["三面図", "https://fanbox.cc/tags/三面図"],
          ["イラスト", "https://fanbox.cc/tags/イラスト"], ["ロゴデザイン", "https://fanbox.cc/tags/ロゴデザイン"], ["モデリング", "https://fanbox.cc/tags/モデリング"],
        ],
        artist_name: "yanmi0308",
        display_name: "栗山やんみ"
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
        download_size: 245_678,
        artist_name: "chanxco",
        display_name: "CHANxCO"
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
        download_size: 320_056,
        artist_name: "chanxco",
        display_name: "CHANxCO"
      )
    end

    context "An age-restricted Fanbox post" do
      strategy_should_work(
        "https://mfr.fanbox.cc/posts/1306390",
        image_urls: ["https://downloads.fanbox.cc/images/post/1306390/VOXblkyvltL5fRhMoR7RdSkk.png"],
        artist_name: "mfr",
        artist_commentary_desc: "これからセックスしまーす♪と言ってるシーン(･ω･｀)\nhttps://downloads.fanbox.cc/images/post/1306390/VOXblkyvltL5fRhMoR7RdSkk.png\n※海苔強化して再アップしました( 'A`;)\n",
        profile_url: "https://mfr.fanbox.cc"
      )
    end

    context "A cover image" do
      strategy_should_work(
        "https://pixiv.pximg.net/c/1620x580_90_a2_g5/fanbox/public/images/creator/1566167/cover/QqxYtuWdy4XWQx1ZLIqr4wvA.jpeg",
        download_size: 750_484,
        profile_url: "https://omu001.fanbox.cc"
      )
    end

    context "A post in the old pixiv format" do
      strategy_should_work(
        "https://www.pixiv.net/fanbox/creator/1566167/post/39714",
        page_url: "https://omu001.fanbox.cc/posts/39714",
        profile_url: "https://omu001.fanbox.cc"
      )
    end

    context "A dead profile picture in the old pixiv format" do
      strategy_should_work(
        "https://pixiv.pximg.net/c/400x400_90_a2_g5/fanbox/public/images/creator/29999491/profile/Ew6fOhLGPvmUcwU6FyH8JAMX.jpeg",
        profile_url: "https://deaver0211.fanbox.cc"
      )
    end

    should "Parse Fanbox URLs correctly" do
      assert_equal("https://www.pixiv.net/fanbox/creator/1566167", Source::URL.page_url("https://pixiv.pximg.net/c/400x400_90_a2_g5/fanbox/public/images/creator/1566167/profile/Ix6bnJmTaOAFZhXHLbWyIY1e.jpeg"))

      assert(Source::URL.image_url?("https://pixiv.pximg.net/c/936x600_90_a2_g5/fanbox/public/images/plan/4635/cover/L6AZNneFuHW6r25CHHlkpHg4.jpeg"))
      assert(Source::URL.image_url?("https://pixiv.pximg.net/c/400x400_90_a2_g5/fanbox/public/images/creator/1566167/profile/Ix6bnJmTaOAFZhXHLbWyIY1e.jpeg"))
      assert(Source::URL.image_url?("https://downloads.fanbox.cc/images/post/39714/JvjJal8v1yLgc5DPyEI05YpT.png"))

      assert(Source::URL.page_url?("https://www.fanbox.cc/@tsukiori/posts/1080657"))
      assert(Source::URL.page_url?("https://www.pixiv.net/fanbox/creator/1566167/post/39714"))
      assert(Source::URL.page_url?("https://omu001.fanbox.cc/posts/39714"))

      assert(Source::URL.profile_url?("https://www.pixiv.net/fanbox/creator/1566167"))
      assert(Source::URL.profile_url?("https://pixiv.net/fanbox/creator/1566167"))
      assert(Source::URL.profile_url?("https://www.pixiv.net/fanbox/member.php?user_id=3410642"))
      assert(Source::URL.profile_url?("https://pixiv.net/fanbox/member.php?user_id=3410642"))
      assert(Source::URL.profile_url?("https://omu001.fanbox.cc"))
      assert(Source::URL.profile_url?("https://www.fanbox.cc/@tsukiori"))
      assert_not(Source::URL.profile_url?("https://www.fanbox.cc"))
      assert_not(Source::URL.profile_url?("https://fanbox.cc"))
    end
  end
end
