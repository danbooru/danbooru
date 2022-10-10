require 'test_helper'

module Downloads
  class PixivTest < ActiveSupport::TestCase
    context "in all cases" do
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

        should "download the full size image instead of the thumbnail" do
          skip "Pixiv credentials not configured" unless Source::Extractor::Pixiv.enabled?

          assert_rewritten(@p0_full_size_image, @p0_large_thumbnail)
          assert_rewritten(@p1_full_size_image, @p1_large_thumbnail)
          assert_downloaded(@p0_file_size, @p0_large_thumbnail)
          assert_downloaded(@p1_file_size, @p1_large_thumbnail)
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
          skip "profile images are no longer supported"

          @file_url = "https://i.pximg.net/user-profile/img/2014/12/18/10/31/23/8733472_7dc7310db6cc37163af145d04499e411_170.jpg"
          @file_size = 23_328

          assert_not_rewritten(@file_url)
          assert_downloaded(@file_size, @file_url)
        end
      end

      context "downloading a background image" do
        should "download the image" do
          skip "background images are no longer supported"

          @file_url = "https://i.pximg.net/background/img/2015/10/25/08/45/27/198128_77ddf78cdb162e3d1c0d5134af185813.jpg"
          @file_size = 0

          assert_not_rewritten(@file_url)
          assert_downloaded(@file_size, @file_url)
        end
      end

      context "downloading a novel image" do
        should "download new novel images" do
          @file_url = "https://i.pximg.net/novel-cover-original/img/2017/07/27/23/14/17/8465454_80685d10e6df4d7d53ad347ddc18a36b.jpg"
          @ref = 'https://www.pixiv.net/novel/show.php?id=8465454&mode=cover'
          @file_size = 532_037

          assert_not_rewritten(@file_url, @ref)
          assert_downloaded(@file_size, @file_url, @ref)
        end
      end
    end

    context "An ugoira site for pixiv" do
      should "capture the data" do
        @strategy = Source::Extractor.find("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364")
        media_file = @strategy.download_file!(@strategy.image_urls.sole)

        assert_equal([125, 125], media_file.frame_delays)
      end
    end
  end
end
