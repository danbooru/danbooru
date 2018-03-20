require 'test_helper'

module Downloads
  class PixivTest < ActiveSupport::TestCase
    context "An ugoira site for pixiv" do
      setup do
        @download = Downloads::File.new("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364")
        @tempfile = @download.download!
        @tempfile.close!
      end

      should "capture the data" do
        assert_equal("https://i.pximg.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip", @download.source)
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

          @file_size = 1261
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
          @medium_page = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46324488"
          @manga_page  = "http://www.pixiv.net/member_illust.php?mode=manga&illust_id=46324488"
          @manga_big_p1_page = "http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=46324488&page=1"

          @p0_large_thumbnail = "https://i.pximg.net/img-master/img/2014/10/03/18/10/20/46324488_p0_master1200.jpg"
          @p1_large_thumbnail = "https://i.pximg.net/img-master/img/2014/10/03/18/10/20/46324488_p1_master1200.jpg"
          @p0_full_size_image = "https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png"
          @p1_full_size_image = "https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p1.png"

          @p0_file_size = 21_213
          @p1_file_size = 24_672
        end

        should "download the full size image" do
          assert_not_rewritten(@p0_full_size_image)
          assert_not_rewritten(@p1_full_size_image)

          assert_downloaded(@p0_file_size, @p0_full_size_image)
          assert_downloaded(@p1_file_size, @p1_full_size_image)
        end

        should "download the full size image instead of the HTML page" do
          assert_rewritten(@p0_full_size_image, @medium_page)
          assert_rewritten(@p0_full_size_image, @manga_page)
          assert_rewritten(@p1_full_size_image, @manga_big_p1_page)
          assert_downloaded(@p0_file_size, @medium_page)
          assert_downloaded(@p0_file_size, @manga_page)
          assert_downloaded(@p1_file_size, @manga_big_p1_page)
        end

        should "download the full size image instead of the thumbnail" do
          assert_rewritten(@p0_full_size_image, @p0_large_thumbnail)
          assert_rewritten(@p1_full_size_image, @p1_large_thumbnail)
          assert_downloaded(@p0_file_size, @p0_large_thumbnail)
          assert_downloaded(@p1_file_size, @p1_large_thumbnail)
        end
      end

      context "downloading a bad id image" do
        setup do
          @bad_id_full   = "https://i.pximg.net/img-original/img/2017/11/22/01/06/44/65991677_p0.png"
          @bad_id_sample = "https://i.pximg.net/c/600x600/img-master/img/2017/11/22/01/06/44/65991677_p0_master1200.jpg"
        end

        should "not raise an error when rewriting the url" do
          assert_nothing_raised { assert_not_rewritten(@bad_id_full) }
        end

        should_eventually "rewrite bad id samples to full size" do
          assert_rewritten(@bad_id_full, @bad_id_sample)
        end
      end

      context "downloading a ugoira" do
        setup do
          @medium_page     = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364"
          @zip_file        = "https://i.pximg.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip"
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
          @file_url = "https://i.pximg.net/user-profile/img/2014/12/18/10/31/23/8733472_7dc7310db6cc37163af145d04499e411_170.jpg"
          @file_size = 23_328

          assert_not_rewritten(@file_url)
          assert_downloaded(@file_size, @file_url)
        end

      end

      context "downloading a background image" do
        should "download the image" do
          @file_url = "http://i1.pixiv.net/background/img/2016/05/17/12/05/48/2074388_d4ac52034f7ca0af3e083d59fde7e97f.jpg"
          @file_size = 386_678

          assert_not_rewritten(@file_url)
          assert_downloaded(@file_size, @file_url)
        end
      end

      context "downloading a novel image" do
        should "download new novel images" do
          @file_url = "http://i1.pixiv.net/novel-cover-original/img/2016/11/03/20/10/58/7436075_f75af69f3eacd1656d3733c72aa959cf.jpg"
          @file_size = 316_311

          assert_not_rewritten(@file_url)
          assert_downloaded(@file_size, @file_url)
        end
      end
    end
  end
end
