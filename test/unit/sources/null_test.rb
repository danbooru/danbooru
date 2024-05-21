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

      should "work for a known site" do
        assert_equal("AllMyLinks", Source::URL.parse("https://allmylinks.com/enigma404").site_name)
        assert_equal("Anime News Network", Source::URL.parse("https://www.animenewsnetwork.com/encyclopedia/people.php?id=17056").site_name)
        assert_equal("Amino", Source::URL.parse("https://aminoapps.com/u/SequelUncut").site_name)
        assert_equal("AniList", Source::URL.parse("https://anilist.co/user/Megumon").site_name)
        assert_equal("Apple Music", Source::URL.parse("https://music.apple.com/artist/1626455561").site_name)
        assert_equal("Archive of Our Own", Source::URL.parse("https://archiveofourown.org/users/ari1654").site_name)
        assert_equal("Art Fight", Source::URL.parse("http://artfight.net/~OFUKITTY").site_name)
        assert_equal("Artists&Clients", Source::URL.parse("https://artistsnclients.com/people/sbong2").site_name)
        assert_equal("Ask.fm", Source::URL.parse("https://ask.fm/mochaxmr").site_name)
        assert_equal("Bandcamp", Source::URL.parse("https://pigmhall.bandcamp.com").site_name)
        assert_equal("BCY", Source::URL.parse("https://bcy.net/u/2995502149020334").site_name)
        assert_equal("Big Cartel", Source::URL.parse("https://quintzeee.bigcartel.com").site_name)
        assert_equal("Blogger", Source::URL.parse("http://chiizupan.blogspot.com").site_name)
        assert_equal("Buy Me a Coffee", Source::URL.parse("https://www.buymeacoffee.com/sasimekk42").site_name)
        assert_equal("Circle.ms", Source::URL.parse("https://portal.circle.ms/Circle/Index/10084525").site_name)
        assert_equal("Class101", Source::URL.parse("https://class101.net/products/315Q19v2UzhkELv2X4Xa").site_name)
        assert_equal("Colors Live", Source::URL.parse("https://www.colorslive.com/artist/nasubino").site_name)
        assert_equal("Curious Cat", Source::URL.parse("https://curiouscat.live/LOPPromptbot").site_name)
        assert_equal("DLSite", Source::URL.parse("https://www.dlsite.com/maniax/circle/profile/=/maker_id/RG33298.html").site_name)
        assert_equal("Danbooru", Source::URL.parse("https://danbooru.donmai.us/users/1176221").site_name)
        assert_equal("DC Inside", Source::URL.parse("https://gallog.dcinside.com/clonatenshi").site_name)
        assert_equal("Doujinshi.org", Source::URL.parse("http://www.doujinshi.org/browse/author/92838/Ojo").site_name)
        assert_equal("Doujinshi.org", Source::URL.parse("http://doujinshi.mugimugi.org/browse/author/47832/MisRoma/").site_name)
        assert_equal("E-Hentai", Source::URL.parse("https://e-hentai.org/uploader/Laundrymom").site_name)
        assert_equal("Excite Blog", Source::URL.parse("http://spzinno.exblog.jp").site_name)
        assert_equal("Facebook", Source::URL.parse("https://www.facebook.com/sinyu.tang.9").site_name)
        assert_equal("FanFiction.Net", Source::URL.parse("https://www.fanfiction.net/u/1795942").site_name)
        assert_equal("Flickr", Source::URL.parse("http://www.flickr.com/people/hizna").site_name)
        assert_equal("GitHub", Source::URL.parse("https://github.com/Shimofumi").site_name)
        assert_equal("Gunsta", Source::URL.parse("https://gumpla.jp/author/Salty_GUNPLA").site_name)
        assert_equal("Hatena", Source::URL.parse("http://d.hatena.ne.jp/yuutamiitan/").site_name)
        assert_equal("Hatena Blog", Source::URL.parse("http://yeaththekid.hatenablog.com").site_name)
        assert_equal("HoYoLAB", Source::URL.parse("https://www.hoyolab.com/accountCenter/postList?id=129912579").site_name)
        assert_equal("html.co.jp", Source::URL.parse("https://html.co.jp/zeelch").site_name)
        assert_equal("Itch.io", Source::URL.parse("https://lewdwayne.itch.io").site_name)
        assert_equal("Line", Source::URL.parse("https://store.line.me/stickershop/author/103126").site_name)
        assert_equal("LinkedIn", Source::URL.parse("https://www.linkedin.com/in/star-ren/").site_name)
        assert_equal("Linktree", Source::URL.parse("https://linktr.ee/crankbot").site_name)
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

    context "The bad_source? method" do
      should "not treat recognized but unhandled sites as bad sources" do
        assert_nil(Source::URL.parse("https://www.etsy.com/shop/yeurei").bad_source?)
        assert_nil(Source::URL.parse("https://i.etsystatic.com/isbl/ef769d/65460303/isbl_3360x840.65460303_idqpnurw.jpg").bad_source?)
      end
    end

    context "The bad_link? method" do
      should "not treat recognized but unhandled sites as bad links" do
        assert_nil(Source::URL.parse("https://www.etsy.com/shop/yeurei").bad_link?)
        assert_nil(Source::URL.parse("https://i.etsystatic.com/isbl/ef769d/65460303/isbl_3360x840.65460303_idqpnurw.jpg").bad_link?)
      end
    end
  end
end
