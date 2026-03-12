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
        assert_equal("ImgBB", Source::URL.parse("https://meliach.imgbb.com").site_name)
        assert_equal("Itch.io", Source::URL.parse("https://lewdwayne.itch.io").site_name)
        assert_equal("Line", Source::URL.parse("https://store.line.me/stickershop/author/103126").site_name)
        assert_equal("LinkedIn", Source::URL.parse("https://www.linkedin.com/in/star-ren/").site_name)
        assert_equal("Linktree", Source::URL.parse("https://linktr.ee/crankbot").site_name)
        assert_equal("TikTok", Source::URL.parse("https://www.tiktok.com/@lenn0n__?").site_name)
        assert_equal("7-Eleven MyShip", Source::URL.parse("https://myship.7-11.com.tw/general/detail/GM2311291644399").site_name)
        assert_equal("Bahamut", Source::URL.parse("https://home.gamer.com.tw/homeindex.php?owner=zxc16978").site_name)
        assert_equal("BASE", Source::URL.parse("https://tsukiakari09.theshop.jp").site_name)
        assert_equal("BASE", Source::URL.parse("https://artistname.thebase.com").site_name)
        assert_equal("Cash App", Source::URL.parse("https://cash.app/$artistname").site_name)
        assert_equal("Clibo", Source::URL.parse("https://cli-bo.com/user/abc").site_name)
        assert_equal("Comic Vine", Source::URL.parse("https://comicvine.gamespot.com/profile/artist").site_name)
        assert_equal("Commiss.io", Source::URL.parse("https://commiss.io/artistname").site_name)
        assert_equal("Direct.me", Source::URL.parse("https://direct.me/artist").site_name)
        assert_equal("Drawcrowd", Source::URL.parse("https://dxthpu4318olx.cloudfront.net/users/agussw").site_name)
        assert_equal("Eth.co", Source::URL.parse("https://eth.co/artist").site_name)
        assert_equal("Final Fantasy XIV", Source::URL.parse("https://na.finalfantasyxiv.com/lodestone/character/1234").site_name)
        assert_equal("GameFAQs", Source::URL.parse("https://gamefaqs.gamespot.com/community/artist").site_name)
        assert_equal("Gank", Source::URL.parse("https://www.ganknow.com/artist").site_name)
        assert_equal("Image Comics", Source::URL.parse("https://imagecomics.com/creators/view/artist").site_name)
        assert_equal("img.ly", Source::URL.parse("http://img.ly/images/ermame26").site_name)
        assert_equal("Instabio", Source::URL.parse("https://instabio.cc/artist").site_name)
        assert_equal("Instabio", Source::URL.parse("https://linkbio.co/artist").site_name)
        assert_equal("Kemono Party", Source::URL.parse("https://kemono.party/patreon/user/123").site_name)
        assert_equal("Kirby's Comic Art", Source::URL.parse("https://www.kirbyscomicart.com/artist").site_name)
        assert_equal("Kiru Made", Source::URL.parse("https://kirumade.com/artist").site_name)
        assert_equal("Last.fm", Source::URL.parse("https://www.last.fm/user/artist").site_name)
        assert_equal("Lava.top", Source::URL.parse("https://lava.top/@artist").site_name)
        assert_equal("League of Comic Geeks", Source::URL.parse("https://leagueofcomicgeeks.com/profile/artist").site_name)
        assert_equal("Livedoor", Source::URL.parse("https://blog.livedoor.jp/ac370ml").site_name)
        assert_equal("Livedoor", Source::URL.parse("https://livedoor.livedoor.biz/archives/artist.html").site_name)
        assert_equal("Lit.link", Source::URL.parse("https://lit.link/en/artist").site_name)
        assert_equal("Manga Library Z", Source::URL.parse("https://www.mangaz.com/person/detail/44761").site_name)
        assert_equal("Mangano", Source::URL.parse("https://manga-no.com/artist/123").site_name)
        assert_equal("MarppleShop", Source::URL.parse("https://marpple.shop/kr/@artist").site_name)
        assert_equal("Mastodon", Source::URL.parse("https://mastodon.cloud/@artist").site_name)
        assert_equal("Mastodon", Source::URL.parse("https://mstdn.jp/@oneb").site_name)
        assert_equal("Milkshake", Source::URL.parse("https://msha.ke/artist").site_name)
        assert_equal("Milkshake", Source::URL.parse("https://milkshake.app/artist").site_name)
        assert_equal("MyAnimeList", Source::URL.parse("https://myanimelist.net/profile/artist").site_name)
        assert_equal("MyFigureCollection", Source::URL.parse("https://myfigurecollection.net/profile/artist").site_name)
        assert_equal("OCN", Source::URL.parse("http://homepage3.ocn.ne.jp/~artist").site_name)
        assert_equal("OnlyFans", Source::URL.parse("https://onlyfans.com/artist").site_name)
        assert_equal("Ou Xiang Xie Zhen", Source::URL.parse("https://www.ouxiangxiezhen.com/artist").site_name)
        assert_equal("Overdoll", Source::URL.parse("https://overdoll.com/artist").site_name)
        assert_equal("Overdoll", Source::URL.parse("https://dollycdn.net/artist").site_name)
        assert_equal("PayPal", Source::URL.parse("https://www.paypal.me/artist").site_name)
        assert_equal("PayPal", Source::URL.parse("https://www.paypal.com/donate/?hosted_button_id=ABC").site_name)
        assert_equal("Pixel Joint", Source::URL.parse("https://pixeljoint.com/p/artist.htm").site_name)
        assert_equal("Planet Minecraft", Source::URL.parse("https://www.planetminecraft.com/member/artist").site_name)
        assert_equal("Pronouns.page", Source::URL.parse("https://en.pronouns.page/@artist").site_name)
        assert_equal("Pronouny.xyz", Source::URL.parse("https://pronouny.xyz/u/artist").site_name)
        assert_equal("Joyreactor", Source::URL.parse("https://joyreactor.cc/user/artist").site_name)
        assert_equal("Joyreactor", Source::URL.parse("https://reactor.cc/user/artist").site_name)
        assert_equal("Jump Rookie!", Source::URL.parse("https://rookie.shonenjump.com/author/artist").site_name)
        assert_equal("Sakura.ne.jp", Source::URL.parse("https://www117.sakura.ne.jp/~artist").site_name)
        assert_equal("Scratch", Source::URL.parse("https://scratch.mit.edu/users/artist").site_name)
        assert_equal("Secret Drawing Box", Source::URL.parse("https://drawme.share-on.me/artist").site_name)
        assert_equal("Sheezy.art", Source::URL.parse("https://sheezy.art/artist").site_name)
        assert_equal("Solo.to", Source::URL.parse("https://solo.to/artist").site_name)
        assert_equal("SoundCloud", Source::URL.parse("https://soundcloud.com/artist").site_name)
        assert_equal("Spotify", Source::URL.parse("https://open.spotify.com/artist/123").site_name)
        assert_equal("Square", Source::URL.parse("https://artist.square.site").site_name)
        assert_equal("Square", Source::URL.parse("https://squareup.com/store/artist").site_name)
        assert_equal("Steam", Source::URL.parse("https://steamcommunity.com/id/artist").site_name)
        assert_equal("Straw.page", Source::URL.parse("https://straw.page/artist").site_name)
        assert_equal("SubscribeStar", Source::URL.parse("https://subscribestar.adult/artist").site_name)
        assert_equal("SubscribeStar", Source::URL.parse("https://subscribestar.com/artist").site_name)
        assert_equal("SuperRare", Source::URL.parse("https://superrare.com/artist").site_name)
        assert_equal("Suzuri", Source::URL.parse("https://suzuri.jp/artist").site_name)
        assert_equal("Suzuri", Source::URL.parse("https://dijsur42hqnz1.cloudfront.net/products/artist").site_name)
        assert_equal("Taiwan Doujinshi Center", Source::URL.parse("https://shop.doujin.com.tw/artist").site_name)
        assert_equal("Tapas", Source::URL.parse("https://tapas.io/artist").site_name)
        assert_equal("Tapas", Source::URL.parse("https://d30womf5coomej.cloudfront.net/artist").site_name)
        assert_equal("TeePublic", Source::URL.parse("https://www.teepublic.com/user/artist").site_name)
        assert_equal("Telegram", Source::URL.parse("https://t.me/artist").site_name)
        assert_equal("Telegram", Source::URL.parse("https://telegram.org/artist").site_name)
        assert_equal("TensorArt", Source::URL.parse("https://tensor.art/u/artist").site_name)
        assert_equal("The Interviews", Source::URL.parse("http://theinterviews.jp/artist").site_name)
        assert_equal("Tistory", Source::URL.parse("https://artist.tistory.com").site_name)
        assert_equal("Toyhouse", Source::URL.parse("https://toyhou.se/artist").site_name)
        assert_equal("Trello", Source::URL.parse("https://bxp-content-static.prod.public.atl-paas.net/board-bg.jpg").site_name)
        assert_equal("tsunagu.cloud", Source::URL.parse("https://tsunagu.cloud/artist").site_name)
        assert_equal("Vimeo", Source::URL.parse("https://vimeo.com/artist").site_name)
        assert_equal("Vimeo", Source::URL.parse("https://livestream.com/artist").site_name)
        assert_equal("Webtoons", Source::URL.parse("https://www.webtoons.com/en/creator/artist").site_name)
        assert_equal("Weebly", Source::URL.parse("https://artist.weebly.com").site_name)
        assert_equal("Weebly", Source::URL.parse("https://artist.weeblysite.com").site_name)
        assert_equal("Willow", Source::URL.parse("https://wlo.link/@artist").site_name)
        assert_equal("Wix", Source::URL.parse("https://artist.wixsite.com/home").site_name)
        assert_equal("Wix", Source::URL.parse("https://static.wixstatic.com/media/artist.jpg").site_name)
        assert_equal("WordPress", Source::URL.parse("https://artist.wordpress.com").site_name)
        assert_equal("Ameba", Source::URL.parse("https://www.ameba.jp/artist").site_name)
        assert_equal("Anidb", Source::URL.parse("https://anidb.net/creator/65313").site_name)
        assert_equal("Booru.org", Source::URL.parse("https://img.booru.org/drawfriends/images/36/de65.jpg").site_name)
        assert_equal("Comiczin", Source::URL.parse("https://shop.comiczin.jp/products/list.php?category_id=3394").site_name)
        assert_equal("Dropbox", Source::URL.parse("https://www.dropbox.com/sh/gz9/GHt_oHDKsR").site_name)
        assert_equal("E Shuushuu", Source::URL.parse("https://e-shuushuu.net/images/2014-07-22-662472.png").site_name)
        assert_equal("Minitokyo", Source::URL.parse("http://gallery.minitokyo.net/view/365677").site_name)
        assert_equal("Nanos", Source::URL.parse("https://nanos.jp/artist").site_name)
        assert_equal("Pomf", Source::URL.parse("https://pomf.tv/artist").site_name)
        assert_equal("SmutBase", Source::URL.parse("https://smutba.se/artist").site_name)
        assert_equal("Tegaki", Source::URL.parse("https://tegaki.com/user/artist").site_name)
        assert_equal("YCH.art", Source::URL.parse("https://ych.art/user/artist").site_name)
        assert_equal("Youtube", Source::URL.parse("https://youtu.be/dQw4w9WgXcQ").site_name)
      end
    end

    context "For karabako links" do
      url_parser_should_work("http://www.karabako.net/images/karabako_38835.jpg",
                             page_url: "http://www.karabako.net/post/view/38835")
    end

    context "For twipple links" do
      url_parser_should_work("http://p.twpl.jp/show/orig/mI2c3",
                             page_url: "http://p.twipple.jp/mI2c3")
    end

    context "For sankaku links" do
      url_parser_should_work("http://cs.sankakucomplex.com/data/sample/c2/d7/sample-c2d7270b84ac81326384d4eadd4d4746.jpg?2738848",
                             page_url: "https://chan.sankakucomplex.com/post/show?md5=c2d7270b84ac81326384d4eadd4d4746")
    end

    context "For minitokyo links" do
      url_parser_should_work("http://static.minitokyo.net/downloads/27/13/365677.jpg?433592448,Minitokyo.Eien.no.Aselia.Scans_365677.jpg",
                             page_url: "http://gallery.minitokyo.net/view/365677")

      url_parser_should_work("http://static.minitokyo.net/downloads/14/33/199164.jpg?928244019",
                             page_url: "http://gallery.minitokyo.net/view/199164")
    end

    context "For e-shuushuu links" do
      url_parser_should_work("http://e-shuushuu.net/images/2014-07-22-662472.png",
                             page_url: "https://e-shuushuu.net/image/662472")
    end

    context "For nijigen-daiaru links" do
      url_parser_should_work("http://jpg.nijigen-daiaru.com/19909/029.jpg",
                             page_url: "http://nijigen-daiaru.com/book.php?idb=19909")
    end

    context "For doujinantena links" do
      url_parser_should_work("http://sozai.doujinantena.com/contents_jpg/d6c39f09d435e32c221e4ef866eceba4/015.jpg",
                             page_url: "http://doujinantena.com/page.php?id=d6c39f09d435e32c221e4ef866eceba4")
    end

    context "For paheal.net links" do
      url_parser_should_work("http://rule34-data-010.paheal.net/_images/854806addcd3b1246424e7cea49afe31/852405%20-%20Darkstalkers%20Felicia.jpg",
                             page_url: "https://rule34.paheal.net/post/view/852405")
    end

    context "For shimmie.katawa-shoujo.com links" do
      url_parser_should_work("http://shimmie.katawa-shoujo.com/image/2740.png",
                             page_url: "https://shimmie.katawa-shoujo.com/post/view/2740")
    end

    context "For diarypro links" do
      url_parser_should_work("http://nekomataya.net/diarypro/data/upfile/216-1.jpg",
                             page_url: "http://nekomataya.net/diarypro/diary.cgi?no=216")

      url_parser_should_work("http://akimbo.sakura.ne.jp/diarypro/diary.cgi?mode=image&upfile=716-3.jpg",
                             page_url: "http://akimbo.sakura.ne.jp/diarypro/diary.cgi?no=716")
    end

    context "For minus.com links" do
      url_parser_should_work("http://i1.minus.com/ibb0DuE2Ds0yE6.jpg",
                             page_url: "http://minus.com/i/bb0DuE2Ds0yE6")
    end

    context "For photozou links" do
      url_parser_should_work("http://kura3.photozou.jp/pub/794/1481794/photo/161537258_org.v1364829097.jpg",
                             page_url: "https://photozou.jp/photo/show/1481794/161537258")
      url_parser_should_work("http://art59.photozou.jp/pub/212/1986212/photo/118493247_org.v1534644005.jpg",
                             page_url: "https://photozou.jp/photo/show/1986212/118493247")
    end

    context "For toranoana links" do
      url_parser_should_work("http://img.toranoana.jp/popup_img/04/0030/09/76/040030097695-2p.jpg",
                             page_url: "https://ec.toranoana.jp/tora_r/ec/item/040030097695")
      url_parser_should_work("https://ecdnimg.toranoana.jp/ec/img/04/0030/65/34/040030653417-6p.jpg",
                             page_url: "https://ec.toranoana.jp/tora_r/ec/item/040030653417")
    end

    context "For hitomi.la links" do
      url_parser_should_work("https://aa.hitomi.la/galleries/883451/t_rena1g.png",
                             page_url: "https://hitomi.la/galleries/883451.html")
      url_parser_should_work("https://la.hitomi.la/galleries/1054851/001_main_image.jpg",
                             page_url: "https://hitomi.la/reader/1054851.html#1")
    end

    context "For imgbb links" do
      url_parser_should_work("https://meliach.imgbb.com",
                             profile_url: "https://meliach.imgbb.com")

      url_parser_should_work("https://meliach.imgbb.com/albums",
                             profile_url: "https://meliach.imgbb.com")
    end

    context "For tiktok links" do
      url_parser_should_work("https://www.tiktok.com/@ajmarekart?_t=ZM-8wmxRtoZXjq&_r=1",
                             profile_url: "https://www.tiktok.com/@ajmarekart")

      url_parser_should_work("https://www.tiktok.com/@lenn0n__?",
                             profile_url: "https://www.tiktok.com/@lenn0n__")

      url_parser_should_work("https://www.tiktok.com/@h.panda_12",
                             profile_url: "https://www.tiktok.com/@h.panda_12")
    end

    context "For about.me links" do
      url_parser_should_work("http://about.me/rig22",
                             profile_url: "https://about.me/rig22")
    end

    context "For ameblo.jp links" do
      url_parser_should_work("http://marilyn77.ameblo.jp/",
                             profile_url: "https://ameblo.jp/marilyn77")

      url_parser_should_work("https://ameblo.jp/g8set55679",
                             profile_url: "https://ameblo.jp/g8set55679")

      url_parser_should_work("http://ameblo.jp/hanauta-os/entry-11860045489.html",
                             profile_url: "https://ameblo.jp/hanauta-os")

      url_parser_should_work("http://stat.ameba.jp/user_images/20130802/21/moment1849/38/bd/p",
                             profile_url: "https://ameblo.jp/moment1849")

      url_parser_should_work("https://profile.ameba.jp/ameba/kbnr32rbfs",
                             profile_url: "https://ameblo.jp/kbnr32rbfs")
    end

    context "For anidb.net links" do
      url_parser_should_work("https://anidb.net/creator/65313",
                             profile_url: "https://anidb.net/creator/65313")

      url_parser_should_work("https://anidb.net/perl-bin/animedb.pl?show=creator&creatorid=3903",
                             profile_url: "https://anidb.net/creator/3903")
    end

    context "For baidu.com links" do
      url_parser_should_work("http://hi.baidu.com/new/mocaorz",
                             profile_url: "http://hi.baidu.com/mocaorz")

      url_parser_should_work("http://hi.baidu.com/longbb1127/home",
                             profile_url: "http://hi.baidu.com/longbb1127")
    end

    context "For flickr.com links" do
      url_parser_should_work("https://www.flickr.com/people/shirasaki408/",
                             profile_url: "https://www.flickr.com/people/shirasaki408")

      url_parser_should_work("https://www.flickr.com/photos/shirasaki408/49398982266/",
                             profile_url: "https://www.flickr.com/people/shirasaki408")

      url_parser_should_work("https://www.flickr.com/photos/hizna/sets/72157629448846789/",
                             profile_url: "https://www.flickr.com/people/hizna")
    end

    context "For linktr.ee links" do
      url_parser_should_work("https://linktr.ee/cxlinray",
                             profile_url: "https://linktr.ee/cxlinray")
    end

    context "For twpl.jp profile links" do
      url_parser_should_work("http://twpl.jp/swacoro",
                             profile_url: "https://twpf.jp/swacoro")
    end

    context "For yfrog.com links" do
      url_parser_should_work("http://yfrog.com/gyi1smoj",
                             page_url: "http://yfrog.com/gyi1smoj")

      url_parser_should_work("http://twitter.yfrog.com/z/oe3umiifj",
                             page_url: "http://yfrog.com/oe3umiifj")

      url_parser_should_work("http://yfrog.com/user/0128sinonome/photos",
                             profile_url: "http://yfrog.com/user/0128sinonome/photos")
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
