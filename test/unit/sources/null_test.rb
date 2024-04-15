require 'test_helper'

module Sources
  class NullTest < ActiveSupport::TestCase
    context "An image from an unknown site" do
      strategy_should_work(
        # "http://oremuhax.x0.com/yo125.htm"
        "http://oremuhax.x0.com/yoro1603.jpg",
        image_urls: ["http://oremuhax.x0.com/yoro1603.jpg"],
        media_files: [{ file_size: 263_253 }],
        page_url: nil,
        profile_url: nil,
        tags: [],
        tag_name: nil,
        other_names: [],
        artist_name: nil,
        dtext_artist_commentary_title: nil,
        dtext_artist_commentary_desc: nil,
      )
    end

    context "A IP-based source" do
      strategy_should_work(
        "http://125.6.189.215/kcs2/resources/ship/full/0935_5098_aeltexuflkxs.png?version=52",
        image_urls: ["http://125.6.189.215/kcs2/resources/ship/full/0935_5098_aeltexuflkxs.png?version=52"],
        media_files: [{ file_size: 86_605 }],
        page_url: nil,
        profile_url: nil,
        tags: [],
        tag_name: nil,
        artist_name: nil,
        artist_commentary_title: nil,
        artist_commentary_desc: nil
      )
    end

    context "A file:// source" do
      strategy_should_work(
        "file://image.jpg",
        image_urls: [],
        page_url: nil,
        profile_url: nil,
        tags: [],
        tag_name: nil,
        artist_name: nil,
        artist_commentary_title: nil,
        artist_commentary_desc: nil
      )
    end

    context "determining the site name" do
      should "work" do
        assert_equal("Foo", Source::URL.parse("https://foo.com.").site_name)
        assert_equal("Foo", Source::URL.parse("https://user:pass@foo.com:80").site_name)
        assert_equal("Localhost", Source::URL.parse("https://localhost").site_name)
        assert_equal("127.0.0.1", Source::URL.parse("https://127.0.0.1").site_name)
        assert_equal("127.0.0.1:3000", Source::URL.parse("https://127.0.0.1:3000").site_name)
        assert_equal("[::1]", Source::URL.parse("https://[::1]").site_name)
        assert_equal("[::1]:3000", Source::URL.parse("https://[::1]:3000").site_name)
      end
    end

    context "normalizing for source" do
      should "normalize karabako links" do
        source = "http://www.karabako.net/images/karabako_38835.jpg"
        assert_equal("http://www.karabako.net/post/view/38835", Source::URL.page_url(source))
      end

      should "normalize twipple links" do
        source = "http://p.twpl.jp/show/orig/mI2c3"
        assert_equal("http://p.twipple.jp/mI2c3", Source::URL.page_url(source))
      end

      should "normalize fc2 links" do
        source1 = "https://blog-imgs-41.fc2.com/t/u/y/tuyadasi/file.png"
        source2 = "http://diary.fc2.com/user/kazuharoom/img/2020_1/29.jpg"

        assert_equal("http://tuyadasi.blog.fc2.com/img/file.png", Source::URL.page_url(source1))
        assert_equal("http://diary.fc2.com/cgi-sys/ed.cgi/kazuharoom?Y=2020&M=1&D=29", Source::URL.page_url(source2))
      end

      should "normalize facebook links" do
        source = "https://scontent-sin1-1.xx.fbcdn.net/hphotos-xtp1/t31.0-8/11254493_576443445841777_7716273903390212288_o.jpg"
        assert_equal("https://www.facebook.com/photo?fbid=576443445841777", Source::URL.page_url(source))
      end

      should "normalize sankaku links" do
        source = "http://cs.sankakucomplex.com/data/sample/c2/d7/sample-c2d7270b84ac81326384d4eadd4d4746.jpg?2738848"
        assert_equal("https://chan.sankakucomplex.com/post/show?md5=c2d7270b84ac81326384d4eadd4d4746", Source::URL.page_url(source))
      end

      should "normalize minitokyo links" do
        source1 = "http://static.minitokyo.net/downloads/27/13/365677.jpg?433592448,Minitokyo.Eien.no.Aselia.Scans_365677.jpg"
        source2 = "http://static.minitokyo.net/downloads/14/33/199164.jpg?928244019"

        assert_equal("http://gallery.minitokyo.net/view/365677", Source::URL.page_url(source1))
        assert_equal("http://gallery.minitokyo.net/view/199164", Source::URL.page_url(source2))
      end

      should "normalize e-shuushuu links" do
        source = "http://e-shuushuu.net/images/2014-07-22-662472.png"
        assert_equal("https://e-shuushuu.net/image/662472", Source::URL.page_url(source))
      end

      should "normalize nijigen-daiaru links" do
        source = "http://jpg.nijigen-daiaru.com/19909/029.jpg"
        assert_equal("http://nijigen-daiaru.com/book.php?idb=19909", Source::URL.page_url(source))
      end

      should "normalize doujinantena links" do
        source = "http://sozai.doujinantena.com/contents_jpg/d6c39f09d435e32c221e4ef866eceba4/015.jpg"
        assert_equal("http://doujinantena.com/page.php?id=d6c39f09d435e32c221e4ef866eceba4", Source::URL.page_url(source))
      end

      should "normalize paheal.net links" do
        source = "http://rule34-data-010.paheal.net/_images/854806addcd3b1246424e7cea49afe31/852405%20-%20Darkstalkers%20Felicia.jpg"
        assert_equal("https://rule34.paheal.net/post/view/852405", Source::URL.page_url(source))
      end

      should "normalize shimmie.katawa-shoujo.com links" do
        source = "http://shimmie.katawa-shoujo.com/image/2740.png"
        assert_equal("https://shimmie.katawa-shoujo.com/post/view/2740", Source::URL.page_url(source))
      end

      should "normalize diarypro links" do
        source1 = "http://nekomataya.net/diarypro/data/upfile/216-1.jpg"
        source2 = "http://akimbo.sakura.ne.jp/diarypro/diary.cgi?mode=image&upfile=716-3.jpg"
        assert_equal("http://nekomataya.net/diarypro/diary.cgi?no=216", Source::URL.page_url(source1))
        assert_equal("http://akimbo.sakura.ne.jp/diarypro/diary.cgi?no=716", Source::URL.page_url(source2))
      end

      should "normalize minus.com links" do
        source = "http://i1.minus.com/ibb0DuE2Ds0yE6.jpg"
        assert_equal("http://minus.com/i/bb0DuE2Ds0yE6", Source::URL.page_url(source))
      end

      should "normalize photozou links" do
        source1 = "http://kura3.photozou.jp/pub/794/1481794/photo/161537258_org.v1364829097.jpg"
        source2 = "http://art59.photozou.jp/pub/212/1986212/photo/118493247_org.v1534644005.jpg"
        assert_equal("https://photozou.jp/photo/show/1481794/161537258", Source::URL.page_url(source1))
        assert_equal("https://photozou.jp/photo/show/1986212/118493247", Source::URL.page_url(source2))
      end

      should "normalize toranoana links" do
        source1 = "http://img.toranoana.jp/popup_img/04/0030/09/76/040030097695-2p.jpg"
        source2 = "https://ecdnimg.toranoana.jp/ec/img/04/0030/65/34/040030653417-6p.jpg"
        assert_equal("https://ec.toranoana.jp/tora_r/ec/item/040030097695", Source::URL.page_url(source1))
        assert_equal("https://ec.toranoana.jp/tora_r/ec/item/040030653417", Source::URL.page_url(source2))
      end

      should "normalize hitomi.la links" do
        source1 = "https://aa.hitomi.la/galleries/883451/t_rena1g.png"
        source2 = "https://la.hitomi.la/galleries/1054851/001_main_image.jpg"
        assert_equal("https://hitomi.la/galleries/883451.html", Source::URL.page_url(source1))
        assert_equal("https://hitomi.la/reader/1054851.html#1", Source::URL.page_url(source2))
      end

      should "leave unknown sources as they are" do
        assert_nil(Source::URL.page_url("https://google.com"))
        assert_nil(Source::URL.page_url("a bad non-http source"))
        assert_nil(Source::URL.page_url("https://example.com/Folder/中央大学.html"))
      end
    end
  end
end
