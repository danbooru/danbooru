require 'test_helper'

module Downloads
  class PixivTest < ActiveSupport::TestCase
    def download_from_source(source, cassette)
      tempfile = Tempfile.new("danbooru-test")
      download = Downloads::File.new(source, tempfile.path)

      VCR.use_cassette(cassette, :record => :once) do
        download.download!
      end

      return [download, tempfile]
    end

    def assert_rewritten(unnormalized_source, normalized_source)
      tempfile = Tempfile.new("danbooru-test")
      download = Downloads::File.new(unnormalized_source, tempfile.path)

      url, headers = download.before_download(unnormalized_source, {})
      assert_equal(url, normalized_source)
    end

    def assert_not_rewritten(source)
      assert_rewritten(source, source)
    end

    context "a download for a pixiv manga page" do
      setup do
        @download, @tempfile = download_from_source("http://img65.pixiv.net/img/kiyoringo/21755794_p2.png", "download-pixiv-manga")
      end

      should "instead download the big version" do
        assert_equal("http://img65.pixiv.net/img/kiyoringo/21755794_big_p2.png", @download.source)
      end
    end

    context "a download for an html page" do
      setup do
        @download1, @tempfile1 = download_from_source("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=4348318", "download-pixiv-medium-html")
        @download2, @tempfile2 = download_from_source("http://www.pixiv.net/member_illust.php?mode=big&illust_id=4348318", "download-pixiv-big-html")
      end

      should "instead download the full image" do
        assert_equal("http://i1.pixiv.net/img02/img/wanwandoh/4348318.jpg", @download1.source)
        assert_equal("http://i1.pixiv.net/img02/img/wanwandoh/4348318.jpg", @download2.source)

        assert_equal(185_778, ::File.size(@tempfile1.path))
        assert_equal(185_778, ::File.size(@tempfile2.path))
      end
    end

    context "a download for an old small-size image" do
      setup do
        @download, @tempfile = download_from_source("http://img02.pixiv.net/img/wanwandoh/4348318_s.jpg", "download-pixiv-old-small")
      end

      should "instead download the original version" do
        assert_equal("http://img02.pixiv.net/img/wanwandoh/4348318.jpg", @download.source)
      end

      should "work" do
        assert_equal(185_778, ::File.size(@tempfile.path))
      end
    end

    context "a download for an old medium-size image" do
      setup do
        @download, @tempfile = download_from_source("http://img02.pixiv.net/img/wanwandoh/4348318_m.jpg", "download-pixiv-old-medium")
      end

      should "instead download the original version" do
        assert_equal("http://img02.pixiv.net/img/wanwandoh/4348318.jpg", @download.source)
      end

      should "work" do
        assert_equal(185_778, ::File.size(@tempfile.path))
      end
    end

    context "a download for a new medium-size image" do
      setup do
        @download, @tempfile = download_from_source("http://i1.pixiv.net/c/600x600/img-master/img/2014/09/24/23/25/08/46168376_p0_master1200.jpg", "download-pixiv-new-medium")
      end

      should "instead download the original version" do
        assert_equal("http://i1.pixiv.net/img81/img/kuboishikennzi/46168376.png", @download.source)
      end

      should "work" do
        assert_equal(1_698_761, ::File.size(@tempfile.path))
      end
    end

    context "a download for a new full-size image" do
      setup do
        # 
        @download, @tempfile = download_from_source("http://i1.pixiv.net/img-original/img/2014/09/25/23/09/29/46183440_p0.jpg", "download-pixiv-new-full-size")
      end

      should "instead use the old source" do
        assert_equal("http://i1.pixiv.net/img42/img/bron-yr-aur/46183440.jpg", @download.source)
      end

      should "work" do
        assert_equal(1_039_109, ::File.size(@tempfile.path))
      end
    end

    context "a download for a ugoira thumbnail" do
      should "fail" do
        assert_raises Downloads::File::Error do
          download_from_source("http://i2.pixiv.net/img-inf/img/2014/09/25/00/48/37/46170739_s.jpg", "download-pixiv-ugoira-small")
        end
      end
    end

    context "a download for a manga thumbnail" do
      setup do
        @download, @tempfile = download_from_source("http://i2.pixiv.net/img-inf/img/2014/09/25/00/57/24/46170939_128x128.jpg", "download-pixiv-manga-thumbnail")
      end

      should "instead download the full image" do
        assert_equal("http://i1.pixiv.net/img04/img/syounen_no_uta/46170939_big_p0.jpg", @download.source)

        assert_equal(474_738, ::File.size(@tempfile.path))
      end
    end

    context "a download for an html manga page" do
      setup do
        @download1, @tempfile1 = download_from_source("http://www.pixiv.net/member_illust.php?mode=manga&illust_id=46170939", "download-pixiv-manga-html")
        @download2, @tempfile2 = download_from_source("http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=46170939&page=1", "download-pixiv-manga-big-html")
      end

      should "instead download the full image" do
        assert_equal("http://i1.pixiv.net/img04/img/syounen_no_uta/46170939_big_p0.jpg", @download1.source)
        assert_equal("http://i1.pixiv.net/img04/img/syounen_no_uta/46170939_big_p1.jpg", @download2.source)

        assert_equal(474_738, ::File.size(@tempfile1.path))
        assert_equal(411_400, ::File.size(@tempfile2.path))
      end
    end

    context "medium image URLs" do
      should "be rewritten without HTTP requests" do
        assert_rewritten("http://i1.pixiv.net/img63/img/hirohiro31/25211135_m.jpg", "http://i1.pixiv.net/img63/img/hirohiro31/25211135.jpg")
        assert_rewritten("http://img63.pixiv.net/img/hirohiro31/25211135_m.jpg",    "http://img63.pixiv.net/img/hirohiro31/25211135.jpg")
      end
    end

    context "small manga image URLs" do
      should "be rewritten with HTTP requests" do
        VCR.use_cassette("rewrite-small-manga-images", :record => :once) do
          assert_rewritten("http://i2.pixiv.net/img04/img/syounen_no_uta/46170939_p0.jpg", "http://i2.pixiv.net/img04/img/syounen_no_uta/46170939_big_p0.jpg")
          assert_rewritten("http://img04.pixiv.net/img/syounen_no_uta/46170939_p0.jpg",    "http://img04.pixiv.net/img/syounen_no_uta/46170939_big_p0.jpg")
        end
      end
    end

    context "ugoira thumbnail image URLs" do
      should "be rewritten with HTTP requests" do
        VCR.use_cassette("rewrite-ugoira-thumbnails", :record => :once) do
          assert_rewritten("http://i2.pixiv.net/img-inf/img/2014/09/25/00/48/37/46170739_s.jpg", "http://i1.pixiv.net/img12/img/hokkaido/46170739.jpg")
        end
      end
    end

    context "full-size image URLs" do
      should "not be rewritten" do
        assert_not_rewritten("http://i2.pixiv.net/img78/img/demekyon/46187950.jpg?1411668966")
        assert_not_rewritten("http://img78.pixiv.net/img/demekyon/46187950.jpg?1411668966")
        assert_not_rewritten("http://i2.pixiv.net/img04/img/syounen_no_uta/46170939_big_p0.jpg")
        assert_not_rewritten("http://img04.pixiv.net/img/syounen_no_uta/46170939_big_p0.jpg")
      end
    end

    context "full-size manga image URLs" do
      should "not be rewritten" do
        assert_not_rewritten("http://i2.pixiv.net/img04/img/syounen_no_uta/46170939_big_p0.jpg")
        assert_not_rewritten("http://img04.pixiv.net/img/syounen_no_uta/46170939_big_p0.jpg")
      end
    end
  end
end
