require 'test_helper'

module Downloads
  class PixivTest < ActiveSupport::TestCase
    PHPSESSID = "696859_678b7a07e1fff94719fb6560eed5958f"

    def assert_downloaded(expected_filesize, source, cassette, record = :none)
      tempfile = Tempfile.new("danbooru-test")
      download = Downloads::File.new(source, tempfile.path)

      VCR.use_cassette(cassette, :record => record) do
        assert_nothing_raised(Downloads::File::Error) do
          download.download!
        end
      end

      assert_equal(expected_filesize, tempfile.size, "Tested source URL: #{source}")
    end

    def assert_rewritten(expected_source, test_source, cassette, record = :none)
      tempfile = Tempfile.new("danbooru-test")
      download = Downloads::File.new(test_source, tempfile.path)

      VCR.use_cassette(cassette, :record => record) do
        rewritten_source, headers, _ = download.before_download(test_source, {}, {})
        assert_equal(expected_source, rewritten_source, "Tested source URL: #{test_source}")
      end
    end

    def assert_not_rewritten(source, cassette, record = :none)
      assert_rewritten(source, source, cassette, record)
    end

    context "An ugoira site for pixiv" do
      setup do
        Delayed::Worker.delay_jobs = false
        @tempfile = Tempfile.new("danbooru-test")
        @download = Downloads::File.new("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46378654", @tempfile.path)
        VCR.use_cassette("download-ugoira-converter", :record => :none) do
          @download.download!
        end
      end

      teardown do
        @tempfile.unlink
      end

      should "download the zip file and update the source" do
        assert_equal("http://i3.pixiv.net/img-zip-ugoira/img/2014/10/05/23/42/23/46378654_ugoira1920x1080.zip", @download.source)
      end

      should "capture the frame data" do
        assert_equal([{"file"=>"000000.jpg", "delay"=>200}, {"file"=>"000001.jpg", "delay"=>200}, {"file"=>"000002.jpg", "delay"=>200}, {"file"=>"000003.jpg", "delay"=>200}, {"file"=>"000004.jpg", "delay"=>250}], @download.data[:ugoira_frame_data])
      end
    end

    context "in all cases" do
      setup do
        PixivWebAgent.stubs(:phpsessid).returns(PHPSESSID)
      end

      # Test an old illustration (one uploaded before 2014-09-16). New
      # /img-original/ and /img-master/ URLs currently don't work for images
      # uploaded before this date. Only old /imgXX/img/username/ URLs work.
      context "downloading an old PNG illustration" do
        setup do
          @medium_page = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=14901720"
          @big_page    = "http://www.pixiv.net/member_illust.php?mode=big&illust_id=14901720"

          @old_small_thumbnail  = "http://i2.pixiv.net/img18/img/evazion/14901720_s.png"
          @old_medium_thumbnail = "http://i2.pixiv.net/img18/img/evazion/14901720_m.png"
          @old_full_size_image  = "http://i2.pixiv.net/img18/img/evazion/14901720.png"

          @new_small_thumbnail  = "http://i1.pixiv.net/c/150x150/img-master/img/2010/11/30/08/39/58/14901720_p0_master1200.jpg"
          @new_medium_thumbnail = "http://i1.pixiv.net/c/600x600/img-master/img/2010/11/30/08/39/58/14901720_p0_master1200.jpg"
          @new_full_size_image  = "http://i1.pixiv.net/img-original/img/2010/11/30/08/39/58/14901720_p0.png"

          @file_size = 1_083
        end

        should "download the full size image" do
          assert_not_rewritten(@full_size_image, "rewrite-pixiv-old-png-full-size")
          assert_downloaded(@file_size, @old_full_size_image, "download-pixiv-old-png-full-size")
        end

        should "download the full size image instead of the HTML page" do
          assert_rewritten(@old_full_size_image, @medium_page, "rewrite-pixiv-old-png-medium-html")
          assert_rewritten(@old_full_size_image, @big_page, "rewrite-pixiv-old-png-big-html")
          assert_downloaded(@file_size, @medium_page, "download-pixiv-old-png-medium-html")
          assert_downloaded(@file_size, @big_page,    "download-pixiv-old-png-big-html")
        end

        should "download the full size image instead of the thumbnail" do
          assert_rewritten(@old_full_size_image, @old_small_thumbnail, "rewrite-pixiv-old-png-old-small-thumbnail")
          assert_rewritten(@old_full_size_image, @old_medium_thumbnail, "rewrite-pixiv-old-png-old-medium-thumbnail")
          assert_downloaded(@file_size, @old_small_thumbnail,  "download-pixiv-old-png-old-small-thumbnail")
          assert_downloaded(@file_size, @old_medium_thumbnail, "download-pixiv-old-png-old-medium-thumbnail")
        end

        # These tests aren't expected to pass. This is just to test if Pixiv has changed to using new URLs for old images.
        should_eventually "work when using new URLs" do
          # Don't know the actual file size of the thumbnails since they don't work.
          assert_downloaded(1083, @new_small_thumbnail,  "download-pixiv-old-png-new-small-thumbnail")
          assert_downloaded(1083, @new_medium_thumbnail, "download-pixiv-old-png-new-medium-thumbnail")
          assert_downloaded(@file_size, @new_full_size_image, "download-pixiv-old-png-new-full-size")
        end
      end



      # Test a new illustration (one uploaded after 2014-09-30). New illustrations
      # must use /img-original/ for full size URLs. Old /imgXX/img/username/ style URLs
      # don't work for images uploaded after this date.
      context "downloading a new PNG illustration" do
        setup do
          @medium_page = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46337015"
          @big_page    = "http://www.pixiv.net/member_illust.php?mode=big&illust_id=46337015"

          @medium_thumbnail = "http://i2.pixiv.net/c/600x600/img-master/img/2014/10/04/03/59/52/46337015_p0_master1200.jpg"
          @full_size_image  = "http://i4.pixiv.net/img-original/img/2014/10/04/03/59/52/46337015_p0.png"

          @file_size = 5_141
        end

        should "1111 download the full size image" do
          assert_not_rewritten(@full_size_image, "rewrite-pixiv-new-png-full-size")
          assert_downloaded(@file_size, @full_size_image, "download-pixiv-new-png-full-size")
        end

        should "download the full size image instead of the HTML page" do
          assert_rewritten(@full_size_image, @medium_page, "rewrite-pixiv-new-png-medium-html")
          assert_rewritten(@full_size_image, @big_page, "rewrite-pixiv-new-png-big-html")
          assert_downloaded(@file_size, @medium_page, "download-pixiv-new-png-medium-html")
          assert_downloaded(@file_size, @big_page,    "download-pixiv-new-png-big-html")
        end

        should "download the full size image instead of the thumbnail" do
          assert_rewritten(@full_size_image, @medium_thumbnail, "rewrite-pixiv-new-png-medium-thumbnail")
          assert_downloaded(@file_size, @medium_thumbnail, "download-pixiv-new-png-medium-thumbnail")
        end
      end

      context "downloading an old manga image" do
        setup do
          @medium_page = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=18557054"
          @manga_page  = "http://www.pixiv.net/member_illust.php?mode=manga&illust_id=18557054"
          @manga_big_p1_page = "http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=18557054&page=1"

          @p0_tiny_thumbnail   = "http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_64x64.jpg"
          @p0_small_thumbnail  = "http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_s.png"
          @p0_medium_thumbnail = "http://i1.pixiv.net/img07/img/pasirism/18557054_m.png"
          @p0_large_thumbnail  = "http://i1.pixiv.net/img07/img/pasirism/18557054_p0.png"
          @p1_large_thumbnail  = "http://i1.pixiv.net/img07/img/pasirism/18557054_p1.png"

          @p0_full_size_image   = "http://i3.pixiv.net/img07/img/pasirism/18557054_big_p0.png"
          @p0_full_size_image_1 = "http://i1.pixiv.net/img07/img/pasirism/18557054_big_p0.png"
          @p1_full_size_image   = "http://i1.pixiv.net/img07/img/pasirism/18557054_big_p1.png"
          @p1_full_size_image_3 = "http://i3.pixiv.net/img07/img/pasirism/18557054_big_p1.png"

          @p0_file_size = 1964
          @p1_file_size = 1927
        end

        should "download the full size image" do
          assert_not_rewritten(@p0_full_size_image, "rewrite-pixiv-old-manga-p0-full-size")
          assert_not_rewritten(@p1_full_size_image, "rewrite-pixiv-old-manga-p1-full-size")
          assert_downloaded(@p0_file_size, @p0_full_size_image, "download-pixiv-old-manga-p0-full-size")
          assert_downloaded(@p1_file_size, @p1_full_size_image, "download-pixiv-old-manga-p1-full-size")
        end

        should "download the full size image instead of the HTML page" do
          assert_rewritten(@p0_full_size_image, @medium_page, "rewrite-pixiv-old-manga-p0-medium-html")
          assert_rewritten(@p0_full_size_image, @manga_page, "rewrite-pixiv-old-manga-p0-big-html")
          assert_rewritten(@p1_full_size_image_3, @manga_big_p1_page, "rewrite-pixiv-old-manga-p1-big-html")
          assert_downloaded(@p0_file_size, @medium_page,       "download-pixiv-old-manga-p0-medium-html")
          assert_downloaded(@p0_file_size, @manga_page,        "download-pixiv-old-manga-p0-big-html")
          assert_downloaded(@p1_file_size, @manga_big_p1_page, "download-pixiv-old-manga-p1-big-html")
        end

        should "download the full size image instead of the thumbnail" do
          assert_rewritten(@p0_full_size_image, @p0_tiny_thumbnail, "download-pixiv-old-manga-p0-tiny-thumbnail")
          assert_rewritten(@p0_full_size_image, @p0_small_thumbnail, "download-pixiv-old-manga-p0-small-thumbnail")
          assert_rewritten(@p0_full_size_image_1, @p0_large_thumbnail, "download-pixiv-old-manga-p0-large-thumbnail")
          assert_rewritten(@p1_full_size_image, @p1_large_thumbnail, "download-pixiv-old-manga-p1-large-thumbnail")
          assert_downloaded(@p0_file_size, @p0_tiny_thumbnail,  "download-pixiv-old-manga-p0-tiny-thumbnail")
          assert_downloaded(@p0_file_size, @p0_small_thumbnail, "download-pixiv-old-manga-p0-small-thumbnail")
          assert_downloaded(@p0_file_size, @p0_large_thumbnail, "download-pixiv-old-manga-p0-large-thumbnail")
          assert_downloaded(@p1_file_size, @p1_large_thumbnail, "download-pixiv-old-manga-p1-large-thumbnail")
        end

        should "download the full size image instead of the medium thumbnail" do
          assert_rewritten(@p0_full_size_image_1, @p0_medium_thumbnail, "rewrite-pixiv-old-manga-p0-medium-thumbnail")
          assert_downloaded(@p0_file_size, @p0_medium_thumbnail, "download-pixiv-old-manga-p0-medium-thumbnail")
        end
      end

      context "downloading a new manga image" do
        setup do
          @medium_page = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46304614"
          @manga_page  = "http://www.pixiv.net/member_illust.php?mode=manga&illust_id=46304614"
          @manga_big_p1_page = "http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=46304614&page=1"

          @p0_large_thumbnail = "http://i1.pixiv.net/c/1200x1200/img-master/img/2014/10/02/14/21/39/46304614_p0_master1200.jpg"
          @p1_large_thumbnail = "http://i1.pixiv.net/c/1200x1200/img-master/img/2014/10/02/14/21/39/46304614_p1_master1200.jpg"
          @p0_full_size_image = "http://i1.pixiv.net/img-original/img/2014/10/02/14/21/39/46304614_p0.gif"
          @p0_full_size_image_3 = "http://i3.pixiv.net/img-original/img/2014/10/02/14/21/39/46304614_p0.gif"
          @p1_full_size_image = "http://i1.pixiv.net/img-original/img/2014/10/02/14/21/39/46304614_p1.gif"
          @p1_full_size_image_3 = "http://i3.pixiv.net/img-original/img/2014/10/02/14/21/39/46304614_p1.gif"

          @p0_file_size = 61_131
          @p1_file_size = 46_818
        end

        should "download the full size image" do
          assert_not_rewritten(@p0_full_size_image, "rewrite-pixiv-new-manga-p0-full-size")
          assert_not_rewritten(@p1_full_size_image, "rewrite-pixiv-new-manga-p1-full-size")

          assert_downloaded(@p0_file_size, @p0_full_size_image, "download-pixiv-new-manga-p0-full-size")
          assert_downloaded(@p1_file_size, @p1_full_size_image, "download-pixiv-new-manga-p1-full-size")
        end

        should "download the full size image instead of the HTML page" do
          assert_rewritten(@p0_full_size_image_3, @medium_page, "rewrite-pixiv-new-manga-p0-medium-html")
          assert_rewritten(@p0_full_size_image_3, @manga_page, "rewrite-pixiv-new-manga-p0-big-html")
          assert_rewritten(@p1_full_size_image_3, @manga_big_p1_page, "rewrite-pixiv-new-manga-p1-big-html")
          assert_downloaded(@p0_file_size, @medium_page,       "download-pixiv-new-manga-p0-medium-html")
          assert_downloaded(@p0_file_size, @manga_page,        "download-pixiv-new-manga-p0-big-html")
          assert_downloaded(@p1_file_size, @manga_big_p1_page, "download-pixiv-new-manga-p1-big-html")
        end

        should "download the full size image instead of the thumbnail" do
          assert_rewritten(@p0_full_size_image_3, @p0_large_thumbnail, "rewrite-pixiv-new-manga-p0-large-thumbnail")
          assert_rewritten(@p1_full_size_image_3, @p1_large_thumbnail, "rewrite-pixiv-new-manga-p1-large-thumbnail")
          assert_downloaded(@p0_file_size, @p0_large_thumbnail, "download-pixiv-new-manga-p0-large-thumbnail")
          assert_downloaded(@p1_file_size, @p1_large_thumbnail, "download-pixiv-new-manga-p1-large-thumbnail")
        end
      end

      context "downloading a ugoira" do
        setup do
          @medium_page     = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46323924"
          @small_thumbnail = "http://i1.pixiv.net/img-inf/img/2014/10/03/17/29/16/46323924_s.jpg"
          @zip_file        = "http://i1.pixiv.net/img-zip-ugoira/img/2014/10/03/17/29/16/46323924_ugoira1920x1080.zip"
          @file_size       = 41_171
        end

        should "download the zip file instead of the HTML page" do
          assert_rewritten(@zip_file, @medium_page, "rewrite-pixiv-ugoira-medium-page")
          assert_downloaded(@file_size, @medium_page, "download-pixiv-ugoira-medium-page")
        end

        should "download the zip file instead of the thumbnail" do
          assert_rewritten(@zip_file, @small_thumbnail, "rewrite-pixiv-ugoira-small-thumbnail")
          assert_downloaded(@file_size, @small_thumbnail, "download-pixiv-ugoira-small-thumbnail")
        end

        should "download the zip file" do
          assert_not_rewritten(@zip_file, "rewrite-pixiv-ugoira-zip-file")
          assert_downloaded(@file_size, @zip_file, "download-pixiv-ugoira-zip-file")
        end
      end
    end
  end
end
