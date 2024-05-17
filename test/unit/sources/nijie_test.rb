require 'test_helper'

module Sources
  class NijieTest < ActiveSupport::TestCase
    setup do
      skip "Nijie credentials not configured" unless Source::Extractor::Nijie.enabled?
    end

    context "A 'http://nijie.info/view.php?id=:id' url" do
      strategy_should_work(
        "http://nijie.info/view.php?id=213043",
        image_urls: ["https://pic.nijie.net/07/nijie/17/95/728995/illust/0_0_403fdd541191110c_c25585.jpg"],
        media_files: [{ file_size: 132_555 }],
        profile_url: "https://nijie.info/members.php?id=728995",
        display_name: "莚",
        dtext_artist_commentary_title: "ジャージの下は",
        dtext_artist_commentary_desc: "「リトルウィッチアカデミア」から無自覚サキュバスぶりを発揮するアーシュラ先生です"
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
        dtext_artist_commentary_desc: ""
      )
    end

    context "A 'https://pic*.nijie.info/__rs_*/nijie_picture/:id.jpg' preview url (1)" do
      strategy_should_work(
        "https://pic.nijie.net/01/__rs_l120x120/nijie_picture/diff/main/218856_0_236014_20170620101329.png",
        image_urls: ["https://pic.nijie.net/01/nijie_picture/diff/main/218856_0_236014_20170620101329.png"],
        page_url: "https://nijie.info/view.php?id=218856",
        profile_url: "https://nijie.info/members.php?id=236014",
        display_name: "名無しのチンポップ"
      )
    end

    context "A 'https://pic*.nijie.info/__rs_*/nijie_picture/:id.jpg' preview url (2)" do
      strategy_should_work(
        "https://pic.nijie.net/03/__rs_cns350x350/nijie_picture/236014_20170620101426_0.png",
        image_urls: ["https://pic.nijie.net/03/nijie_picture/236014_20170620101426_0.png"],
        page_url: nil,
        profile_url: "https://nijie.info/members.php?id=236014",
        display_name: nil
      )
    end

    context "A Nijie view.php page" do
      strategy_should_work(
        "https://nijie.info/view.php?id=213043",
        image_urls: ["https://pic.nijie.net/07/nijie/17/95/728995/illust/0_0_403fdd541191110c_c25585.jpg"],
        media_files: [{ file_size: 132_555 }],
        display_name: "莚",
        other_names: ["莚"],
        profile_url: "https://nijie.info/members.php?id=728995",
        artist_commentary_title: "ジャージの下は",
        dtext_artist_commentary_desc: "「リトルウィッチアカデミア」から無自覚サキュバスぶりを発揮するアーシュラ先生です",
        tags: %w[眼鏡 リトルウィッチアカデミア アーシュラ先生],
      )
    end

    context "A Nijie post with （）characters in tags" do
      strategy_should_work(
        "https://nijie.info/view.php?id=208316",
        image_urls: %w[https://pic.nijie.net/01/nijie/17/73/715273/illust/0_0_95c084a0a9926fec_97f8d2.jpg],
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
        dtext_artist_commentary_desc: <<~EOS.chomp
          おはようゴザイマスヾ(o´∀｀o)ﾉ
        EOS
      )
    end

    context "A Nijie post with a long commentary that may be truncated" do
      strategy_should_work(
        "http://nijie.info/view.php?id=266532",
        dtext_artist_commentary_title: "ラミアの里",
        dtext_artist_commentary_desc: <<~EOS.chomp
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
        page_url: "https://nijie.info/view.php?id=213043",
        profile_url: "https://nijie.info/members.php?id=728995",
        display_name: "莚"
      )
    end

    context "A Nijie view_popup.php URL" do
      strategy_should_work(
        "https://nijie.info/view_popup.php?id=213043",
        image_urls: ["https://pic.nijie.net/07/nijie/17/95/728995/illust/0_0_403fdd541191110c_c25585.jpg"],
        page_url: "https://nijie.info/view.php?id=213043",
        profile_url: "https://nijie.info/members.php?id=728995",
        display_name: "莚"
      )
    end

    context "A Nijie post with multiple images" do
      strategy_should_work(
        "https://nijie.info/view.php?id=218856",
        image_urls: %w[
          https://pic.nijie.net/02/nijie/17/14/236014/illust/0_0_5a51fc32aa2e13a5_1d8d06.png
          https://pic.nijie.net/06/nijie/17/14/236014/illust/218856_0_d1c29eff823097a1_2449d1.png
          https://pic.nijie.net/06/nijie/17/14/236014/illust/218856_1_7646cf57f6f1c695_f2ed81.png
          https://pic.nijie.net/07/nijie/17/14/236014/illust/218856_2_fba142a9dfda41e3_1c0259.png
          https://pic.nijie.net/08/nijie/17/14/236014/illust/218856_3_2074431327728df6_6ae716.png
          https://pic.nijie.net/05/nijie/17/14/236014/illust/218856_4_6233f9240df78826_14bec9.png
        ],
        dtext_artist_commentary_desc: <<~EOS.chomp
          foo [b]bold[/b] [i]italics[/i] [s]strike[/s] red

          <http://nijie.info/view.php?id=218944>
        EOS
      )
    end

    context "A Nijie image URL without referer" do
      strategy_should_work(
        "https://pic.nijie.net/03/nijie_picture/236014_20170620101426_0.png",
        page_url: nil,
        image_urls: ["https://pic.nijie.net/03/nijie_picture/236014_20170620101426_0.png"],
        profile_url: "https://nijie.info/members.php?id=236014",
      )
    end

    context "A Nijie image url that contains the illust id and artist id (format 1)" do
      strategy_should_work(
        "https://pic.nijie.net/03/nijie_picture/diff/main/218856_4_236014_20170620101333.png",
        image_urls: ["https://pic.nijie.net/03/nijie_picture/diff/main/218856_4_236014_20170620101333.png"],
        page_url: "https://nijie.info/view.php?id=218856",
        profile_url: "https://nijie.info/members.php?id=236014",
        display_name: "名無しのチンポップ"
      )
    end

    context "A Nijie image url that contains the illust id and artist id (format 2)" do
      strategy_should_work(
        "https://pic.nijie.net/04/nijie_picture/diff/main/287736_161475_20181112032855_1.png",
        image_urls: ["https://pic.nijie.net/04/nijie_picture/diff/main/287736_161475_20181112032855_1.png"],
        page_url: "https://nijie.info/view.php?id=287736",
        profile_url: "https://nijie.info/members.php?id=161475",
        display_name: "みな本"
      )
    end

    context "A Nijie mp4 post" do
      strategy_should_work(
        "http://nijie.info/view.php?id=324604",
        image_urls: %w[
          https://pic.nijie.net/01/nijie/19/69/1349569/illust/0_0_a20b709587eb7713_30b409.mp4
          https://pic.nijie.net/03/nijie/19/69/1349569/illust/324604_0_baebdf6d2bf26239_435649.gif
        ]
      )
    end

    context "A Nijie artist profile url" do
      strategy_should_work(
        "https://nijie.info/members_illust.php?id=236014",
        image_urls: [],
        page_url: nil,
        profile_url: "https://nijie.info/members.php?id=236014"
      )
    end

    context "A Nijie url that is invalid" do
      strategy_should_work(
        "http://nijie.info/index.php",
        image_urls: [],
        page_url: nil
      )
    end

    context "A Nijie image belonging to a deleted work" do
      strategy_should_work(
        "https://pic.nijie.net/01/nijie_picture/diff/main/196201_20150201033106_0.jpg",
        profile_url: "https://nijie.info/members.php?id=196201",
        image_urls: ["https://pic.nijie.net/01/nijie_picture/diff/main/196201_20150201033106_0.jpg"]
      )
    end

    context "A deleted Nijie post" do
      strategy_should_work(
        "http://www.nijie.info/view_popup.php?id=212355",
        page_url: "https://nijie.info/view.php?id=212355",
        profile_url: nil,
        display_name: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: ""
      )
    end

    context "a Nijie post requiring login" do
      strategy_should_work(
        "https://nijie.info/view.php?id=203688",
        image_urls: %w[
          https://pic.nijie.net/07/nijie/17/27/676327/illust/0_0_2e46f254324c90c8_dbfc1a.jpg
          https://pic.nijie.net/01/nijie/17/27/676327/illust/203688_0_6f7baf9290a2b1d9_3badf7.jpg
        ]
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
        profile_url: "https://nijie.info/members.php?id=334",
        display_name: "リック・ロガニー",
        tags: %w[中出し フェラ TS ほのぼの],
        dtext_artist_commentary_title: "作品情報",
        dtext_artist_commentary_desc: <<~EOS.chomp
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
        image_urls: ["https://pic.nijie.net/01/nijie_picture/diff/main/201207181053373205_0.jpg"]
      )
    end

    should "Parse Nijie URLs correctly" do
      assert_equal("https://nijie.info/view.php?id=218856", Source::URL.page_url("https://pic01.nijie.info/nijie_picture/diff/main/218856_0_236014_20170620101329.png"))
      assert_equal("https://nijie.info/view.php?id=287736", Source::URL.page_url("https://pic04.nijie.info/nijie_picture/diff/main/287736_161475_20181112032855_1.png"))

      assert(Source::URL.image_url?("https://pic04.nijie.info/omata/4829_20161128012012.png"))
      assert(Source::URL.image_url?("https://pic01.nijie.info/nijie_picture/20120211210359.jpg"))
      assert(Source::URL.image_url?("https://pic03.nijie.info/nijie_picture/28310_20131101215959.jpg"))
      assert(Source::URL.image_url?("https://pic01.nijie.info/nijie_picture/diff/main/218856_0_236014_20170620101329.png "))
      assert(Source::URL.image_url?("https://pic.nijie.net/07/nijie/17/95/728995/illust/0_0_403fdd541191110c_c25585.jpg"))
      assert(Source::URL.image_url?("https://pic.nijie.net/06/nijie/17/14/236014/illust/218856_1_7646cf57f6f1c695_f2ed81.png"))
      assert(Source::URL.image_url?("https://pic.nijie.net/03/nijie_picture/236014_20170620101426_0.png "))
      assert(Source::URL.image_url?("https://pic.nijie.net/01/nijie_picture/diff/main/196201_20150201033106_0.jpg"))

      assert(Source::URL.page_url?("https://nijie.info/view.php?id=218856"))
      assert(Source::URL.page_url?("https://nijie.info/view_popup.php?id=218856"))
      assert(Source::URL.page_url?("https://www.nijie.info/view.php?id=218856"))
      assert(Source::URL.page_url?("https://sp.nijie.info/view.php?id=218856"))

      assert(Source::URL.profile_url?("https://nijie.info/members.php?id=236014"))
      assert(Source::URL.profile_url?("https://nijie.info/members_illust.php?id=236014"))

      assert_nil(Source::URL.page_url("http://pic02.nijie.info/nijie_picture/diff/main/0_23473_141_20120913002158.jpg"))
    end
  end
end
