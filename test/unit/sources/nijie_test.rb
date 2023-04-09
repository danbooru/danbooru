require 'test_helper'

module Sources
  class NijieTest < ActiveSupport::TestCase
    setup do
      skip "Nijie credentials not configured" unless Source::Extractor::Nijie.enabled?
      skip if ENV["CI"].present?
    end

    context "downloading a 'http://nijie.info/view.php?id=:id' url" do
      should "download the original file" do
        @source = "http://nijie.info/view.php?id=213043"
        @rewrite = "https://pic.nijie.net/07/nijie/17/95/728995/illust/0_0_403fdd541191110c_c25585.jpg"
        assert_rewritten(@rewrite, @source)
        assert_downloaded(132_555, @source)
      end
    end

    context "downloading a 'https://pic*.nijie.info/nijie_picture/:id.jpg' url" do
      should "download the original file" do
        @source = "https://pic.nijie.net/07/nijie/17/95/728995/illust/0_0_403fdd541191110c_c25585.jpg"
        assert_not_rewritten(@source)
        assert_downloaded(132_555, @source)
      end
    end

    context "downloading a 'https://pic*.nijie.info/__rs_*/nijie_picture/:id.jpg' preview url" do
      should "download the original file" do
        assert_rewritten(
          "https://pic.nijie.net/01/nijie_picture/diff/main/218856_0_236014_20170620101329.png",
          "https://pic.nijie.net/01/__rs_l120x120/nijie_picture/diff/main/218856_0_236014_20170620101329.png"
        )

        assert_rewritten(
          "https://pic.nijie.net/03/nijie_picture/236014_20170620101426_0.png",
          "https://pic.nijie.net/03/__rs_cns350x350/nijie_picture/236014_20170620101426_0.png"
        )
      end
    end

    context "A Nijie page" do
      strategy_should_work(
        "https://nijie.info/view.php?id=213043",
        image_urls: ["https://pic.nijie.net/07/nijie/17/95/728995/illust/0_0_403fdd541191110c_c25585.jpg"],
        media_files: [{ file_size: 132_555 }],
        artist_name: "莚",
        other_names: ["莚"],
        profile_url: "https://nijie.info/members.php?id=728995",
        artist_commentary_title: "ジャージの下は",
        dtext_artist_commentary_desc: "「リトルウィッチアカデミア」から無自覚サキュバスぶりを発揮するアーシュラ先生です",
        tags: %w[眼鏡 リトルウィッチアカデミア アーシュラ先生],
      )
    end

    context "A Nijie post" do
      should "normalize （）characters in tags" do
        FactoryBot.create(:tag, :name => "kaga")
        FactoryBot.create(:wiki_page, :title => "kaga", :other_names => "加賀(艦これ)")

        @site = Source::Extractor.find("https://nijie.info/view.php?id=208316")

        assert_includes(@site.tags.map(&:first), "加賀（艦これ）")
        assert_includes(@site.translated_tags.map(&:name), "kaga")
      end
    end

    context "For long commentaries that may be truncated" do
      should "get the full commentary" do
        site = Source::Extractor.find("http://nijie.info/view.php?id=266532")
        title = "ラミアの里"
        desc = <<~EOS.chomp
          サークルaskot様より販売されました「ラミアの里 ～ラミアはぁれむで搾られて～」にて前回に引き続きフラウのイラストを担当させて頂きました。

          前作を知らなくても問題なく愉しめる内容となっております。体験版もありますので気になりましたら是非ダウンロードしてみて下さい。

          DLsite【<http://www.dlsite.com/maniax/work/=/product_id/RJ226998.html>】
        EOS

        assert_equal(title, site.dtext_artist_commentary_title)
        assert_equal(desc, site.dtext_artist_commentary_desc)
      end
    end

    context "The source site for a nijie referer url" do
      setup do
        @site = Source::Extractor.find("http://pic.nijie.net/03/nijie_picture/728995_20170505014820_0.jpg", "https://nijie.info/view_popup.php?id=213043")
      end

      should "get the image url" do
        assert_equal(["https://pic.nijie.net/03/nijie_picture/728995_20170505014820_0.jpg"], @site.image_urls)
      end

      should "get the page url" do
        assert_equal("https://nijie.info/view.php?id=213043", @site.page_url)
      end

      should "get the profile" do
        assert_equal("https://nijie.info/members.php?id=728995", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("莚", @site.artist_name)
      end
    end

    context "The source site for a nijie popup" do
      setup do
        @site = Source::Extractor.find("https://nijie.info/view_popup.php?id=213043")
      end

      should "get the image url" do
        assert_equal(["https://pic.nijie.net/07/nijie/17/95/728995/illust/0_0_403fdd541191110c_c25585.jpg"], @site.image_urls)
      end

      should "get the page url" do
        assert_equal("https://nijie.info/view.php?id=213043", @site.page_url)
      end

      should "get the profile" do
        assert_equal("https://nijie.info/members.php?id=728995", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("莚", @site.artist_name)
      end
    end

    context "The source site for a nijie gallery" do
      setup do
        @site = Source::Extractor.find("https://nijie.info/view.php?id=218856")
      end

      should "get the image urls" do
        urls = %w[
          https://pic.nijie.net/02/nijie/17/14/236014/illust/0_0_5a51fc32aa2e13a5_1d8d06.png
          https://pic.nijie.net/06/nijie/17/14/236014/illust/218856_0_d1c29eff823097a1_2449d1.png
          https://pic.nijie.net/06/nijie/17/14/236014/illust/218856_1_7646cf57f6f1c695_f2ed81.png
          https://pic.nijie.net/07/nijie/17/14/236014/illust/218856_2_fba142a9dfda41e3_1c0259.png
          https://pic.nijie.net/08/nijie/17/14/236014/illust/218856_3_2074431327728df6_6ae716.png
          https://pic.nijie.net/05/nijie/17/14/236014/illust/218856_4_6233f9240df78826_14bec9.png
        ]

        assert_equal(urls, @site.image_urls)
      end

      should "get the dtext-ified commentary" do
        desc = <<-EOS.strip_heredoc.chomp
          foo [b]bold[/b] [i]italics[/i] [s]strike[/s] red

          <http://nijie.info/view.php?id=218944>
        EOS

        assert_equal(desc, @site.dtext_artist_commentary_desc)
      end
    end

    context "The source site for a nijie image url without referer" do
      should "get the correct urls" do
        image_url = "https://pic.nijie.net/03/nijie_picture/236014_20170620101426_0.png"
        site = Source::Extractor.find(image_url)

        assert_nil(site.page_url)
        assert_equal([image_url], site.image_urls)
        assert_equal("https://nijie.info/members.php?id=236014", site.profile_url)
        assert_nothing_raised { site.to_h }
      end
    end

    context "An image url that contains the illust id and artist id (format 1)" do
      should "fetch all the data" do
        site = Source::Extractor.find("https://pic.nijie.net/03/nijie_picture/diff/main/218856_4_236014_20170620101333.png")

        assert_equal("https://nijie.info/view.php?id=218856", site.page_url)
        assert_equal("https://nijie.info/members.php?id=236014", site.profile_url)
        assert_equal("名無しのチンポップ", site.artist_name)
        assert_equal([site.url], site.image_urls)
      end
    end

    context "An image url that contains the illust id and artist id (format 2)" do
      should "fetch all the data" do
        site = Source::Extractor.find("https://pic.nijie.net/04/nijie_picture/diff/main/287736_161475_20181112032855_1.png")

        assert_equal("https://nijie.info/view.php?id=287736", site.page_url)
        assert_equal("https://nijie.info/members.php?id=161475", site.profile_url)
        assert_equal("みな本", site.artist_name)
        assert_equal([site.url], site.image_urls)
      end
    end

    context "An mp4 post" do
      should "find the mp4 file" do
        site = Source::Extractor.find("http://nijie.info/view.php?id=324604")

        assert_equal(%w[
          https://pic.nijie.net/01/nijie/19/69/1349569/illust/0_0_a20b709587eb7713_30b409.mp4
          https://pic.nijie.net/03/nijie/19/69/1349569/illust/324604_0_baebdf6d2bf26239_435649.gif
        ], site.image_urls)
      end
    end

    context "An artist profile url" do
      should "not fail" do
        site = Source::Extractor.find("https://nijie.info/members_illust.php?id=236014")
        assert_equal("https://nijie.info/members.php?id=236014", site.profile_url)
        assert_nothing_raised { site.to_h }
      end
    end

    context "An url that is invalid" do
      should "not fail" do
        site = Source::Extractor.find("http://nijie.info/index.php")
        assert_nothing_raised { site.to_h }
      end
    end

    context "A deleted work" do
      context "for an image url" do
        should "find the profile url" do
          site = Source::Extractor.find("https://pic.nijie.net/01/nijie_picture/diff/main/196201_20150201033106_0.jpg")

          assert_nothing_raised { site.to_h }
          assert_equal("https://nijie.info/members.php?id=196201", site.profile_url)
          assert_equal([site.url], site.image_urls)
        end
      end

      context "for a page url" do
        should "not fail" do
          site = Source::Extractor.find("http://www.nijie.info/view_popup.php?id=212355")

          assert_equal("https://nijie.info/view.php?id=212355", site.page_url)
          assert_nil(site.profile_url)
          assert_nil(site.artist_name)
          assert_nil(site.artist_commentary_desc)
          assert_nil(site.artist_commentary_title)
          assert_empty(site.tags)
          assert_nothing_raised { site.to_h }
        end
      end
    end

    context "a post requiring login" do
      should "not fail" do
        site = Source::Extractor.find("https://nijie.info/view.php?id=203688")

        urls = %w[
          https://pic.nijie.net/07/nijie/17/27/676327/illust/0_0_2e46f254324c90c8_dbfc1a.jpg
          https://pic.nijie.net/01/nijie/17/27/676327/illust/203688_0_6f7baf9290a2b1d9_3badf7.jpg
        ]
        assert_equal(urls, site.image_urls)
      end
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

    context "a doujin post" do
      should "work" do
        image = "https://pic.nijie.net/01/dojin_main/dojin_sam/20120213044700%E3%82%B3%E3%83%94%E3%83%BC%20%EF%BD%9E%200011%E3%81%AE%E3%82%B3%E3%83%94%E3%83%BC.jpg"
        page = "https://nijie.info/view.php?id=53023"
        site = Source::Extractor.find(image, page)

        tags = [%w[中出し https://nijie.info/search_dojin.php?word=%E4%B8%AD%E5%87%BA%E3%81%97],
                %w[フェラ https://nijie.info/search_dojin.php?word=%E3%83%95%E3%82%A7%E3%83%A9],
                %w[TS https://nijie.info/search_dojin.php?word=TS],
                %w[ほのぼの https://nijie.info/search_dojin.php?word=%E3%81%BB%E3%81%AE%E3%81%BC%E3%81%AE]]

        assert(site.doujin?)
        assert_equal([image], site.image_urls)
        assert_equal("作品情報", site.artist_commentary_title)
        assert_equal("<p>ある日目がさめると女の子になっていたいつき<br>\nそこへ幼馴染の小梅が現れて…<br>\n2010年コミックマーケット78で販売したコピー本のDL版で<br>\n本編18Pの短編マンガです <br>\n</p>", site.artist_commentary_desc)
        assert_equal(tags, site.tags)
        assert_equal("リック・ロガニー", site.artist_name)
      end
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
    end

    context "an unsupported image url" do
      should "not break the bookmarklet" do
        image_url = "https://pic.nijie.net/01/nijie_picture/diff/main/201207181053373205_0.jpg"
        source = Source::Extractor.find(image_url, "https://nijie.info/view_popup.php?id=18858&#diff_1")

        assert_equal([image_url], source.image_urls)
      end
    end
  end
end
