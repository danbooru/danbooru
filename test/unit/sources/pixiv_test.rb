require 'test_helper'

module Sources
  class PixivTest < ActiveSupport::TestCase
    setup do
      skip "Pixiv credentials not configured" unless Source::Extractor::Pixiv.enabled?
    end

    def assert_illust_id(illust_id, url)
      site = Source::Extractor.find(url)
      assert_equal(illust_id, site.illust_id.to_i)
    end

    def assert_nil_illust_id(url)
      site = Source::Extractor.find(url)
      assert_nil(site.illust_id)
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
          artist_commentary_title: "ツイログ",
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
          artist_commentary_title: "ugoira",
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
          artist_commentary_title: "ugoira",
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
          artist_commentary_title: "水着フランたそ",
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
          artist_commentary_title: nil,
          dtext_artist_commentary_desc: nil,
          deleted: true,
        )
      end

      context "A raw image URL that has been revised should get the unrevised image URL" do
        strategy_should_work(
          "https://i.pximg.net/img-original/img/2022/08/14/19/23/06/100474393_p0.png",
          deleted: true,
          image_urls: ["https://i.pximg.net/img-original/img/2022/08/14/19/23/06/100474393_p0.png"],
          artist_commentary_title: "シャイリリー",
          artist_name: "影おじ (隠れエリア)",
          profile_url: "https://www.pixiv.net/users/6570768",
          profile_urls: %w[https://www.pixiv.net/stacc/haku3490 https://www.pixiv.net/users/6570768],
          tags: %w[r-18 shylily シャイリリー バーチャルyoutuber バーチャルyoutuber30000users入り 両手に茎 乱交],
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
          artist_commentary_title: "シャイリリー",
          artist_name: "影おじ (隠れエリア)",
          profile_url: "https://www.pixiv.net/users/6570768",
          profile_urls: %w[https://www.pixiv.net/stacc/haku3490 https://www.pixiv.net/users/6570768],
          tags: %w[r-18 shylily シャイリリー バーチャルyoutuber バーチャルyoutuber30000users入り 両手に茎 乱交],
        )
      end

      context "An AI-generated post should get the AI tag" do
        strategy_should_work(
          "https://www.pixiv.net/en/artworks/103291492",
          image_urls: ["https://i.pximg.net/img-original/img/2022/12/03/05/06/51/103291492_p0.png"],
          artist_commentary_title: "Rem's present",
          artist_name: "Anzatiridonia",
          profile_url: "https://www.pixiv.net/users/33589885",
          tags: %w[AI Re:ゼロから始める異世界生活 レム リゼロ レム(リゼロ) AIイラスト AnythingV3 Present sweater],
        )
      end

      context "A work requested via Pixiv Requests" do
        strategy_should_work(
          "https://www.pixiv.net/en/artworks/101951859",
          tags: %w[pixiv_commission r-18 つつちゃ よその子 チンコ包囲網 パイズリ レイプ ロリ巨乳 女の子 猫耳 肉便器],
          dtext_artist_commentary_desc: <<~EOS.chomp
            Fanbox: <https://herishop213.fanbox.cc>
            Patreon: <https://www.patreon.com/Herishop>
            =====
            Original artist: [b]"user/61121665":[https://www.pixiv.net/users/61121665] "»":[/artists?search%5Burl_matches%5D=https%3A%2F%2Fwww.pixiv.net%2Fusers%2F61121665][/b]

            [tn]
            Source: https://www.pixiv.net/artworks/101951859
            [/tn]

            Hi boss, I hope you can help me draw original characters from artist "つつちゃ"
            "user/61121665":[https://www.pixiv.net/users/61121665] "»":[/artists?search%5Burl_matches%5D=https%3A%2F%2Fwww.pixiv.net%2Fusers%2F61121665]
            The character name seems to be "みみ", she is very cute big tit loli and pervert exhibitionist
            pixiv #101951859 "»":[/posts?tags=pixiv%3A101951859]
            pixiv #101951859 "»":[/posts?tags=pixiv%3A101951859]
            pixiv #101951859 "»":[/posts?tags=pixiv%3A101951859]
            I want to see her get gangbang by a bunch of disgusting guys, all with dicks around her exposed cleavage just doing tit fuck.

            [tn]
            Source: https://www.pixiv.net/requests/99649
            [/tn]
          EOS
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
            今週末京都みやこめっせで開催される「古明地こんぷれっくす　いつつめ」にも持っていきます〜。スペースは【古13】です。他にも色々持って行く予定なので、改めて告知します。

            ◇pixivFANBOX開設してみました。のんびり投稿していく予定です(:˒[￣]メイキングとかやってみたい…▶︎<https://www.pixiv.net/fanbox/creator/143555>
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
          artist_commentary_title: "single image",
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
          artist_commentary_title: "single image",
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
          artist_commentary_title: "single image",
          dtext_artist_commentary_desc: "description here",
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
          artist_commentary_title: nil,
          dtext_artist_commentary_desc: nil,
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
          artist_commentary_title: nil,
          dtext_artist_commentary_desc: nil,
        )
      end

      context "A novel image URL" do
        strategy_should_work(
          "https://i.pximg.net/novel-cover-original/img/2017/07/27/23/14/17/8465454_80685d10e6df4d7d53ad347ddc18a36b.jpg",
          image_urls: ["https://i.pximg.net/novel-cover-original/img/2017/07/27/23/14/17/8465454_80685d10e6df4d7d53ad347ddc18a36b.jpg"],
          media_files: [{ file_size: 532_037 }],
          page_url: nil,
          profile_url: nil,
          artist_name: nil,
          tag_name: nil,
          tags: [],
          artist_commentary_title: nil,
          dtext_artist_commentary_desc: nil,
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
        end

        should "parse ids from expicit/guro illust urls" do
          assert_illust_id(46324488, "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=46324488")
          assert_illust_id(46324488, "https://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=46324488&page=0")
          assert_illust_id(46324488, "https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png")
          assert_illust_id(46324488, "https://i.pximg.net/img-master/img/2014/10/03/18/10/20/46324488_p0_master1200.jpg")

          assert_illust_id(46323924, "http://i1.pixiv.net/img-zip-ugoira/img/2014/10/03/17/29/16/46323924_ugoira1920x1080.zip")
        end

        should "not misparse ids from novel urls" do
          assert_nil_illust_id("https://i.pximg.net/novel-cover-original/img/2019/01/14/01/15/05/10617324_d84daae89092d96bbe66efafec136e42.jpg")
          assert_nil_illust_id("https://i.pximg.net/c/600x600/novel-cover-master/img/2019/01/14/01/15/05/10617324_d84daae89092d96bbe66efafec136e42_master1200.jpg")
          assert_nil_illust_id("https://www.pixiv.net/novel/show.php?id=10617324")
        end

        should "not misparse /member_illust.php urls" do
          assert_nil_illust_id("https://www.pixiv.net/member_illust.php")
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
      assert(Source::URL.page_url?("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=18557054"))
      assert(Source::URL.page_url?("http://www.pixiv.net/member_illust.php?mode=big&illust_id=18557054"))
      assert(Source::URL.page_url?("http://www.pixiv.net/member_illust.php?mode=manga&illust_id=18557054"))
      assert(Source::URL.page_url?("http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=18557054&page=1"))

      assert(Source::URL.profile_url?("https://www.pixiv.net/member.php?id=339253"))
      assert(Source::URL.profile_url?("https://www.pixiv.net/u/9202877"))
      assert(Source::URL.profile_url?("https://www.pixiv.net/users/9202877"))
      assert(Source::URL.profile_url?("https://www.pixiv.net/en/users/9202877"))
      assert(Source::URL.profile_url?("https://www.pixiv.net/stacc/noizave"))
      assert(Source::URL.profile_url?("http://www.pixiv.me/noizave"))
      assert(Source::URL.profile_url?("https://pixiv.cc/zerousagi/"))
    end
  end
end
