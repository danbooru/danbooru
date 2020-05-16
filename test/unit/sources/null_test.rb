require 'test_helper'

module Sources
  class NullTest < ActiveSupport::TestCase
    context "A source from an unknown site" do
      setup do
        @site = Sources::Strategies.find("http://oremuhax.x0.com/yoro1603.jpg", "http://oremuhax.x0.com/yo125.htm")
      end

      should "be handled by the null strategy" do
        assert(@site.is_a?(Sources::Strategies::Null))
      end

      should "find the metadata" do
        assert_equal("oremuhax.x0.com", @site.site_name)
        assert_equal(["http://oremuhax.x0.com/yoro1603.jpg"], @site.image_urls)
        assert_equal("http://oremuhax.x0.com/yoro1603.jpg", @site.image_url)
        assert_equal("http://oremuhax.x0.com/yoro1603.jpg", @site.canonical_url)
        assert_nil(@site.artist_name)
        assert_nil(@site.profile_url)
        assert_nothing_raised { @site.to_h }
      end

      should "find the artist" do
        a1 = FactoryBot.create(:artist, name: "test1", url_string: "http://oremuhax.x0.com")

        assert_equal([a1], @site.artists)
      end
    end

    context "normalizing for source" do
      should "normalize twitpic links" do
        source = "http://d3j5vwomefv46c.cloudfront.net/photos/large/820960031.jpg?1384107199"
        assert_equal("https://twitpic.com/dks0tb", Sources::Strategies.normalize_source(source))
      end

      should "normalize karabako links" do
        source = "http://www.karabako.net/images/karabako_38835.jpg"
        assert_equal("http://www.karabako.net/post/view/38835", Sources::Strategies.normalize_source(source))
      end

      should "normalize twipple links" do
        source = "http://p.twpl.jp/show/orig/mI2c3"
        assert_equal("http://p.twipple.jp/mI2c3", Sources::Strategies.normalize_source(source))
      end

      should "normalize fc2 links" do
        source1 = "https://blog-imgs-41.fc2.com/t/u/y/tuyadasi/file.png"
        source2 = "http://diary.fc2.com/user/kazuharoom/img/2020_1/29.jpg"

        assert_equal("http://tuyadasi.blog.fc2.com/img/file.png/", Sources::Strategies.normalize_source(source1))
        assert_equal("http://diary.fc2.com/cgi-sys/ed.cgi/kazuharoom?Y=2020&M=1&D=29", Sources::Strategies.normalize_source(source2))
      end

      should "normalize facebook links" do
        source = "https://scontent-sin1-1.xx.fbcdn.net/hphotos-xtp1/t31.0-8/11254493_576443445841777_7716273903390212288_o.jpg"
        assert_equal("https://www.facebook.com/photo.php?fbid=576443445841777", Sources::Strategies.normalize_source(source))
      end

      should "normalize sankaku links" do
        source = "http://cs.sankakucomplex.com/data/sample/c2/d7/sample-c2d7270b84ac81326384d4eadd4d4746.jpg?2738848"
        assert_equal("https://chan.sankakucomplex.com/en/post/show?md5=c2d7270b84ac81326384d4eadd4d4746", Sources::Strategies.normalize_source(source))
      end

      should "normalize zerochan links" do
        source1 = "http://static.zerochan.net/full/23/15/183273.jpg"
        source2 = "https://s4.zerochan.net/Victorique.de.Blois.full.411536.jpg"
        source3 = "http://www.zerochan.net/full/1567893"

        assert_equal("https://www.zerochan.net/183273#full", Sources::Strategies.normalize_source(source1))
        assert_equal("https://www.zerochan.net/411536#full", Sources::Strategies.normalize_source(source2))
        assert_equal("https://www.zerochan.net/1567893#full", Sources::Strategies.normalize_source(source3))
      end

      should "normalize minitokyo links" do
        source1 = "http://static.minitokyo.net/downloads/27/13/365677.jpg?433592448,Minitokyo.Eien.no.Aselia.Scans_365677.jpg"
        source2 = "http://static.minitokyo.net/downloads/14/33/199164.jpg?928244019"

        assert_equal("http://gallery.minitokyo.net/download/365677", Sources::Strategies.normalize_source(source1))
        assert_equal("http://gallery.minitokyo.net/download/199164", Sources::Strategies.normalize_source(source2))
      end

      should "normalize gelbooru links" do
        source1 = "https://gelbooru.com//images/ee/5c/ee5c9a69db9602c95debdb9b98fb3e3e.jpeg"
        source2 = "http://simg.gelbooru.com//images/2003/edd1d2b3881cf70c3acf540780507531.png"
        source3 = "https://simg3.gelbooru.com//samples/0b/3a/sample_0b3ae5e225072b8e391c827cb470d29c.jpg"

        assert_equal("https://gelbooru.com/index.php?page=post&s=list&md5=ee5c9a69db9602c95debdb9b98fb3e3e", Sources::Strategies.normalize_source(source1))
        assert_equal("https://gelbooru.com/index.php?page=post&s=list&md5=edd1d2b3881cf70c3acf540780507531", Sources::Strategies.normalize_source(source2))
        assert_equal("https://gelbooru.com/index.php?page=post&s=list&md5=0b3ae5e225072b8e391c827cb470d29c", Sources::Strategies.normalize_source(source3))
      end

      should "normalize wikia links" do
        source = "https://vignette.wikia.nocookie.net/valkyriecrusade/images/c/c5/Crimson_Hatsune_H.png/revision/latest?cb=20180702031954"
        assert_equal("https://valkyriecrusade.wikia.com/wiki/File:Crimson_Hatsune_H.png", Sources::Strategies.normalize_source(source))
      end

      should "normalize e-shuushuu links" do
        source = "http://e-shuushuu.net/images/2014-07-22-662472.png"
        assert_equal("https://e-shuushuu.net/image/662472", Sources::Strategies.normalize_source(source))
      end

      should "normalize nijigen-daiaru links" do
        source = "http://jpg.nijigen-daiaru.com/19909/029.jpg"
        assert_equal("http://nijigen-daiaru.com/book.php?idb=19909", Sources::Strategies.normalize_source(source))
      end

      should "normalize doujinantena links" do
        source = "http://sozai.doujinantena.com/contents_jpg/d6c39f09d435e32c221e4ef866eceba4/015.jpg"
        assert_equal("http://doujinantena.com/page.php?id=d6c39f09d435e32c221e4ef866eceba4", Sources::Strategies.normalize_source(source))
      end

      should "normalize paheal.net links" do
        source = "http://rule34-data-010.paheal.net/_images/854806addcd3b1246424e7cea49afe31/852405%20-%20Darkstalkers%20Felicia.jpg"
        assert_equal("https://rule34.paheal.net/post/list/md5:854806addcd3b1246424e7cea49afe31/1", Sources::Strategies.normalize_source(source))
      end

      should "normalize shimmie.katawa-shoujo.com links" do
        source = "http://shimmie.katawa-shoujo.com/image/2740.png"
        assert_equal("https://shimmie.katawa-shoujo.com/post/view/2740", Sources::Strategies.normalize_source(source))
      end

      should "normalize rule34.xxx links" do
        source = "https://us.rule34.xxx//images/1802/0adc8fa0604dc445b4b47e6f4c436a08.jpeg?1949807"
        assert_equal("https://rule34.xxx/index.php?page=post&s=list&md5=0adc8fa0604dc445b4b47e6f4c436a08", Sources::Strategies.normalize_source(source))
      end

      should "normalize diarypro links" do
        source1 = "http://nekomataya.net/diarypro/data/upfile/216-1.jpg"
        source2 = "http://akimbo.sakura.ne.jp/diarypro/diary.cgi?mode=image&upfile=716-3.jpg"
        assert_equal("http://nekomataya.net/diarypro/diary.cgi?no=216", Sources::Strategies.normalize_source(source1))
        assert_equal("http://akimbo.sakura.ne.jp/diarypro/diary.cgi?no=716", Sources::Strategies.normalize_source(source2))
      end

      should "normalize minus.com links" do
        source = "http://i1.minus.com/ibb0DuE2Ds0yE6.jpg"
        assert_equal("http://minus.com/i/bb0DuE2Ds0yE6", Sources::Strategies.normalize_source(source))
      end

      should "normalize photozou links" do
        source1 = "http://kura3.photozou.jp/pub/794/1481794/photo/161537258_org.v1364829097.jpg"
        source2 = "http://art59.photozou.jp/pub/212/1986212/photo/118493247_org.v1534644005.jpg"
        assert_equal("https://photozou.jp/photo/show/1481794/161537258", Sources::Strategies.normalize_source(source1))
        assert_equal("https://photozou.jp/photo/show/1986212/118493247", Sources::Strategies.normalize_source(source2))
      end

      should "normalize toranoana links" do
        source1 = "http://img.toranoana.jp/popup_img/04/0030/09/76/040030097695-2p.jpg"
        source2 = "https://ecdnimg.toranoana.jp/ec/img/04/0030/65/34/040030653417-6p.jpg"
        assert_equal("https://ec.toranoana.jp/tora_r/ec/item/040030097695/", Sources::Strategies.normalize_source(source1))
        assert_equal("https://ec.toranoana.jp/tora_r/ec/item/040030653417/", Sources::Strategies.normalize_source(source2))
      end

      should "normalize hitomi.la links" do
        source1 = "https://aa.hitomi.la/galleries/883451/t_rena1g.png"
        source2 = "https://la.hitomi.la/galleries/1054851/001_main_image.jpg"
        assert_equal("https://hitomi.la/galleries/883451.html", Sources::Strategies.normalize_source(source1))
        assert_equal("https://hitomi.la/reader/1054851.html#1", Sources::Strategies.normalize_source(source2))
      end

      should "leave unknown sources as they are" do
        source1 = "https://google.com"
        source2 = "a bad non-http source"
        source3 = "https://example.com/Folder/中央大学.html"

        assert_equal(source1, Sources::Strategies.normalize_source(source1))
        assert_equal(source2, Sources::Strategies.normalize_source(source2))
        assert_equal(source3, Sources::Strategies.normalize_source(source3))
      end
    end
  end
end
