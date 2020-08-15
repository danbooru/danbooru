require 'test_helper'

module Sources
  class NijieTest < ActiveSupport::TestCase
    context "downloading a 'http://nijie.info/view.php?id=:id' url" do
      should "download the original file" do
        @source = "http://nijie.info/view.php?id=213043"
        @rewrite = "https://pic.nijie.net/03/nijie_picture/728995_20170505014820_0.jpg"
        assert_rewritten(@rewrite, @source)
        assert_downloaded(132_555, @source)
      end
    end

    context "downloading a 'https://pic*.nijie.info/nijie_picture/:id.jpg' url" do
      should "download the original file" do
        @source = "https://pic.nijie.net/03/nijie_picture/728995_20170505014820_0.jpg"
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

    context "The source site for a nijie page" do
      setup do
        CurrentUser.user = FactoryBot.create(:user)
        CurrentUser.ip_addr = "127.0.0.1"

        @site = Sources::Strategies.find("https://nijie.info/view.php?id=213043")
      end

      should "get the image url" do
        assert_equal("https://pic.nijie.net/03/nijie_picture/728995_20170505014820_0.jpg", @site.image_url)
        assert_downloaded(132_555, @site.image_url)
      end

      should "get the canonical url" do
        assert_equal("https://nijie.info/view.php?id=213043", @site.canonical_url)
      end

      should "get the preview url" do
        assert_equal("https://pic.nijie.net/03/__rs_l170x170/nijie_picture/728995_20170505014820_0.jpg", @site.preview_url)
        assert_equal([@site.preview_url], @site.preview_urls)
        assert_downloaded(132_555, @site.preview_url)
      end

      should "get the profile" do
        assert_equal("https://nijie.info/members.php?id=728995", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("莚", @site.artist_name)
      end

      should "get the tags" do
        tags = [
          ["眼鏡", "https://nijie.info/search.php?word=%E7%9C%BC%E9%8F%A1"],
          ["谷間", "https://nijie.info/search.php?word=%E8%B0%B7%E9%96%93"],
          ["リトルウィッチアカデミア", "https://nijie.info/search.php?word=%E3%83%AA%E3%83%88%E3%83%AB%E3%82%A6%E3%82%A3%E3%83%83%E3%83%81%E3%82%A2%E3%82%AB%E3%83%87%E3%83%9F%E3%82%A2"],
          ["アーシュラ先生", "https://nijie.info/search.php?word=%E3%82%A2%E3%83%BC%E3%82%B7%E3%83%A5%E3%83%A9%E5%85%88%E7%94%9F"],
          ["上着全開", "https://nijie.info/search.php?word=%E4%B8%8A%E7%9D%80%E5%85%A8%E9%96%8B"]
        ]

        assert_equal(tags, @site.tags)
      end

      should "normalize （）characters in tags" do
        FactoryBot.create(:tag, :name => "kaga")
        FactoryBot.create(:wiki_page, :title => "kaga", :other_names => "加賀(艦これ)")

        @site = Sources::Strategies.find("https://nijie.info/view.php?id=208316")

        assert_includes(@site.tags.map(&:first), "加賀（艦これ）")
        assert_includes(@site.translated_tags.map(&:name), "kaga")
      end

      should "get the commentary" do
        title = "ジャージの下は"
        desc = "「リトルウィッチアカデミア」から無自覚サキュバスぶりを発揮するアーシュラ先生です"

        assert_equal(title, @site.dtext_artist_commentary_title)
        assert_equal(desc, @site.dtext_artist_commentary_desc)
      end
    end

    context "For long commentaries that may be truncated" do
      should "get the full commentary" do
        site = Sources::Strategies.find("http://nijie.info/view.php?id=266532")
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
        @site = Sources::Strategies.find("http://pic.nijie.net/03/nijie_picture/728995_20170505014820_0.jpg", "https://nijie.info/view_popup.php?id=213043")
      end

      should "get the image url" do
        assert_equal("https://pic.nijie.net/03/nijie_picture/728995_20170505014820_0.jpg", @site.image_url)
      end

      should "get the preview urls" do
        assert_equal("https://pic.nijie.net/03/__rs_l170x170/nijie_picture/728995_20170505014820_0.jpg", @site.preview_url)
        assert_equal([@site.preview_url], @site.preview_urls)
      end

      should "get the canonical url" do
        assert_equal("https://nijie.info/view.php?id=213043", @site.canonical_url)
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
        @site = Sources::Strategies.find("https://nijie.info/view_popup.php?id=213043")
      end

      should "get the image url" do
        assert_equal("https://pic.nijie.net/03/nijie_picture/728995_20170505014820_0.jpg", @site.image_url)
      end

      should "get the preview urls" do
        assert_equal("https://pic.nijie.net/03/__rs_l170x170/nijie_picture/728995_20170505014820_0.jpg", @site.preview_url)
        assert_equal([@site.preview_url], @site.preview_urls)
      end

      should "get the canonical url" do
        assert_equal("https://nijie.info/view.php?id=213043", @site.canonical_url)
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
        @site = Sources::Strategies.find("https://nijie.info/view.php?id=218856")
      end

      should "get the image urls" do
        urls = %w[
          https://pic.nijie.net/03/nijie_picture/236014_20170620101426_0.png
          https://pic.nijie.net/01/nijie_picture/diff/main/218856_0_236014_20170620101329.png
          https://pic.nijie.net/01/nijie_picture/diff/main/218856_1_236014_20170620101330.png
          https://pic.nijie.net/01/nijie_picture/diff/main/218856_2_236014_20170620101331.png
          https://pic.nijie.net/03/nijie_picture/diff/main/218856_3_236014_20170620101331.png
          https://pic.nijie.net/03/nijie_picture/diff/main/218856_4_236014_20170620101333.png
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
        site = Sources::Strategies.find(image_url)

        assert_nil(site.page_url)
        assert_equal(image_url, site.image_url)
        assert_equal(image_url, site.canonical_url)
        assert_equal("https://nijie.info/members.php?id=236014", site.profile_url)
        assert_nothing_raised { site.to_h }

        assert_downloaded(3619, site.image_url)
        assert_downloaded(3619, site.preview_url)
      end
    end

    context "An image url that contains the illust id and artist id (format 1)" do
      should "fetch all the data" do
        site = Sources::Strategies.find("https://pic.nijie.net/03/nijie_picture/diff/main/218856_4_236014_20170620101333.png")

        assert_equal("https://nijie.info/view.php?id=218856", site.page_url)
        assert_equal("https://nijie.info/view.php?id=218856", site.canonical_url)
        assert_equal("https://nijie.info/members.php?id=236014", site.profile_url)
        assert_equal("名無しのチンポップ", site.artist_name)
        assert_equal(site.url, site.image_url)
        assert_equal(6, site.image_urls.size)
        assert_equal(6, site.preview_urls.size)
      end
    end

    context "An image url that contains the illust id and artist id (format 2)" do
      should "fetch all the data" do
        site = Sources::Strategies.find("https://pic.nijie.net/04/nijie_picture/diff/main/287736_161475_20181112032855_1.png")

        assert_equal("https://nijie.info/view.php?id=287736", site.page_url)
        assert_equal("https://nijie.info/view.php?id=287736", site.canonical_url)
        assert_equal("https://nijie.info/members.php?id=161475", site.profile_url)
        assert_equal("みな本", site.artist_name)
        assert_equal(site.url, site.image_url)
        assert_equal(3, site.image_urls.size)
      end
    end

    context "An mp4 post" do
      should "find the mp4 file" do
        site = Sources::Strategies.find("http://nijie.info/view.php?id=324604")

        assert_equal("https://pic.nijie.net/01/nijie_picture/1349569_20190727172205_0.mp4", site.image_urls[0])
      end
    end

    context "An artist profile url" do
      should "not fail" do
        site = Sources::Strategies.find("https://nijie.info/members_illust.php?id=236014")
        assert_equal("https://nijie.info/members.php?id=236014", site.profile_url)
        assert_nothing_raised { site.to_h }
      end
    end

    context "An url that is invalid" do
      should "not fail" do
        site = Sources::Strategies.find("http://nijie.info/index.php")
        assert_nothing_raised { site.to_h }
      end
    end

    context "A deleted work" do
      context "for an image url" do
        should "find the profile url" do
          site = Sources::Strategies.find("https://pic.nijie.net/01/nijie_picture/diff/main/196201_20150201033106_0.jpg")

          assert_nothing_raised { site.to_h }
          assert_equal("https://nijie.info/members.php?id=196201", site.profile_url)
          assert_equal(site.url, site.image_url)
          assert_equal([site.url], site.image_urls)
          assert_equal(1, site.preview_urls.size)
        end
      end

      context "for a page url" do
        should "not fail" do
          site = Sources::Strategies.find("http://www.nijie.info/view_popup.php?id=212355")

          assert_equal("https://nijie.info/view.php?id=212355", site.page_url)
          assert_nil(site.profile_url)
          assert_nil(site.artist_name)
          assert_nil(site.artist_commentary_desc)
          assert_nil(site.artist_commentary_title)
          assert_nil(site.image_url)
          assert_nil(site.preview_url)
          assert_empty(site.image_urls)
          assert_empty(site.preview_urls)
          assert_empty(site.tags)
          assert_nothing_raised { site.to_h }
        end
      end
    end

    context "a post requiring login" do
      should "not fail" do
        site = Sources::Strategies.find("https://nijie.info/view.php?id=203688")

        urls = %w[
          https://pic.nijie.net/01/nijie_picture/676327_20170216212803_0.jpg
          https://pic.nijie.net/04/nijie_picture/diff/main/676327_20170216212806_0.jpg
        ]
        assert_equal(urls, site.image_urls)
      end
    end

    context "a doujin post" do
      should "work" do
        image = "https://pic.nijie.net/01/dojin_main/dojin_sam/20120213044700%E3%82%B3%E3%83%94%E3%83%BC%20%EF%BD%9E%200011%E3%81%AE%E3%82%B3%E3%83%94%E3%83%BC.jpg"
        page = "https://nijie.info/view.php?id=53023"
        site = Sources::Strategies.find(image, page)

        images = %w[
          https://pic.nijie.net/01/dojin_main/20120213044700表紙サンプル.jpg
          https://pic.nijie.net/01/dojin_main/dojin_sam/20120213044700コピー\ ～\ 0006のコピー.jpg
          https://pic.nijie.net/01/dojin_main/dojin_sam/20120213044700コピー\ ～\ 0011のコピー.jpg
        ]
        tags = [%w[中出し https://nijie.info/search_dojin.php?word=%E4%B8%AD%E5%87%BA%E3%81%97],
                %w[フェラ https://nijie.info/search_dojin.php?word=%E3%83%95%E3%82%A7%E3%83%A9],
                %w[TS https://nijie.info/search_dojin.php?word=TS],
                %w[ほのぼの https://nijie.info/search_dojin.php?word=%E3%81%BB%E3%81%AE%E3%81%BC%E3%81%AE]]

        assert(true, site.doujin?)
        assert_equal(image, site.image_url)
        assert_equal(images, site.image_urls)
        assert_equal("作品情報", site.artist_commentary_title)
        assert_equal("<p>ある日目がさめると女の子になっていたいつき<br>\nそこへ幼馴染の小梅が現れて…<br>\n2010年コミックマーケット78で販売したコピー本のDL版で<br>\n本編18Pの短編マンガです <br>\n</p>", site.artist_commentary_desc)
        assert_equal(tags, site.tags)
        assert_equal("リック・ロガニー", site.artist_name)
      end
    end

    context "normalizing for source" do
      should "normalize correctly" do
        source1 = "https://pic01.nijie.info/nijie_picture/diff/main/218856_0_236014_20170620101329.png"
        source2 = "https://pic04.nijie.info/nijie_picture/diff/main/287736_161475_20181112032855_1.png"

        assert_equal("https://nijie.info/view.php?id=218856", Sources::Strategies.normalize_source(source1))
        assert_equal("https://nijie.info/view.php?id=287736", Sources::Strategies.normalize_source(source2))
      end

      should "avoid normalizing unnormalizable urls" do
        bad_source1 = "https://pic01.nijie.info/nijie_picture/20120211210359.jpg"
        bad_source2 = "https://pic04.nijie.info/omata/4829_20161128012012.png"
        bad_source3 = "https://pic03.nijie.info/nijie_picture/28310_20131101215959.jpg"

        assert_equal(bad_source1, Sources::Strategies.normalize_source(bad_source1))
        assert_equal(bad_source2, Sources::Strategies.normalize_source(bad_source2))
        assert_equal(bad_source3, Sources::Strategies.normalize_source(bad_source3))
      end
    end
  end
end
