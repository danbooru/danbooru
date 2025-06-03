require "test_helper"

module Source::Tests::Extractor
  class NijieExtractorTest < ActiveSupport::TestCase
    setup do
      skip "Nijie credentials not configured" unless Source::Extractor::Nijie.enabled?
    end

    context "A 'http://nijie.info/view.php?id=:id' url" do
      strategy_should_work(
        "http://nijie.info/view.php?id=213043",
        image_urls: ["https://pic.nijie.net/__s4__/d7e38dee79ff08328ccdb0b5a2edeb7e5454f3ad2e3ec8bf044d47c0faf317fd2cfc650ebe4361ce3b43062b23cf44638f9ac782ce690f1db4b7f5fff72ee91fffebe1c4ae6fb677b43854f3c9ec4c9dcc418dd165e834839f381a2c.jpg"],
        media_files: [{ file_size: 132_555 }],
        profile_url: "https://nijie.info/members.php?id=728995",
        display_name: "莚",
        dtext_artist_commentary_title: "ジャージの下は",
        dtext_artist_commentary_desc: "「リトルウィッチアカデミア」から無自覚サキュバスぶりを発揮するアーシュラ先生です",
      )
    end

    context "A 'https://pic*.nijie.info/nijie_picture/:id.jpg' url" do
      strategy_should_work(
        "https://pic.nijie.net/07/nijie/17/95/728995/illust/0_0_403fdd541191110c_c25585.jpg",
        image_urls: ["https://pic.nijie.net/07/nijie/17/95/728995/illust/0_0_403fdd541191110c_c25585.jpg"],
        media_files: [{ file_size: 132_555 }],
        profile_url: "https://nijie.info/members.php?id=728995",
        display_name: nil,
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A 'https://pic*.nijie.info/__rs_*/nijie_picture/:id.jpg' preview url (1)" do
      strategy_should_work(
        "https://pic.nijie.net/01/__rs_l120x120/nijie_picture/diff/main/218856_0_236014_20170620101329.png",
        image_urls: ["https://pic.nijie.net/01/nijie_picture/diff/main/218856_0_236014_20170620101329.png"],
        page_url: "https://nijie.info/view.php?id=218856",
        profile_url: "https://nijie.info/members.php?id=236014",
        display_name: "名無しのチンポップ",
      )
    end

    context "A 'https://pic*.nijie.info/__rs_*/nijie_picture/:id.jpg' preview url (2)" do
      strategy_should_work(
        "https://pic.nijie.net/03/__rs_cns350x350/nijie_picture/236014_20170620101426_0.png",
        image_urls: ["https://pic.nijie.net/03/nijie_picture/236014_20170620101426_0.png"],
        page_url: nil,
        profile_url: "https://nijie.info/members.php?id=236014",
        display_name: nil,
      )
    end

    context "A Nijie view.php page" do
      strategy_should_work(
        "https://nijie.info/view.php?id=213043",
        image_urls: %w[https://pic.nijie.net/__s4__/d7e38dee79ff08328ccdb0b5a2edeb7e5454f3ad2e3ec8bf044d47c0faf317fd2cfc650ebe4361ce3b43062b23cf44638f9ac782ce690f1db4b7f5fff72ee91fffebe1c4ae6fb677b43854f3c9ec4c9dcc418dd165e834839f381a2c.jpg],
        media_files: [{ file_size: 132_555 }],
        page_url: "https://nijie.info/view.php?id=213043",
        profile_urls: %w[https://nijie.info/members.php?id=728995],
        display_name: "莚",
        username: nil,
        tags: %w[眼鏡 リトルウィッチアカデミア アーシュラ先生],
        dtext_artist_commentary_title: "ジャージの下は",
        dtext_artist_commentary_desc: "「リトルウィッチアカデミア」から無自覚サキュバスぶりを発揮するアーシュラ先生です",
      )
    end

    context "A Nijie post with （）characters in tags" do
      strategy_should_work(
        "https://nijie.info/view.php?id=208316",
        image_urls: %w[https://pic.nijie.net/__s4__/d7b38ab576a90862dbc8b0baa7e6b67a4c19c94e79b0aa866fad2767bb4dbc858f3f2cd8df943eca008c509fba206c2c59d327c235a742f9f491ae85195bf45e11c976a57d7b8b1aea730b16899120feb05bb5bceae76b9a3d9f1135.jpg],
        media_files: [{ file_size: 394_275 }],
        page_url: "https://nijie.info/view.php?id=208316",
        profile_url: "https://nijie.info/members.php?id=715273",
        profile_urls: %w[https://nijie.info/members.php?id=715273],
        display_name: "雪代あるて",
        other_names: ["雪代あるて"],
        tag_name: "nijie_715273",
        tags: [
          ["艦隊これくしょん", "https://nijie.info/search.php?word=%E8%89%A6%E9%9A%8A%E3%81%93%E3%82%8C%E3%81%8F%E3%81%97%E3%82%87%E3%82%93"],
          ["艦これ", "https://nijie.info/search.php?word=%E8%89%A6%E3%81%93%E3%82%8C"],
          ["加賀（艦これ）", "https://nijie.info/search.php?word=%E5%8A%A0%E8%B3%80%EF%BC%88%E8%89%A6%E3%81%93%E3%82%8C%EF%BC%89"],
          ["加賀(艦これ)", "https://nijie.info/search.php?word=%E5%8A%A0%E8%B3%80%28%E8%89%A6%E3%81%93%E3%82%8C%29"],
          ["正規空母", "https://nijie.info/search.php?word=%E6%AD%A3%E8%A6%8F%E7%A9%BA%E6%AF%8D"],
          ["航空母艦", "https://nijie.info/search.php?word=%E8%88%AA%E7%A9%BA%E6%AF%8D%E8%89%A6"],
        ],
        dtext_artist_commentary_title: "加賀さん",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          おはようゴザイマスヾ(o´∀｀o)ﾉ
        EOS
      )
    end

    context "A Nijie post with a long commentary that may be truncated" do
      strategy_should_work(
        "http://nijie.info/view.php?id=266532",
        image_urls: %w[https://pic.nijie.net/__s4__/d7b7ddb372fb59388d9ae1baa3eaea7e8e6dfba9fab96f2e17916139ff22f26cefb189070a222b6cb594131349c580aefef6cca4f1bcaff8ce4c8e57b542ea28219fd3232910ea6215e7bcc766092e19cf02f6d5af2cd6b824259cd5.jpg],
        media_files: [{ file_size: 483_643 }],
        page_url: "https://nijie.info/view.php?id=266532",
        profile_urls: %w[https://nijie.info/members.php?id=74777],
        display_name: "ランタナ",
        username: nil,
        tags: %w[人外 褐色 モンスター娘 ラミア],
        dtext_artist_commentary_title: "ラミアの里",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          サークルaskot様より販売されました「ラミアの里 ～ラミアはぁれむで搾られて～」にて前回に引き続きフラウのイラストを担当させて頂きました。
          前作を知らなくても問題なく愉しめる内容となっております。体験版もありますので気になりましたら是非ダウンロードしてみて下さい。
          DLsite【<http://www.dlsite.com/maniax/work/=/product_id/RJ226998.html>】
        EOS
      )
    end

    context "A Nijie image with a view_popup.php referer url" do
      strategy_should_work(
        "http://pic.nijie.net/03/nijie_picture/728995_20170505014820_0.jpg",
        referer: "https://nijie.info/view_popup.php?id=213043",
        image_urls: ["https://pic.nijie.net/03/nijie_picture/728995_20170505014820_0.jpg"],
        # media_files: [{ file_size: 132_555 }],
        page_url: "https://nijie.info/view.php?id=213043",
        profile_urls: %w[https://nijie.info/members.php?id=728995],
        display_name: "莚",
        username: nil,
        tags: %w[眼鏡 リトルウィッチアカデミア アーシュラ先生],
        dtext_artist_commentary_title: "ジャージの下は",
        dtext_artist_commentary_desc: "「リトルウィッチアカデミア」から無自覚サキュバスぶりを発揮するアーシュラ先生です",
      )
    end

    context "A Nijie view_popup.php URL" do
      strategy_should_work(
        "https://nijie.info/view_popup.php?id=213043",
        image_urls: ["https://pic.nijie.net/__s4__/d7e38dee79ff08328ccdb0b5a2edeb7e5454f3ad2e3ec8bf044d47c0faf317fd2cfc650ebe4361ce3b43062b23cf44638f9ac782ce690f1db4b7f5fff72ee91fffebe1c4ae6fb677b43854f3c9ec4c9dcc418dd165e834839f381a2c.jpg"],
        media_files: [{ file_size: 132_555 }],
        page_url: "https://nijie.info/view.php?id=213043",
        profile_urls: %w[https://nijie.info/members.php?id=728995],
        display_name: "莚",
        username: nil,
        tags: %w[眼鏡 リトルウィッチアカデミア アーシュラ先生],
        dtext_artist_commentary_title: "ジャージの下は",
        dtext_artist_commentary_desc: "「リトルウィッチアカデミア」から無自覚サキュバスぶりを発揮するアーシュラ先生です",
      )
    end

    context "A Nijie post with multiple images" do
      strategy_should_work(
        "https://nijie.info/view.php?id=218856",
        image_urls: %w[
          https://pic.nijie.net/__s4__/d7e18ab173fc5c31d89de3eba7eae62cde568c34049046bbd00d5db57365f22a664560e3b6563a86c71c70a15505489eb915f8f2102c1732144fa69453179e712b1a46f390b3d51e152a1717c557876500cac9bc742b28d43556f5b4.png
          https://pic.nijie.net/__s4__/d7b98ae276fe5f368fc9b7b5a2bee62d98e426ea830f2ffa6cd42076c2260b2308bd8cdc31981ce323cb93de23694dee1ba3a364f53bda6150b3102b995ea722040a9f8f084d0164cc3813f83dade80f4a468d28f0b6642602ddf692.png
          https://pic.nijie.net/__s4__/d7b0dae125ac0a33dfc9e4bcf0e6e72d320299f00891a633261ad6710b2bf68ca525b1c6d8008f9276327057f2b0340483bf3bba5ea3886029036200835b9e28774db2e209d27da0e77b647fccd1cfb4d7a85ed08326a8df487ff308.png
          https://pic.nijie.net/__s4__/d7e5dae222f859638a9ab1bef2ecb27e4a55a54d6bdd24a831312fa2413325b22c12ea318f0083b43fbc15d1367d3eb99b7455e1bf127a3406736ed3e774e7f9b8eee9a8da1adf376335af9d93f9f83665ad6f43e868c888ac010501.png
          https://pic.nijie.net/__s4__/d7b28ab474fe5a358c9ee4baa0eaea2ebe6a4e49d9d5aefe339e01e19cbadb97517069e692fdccf06aed6c4af2b2573095717449f193150ca336ea68996b0e86e8c8e1920757cbc9584737f50adeb88fbf8a14572163a9ec6dc82361.png
          https://pic.nijie.net/__s4__/d7b7d8e774fc0c678e9ee5baa4e7e37f43c1d5c9ba91a7daa7946630a7715b6a7d3763a6114a8d361f335a860cf1fcc22ffcf24b69d8e03c023d9f77f86265c4eb57903a5715893d94e538b2a0c810b7b4fca9ea02ab2db1766e49d4.png
        ],
        media_files: [
          { file_size: 3_619 },
          { file_size: 3_620 },
          { file_size: 83_421 },
          { file_size: 72_628 },
          { file_size: 62_664 },
          { file_size: 65_244 },
        ],
        page_url: "https://nijie.info/view.php?id=218856",
        profile_urls: %w[https://nijie.info/members.php?id=236014],
        display_name: "名無しのチンポップ",
        username: nil,
        tags: %w[BAR foo baz],
        dtext_artist_commentary_title: "public - r18 - gallery",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          foo [b]bold[/b] [i]italics[/i] [s]strike[/s] red

          <http://nijie.info/view.php?id=218944>
        EOS
      )
    end

    context "A Nijie image URL without referer" do
      strategy_should_work(
        "https://pic.nijie.net/03/nijie_picture/236014_20170620101426_0.png",
        image_urls: ["https://pic.nijie.net/03/nijie_picture/236014_20170620101426_0.png"],
        page_url: nil,
        profile_urls: %w[https://nijie.info/members.php?id=236014],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A Nijie image url that contains the illust id and artist id (format 1)" do
      strategy_should_work(
        "https://pic.nijie.net/03/nijie_picture/diff/main/218856_4_236014_20170620101333.png",
        image_urls: ["https://pic.nijie.net/03/nijie_picture/diff/main/218856_4_236014_20170620101333.png"],
        page_url: "https://nijie.info/view.php?id=218856",
        profile_url: "https://nijie.info/members.php?id=236014",
        display_name: "名無しのチンポップ",
      )
    end

    context "A Nijie image url that contains the illust id and artist id (format 2)" do
      strategy_should_work(
        "https://pic.nijie.net/04/nijie_picture/diff/main/287736_161475_20181112032855_1.png",
        image_urls: ["https://pic.nijie.net/04/nijie_picture/diff/main/287736_161475_20181112032855_1.png"],
        page_url: "https://nijie.info/view.php?id=287736",
        profile_urls: %w[https://nijie.info/members.php?id=161475],
        display_name: "みな本",
        username: nil,
        tags: %w[オリジナル 制服 R-18 バック JK],
        dtext_artist_commentary_title: "がっこうのかいだん",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          ニジエの効果音再生が使いたくて描きました。
          あれは本当にいい機能だ、、、特に環境音、趣がある

          【例】
          環境音「学校」効果音「ぱんぱん弱」声「あえぎ弱or興奮_弱」

          二枚目以降は書き文字なしとか、アップとか
        EOS
      )
    end

    context "A Nijie mp4 post" do
      strategy_should_work(
        "http://nijie.info/view.php?id=324604",
        image_urls: %w[
          https://pic.nijie.net/__s4__/d7b4d9e024f20c318e9feaeea6efeb2366c9d8c18f09c78f757f854a0cda8a1ab7ba4605ab51cd6fdfcbc9e2e5f6592891f7e476cfec579af0692f680a5320b01fddc0700c2c5575bfd1fb4c30b41390d73aa31a87c246cf40589f74.mp4
          https://pic.nijie.net/__s4__/d7b18ae424fc0838dfc5e1bba5e8e2239ec10ba9555c708446b9e781b06f8b7f043d36efa27676943fa40cebe606bcf3343dd0a4cf6cbcb13502ce9a613878d6ff364dcfcabbd10122aeb35e9767057699d061f0a6f1f922381db75b.gif
        ],
        media_files: [
          { file_size: 4_888_400 },
          { file_size: 1_785_723 },
        ],
        page_url: "https://nijie.info/view.php?id=324604",
        profile_urls: %w[https://nijie.info/members.php?id=1349569],
        display_name: "きがんえいじ",
        username: nil,
        tags: [
          ["東方", "https://nijie.info/search.php?word=%E6%9D%B1%E6%96%B9"],
          ["パイズリ", "https://nijie.info/search.php?word=%E3%83%91%E3%82%A4%E3%82%BA%E3%83%AA"],
          ["ロリ巨乳", "https://nijie.info/search.php?word=%E3%83%AD%E3%83%AA%E5%B7%A8%E4%B9%B3"],
          ["博麗霊夢", "https://nijie.info/search.php?word=%E5%8D%9A%E9%BA%97%E9%9C%8A%E5%A4%A2"],
          ["GIFアニメ", "https://nijie.info/search.php?word=GIF%E3%82%A2%E3%83%8B%E3%83%A1"],
          ["MP4", "https://nijie.info/search.php?word=MP4"],
        ],
        dtext_artist_commentary_title: "【GIF】霊夢パイズリ",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          嫌々パイズリをしてくれる霊夢のGIF
          2枚目：ループ部分
        EOS
      )
    end

    context "A Nijie artist profile url" do
      strategy_should_work(
        "https://nijie.info/members_illust.php?id=236014",
        image_urls: [],
        page_url: nil,
        profile_url: "https://nijie.info/members.php?id=236014",
      )
    end

    context "A Nijie url that is invalid" do
      strategy_should_work(
        "http://nijie.info/index.php",
        image_urls: [],
        page_url: nil,
      )
    end

    context "A Nijie image belonging to a deleted work" do
      strategy_should_work(
        "https://pic.nijie.net/01/nijie_picture/diff/main/196201_20150201033106_0.jpg",
        image_urls: %w[https://pic.nijie.net/01/nijie_picture/diff/main/196201_20150201033106_0.jpg],
        page_url: nil,
        profile_urls: %w[https://nijie.info/members.php?id=196201],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A deleted Nijie post" do
      strategy_should_work(
        "http://www.nijie.info/view_popup.php?id=212355",
        image_urls: [],
        page_url: "https://nijie.info/view.php?id=212355",
        profile_urls: [],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "a Nijie post requiring login" do
      strategy_should_work(
        "https://nijie.info/view.php?id=203688",
        image_urls: %w[
          https://pic.nijie.net/__s4__/d7e68fe374a850678dcce7bca5bce37866ebc246f1ba8e52ef68ba1f2485071b87a907b7f87fe5ee897b45d7bde18f08a04144995054be4502a00e914829f7a14bd816a14d753bf6efbf535ad5eb8c3388feec2d9963777d24eb3243.jpg
          https://pic.nijie.net/__s4__/d7e5d8ee77fc0837dccee3bba7b9b72daeafc5d6294c81d1cf56f94aa872886fcc083b0a82b2416bd3bad71ec1c37e9a9fff37228d8e4b720df8ab1cf817bcb3ed36114ce839a9c71877c4a1b69a8e9b7f932da7c9320532958b99e8.jpg
        ],
        media_files: [
          { file_size: 1_200_090 },
          { file_size: 1_105_995 },
        ],
        page_url: "https://nijie.info/view.php?id=203688",
        profile_urls: %w[https://nijie.info/members.php?id=676327],
        display_name: "satosi",
        username: nil,
        tags: %w[全裸 看板娘 巨乳 手ブラ バレンタイン 輪チラ 誘ってやがる あいり],
        dtext_artist_commentary_title: "バレンタイン",
        dtext_artist_commentary_desc: "食べちゃってください",
      )
    end

    context "when the cached session cookie is invalid" do
      should "clear the cached cookie after failing to fetch the data" do
        site = Source::Extractor.find("https://nijie.info/view.php?id=203688")

        Cache.put("nijie-session-cookie", { "NIJIEIJIEID" => "fake", "nijie_tok" => "fake" })
        assert_equal({ "NIJIEIJIEID" => "fake", "nijie_tok" => "fake" }, site.cached_session_cookie)

        site.image_urls
        assert_nil(Cache.get("nijie-session-cookie"))
      end
    end

    context "a Nijie doujin post" do
      strategy_should_work(
        "https://pic.nijie.net/01/dojin_main/dojin_sam/20120213044700%E3%82%B3%E3%83%94%E3%83%BC%20%EF%BD%9E%200011%E3%81%AE%E3%82%B3%E3%83%94%E3%83%BC.jpg",
        referer: "https://nijie.info/view.php?id=53023",
        image_urls: ["https://pic.nijie.net/01/dojin_main/dojin_sam/20120213044700%E3%82%B3%E3%83%94%E3%83%BC%20%EF%BD%9E%200011%E3%81%AE%E3%82%B3%E3%83%94%E3%83%BC.jpg"],
        page_url: "https://nijie.info/view.php?id=53023",
        profile_urls: %w[https://nijie.info/members.php?id=334],
        display_name: "リック・ロガニー",
        username: nil,
        tags: %w[中出し フェラ TS ほのぼの],
        dtext_artist_commentary_title: "作品情報",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          ある日目がさめると女の子になっていたいつき
          そこへ幼馴染の小梅が現れて…
          2010年コミックマーケット78で販売したコピー本のDL版で
          本編18Pの短編マンガです
        EOS
      )
    end

    context "an unsupported Nijie image url" do
      strategy_should_work(
        "https://pic.nijie.net/01/nijie_picture/diff/main/201207181053373205_0.jpg",
        referer: "https://nijie.info/view_popup.php?id=18858&#diff_1",
        image_urls: ["https://pic.nijie.net/01/nijie_picture/diff/main/201207181053373205_0.jpg"],
        page_url: "https://nijie.info/view.php?id=18858",
        profile_urls: %w[https://nijie.info/members.php?id=3205],
        display_name: "まる。",
        username: nil,
        tags: %w[漫画 RO C82 アークビショップ ラグナロクオンライン],
        dtext_artist_commentary_title: "ABさん 色いじり",
        dtext_artist_commentary_desc: "C82新刊表紙イラストの、服色を弄ってみました。 黒も捨てがたかったのですけど、EXカラーは青→黒になっただけなのか不安だったので、結局青に～。 本文サンプルは今月末頃に出せたらイイナと思ってます。ABさんのいちゃラブ成人向け本です。 ■C82では他にも新刊とグッズを出す予定です。詳細はサイトで順次出して行きますのでよろしくお願いします <http://sailr.sakura.ne.jp/>",
      )
    end
  end
end
