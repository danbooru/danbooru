require 'test_helper'

module Downloads
  class PixivTest < ActiveSupport::TestCase
    def assert_downloaded(expected_filesize, source)
      tempfile = Tempfile.new("danbooru-test")
      download = Downloads::File.new(source, tempfile.path)

      assert_nothing_raised(Downloads::File::Error) do
        download.download!
      end

      assert_equal(expected_filesize, tempfile.size, "Tested source URL: #{source}")
    end

    def assert_rewritten(expected_source, test_source)
      tempfile = Tempfile.new("danbooru-test")
      download = Downloads::File.new(test_source, tempfile.path)

      rewritten_source, headers, _ = download.before_download(test_source, {}, {})
      assert_equal(expected_source, rewritten_source, "Tested source URL: #{test_source}")
    end

    def assert_not_rewritten(source)
      assert_rewritten(source, source)
    end

    context "An ugoira site for pixiv" do
      setup do
        @tempfile = Tempfile.new("danbooru-test")
        @download = Downloads::File.new("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364", @tempfile.path)
        @download.download!
      end

      teardown do
        @tempfile.unlink
      end

      should "capture the data" do
        assert_equal("https://i1.pixiv.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip", @download.source)
        assert_equal([{"file"=>"000000.jpg", "delay"=>125}, {"file"=>"000001.jpg", "delay"=>125}], @download.data[:ugoira_frame_data])
      end
    end

    context "in all cases" do
      # Test an old illustration (one uploaded before 2014-09-16). New
      # /img-original/ and /img-master/ URLs currently don't work for images
      # uploaded before this date. Only old /imgXX/img/username/ URLs work.
      context "downloading an old PNG illustration" do
        setup do
          @medium_page = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=14901720"
          @big_page    = "http://www.pixiv.net/member_illust.php?mode=big&illust_id=14901720"

          @new_small_thumbnail  = "http://i1.pixiv.net/c/150x150/img-master/img/2010/11/30/08/39/58/14901720_p0_master1200.jpg"
          @new_medium_thumbnail = "http://i1.pixiv.net/c/600x600/img-master/img/2010/11/30/08/39/58/14901720_p0_master1200.jpg"
          @new_full_size_image  = "http://i1.pixiv.net/img-original/img/2010/11/30/08/39/58/14901720_p0.png"

          @file_size = 1_083
        end

        should "work when using new URLs" do
          # Don't know the actual file size of the thumbnails since they don't work.
          assert_downloaded(1083, @new_small_thumbnail)
          assert_downloaded(1083, @new_medium_thumbnail)
          assert_downloaded(@file_size, @new_full_size_image)
        end
      end



      # Test a new illustration (one uploaded after 2014-09-30). New illustrations
      # must use /img-original/ for full size URLs. Old /imgXX/img/username/ style URLs
      # don't work for images uploaded after this date.
      context "downloading a new PNG illustration" do
        setup do
          @medium_page = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247350"
          @medium_thumbnail = "https://i.pximg.net/c/600x600/img-master/img/2017/04/04/08/54/15/62247350_p0_master1200.jpg"
          @full_size_image  = "https://i.pximg.net/img-original/img/2017/04/04/08/54/15/62247350_p0.png"
          @file_size = 16275
        end

        should "download the full size image" do
          assert_not_rewritten(@full_size_image)
          assert_downloaded(@file_size, @full_size_image)
        end

        should "download the full size image instead of the HTML page" do
          assert_rewritten(@full_size_image, @medium_page)
          assert_downloaded(@file_size, @medium_page)
        end

        should "download the full size image instead of the thumbnail" do
          assert_rewritten(@full_size_image, @medium_thumbnail)
          assert_downloaded(@file_size, @medium_thumbnail)
        end
      end

      context "downloading a new manga image" do
        setup do
          @medium_page = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46304614"
          @manga_page  = "http://www.pixiv.net/member_illust.php?mode=manga&illust_id=46304614"
          @manga_big_p1_page = "http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=46304614&page=1"

          @p0_large_thumbnail = "https://i.pximg.net/c/1200x1200/img-master/img/2014/10/02/14/21/39/46304614_p0_master1200.jpg"
          @p1_large_thumbnail = "https://i.pximg.net/c/1200x1200/img-master/img/2014/10/02/14/21/39/46304614_p1_master1200.jpg"
          @p0_full_size_image = "https://i.pximg.net/img-original/img/2014/10/02/14/21/39/46304614_p0.gif"
          @p0_full_size_image_3 = "https://i.pximg.net/img-original/img/2014/10/02/14/21/39/46304614_p0.gif"
          @p1_full_size_image = "https://i.pximg.net/img-original/img/2014/10/02/14/21/39/46304614_p1.gif"
          @p1_full_size_image_3 = "https://i.pximg.net/img-original/img/2014/10/02/14/21/39/46304614_p1.gif"

          @p0_file_size = 61_131
          @p1_file_size = 46_818
        end

        should "download the full size image" do
          assert_not_rewritten(@p0_full_size_image)
          assert_not_rewritten(@p1_full_size_image)

          assert_downloaded(@p0_file_size, @p0_full_size_image)
          assert_downloaded(@p1_file_size, @p1_full_size_image)
        end

        should "download the full size image instead of the HTML page" do
          assert_rewritten(@p0_full_size_image_3, @medium_page)
          assert_rewritten(@p0_full_size_image_3, @manga_page)
          assert_rewritten(@p1_full_size_image_3, @manga_big_p1_page)
          assert_downloaded(@p0_file_size, @medium_page)
          assert_downloaded(@p0_file_size, @manga_page)
          assert_downloaded(@p1_file_size, @manga_big_p1_page)
        end

        should "download the full size image instead of the thumbnail" do
          assert_rewritten(@p0_full_size_image_3, @p0_large_thumbnail)
          assert_rewritten(@p1_full_size_image_3, @p1_large_thumbnail)
          assert_downloaded(@p0_file_size, @p0_large_thumbnail)
          assert_downloaded(@p1_file_size, @p1_large_thumbnail)
        end
      end

      context "downloading a ugoira" do
        setup do
          @medium_page     = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364"
          @zip_file        = "https://i1.pixiv.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip"
          @file_size       = 2804
        end

        should "download the zip file instead of the HTML page" do
          assert_rewritten(@zip_file, @medium_page)
          assert_downloaded(@file_size, @medium_page)
        end

        should "download the zip file" do
          assert_not_rewritten(@zip_file)
          assert_downloaded(@file_size, @zip_file)
        end
      end

      context "downloading a profile image" do
        should "download new profile images" do
          @file_url = "http://i2.pixiv.net/img130/profile/minono_aki/8733472.jpg"
          @file_size = 23266

          assert_not_rewritten(@file_url)
          assert_downloaded(@file_size, @file_url)
        end

      end

      context "downloading a background image" do
        should "download the image" do
          @file_url = "http://i1.pixiv.net/background/img/2016/05/17/12/05/48/2074388_d4ac52034f7ca0af3e083d59fde7e97f.jpg"
          @file_size = 386_500

          assert_not_rewritten(@file_url)
          assert_downloaded(@file_size, @file_url)
        end
      end

      context "downloading a novel image" do
        should "download new novel images" do
          @file_url = "http://i1.pixiv.net/novel-cover-original/img/2016/11/03/20/10/58/7436075_f75af69f3eacd1656d3733c72aa959cf.jpg"
          @file_size = 316_133

          assert_not_rewritten(@file_url)
          assert_downloaded(@file_size, @file_url)
        end
      end
    end
  end
end
