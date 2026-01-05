require "test_helper"

module Source::Tests::Extractor
  class PixivExtractorTest < ActiveSupport::TestCase
    setup do
      skip "Pixiv credentials not configured" unless Source::Extractor::Pixiv.enabled?
    end

    context "A post with multiple images" do
      strategy_should_work(
        "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=49270482",
        image_urls: %w[
          https://i.pximg.net/img-original/img/2015/03/14/17/53/32/49270482_p0.jpg
          https://i.pximg.net/img-original/img/2015/03/14/17/53/32/49270482_p1.jpg
        ],
        page_url: "https://www.pixiv.net/artworks/49270482",
        profile_url: "https://www.pixiv.net/users/341433",
        display_name: "Nardack",
        username: "nardack",
        tags: %w[神崎蘭子 双葉杏 アイドルマスターシンデレラガールズ Star!! アイマス10000users入り],
        dtext_artist_commentary_title: "ツイログ",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A ugoira page URL" do
      strategy_should_work(
        "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364",
        image_urls: ["https://i.pximg.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip?original"],
        media_files: [
          { file_size: 33_197, frame_delays: [125, 125], pixel_hash: "417176a630077fdb8f7d32ed31a0d8fe", md5: "87ddf73e2c6fccef8dd6870cdfc0f245" },
        ],
        page_url: "https://www.pixiv.net/artworks/62247364",
        profile_url: "https://www.pixiv.net/users/22252953",
        display_name: "uroobnad2",
        username: "user_myeg3558",
        tags: %w[Ugoira png blue],
        dtext_artist_commentary_title: "ugoira",
        dtext_artist_commentary_desc: "",
      )

      should "include the Pixiv info in the animation.json file" do
        source = Source::Extractor.find("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364")
        json = source.ugoira_file.animation_json

        assert_equal(62_247_364, json[:illustId])
        assert_equal(22_252_953, json[:userId])
        assert_equal("2017-04-03T23:57:00+00:00", json[:createDate])
        assert_equal("2017-04-03T23:57:00+00:00", json[:uploadDate])
      end
    end

    context "A ugoira zip URL" do
      strategy_should_work(
        "https://i.pximg.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip",
        image_urls: ["https://i.pximg.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip?original"],
        media_files: [
          { file_size: 33_197, frame_delays: [125, 125], pixel_hash: "417176a630077fdb8f7d32ed31a0d8fe", md5: "87ddf73e2c6fccef8dd6870cdfc0f245" },
        ],
        page_url: "https://www.pixiv.net/artworks/62247364",
        profile_url: "https://www.pixiv.net/users/22252953",
        display_name: "uroobnad2",
        username: "user_myeg3558",
        tags: %w[Ugoira png blue],
        dtext_artist_commentary_title: "ugoira",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A ugoira sample frame URL" do
      strategy_should_work(
        "https://i.pximg.net/img-master/img/2017/04/04/08/57/38/62247364_master1200.jpg",
        image_urls: ["https://i.pximg.net/img-original/img/2017/04/04/08/57/38/62247364_ugoira0.png"],
        media_files: [
          { file_size: 16_275, md5: "4ceadc314938bc27f3574053a3e1459a" },
        ],
        page_url: "https://www.pixiv.net/artworks/62247364",
        profile_url: "https://www.pixiv.net/users/22252953",
        display_name: "uroobnad2",
        username: "user_myeg3558",
        tags: %w[Ugoira png blue],
        dtext_artist_commentary_title: "ugoira",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A ugoira original frame URL" do
      strategy_should_work(
        "https://i.pximg.net/img-original/img/2024/07/24/08/46/41/120834265_ugoira1.png",
        image_urls: %w[https://i.pximg.net/img-original/img/2024/07/24/08/46/41/120834265_ugoira1.png],
        media_files: [{ file_size: 10_155 }],
        page_url: "https://www.pixiv.net/artworks/120834265",
        profile_urls: %w[https://www.pixiv.net/users/1802419 https://www.pixiv.net/stacc/thejunebug],
      )
    end

    context "A high resolution png ugoira post" do
      # https://www.pixiv.net/artworks/95586458
      # https://www.pixiv.net/artworks/97127572
      # https://www.pixiv.net/artworks/100977136
      # https://www.pixiv.net/artworks/101003492
      # https://www.pixiv.net/artworks/108198142
      # https://www.pixiv.net/artworks/113760314
      # https://www.pixiv.net/artworks/115856599
      strategy_should_work(
        "https://www.pixiv.net/artworks/113760314",
        image_urls: ["https://i.pximg.net/img-zip-ugoira/img/2023/11/27/19/51/28/113760314_ugoira1920x1080.zip?original"],
        media_files: [
          {
            file_size: 5_320_292,
            width: 3600,
            height: 2560,
            frame_delays: [125] * 42,
            pixel_hash: "0fc604bc072fbb4bce9326ef5e70172a",
            md5: "cc72a104755b7e032444742d84d74425",
            animation_json: {
              "illustId" => 113_760_314,
              "userId" => 20_951_095,
              "createDate" => "2023-11-27T10:51:00+00:00",
              "uploadDate" => "2023-11-27T10:51:00+00:00",
              "width" => 3600,
              "height" => 2560,
              "mime_type" => "image/png",
              "frames" => [
                { "file" => "000000.png", "delay" => 125, "md5" => "eb8525f3367d8053ca3b7e0ae37e1a08" },
                { "file" => "000001.png", "delay" => 125, "md5" => "2e287728ff0467f0f04135f3b3104e19" },
                { "file" => "000002.png", "delay" => 125, "md5" => "24279a2553f0f3b47f1a0feacd60aff6" },
                { "file" => "000003.png", "delay" => 125, "md5" => "c7c9a57cea4eb9c3a66525916b8cf9f4" },
                { "file" => "000004.png", "delay" => 125, "md5" => "aa5e2ab2bf12c9b64619aa9488c294fc" },
                { "file" => "000005.png", "delay" => 125, "md5" => "9b8ca3cce08fa194b76f57e6f1e0f9a8" },
                { "file" => "000006.png", "delay" => 125, "md5" => "8a723c0362d94cbd0a2b6db84ee7a733" },
                { "file" => "000007.png", "delay" => 125, "md5" => "d93d05e17a22c4d1868925f8d8949def" },
                { "file" => "000008.png", "delay" => 125, "md5" => "9b52bab0815eddc24c80c1dc0e00206e" },
                { "file" => "000009.png", "delay" => 125, "md5" => "2f6fba85377c62e28a843aa51f0db0b2" },
                { "file" => "000010.png", "delay" => 125, "md5" => "75631ea86221d30244065166c1d9ead6" },
                { "file" => "000011.png", "delay" => 125, "md5" => "87c406a4a4fcfd813873aae9314a1cdd" },
                { "file" => "000012.png", "delay" => 125, "md5" => "3876c03dd03a3755081f2b9f6b070396" },
                { "file" => "000013.png", "delay" => 125, "md5" => "cd98204cb873a449b622ca9073c1fba8" },
                { "file" => "000014.png", "delay" => 125, "md5" => "8f4dabc16145ac1c2e638b11327f0ed2" },
                { "file" => "000015.png", "delay" => 125, "md5" => "b8e66f45c1a5709f556a14ac7b8df1bd" },
                { "file" => "000016.png", "delay" => 125, "md5" => "b1ac68df36a29c6e40fb5f8e215d676a" },
                { "file" => "000017.png", "delay" => 125, "md5" => "503dd39d0eba19ad96a423155a6ede9f" },
                { "file" => "000018.png", "delay" => 125, "md5" => "501242cb07a67fe4a29979b96755cbd5" },
                { "file" => "000019.png", "delay" => 125, "md5" => "dbc23ee0c8be863ce8a95fc4cf55b023" },
                { "file" => "000020.png", "delay" => 125, "md5" => "7b8c13d9dbd9769caaf69e3993507416" },
                { "file" => "000021.png", "delay" => 125, "md5" => "7dc92b9a03aaaeb349323b2d2e335555" },
                { "file" => "000022.png", "delay" => 125, "md5" => "1b39d71ad7507326d207025fa86d7c16" },
                { "file" => "000023.png", "delay" => 125, "md5" => "a147b04ef1f4f7031727115132cac37e" },
                { "file" => "000024.png", "delay" => 125, "md5" => "dc82f0359f11dac6b3e00df788b1d3d3" },
                { "file" => "000025.png", "delay" => 125, "md5" => "e8ed7f302e60cb43c271b4f4832d0210" },
                { "file" => "000026.png", "delay" => 125, "md5" => "844499da7eff903fd6e8d37efe201152" },
                { "file" => "000027.png", "delay" => 125, "md5" => "dc55a85730a8d00deface9a8aae0edef" },
                { "file" => "000028.png", "delay" => 125, "md5" => "0aa19805d244fb7ce96011053eb3040f" },
                { "file" => "000029.png", "delay" => 125, "md5" => "c04a642219e9b4ad93d3c3606340c328" },
                { "file" => "000030.png", "delay" => 125, "md5" => "299f155a58f9c7e0d23e0e4015b4e65d" },
                { "file" => "000031.png", "delay" => 125, "md5" => "aa1b27c0fc3a5ac00b10e7fa13fbd86d" },
                { "file" => "000032.png", "delay" => 125, "md5" => "5305cf9479a5f3bdcc346d262796a848" },
                { "file" => "000033.png", "delay" => 125, "md5" => "70b823c1bdc044c47d6b09df95a6981f" },
                { "file" => "000034.png", "delay" => 125, "md5" => "80b256d626a728aa5642b83a5172a424" },
                { "file" => "000035.png", "delay" => 125, "md5" => "4198da593c4e802403d070decd83ec80" },
                { "file" => "000036.png", "delay" => 125, "md5" => "a44039a9278998d8f2436527186e131d" },
                { "file" => "000037.png", "delay" => 125, "md5" => "35cd8530fbd860067a59d35dbb10e51c" },
                { "file" => "000038.png", "delay" => 125, "md5" => "39a933a38b20505b7380a3d32c38d499" },
                { "file" => "000039.png", "delay" => 125, "md5" => "a80130c9a062aa87a5516272c0a3410a" },
                { "file" => "000040.png", "delay" => 125, "md5" => "a7268b0b427aa89a5635f29c4aadbbd2" },
                { "file" => "000041.png", "delay" => 125, "md5" => "b056edb439061ba606ddc1f6d583eb6f" },
              ],
            },
          },
        ],
      )
    end

    context "A revised ugoira zip URL should fail" do
      strategy_should_work(
        "https://i.pximg.net/img-zip-ugoira/img/2024/03/24/07/15/10/117197872_ugoira1920x1080.zip",
        image_urls: [],
      )
    end

    context "A https://www.pixiv.net/*/artworks/* source" do
      strategy_should_work(
        "https://www.pixiv.net/en/artworks/64476642",
        image_urls: ["https://i.pximg.net/img-original/img/2017/08/18/00/09/21/64476642_p0.jpg"],
        page_url: "https://www.pixiv.net/artworks/64476642",
        profile_url: "https://www.pixiv.net/users/27207",
        display_name: "イチリ",
        username: "itiri",
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
        display_name: nil,
        username: nil,
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
        display_name: "影おじ (隠れエリア)",
        profile_url: "https://www.pixiv.net/users/6570768",
        profile_urls: %w[https://www.pixiv.net/stacc/haku3490 https://www.pixiv.net/users/6570768],
        tags: %w[r-18 shylily シャイリリー バーチャルyoutuber バーチャルyoutuber30000users入り 両手に茎 乱交 輪姦],
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
        display_name: "影おじ (隠れエリア)",
        profile_url: "https://www.pixiv.net/users/6570768",
        profile_urls: %w[https://www.pixiv.net/stacc/haku3490 https://www.pixiv.net/users/6570768],
        tags: %w[r-18 shylily シャイリリー バーチャルyoutuber バーチャルyoutuber30000users入り 両手に茎 乱交 輪姦],
      )
    end

    context "An AI-generated post should get the AI tag" do
      strategy_should_work(
        "https://www.pixiv.net/en/artworks/103291492",
        image_urls: ["https://i.pximg.net/img-original/img/2022/12/03/05/06/51/103291492_p0.png"],
        dtext_artist_commentary_title: "Rem's present",
        display_name: "Anzatiridonia",
        profile_url: "https://www.pixiv.net/users/33589885",
        tags: %w[AI Re:ゼロから始める異世界生活 レム リゼロ レム(リゼロ) AIイラスト AnythingV3 Present sweater],
      )
    end

    context "A work requested via Pixiv Requests" do
      strategy_should_work(
        "https://www.pixiv.net/en/artworks/91322075",
        tags: %w[アイドルマスターシンデレラガールズ 大槻唯 濡れ透け パンツ 透けブラ 裾結び プール掃除 おへそ ぱんつ パンモロにも定評のあるゆいれそ pixiv_commission],
      )
    end

    context "A work with the isOriginal flag but not tagged オリジナル" do
      strategy_should_work(
        "https://www.pixiv.net/en/artworks/116168818",
        tags: %w[むちむち VTuber タンクトップ 褐色 ぽっちゃり BBW chubby pixiv_commission original],
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
        dtext_artist_commentary_desc: <<~EOS.chomp,
          foo 【[b]pixiv #46337015 "»":[/posts?tags=pixiv%3A46337015][/b]】bar 【[b]pixiv #14901720 "»":[/posts?tags=pixiv%3A14901720][/b]】

          baz【[b]"user/83739":[https://www.pixiv.net/users/83739] "»":[/artists?search%5Burl_matches%5D=https%3A%2F%2Fwww.pixiv.net%2Fusers%2F83739][/b]】
        EOS
      )
    end

    context "A work with jump.php links in the commentary should convert the links to DText" do
      strategy_should_work(
        "https://www.pixiv.net/en/artworks/68955584",
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        display_name: "éé",
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
        display_name: "uroobnad2",
        username: "user_myeg3558",
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
        display_name: "uroobnad2",
        username: "user_myeg3558",
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
        display_name: "uroobnad2",
        username: "user_myeg3558",
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
        display_name: "病んだ犬",
        username: "3md0m2ng",
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
        dtext_artist_commentary_desc: "主にX(旧:Twitter)に載せた絵の寄せ集めです。",
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
        display_name: "wlop",
        username: "wlop",
        other_names: ["wlop"],
        tags: [
          ["ghostblade", "https://www.pixiv.net/tags/ghostblade/artworks"],
          ["original", "https://www.pixiv.net/tags/オリジナル/artworks"],
          ["wlop", "https://www.pixiv.net/tags/wlop/artworks"],
          ["海琴烟", "https://www.pixiv.net/tags/海琴烟/artworks"],
          ["オリジナル10000users入り", "https://www.pixiv.net/tags/オリジナル10000users入り/artworks"],
        ],
        dtext_artist_commentary_title: "Destination",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A profile image URL" do
      strategy_should_work(
        "https://i.pximg.net/user-profile/img/2014/12/18/10/31/23/8733472_7dc7310db6cc37163af145d04499e411_170.jpg",
        image_urls: ["https://i.pximg.net/user-profile/img/2014/12/18/10/31/23/8733472_7dc7310db6cc37163af145d04499e411_170.jpg"],
        media_files: [{ file_size: 26_040 }],
        page_url: nil,
        profile_url: nil,
        display_name: nil,
        username: nil,
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
        display_name: nil,
        username: nil,
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
        page_url: "https://www.pixiv.net/novel/show.php?id=8465454",
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
        display_name: "緋錬",
        username: nil,
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
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        display_name: nil,
        username: nil,
        other_names: [],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
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
        display_name: "しゅか",
        username: nil,
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
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        display_name: "しゅか",
        username: nil,
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
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        display_name: "しゅか",
        username: nil,
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
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        profile_url: "https://www.pixiv.net/users/66091066",
      )
    end

    context "An imgaz url" do
      strategy_should_work(
        "https://i.pximg.net/imgaz/upload/20240417/163474511.jpg",
        image_urls: %w[https://i.pximg.net/imgaz/upload/20240417/163474511.jpg],
        media_files: [{ file_size: 3_049_892 }],
        page_url: nil,
      )
    end
  end
end
