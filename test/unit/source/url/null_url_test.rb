require "test_helper"

module Source::Tests::URL
  class NullTest < ActiveSupport::TestCase
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
        assert_equal("Big Cartel", Source::URL.parse("https://quintzeee.bigcartel.com").site_name)
        assert_equal("Blogger", Source::URL.parse("http://chiizupan.blogspot.com").site_name)
        assert_equal("Buy Me a Coffee", Source::URL.parse("https://www.buymeacoffee.com/sasimekk42").site_name)
        assert_equal("Circle.ms", Source::URL.parse("https://portal.circle.ms/Circle/Index/10084525").site_name)
        assert_equal("Class101", Source::URL.parse("https://class101.net/products/315Q19v2UzhkELv2X4Xa").site_name)
        assert_equal("Colors Live", Source::URL.parse("https://www.colorslive.com/artist/nasubino").site_name)
        assert_equal("Curious Cat", Source::URL.parse("https://curiouscat.live/LOPPromptbot").site_name)
        assert_equal("DLSite", Source::URL.parse("https://www.dlsite.com/maniax/circle/profile/=/maker_id/RG33298.html").site_name)
        assert_equal("Danbooru", Source::URL.parse("https://danbooru.donmai.us/users/1176221").site_name)
        assert_equal("Doujinshi.org", Source::URL.parse("http://www.doujinshi.org/browse/author/92838/Ojo").site_name)
        assert_equal("Doujinshi.org", Source::URL.parse("http://doujinshi.mugimugi.org/browse/author/47832/MisRoma/").site_name)
        assert_equal("E-Hentai", Source::URL.parse("https://e-hentai.org/uploader/Laundrymom").site_name)
        assert_equal("Excite Blog", Source::URL.parse("http://spzinno.exblog.jp").site_name)
        assert_equal("FanFiction.Net", Source::URL.parse("https://www.fanfiction.net/u/1795942").site_name)
        assert_equal("Flickr", Source::URL.parse("http://www.flickr.com/people/hizna").site_name)
        assert_equal("GitHub", Source::URL.parse("https://github.com/Shimofumi").site_name)
        assert_equal("Gunsta", Source::URL.parse("https://gumpla.jp/author/Salty_GUNPLA").site_name)
        assert_equal("Hatena", Source::URL.parse("http://d.hatena.ne.jp/yuutamiitan/").site_name)
        assert_equal("Hatena Blog", Source::URL.parse("http://yeaththekid.hatenablog.com").site_name)
        assert_equal("html.co.jp", Source::URL.parse("https://html.co.jp/zeelch").site_name)
        assert_equal("Itch.io", Source::URL.parse("https://lewdwayne.itch.io").site_name)
        assert_equal("Line", Source::URL.parse("https://store.line.me/stickershop/author/103126").site_name)
        assert_equal("LinkedIn", Source::URL.parse("https://www.linkedin.com/in/star-ren/").site_name)
        assert_equal("Linktree", Source::URL.parse("https://linktr.ee/crankbot").site_name)
      end
    end

    context "For karabako links" do
      url_parser_should_work("http://www.karabako.net/images/karabako_38835.jpg",
                             page_url: "http://www.karabako.net/post/view/38835",)
    end

    context "For twipple links" do
      url_parser_should_work("http://p.twpl.jp/show/orig/mI2c3",
                             page_url: "http://p.twipple.jp/mI2c3",)
    end

    context "For sankaku links" do
      url_parser_should_work("http://cs.sankakucomplex.com/data/sample/c2/d7/sample-c2d7270b84ac81326384d4eadd4d4746.jpg?2738848",
                             page_url: "https://chan.sankakucomplex.com/post/show?md5=c2d7270b84ac81326384d4eadd4d4746",)
    end

    context "For minitokyo links" do
      url_parser_should_work("http://static.minitokyo.net/downloads/27/13/365677.jpg?433592448,Minitokyo.Eien.no.Aselia.Scans_365677.jpg",
                             page_url: "http://gallery.minitokyo.net/view/365677",)

      url_parser_should_work("http://static.minitokyo.net/downloads/14/33/199164.jpg?928244019",
                             page_url: "http://gallery.minitokyo.net/view/199164",)
    end

    context "For e-shuushuu links" do
      url_parser_should_work("http://e-shuushuu.net/images/2014-07-22-662472.png",
                             page_url: "https://e-shuushuu.net/image/662472",)
    end

    context "For nijigen-daiaru links" do
      url_parser_should_work("http://jpg.nijigen-daiaru.com/19909/029.jpg",
                             page_url: "http://nijigen-daiaru.com/book.php?idb=19909",)
    end

    context "For doujinantena links" do
      url_parser_should_work("http://sozai.doujinantena.com/contents_jpg/d6c39f09d435e32c221e4ef866eceba4/015.jpg",
                             page_url: "http://doujinantena.com/page.php?id=d6c39f09d435e32c221e4ef866eceba4",)
    end

    context "For paheal.net links" do
      url_parser_should_work("http://rule34-data-010.paheal.net/_images/854806addcd3b1246424e7cea49afe31/852405%20-%20Darkstalkers%20Felicia.jpg",
                             page_url: "https://rule34.paheal.net/post/view/852405",)
    end

    context "For shimmie.katawa-shoujo.com links" do
      url_parser_should_work("http://shimmie.katawa-shoujo.com/image/2740.png",
                             page_url: "https://shimmie.katawa-shoujo.com/post/view/2740",)
    end

    context "For diarypro links" do
      url_parser_should_work("http://nekomataya.net/diarypro/data/upfile/216-1.jpg",
                             page_url: "http://nekomataya.net/diarypro/diary.cgi?no=216",)

      url_parser_should_work("http://akimbo.sakura.ne.jp/diarypro/diary.cgi?mode=image&upfile=716-3.jpg",
                             page_url: "http://akimbo.sakura.ne.jp/diarypro/diary.cgi?no=716",)
    end

    context "For minus.com links" do
      url_parser_should_work("http://i1.minus.com/ibb0DuE2Ds0yE6.jpg",
                             page_url: "http://minus.com/i/bb0DuE2Ds0yE6",)
    end

    context "For photozou links" do
      url_parser_should_work("http://kura3.photozou.jp/pub/794/1481794/photo/161537258_org.v1364829097.jpg",
                             page_url: "https://photozou.jp/photo/show/1481794/161537258",)
      url_parser_should_work("http://art59.photozou.jp/pub/212/1986212/photo/118493247_org.v1534644005.jpg",
                             page_url: "https://photozou.jp/photo/show/1986212/118493247",)
    end

    context "For toranoana links" do
      url_parser_should_work("http://img.toranoana.jp/popup_img/04/0030/09/76/040030097695-2p.jpg",
                             page_url: "https://ec.toranoana.jp/tora_r/ec/item/040030097695",)
      url_parser_should_work("https://ecdnimg.toranoana.jp/ec/img/04/0030/65/34/040030653417-6p.jpg",
                             page_url: "https://ec.toranoana.jp/tora_r/ec/item/040030653417",)
    end

    context "For hitomi.la links" do
      url_parser_should_work("https://aa.hitomi.la/galleries/883451/t_rena1g.png",
                             page_url: "https://hitomi.la/galleries/883451.html",)
      url_parser_should_work("https://la.hitomi.la/galleries/1054851/001_main_image.jpg",
                             page_url: "https://hitomi.la/reader/1054851.html#1",)
    end

    context "For e-hentai links" do
      should_identify_url_types(
        image_samples: [
          "https://lyjrkow.ksxjubvoouva.hath.network/h/416a7c19fb25549e084876f932e2f6d45a5b2d63-1215161-2400-3589-jpg/keystamp=1683990600-aab6e15ff8;fileindex=119976531;xres=2400/89931055_p0.jpg",
          "https://hacaqjfrpvthigkeomjq.hath.network/om/119976531/188d8aec2d0ae17cfddf32849481385dd3303fc9-13295955-4379-6549-jpg/b09e528c8897a5a0ecb288f85fe9e9230d4a5f1c-483531-1280-1914-jpg/1280/v2f1fil8ij9dbk115c6/89931055_p0.jpg",
        ],
      )
      should_not_find_false_positives(
        image_samples: [
          "https://drjvktq.miqlthdkffuu.hath.network:8080/h/dce4b9677c8f769c12c8889e2581b989a3edd1bb-280532-642-802-png/keystamp=1683992100-6e1bddc318;fileindex=116114230;xres=org/1667196644017_fe0ug7p4.png",
          "https://ykofnavysaepqurqrbmv.hath.network/om/119976531/188d8aec2d0ae17cfddf32849481385dd3303fc9-13295955-4379-6549-jpg/x/0/cqq6hb0kct3sx4115c4/89931055_p0.jpg",
        ],
      )
    end

    context "For unknown sources" do
      should "leave them as they are" do
        assert_nil(Source::URL.page_url("https://google.com"))
        assert_nil(Source::URL.page_url("a bad non-http source"))
        assert_nil(Source::URL.page_url("https://example.com/Folder/中央大学.html"))
      end
    end

    context "The bad_source? method" do
      should "not treat recognized but unhandled sites as bad sources" do
        assert_not(Source::URL.parse("https://www.etsy.com/shop/yeurei").bad_source?)
        assert_not(Source::URL.parse("https://i.etsystatic.com/isbl/ef769d/65460303/isbl_3360x840.65460303_idqpnurw.jpg").bad_source?)
      end
    end

    context "The bad_link? method" do
      should "not treat recognized but unhandled sites as bad links" do
        assert_not(Source::URL.parse("https://www.etsy.com/shop/yeurei").bad_link?)
        assert_not(Source::URL.parse("https://i.etsystatic.com/isbl/ef769d/65460303/isbl_3360x840.65460303_idqpnurw.jpg").bad_link?)
      end
    end
  end
end
