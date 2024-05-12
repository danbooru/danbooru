require 'test_helper'

module Sources
  class PixivTest < ActiveSupport::TestCase
    setup do
      skip "Pixiv credentials not configured" unless Source::Extractor::Pixiv.enabled?
    end

    def assert_illust_id(illust_id, url)
      if illust_id.nil?
        assert_nil(Source::URL.parse(url).work_id)
      else
        assert_equal(illust_id, Source::URL.parse(url).work_id.to_i)
      end
    end

    context "Pixiv:" do
      context "A post with multiple images" do
        strategy_should_work(
          "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=49270482",
          image_urls: %w[
            https://i.pximg.net/img-original/img/2015/03/14/17/53/32/49270482_p0.jpg
            https://i.pximg.net/img-original/img/2015/03/14/17/53/32/49270482_p1.jpg
          ],
          page_url: "https://www.pixiv.net/artworks/49270482",
          profile_url: "https://www.pixiv.net/users/341433",
          artist_name: "Nardack",
          tag_name: "nardack",
          tags: %w[神崎蘭子 双葉杏 アイドルマスターシンデレラガールズ Star!! アイマス10000users入り],
          dtext_artist_commentary_title: "ツイログ",
          dtext_artist_commentary_desc: "",
        )
      end

      context "A ugoira page URL" do
        strategy_should_work(
          "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364",
          image_urls: ["https://i.pximg.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip"],
          media_files: [
            { file_size: 2804, frame_delays: [125, 125] },
          ],
          page_url: "https://www.pixiv.net/artworks/62247364",
          profile_url: "https://www.pixiv.net/users/22252953",
          artist_name: "uroobnad2",
          tag_name: "user_myeg3558",
          tags: %w[Ugoira png blue],
          dtext_artist_commentary_title: "ugoira",
          dtext_artist_commentary_desc: "",
        )
      end

      context "A https://i.pximg.net/img-zip/ugoira/* image URL" do
        strategy_should_work(
          "https://i.pximg.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip",
          image_urls: ["https://i.pximg.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip"],
          media_files: [
            { file_size: 2804, frame_delays: [125, 125] },
          ],
          page_url: "https://www.pixiv.net/artworks/62247364",
          profile_url: "https://www.pixiv.net/users/22252953",
          artist_name: "uroobnad2",
          tag_name: "user_myeg3558",
          tags: %w[Ugoira png blue],
          dtext_artist_commentary_title: "ugoira",
          dtext_artist_commentary_desc: "",
        )
      end

      context "A https://www.pixiv.net/*/artworks/* source" do
        strategy_should_work(
          "https://www.pixiv.net/en/artworks/64476642",
          image_urls: ["https://i.pximg.net/img-original/img/2017/08/18/00/09/21/64476642_p0.jpg"],
          page_url: "https://www.pixiv.net/artworks/64476642",
          profile_url: "https://www.pixiv.net/users/27207",
          artist_name: "イチリ",
          tag_name: "itiri",
          tags: %w[Fate/GrandOrder フランケンシュタイン(Fate) 水着 バーサーかわいい 新宿のアーチャー パパ製造機 Fate/GO5000users入り フランケンシュタイン(水着) セイバー(Fate)],
          dtext_artist_commentary_title: "水着フランたそ",
          dtext_artist_commentary_desc: "ますたーもひかげですずむ？",
        )
      end

      context "A deleted pixiv post" do
        strategy_should_work(
          "https://i.pximg.net/img-original/img/2018/12/30/01/04/55/72373728_p0.png",
          image_urls: ["https://i.pximg.net/img-original/img/2018/12/30/01/04/55/72373728_p0.png"],
          page_url: "https://www.pixiv.net/artworks/72373728",
          profile_url: nil,
          artist_name: nil,
          tag_name: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: "",
          deleted: true,
        )
      end

      context "A raw image URL that has been revised should get the unrevised image URL" do
        strategy_should_work(
          "https://i.pximg.net/img-original/img/2022/08/14/19/23/06/100474393_p0.png",
          deleted: true,
          image_urls: ["https://i.pximg.net/img-original/img/2022/08/14/19/23/06/100474393_p0.png"],
          dtext_artist_commentary_title: "シャイリリー",
          artist_name: "影おじ (隠れエリア)",
          profile_url: "https://www.pixiv.net/users/6570768",
          profile_urls: %w[https://www.pixiv.net/stacc/haku3490 https://www.pixiv.net/users/6570768],
          tags: %w[r-18 shylily シャイリリー バーチャルyoutuber バーチャルyoutuber30000users入り 両手に茎 乱交 輪姦]
        )
      end

      context "A post has been revised should get the revised image URLs" do
        strategy_should_work(
          "https://www.pixiv.net/en/artworks/100474393",
          image_urls: %w[
            https://i.pximg.net/img-original/img/2022/08/14/21/21/24/100474393_p0.png
            https://i.pximg.net/img-original/img/2022/08/14/21/21/24/100474393_p1.png
            https://i.pximg.net/img-original/img/2022/08/14/21/21/24/100474393_p2.png
          ],
          dtext_artist_commentary_title: "シャイリリー",
          artist_name: "影おじ (隠れエリア)",
          profile_url: "https://www.pixiv.net/users/6570768",
          profile_urls: %w[https://www.pixiv.net/stacc/haku3490 https://www.pixiv.net/users/6570768],
          tags: %w[r-18 shylily シャイリリー バーチャルyoutuber バーチャルyoutuber30000users入り 両手に茎 乱交 輪姦]
        )
      end

      context "An AI-generated post should get the AI tag" do
        strategy_should_work(
          "https://www.pixiv.net/en/artworks/103291492",
          image_urls: ["https://i.pximg.net/img-original/img/2022/12/03/05/06/51/103291492_p0.png"],
          dtext_artist_commentary_title: "Rem's present",
          artist_name: "Anzatiridonia",
          profile_url: "https://www.pixiv.net/users/33589885",
          tags: %w[AI Re:ゼロから始める異世界生活 レム リゼロ レム(リゼロ) AIイラスト AnythingV3 Present sweater],
        )
      end

      context "A work requested via Pixiv Requests" do
        strategy_should_work(
          "https://www.pixiv.net/en/artworks/91322075",
          tags: %w[アイドルマスターシンデレラガールズ 大槻唯 濡れ透け パンツ 透けブラ 裾結び プール掃除 おへそ ぱんつ パンモロにも定評のあるゆいれそ pixiv_commission]
        )
      end

      context "A work with the isOriginal flag but not tagged オリジナル" do
        strategy_should_work(
          "https://www.pixiv.net/en/artworks/116168818",
          tags: %w[むちむち VTuber タンクトップ 褐色 ぽっちゃり BBW chubby pixiv_commission original]
        )
      end

      context "A work with HTML in the commentary should convert the commentary to DText" do
        strategy_should_work(
          "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=65985331",
          dtext_artist_commentary_desc: "[b]bold[/b]\n[i]italic[/i]\nred",
        )
      end

      context "A work with Pixiv links in the commentary should convert the links to DText" do
        strategy_should_work(
          "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=63421642",
          dtext_artist_commentary_desc: <<~EOS.chomp
            foo 【[b]pixiv #46337015 "»":[/posts?tags=pixiv%3A46337015][/b]】bar 【[b]pixiv #14901720 "»":[/posts?tags=pixiv%3A14901720][/b]】

            baz【[b]"user/83739":[https://www.pixiv.net/users/83739] "»":[/artists?search%5Burl_matches%5D=https%3A%2F%2Fwww.pixiv.net%2Fusers%2F83739][/b]】
          EOS
        )
      end

      context "A work with jump.php links in the commentary should convert the links to DText" do
        strategy_should_work(
          "https://www.pixiv.net/en/artworks/68955584",
          dtext_artist_commentary_desc: <<~EOS.chomp
            東方や版権中心にまとめました

            ◆例大祭の新刊([b]pixiv #68490887 "»":[/posts?tags=pixiv%3A68490887][/b])を一部加筆して再版しました。通販在庫復活しているのでよろしければ▷<https://www.melonbooks.co.jp/detail/detail.php?product_id=364421>
            今週末京都みやこめっせで開催される「古明地こんぷれっくす いつつめ」にも持っていきます〜。スペースは【古13】です。他にも色々持って行く予定なので、改めて告知します。

            ◇pixivFANBOX開設してみました。のんびり投稿していく予定です(:˒[￣]メイキングとかやってみたい…▶︎<https://www.pixiv.net/fanbox/creator/143555>
          EOS
        )
      end

      context "A work with jump.php links in the commentary should URL-decode the query string in the links" do
        strategy_should_work(
          "https://www.pixiv.net/en/artworks/117099495",
          dtext_artist_commentary_desc: <<~EOS.chomp
            あなたの貴方の後ろにいるよ。
            右手の先には…（ｶﾞｸﾌﾞﾙ）
            ということで、サークル『玉乃露』、東方名華祭18の新作クリアファイル②です。

            イラスト:あおい
            (pixiv:[b]"user/240943":[https://www.pixiv.net/users/240943] "»":[/artists?search%5Burl_matches%5D=https%3A%2F%2Fwww.pixiv.net%2Fusers%2F240943][/b])
            (X 旧Twitter:[b]"twitter/wobumi":[https://twitter.com/wobumi][/b])

            ＜委託取扱店（予約開始はお店によって違います…）＞
            <https://www.melonbooks.co.jp/detail/detail.php?product_id=2344184>
            <https://shop.akbh.jp/collections/vendors?q=%E7%8E%89%E4%B9%83%E9%9C%B2&sort_by=created-descending>
          EOS
        )
      end

      context "A Pixiv post should translate the tags correctly" do
        setup do
          create(:tag, name: "comic")
          create(:tag, name: "scenery")
          create(:tag, name: "i-19_(kancolle)")
          create(:tag, name: "mutsu_(kancolle)")
          create(:tag, name: "fate/grand_order")
          create(:tag, name: "fate")
          create(:tag, name: "foo")

          create(:wiki_page, title: "comic", other_names: ["漫画"])
          create(:wiki_page, title: "scenery", other_names: ["風景"])
          create(:wiki_page, title: "i-19_(kancolle)", other_names: ["伊19"])
          create(:wiki_page, title: "mutsu_(kancolle)", other_names: ["陸奥"])
          create(:wiki_page, title: "fate/grand_order", other_names: ["Fate/GrandOrder"])

          create(:tag, name: "test_paper")
          create(:tag_alias, antecedent_name: "test", consequent_name: "test_paper")
        end

        strategy_should_work(
          "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=65981746",
          tags: %w[test 風景 Fate/GrandOrder 伊19/陸奥 鉛筆 風景10users入り foo FOO],
          translated_tags: %w[test_paper scenery fate/grand_order i-19_(kancolle) mutsu_(kancolle) foo],
        )
      end

      context "A Pixiv post should not translate '1000users入り' to '1'" do
        setup do
          create(:tag, name: "1")
          create(:tag, name: "fate/grand_order")
          create(:wiki_page, title: "fate/grand_order", other_names: ["Fate/GrandOrder"])
        end

        strategy_should_work(
          "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=60665428",
          tags: %w[1000users入り Fate/GrandOrder 「両儀式」 アルジュナ(Fate) アルトリア・ペンドラゴン イシュタル(Fate) グランブルーファンタジー マシュ・キリエライト マーリン(Fate) 手袋],
          translated_tags: %w[fate/grand_order],
        )
      end

      context "A Pixiv post should not add Pixiv-generated 'user_' usernames to the other names field" do
        strategy_should_work(
          "https://www.pixiv.net/en/artworks/88487025",
          artist_name: "éé",
          other_names: ["éé"],
          profile_url: "https://www.pixiv.net/users/66422392",
        )
      end

      context "A http://www.pixiv.net/member_illust.php?mode=medium&illust_id=$id URL" do
        strategy_should_work(
          "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350",
          image_urls: ["https://i.pximg.net/img-original/img/2017/04/04/08/54/15/62247350_p0.png"],
          media_files: [{ file_size: 16_275 }],
          page_url: "https://www.pixiv.net/artworks/62247350",
          profile_url: "https://www.pixiv.net/users/22252953",
          artist_name: "uroobnad2",
          tag_name: "user_myeg3558",
          tags: %w[blue png],
          dtext_artist_commentary_title: "single image",
          dtext_artist_commentary_desc: "description here",
        )
      end

      context "An /img-master/ image URL" do
        strategy_should_work(
          "https://i.pximg.net/c/600x600/img-master/img/2017/04/04/08/54/15/62247350_p0_master1200.jpg",
          image_urls: ["https://i.pximg.net/img-original/img/2017/04/04/08/54/15/62247350_p0.png"],
          media_files: [{ file_size: 16_275 }],
          page_url: "https://www.pixiv.net/artworks/62247350",
          profile_url: "https://www.pixiv.net/users/22252953",
          artist_name: "uroobnad2",
          tag_name: "user_myeg3558",
          tags: %w[blue png],
          dtext_artist_commentary_title: "single image",
          dtext_artist_commentary_desc: "description here",
        )
      end

      context "An /img-original/ image URL" do
        strategy_should_work(
          "https://i.pximg.net/img-original/img/2017/04/04/08/54/15/62247350_p0.png",
          image_urls: ["https://i.pximg.net/img-original/img/2017/04/04/08/54/15/62247350_p0.png"],
          media_files: [{ file_size: 16_275 }],
          page_url: "https://www.pixiv.net/artworks/62247350",
          profile_url: "https://www.pixiv.net/users/22252953",
          artist_name: "uroobnad2",
          tag_name: "user_myeg3558",
          tags: %w[blue png],
          dtext_artist_commentary_title: "single image",
          dtext_artist_commentary_desc: "description here",
        )
      end

      context "A /c/ic:*:*:*/img-original/ sample image URL" do
        strategy_should_work(
          "https://i.pximg.net/c/ic0:900:1280/img-original/img/2024/04/26/13/03/41/118168794_p8.jpg",
          image_urls: %w[https://i.pximg.net/img-original/img/2024/04/26/13/03/41/118168794_p8.jpg],
          media_files: [{ file_size: 1_055_784 }],
          page_url: "https://www.pixiv.net/artworks/118168794",
          profile_url: "https://www.pixiv.net/users/65299569",
          profile_urls: %w[https://www.pixiv.net/users/65299569 https://www.pixiv.net/stacc/3md0m2ng],
          artist_name: "病んだ犬",
          tag_name: "3md0m2ng",
          other_names: ["病んだ犬", "3md0m2ng"],
          tags: [
            ["ひろがるスカイ!プリキュア", "https://www.pixiv.net/tags/ひろがるスカイ!プリキュア/artworks"],
            ["百合", "https://www.pixiv.net/tags/百合/artworks"],
            ["ひろプリ", "https://www.pixiv.net/tags/ひろプリ/artworks"],
            ["ソラまし", "https://www.pixiv.net/tags/ソラまし/artworks"],
            ["虹ヶ丘ましろ", "https://www.pixiv.net/tags/虹ヶ丘ましろ/artworks"],
            ["エル(プリキュア)", "https://www.pixiv.net/tags/エル(プリキュア)/artworks"],
            ["ソラ・ハレワタール", "https://www.pixiv.net/tags/ソラ・ハレワタール/artworks"],
            ["夕凪ツバサ", "https://www.pixiv.net/tags/夕凪ツバサ/artworks"],
            ["聖あげは", "https://www.pixiv.net/tags/聖あげは/artworks"],
            ["入れ替わり", "https://www.pixiv.net/tags/入れ替わり/artworks"],
          ],
          dtext_artist_commentary_title: "ひプまとめ",
          dtext_artist_commentary_desc: "主にX(旧:Twitter)に載せた絵の寄せ集めです。"
        )
      end

      context "A /c/{width}x{height}/custom-thumb/ sample image url" do
        strategy_should_work(
          "https://i.pximg.net/c/360x360_70/custom-thumb/img/2022/03/08/00/00/56/96755248_p0_custom1200.jpg",
          image_urls: %w[https://i.pximg.net/img-original/img/2022/03/08/00/00/56/96755248_p0.jpg],
          media_files: [{ file_size: 267_022 }],
          page_url: "https://www.pixiv.net/artworks/96755248",
          profile_url: "https://www.pixiv.net/users/2188232",
          profile_urls: %w[https://www.pixiv.net/users/2188232 https://www.pixiv.net/stacc/wlop],
          artist_name: "wlop",
          tag_name: "wlop",
          other_names: ["wlop"],
          tags: [
            ["ghostblade", "https://www.pixiv.net/tags/ghostblade/artworks"],
            ["original", "https://www.pixiv.net/tags/オリジナル/artworks"],
            ["wlop", "https://www.pixiv.net/tags/wlop/artworks"],
            ["海琴烟", "https://www.pixiv.net/tags/海琴烟/artworks"],
            ["オリジナル10000users入り", "https://www.pixiv.net/tags/オリジナル10000users入り/artworks"],
          ],
          dtext_artist_commentary_title: "Destination",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A profile image URL" do
        strategy_should_work(
          "https://i.pximg.net/user-profile/img/2014/12/18/10/31/23/8733472_7dc7310db6cc37163af145d04499e411_170.jpg",
          image_urls: ["https://i.pximg.net/user-profile/img/2014/12/18/10/31/23/8733472_7dc7310db6cc37163af145d04499e411_170.jpg"],
          media_files: [{ file_size: 26_040 }],
          page_url: nil,
          profile_url: nil,
          artist_name: nil,
          tag_name: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: "",
        )
      end

      context "A background image URL" do
        strategy_should_work(
          "https://i.pximg.net/background/img/2015/10/25/08/45/27/198128_77ddf78cdb162e3d1c0d5134af185813.jpg",
          image_urls: ["https://i.pximg.net/background/img/2015/10/25/08/45/27/198128_77ddf78cdb162e3d1c0d5134af185813.jpg"],
          media_files: [{ file_size: 266_948 }],
          page_url: nil,
          profile_url: nil,
          artist_name: nil,
          tag_name: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: "",
        )
      end

      context "A novel cover image sample URL" do
        strategy_should_work(
          "https://i.pximg.net/c/600x600/novel-cover-master/img/2017/07/27/23/14/17/8465454_80685d10e6df4d7d53ad347ddc18a36b_master1200.jpg",
          image_urls: %w[https://i.pximg.net/novel-cover-original/img/2017/07/27/23/14/17/8465454_80685d10e6df4d7d53ad347ddc18a36b.jpg],
          media_files: [{ file_size: 532_037 }],
          page_url: "https://www.pixiv.net/novel/show.php?id=8465454"
        )
      end

      context "A novel cover image full size URL" do
        strategy_should_work(
          "https://i.pximg.net/novel-cover-original/img/2017/07/27/23/14/17/8465454_80685d10e6df4d7d53ad347ddc18a36b.jpg",
          image_urls: ["https://i.pximg.net/novel-cover-original/img/2017/07/27/23/14/17/8465454_80685d10e6df4d7d53ad347ddc18a36b.jpg"],
          media_files: [{ file_size: 532_037 }],
          page_url: "https://www.pixiv.net/novel/show.php?id=8465454",
          profile_url: "https://www.pixiv.net/users/2255721",
          profile_urls: %w[https://www.pixiv.net/users/2255721],
          artist_name: "緋錬",
          tag_name: nil,
          other_names: ["緋錬"],
          tags: [
            ["ガールズ&パンツァー", "https://www.pixiv.net/tags/ガールズ%26パンツァー/novels"],
            ["ガルパン", "https://www.pixiv.net/tags/ガルパン/novels"],
            ["西住みほ", "https://www.pixiv.net/tags/西住みほ/novels"],
            ["逸見エリカ", "https://www.pixiv.net/tags/逸見エリカ/novels"],
            ["エリみほ", "https://www.pixiv.net/tags/エリみほ/novels"],
            ["みほエリ", "https://www.pixiv.net/tags/みほエリ/novels"],
            ["百合", "https://www.pixiv.net/tags/百合/novels"],
            ["ガルパン小説100users入り", "https://www.pixiv.net/tags/ガルパン小説100users入り/novels"],
          ],
          dtext_artist_commentary_title: "さよならのその先へ 後編",
          dtext_artist_commentary_desc: <<~EOS.chomp
            前回[b]"novel/8414084":[https://www.pixiv.net/novel/show.php?id=8414084][/b]の続きです。

            エリカさんとみほさんの半同棲もこれでお終い……でしょうか。

            最初の投稿から一年と幾月……全９話（書き下ろしを含めれば１０話）長々とお付き合いくださりましてありがとうございました。

            前編にも書いてありますが、こちらのお話を含んだ本を夏コミ（Ｃ９２）で頒布致します。

            収録するお話は
            幸せの形（[b]"novel/7132764":[https://www.pixiv.net/novel/show.php?id=7132764][/b]）
            あなたは私だけのもの（[b]"novel/7382096":[https://www.pixiv.net/novel/show.php?id=7382096][/b]）
            永遠に咲く桜（[b]"novel/8383409":[https://www.pixiv.net/novel/show.php?id=8383409][/b]）
            さよならのその先へ 前編（[b]"novel/8414084":[https://www.pixiv.net/novel/show.php?id=8414084][/b]）
            さよならのその先へ 後編（この作品）
            二人の証明（書き下ろし。二人が新しい生活に向けて家具などを見に行くお話）
            です。

            表紙挿絵はうーろんさん（[b]"user/1778852":[https://www.pixiv.net/users/1778852] "»":[/artists?search%5Burl_matches%5D=https%3A%2F%2Fwww.pixiv.net%2Fusers%2F1778852][/b]）、章末挿絵は栗林さんに描いて頂きました。
            とても素敵な表紙と挿絵なのでそれだけでも楽しみにして頂けたらと思います。
            フルカラーカバー付き ２２６Ｐ 予価１０００円です。
            当日は８月１２日土曜日 東Ｂ－０９ｂ にてお待ちしております。

            メロンブックスさんで委託もして頂いているのでよろしければー！
            <https://www.melonbooks.co.jp/detail/detail.php?product_id=229407>

            一冊目の既刊も是非に……！
            <https://www.melonbooks.co.jp/detail/detail.php?product_id=203181>
          EOS
        )
      end

      context "A novel embedded image sample URL" do
        strategy_should_work(
          "https://i.pximg.net/c/1200x1200/novel-cover-master/img/2022/11/02/10/04/22/tei62073304808_46e2ad585d3b76d042a1f12ea49625e5_master1200.jpg",
          image_urls: %w[https://i.pximg.net/novel-cover-original/img/2022/11/02/10/04/22/tei62073304808_46e2ad585d3b76d042a1f12ea49625e5.jpg],
          media_files: [{ file_size: 1_038_927 }],
          page_url: nil,
          profile_url: nil,
          profile_urls: %w[],
          artist_name: nil,
          tag_name: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A novel page URL" do
        strategy_should_work(
          "https://www.pixiv.net/novel/show.php?id=18588597",
          image_urls: %w[
            https://i.pximg.net/novel-cover-original/img/2022/10/23/21/11/17/ci18588597_c36ebfb6da3a9eba3ad559feebbaf7e5.jpg
            https://i.pximg.net/novel-cover-original/img/2022/11/02/09/50/08/tei56527215193_81725fe943e2f36608cf01a839b6b762.jpg
            https://i.pximg.net/novel-cover-original/img/2022/11/02/09/55/24/tei829762318070_03560cf6e9838a9ee411e17d45cc672f.jpg
            https://i.pximg.net/novel-cover-original/img/2022/11/02/09/55/42/tei852368151856_f581b161200fb1bb57215785763eb86e.jpg
            https://i.pximg.net/novel-cover-original/img/2022/11/02/10/03/30/tei85585543976_edde8b66ed7ccd5e22d46166ac066931.jpg
          ],
          media_files: [
            { file_size: 953_730 },
            { file_size: 1_020_523 },
            { file_size: 901_436 },
            { file_size: 1_612_851 },
            { file_size: 1_219_383 },
          ],
          page_url: "https://www.pixiv.net/novel/show.php?id=18588597",
          profile_url: "https://www.pixiv.net/users/66091066",
          profile_urls: %w[https://www.pixiv.net/users/66091066],
          artist_name: "しゅか",
          tag_name: nil,
          other_names: ["しゅか"],
          tags: [
            ["original", "https://www.pixiv.net/tags/オリジナル/novels"],
            ["オリキャラ", "https://www.pixiv.net/tags/オリキャラ/novels"],
            ["ファンタジー", "https://www.pixiv.net/tags/ファンタジー/novels"],
            ["pixivファンタジアSOZ", "https://www.pixiv.net/tags/pixivファンタジアSOZ/novels"],
            ["【SOZアロイスとユーゴ】", "https://www.pixiv.net/tags/【SOZアロイスとユーゴ】/novels"],
            ["アラディア院", "https://www.pixiv.net/tags/アラディア院/novels"],
          ],
          dtext_artist_commentary_title: "【PFSOZ】身バレ【アラディア院】",
          dtext_artist_commentary_desc: <<~EOS.chomp
            リーリンの息子であることは隠していましたが、一部の人間に身バレしました。
            絵投稿版[b]pixiv #102168503 "»":[/posts?tags=pixiv%3A102168503][/b]
            ----------------------------
            PFSOZの自キャラのSS、読みやすいように小説投稿もしてあります。
            詳しくはプロローグとキャラシをどうぞ
            アロイス[b]pixiv #101966594 "»":[/posts?tags=pixiv%3A101966594][/b]
            幼少期ユーゴ[b]pixiv #101966826 "»":[/posts?tags=pixiv%3A101966826][/b]
            成人後ユーゴ[b]pixiv #101966594 "»":[/posts?tags=pixiv%3A101966594][/b]
            プロローグ１[b]pixiv #101966734 "»":[/posts?tags=pixiv%3A101966734][/b] プロローグ０[b]pixiv #101966965 "»":[/posts?tags=pixiv%3A101966965][/b]
          EOS
        )
      end

      context "A novel series URL" do
        strategy_should_work(
          "https://www.pixiv.net/novel/series/9593812",
          image_urls: %w[https://i.pximg.net/novel-cover-original/img/2022/10/23/17/31/13/sci9593812_3eb12772f4715a9700d44ffee1107adc.jpg],
          media_files: [{ file_size: 1_770_646 }],
          page_url: "https://www.pixiv.net/novel/series/9593812",
          profile_url: "https://www.pixiv.net/users/66091066",
          profile_urls: %w[https://www.pixiv.net/users/66091066],
          artist_name: "しゅか",
          tag_name: nil,
          other_names: ["しゅか"],
          tags: [
            ["original", "https://www.pixiv.net/tags/オリジナル/novels"],
            ["pixivファンタジアSOZ", "https://www.pixiv.net/tags/pixivファンタジアSOZ/novels"],
            ["オリキャラ", "https://www.pixiv.net/tags/オリキャラ/novels"],
            ["ファンタジー", "https://www.pixiv.net/tags/ファンタジー/novels"],
            ["アラディア院", "https://www.pixiv.net/tags/アラディア院/novels"],
            ["エイリル教団", "https://www.pixiv.net/tags/エイリル教団/novels"],
            ["イスリアド家", "https://www.pixiv.net/tags/イスリアド家/novels"],
            ["【SOZアロイスとユーゴ】", "https://www.pixiv.net/tags/【SOZアロイスとユーゴ】/novels"],
            ["創作", "https://www.pixiv.net/tags/創作/novels"],
          ],
          dtext_artist_commentary_title: "ユーゴとアロイス",
          dtext_artist_commentary_desc: <<~EOS.chomp
            PFSOZの自キャラのSS。傾向はブロマンス。友情と家族愛。魔術師リーリンの息子であるユーゴは正体を隠した父親に育てられるが、彼との関係に行き詰まり、外の世界を知ろうとアラディア院の門をたたくのだった。
            詳しくはプロローグとキャラシをどうぞ
            アロイスhttps://www.pixiv.net/artworks/101966594
            幼少期ユーゴhttps://www.pixiv.net/artworks/101966826
            成人後ユーゴhttps://www.pixiv.net/artworks/101966594
            プロローグ１https://www.pixiv.net/artworks/101966734 プロローグ０https://www.pixiv.net/artworks/101966965
          EOS
        )
      end

      context "A novel series URL with a novel page referer" do
        strategy_should_work(
          "https://www.pixiv.net/novel/series/9593812",
          referer: "https://www.pixiv.net/novel/show.php?id=18588585",
          image_urls: %w[https://i.pximg.net/novel-cover-original/img/2022/10/23/17/31/13/sci9593812_3eb12772f4715a9700d44ffee1107adc.jpg],
          media_files: [{ file_size: 1_770_646 }],
          page_url: "https://www.pixiv.net/novel/series/9593812",
          profile_url: "https://www.pixiv.net/users/66091066",
          profile_urls: %w[https://www.pixiv.net/users/66091066],
          artist_name: "しゅか",
          tag_name: nil,
          other_names: ["しゅか"],
          tags: [
            ["original", "https://www.pixiv.net/tags/オリジナル/novels"],
            ["pixivファンタジアSOZ", "https://www.pixiv.net/tags/pixivファンタジアSOZ/novels"],
            ["オリキャラ", "https://www.pixiv.net/tags/オリキャラ/novels"],
            ["ファンタジー", "https://www.pixiv.net/tags/ファンタジー/novels"],
            ["アラディア院", "https://www.pixiv.net/tags/アラディア院/novels"],
            ["エイリル教団", "https://www.pixiv.net/tags/エイリル教団/novels"],
            ["イスリアド家", "https://www.pixiv.net/tags/イスリアド家/novels"],
            ["【SOZアロイスとユーゴ】", "https://www.pixiv.net/tags/【SOZアロイスとユーゴ】/novels"],
            ["創作", "https://www.pixiv.net/tags/創作/novels"],
          ],
          dtext_artist_commentary_title: "ユーゴとアロイス",
          dtext_artist_commentary_desc: <<~EOS.chomp
            PFSOZの自キャラのSS。傾向はブロマンス。友情と家族愛。魔術師リーリンの息子であるユーゴは正体を隠した父親に育てられるが、彼との関係に行き詰まり、外の世界を知ろうとアラディア院の門をたたくのだった。
            詳しくはプロローグとキャラシをどうぞ
            アロイスhttps://www.pixiv.net/artworks/101966594
            幼少期ユーゴhttps://www.pixiv.net/artworks/101966826
            成人後ユーゴhttps://www.pixiv.net/artworks/101966594
            プロローグ１https://www.pixiv.net/artworks/101966734 プロローグ０https://www.pixiv.net/artworks/101966965
          EOS
        )
      end

      context "A novel series cover image sample URL" do
        strategy_should_work(
          "https://i.pximg.net/c/480x960/novel-cover-master/img/2022/10/23/17/31/13/sci9593812_3eb12772f4715a9700d44ffee1107adc_master1200.jpg",
          image_urls: %w[https://i.pximg.net/novel-cover-original/img/2022/10/23/17/31/13/sci9593812_3eb12772f4715a9700d44ffee1107adc.jpg],
          media_files: [{ file_size: 1_770_646 }],
          page_url: "https://www.pixiv.net/novel/series/9593812",
          profile_url: "https://www.pixiv.net/users/66091066"
        )
      end

      context "parsing illust ids" do
        should "parse ids from illust urls" do
          assert_illust_id(46785915, "https://i.pximg.net/c/250x250_80_a2/img-master/img/2014/10/29/09/27/19/46785915_p0_square1200.jpg")
          assert_illust_id(79584713, "https://i-f.pximg.net/img-original/img/2020/02/19/00/40/18/79584713_p0.png")

          assert_illust_id(46304396, "http://i1.pixiv.net/img-original/img/2014/10/02/13/51/23/46304396_p0.png")
          assert_illust_id(46304396, "http://i1.pixiv.net/c/600x600/img-master/img/2014/10/02/13/51/23/46304396_p0_master1200.jpg")

          assert_illust_id(14901720, "http://img18.pixiv.net/img/evazion/14901720.png")
          assert_illust_id(14901720, "http://i2.pixiv.net/img18/img/evazion/14901720.png")
          assert_illust_id(14901720, "http://i2.pixiv.net/img18/img/evazion/14901720_m.png")
          assert_illust_id(14901720, "http://i2.pixiv.net/img18/img/evazion/14901720_s.png")

          assert_illust_id(18557054, "http://i1.pixiv.net/img07/img/pasirism/18557054_p1.png")
          assert_illust_id(18557054, "http://i1.pixiv.net/img07/img/pasirism/18557054_big_p1.png")
          assert_illust_id(18557054, "http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_64x64.jpg")
          assert_illust_id(18557054, "http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_s.png")
          assert_illust_id(18557054, "http://www.pixiv.net/i/18557054")

          assert_illust_id(18557054, "http://www.pixiv.net/en/artworks/18557054")
          assert_illust_id(18557054, "http://www.pixiv.net/artworks/18557054")
          assert_illust_id(18557054, "http://p.tl/i/18557054")
        end

        should "parse ids from expicit/guro illust urls" do
          assert_illust_id(46324488, "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=46324488")
          assert_illust_id(46324488, "https://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=46324488&page=0")
          assert_illust_id(46324488, "https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png")
          assert_illust_id(46324488, "https://i.pximg.net/img-master/img/2014/10/03/18/10/20/46324488_p0_master1200.jpg")

          assert_illust_id(46323924, "http://i1.pixiv.net/img-zip-ugoira/img/2014/10/03/17/29/16/46323924_ugoira1920x1080.zip")
        end

        should "not misparse ids from novel urls" do
          assert_illust_id(nil, "https://i.pximg.net/novel-cover-original/img/2019/01/14/01/15/05/10617324_d84daae89092d96bbe66efafec136e42.jpg")
          assert_illust_id(nil, "https://i.pximg.net/c/600x600/novel-cover-master/img/2019/01/14/01/15/05/10617324_d84daae89092d96bbe66efafec136e42_master1200.jpg")
          assert_illust_id(nil, "https://www.pixiv.net/novel/show.php?id=10617324")
        end

        should "not misparse /member_illust.php urls" do
          assert_illust_id(nil, "https://www.pixiv.net/member_illust.php")
          assert_illust_id(64476642, "https://www.pixiv.net/member_illust.php?illust_id=64476642&mode=medium")
        end
      end
    end

    should "Parse Pixiv URLs correctly" do
      assert_equal("https://www.pixiv.net/artworks/39749565", Source::URL.page_url("http://i2.pixiv.net/img12/img/zenze/39749565.png"))
      assert_equal("https://www.pixiv.net/artworks/39735353", Source::URL.page_url("http://i1.pixiv.net/img53/img/themare/39735353_big_p1.jpg"))
      assert_equal("https://www.pixiv.net/artworks/14901720", Source::URL.page_url("http://i1.pixiv.net/c/150x150/img-master/img/2010/11/30/08/39/58/14901720_p0_master1200.jpg"))
      assert_equal("https://www.pixiv.net/artworks/14901720", Source::URL.page_url("http://i1.pixiv.net/img-original/img/2010/11/30/08/39/58/14901720_p0.png"))
      assert_equal("https://www.pixiv.net/artworks/44524589", Source::URL.page_url("http://i2.pixiv.net/img-zip-ugoira/img/2014/08/05/06/01/10/44524589_ugoira1920x1080.zip"))

      assert(Source::URL.image_url?("https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png"))
      assert(Source::URL.image_url?("https://i.pximg.net/img-master/img/2014/10/03/18/10/20/46324488_p0_master1200.jpg"))
      assert(Source::URL.image_url?("https://i.pximg.net/img-zip-ugoira/img/2016/04/09/14/25/29/56268141_ugoira1920x1080.zip"))
      assert(Source::URL.image_url?("https://i.pximg.net/c/250x250_80_a2/img-master/img/2014/10/29/09/27/19/46785915_p0_square1200.jpg"))
      assert(Source::URL.image_url?("https://i-f.pximg.net/img-original/img/2020/02/19/00/40/18/79584713_p0.png"))
      assert(Source::URL.image_url?("http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_64x64.jpg"))
      assert(Source::URL.image_url?("http://img18.pixiv.net/img/evazion/14901720.png"))
      assert(Source::URL.image_url?("http://i2.pixiv.net/img18/img/evazion/14901720.png"))

      assert(Source::URL.page_url?("https://www.pixiv.net/en/artworks/46324488"))
      assert(Source::URL.page_url?("https://www.pixiv.net/artworks/46324488"))
      assert(Source::URL.page_url?("http://www.pixiv.net/i/18557054"))
      assert(Source::URL.page_url?("http://p.tl/i/18557054"))
      assert(Source::URL.page_url?("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=18557054"))
      assert(Source::URL.page_url?("http://www.pixiv.net/member_illust.php?mode=big&illust_id=18557054"))
      assert(Source::URL.page_url?("http://www.pixiv.net/member_illust.php?mode=manga&illust_id=18557054"))
      assert(Source::URL.page_url?("http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=18557054&page=1"))
      assert(Source::URL.page_url?("https://www.pixiv.net/novel/series/9593812"))
      assert(Source::URL.page_url?("https://www.pixiv.net/novel/show.php?id=18588585"))
      assert(Source::URL.page_url?("https://embed.pixiv.net/novel.php?id=18588585&mdate=20221102100423"))

      assert(Source::URL.profile_url?("https://www.pixiv.net/member.php?id=339253"))
      assert(Source::URL.profile_url?("https://www.pixiv.net/u/9202877"))
      assert(Source::URL.profile_url?("https://www.pixiv.net/users/9202877"))
      assert(Source::URL.profile_url?("https://www.pixiv.net/en/users/9202877"))
      assert(Source::URL.profile_url?("https://www.pixiv.net/stacc/noizave"))
      assert(Source::URL.profile_url?("http://www.pixiv.me/noizave"))
      assert(Source::URL.profile_url?("https://pixiv.cc/zerousagi/"))
      assert(Source::URL.profile_url?("https://p.tl/m/9202877"))

      assert_equal("https://www.pixiv.net/novel/series/9593812", Source::URL.page_url("https://i.pximg.net/c/480x960/novel-cover-master/img/2022/10/23/17/31/13/sci9593812_3eb12772f4715a9700d44ffee1107adc_master1200.jpg"))
      assert_equal("https://www.pixiv.net/novel/series/9593812", Source::URL.page_url("https://i.pximg.net/novel-cover-original/img/2022/10/23/17/31/13/sci9593812_3eb12772f4715a9700d44ffee1107adc.jpg"))

      assert_equal("https://www.pixiv.net/novel/show.php?id=18588585", Source::URL.page_url("https://embed.pixiv.net/novel.php?id=18588585&mdate=20221102100423"))
      assert_equal("https://www.pixiv.net/novel/show.php?id=18588585", Source::URL.page_url("https://i.pximg.net/c/600x600/novel-cover-master/img/2022/10/23/17/33/05/ci18588585_2332b5586ce5a9b039859254b6b220d4_master1200.jpg"))
      assert_equal("https://www.pixiv.net/novel/show.php?id=18588585", Source::URL.page_url("https://i.pximg.net/novel-cover-original/img/2022/10/23/17/33/05/ci18588585_2332b5586ce5a9b039859254b6b220d4.jpg"))
      assert_equal("https://www.pixiv.net/novel/show.php?id=9434677",  Source::URL.page_url("https://i.pximg.net/novel-cover-original/img/2018/04/02/19/38/29/9434677_6ab6c651d5568ff39e2ba6ab45edaf28.jpg"))
      assert_equal("https://www.pixiv.net/novel/show.php?id=7463785",  Source::URL.page_url("http://i1.pixiv.net/novel-cover-original/img/2016/11/11/20/11/46/7463785_0e2446dc1671dd3a4937dfaee39c227f.jpg"))

      assert_nil(Source::URL.page_url("https://i.pximg.net/c/1200x1200/novel-cover-master/img/2022/11/02/10/04/22/tei62073304808_46e2ad585d3b76d042a1f12ea49625e5_master1200.jpg"))
      assert_nil(Source::URL.page_url("https://i.pximg.net/novel-cover-original/img/2022/11/02/10/04/22/tei62073304808_46e2ad585d3b76d042a1f12ea49625e5.jpg"))
    end
  end
end
