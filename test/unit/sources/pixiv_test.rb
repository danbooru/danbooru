require 'test_helper'

module Sources
  class PixivTest < ActiveSupport::TestCase
    def get_source(source)
      @site = Sources::Site.new(source)
      @site.get
      @site
    end

    context "in all cases" do
      context "A whitecube page" do
        setup do
          @site = Sources::Site.new("https://www.pixiv.net/whitecube/user/277898/illust/59182257")
          @site.get
          @image_urls = @site.image_urls
        end

        should "get all the image urls" do
          assert_equal(["https://i.pximg.net/img-original/img/2016/09/26/21/30/41/59182257_p0.jpg"], @image_urls)
        end
      end

      context "A touch page" do
        setup do
          @site = Sources::Site.new("http://touch.pixiv.net/member_illust.php?mode=medium&illust_id=59687915")
          @image_urls = @site.get
        end

        should "get all the image urls" do
          assert_equal("https://i.pximg.net/img-original/img/2016/10/29/17/13/23/59687915_p0.png", @image_urls)
        end
      end

      context "A gallery page" do
        setup do
          @site = Sources::Site.new("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=49270482")
          @site.get
          @image_urls = @site.image_urls
        end

        should "get all the image urls" do
          assert_equal(["https://i.pximg.net/img-original/img/2015/03/14/17/53/32/49270482_p0.jpg", "https://i.pximg.net/img-original/img/2015/03/14/17/53/32/49270482_p1.jpg"], @image_urls)
        end
      end

      context "An ugoira source site for pixiv" do
        setup do
          @site = Sources::Site.new("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364")
          @site.get
        end

        should "get the file url" do
          assert_equal("https://i1.pixiv.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip", @site.file_url)
        end

        should "capture the frame data" do
          assert_equal([{"file"=>"000000.jpg", "delay"=>125}, {"file"=>"000001.jpg", "delay"=>125}], @site.ugoira_frame_data)
        end
      end

      context "fetching source data for a new manga image" do
        setup do
          get_source("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46304614")
        end

        should "get the profile" do
          assert_equal("http://www.pixiv.net/member.php?id=339253", @site.profile_url)
        end

        should "get the artist name" do
          assert_equal("evazion", @site.artist_name)
        end

        should "get the full size image url" do
          assert_equal("https://i.pximg.net/img-original/img/2014/10/02/14/21/39/46304614_p0.gif", @site.image_url)
        end

        should "get the page count" do
          assert_equal(3, @site.image_urls.size)
        end

        should "get the tags" do
          pixiv_tags  = @site.tags.map(&:first)
          pixiv_links = @site.tags.map(&:last)

          assert_equal(%w[漫画 Fate/GrandOrder foo FOO 風景10users入り 伊19/陸奥 鉛筆], pixiv_tags)
          assert_contains(pixiv_links, /search\.php/)
        end

        should "get the artist commentary" do
          assert_not_nil(@site.artist_commentary_title)
          assert_not_nil(@site.artist_commentary_desc)
          assert_not_nil(@site.dtext_artist_commentary_title)
          assert_not_nil(@site.dtext_artist_commentary_desc)
        end

        should "convert a page into a json representation" do
          assert_nothing_raised do
            @site.to_json
          end
        end
      end

      context "fetching source data for a new illustration" do
        setup do
          get_source("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46785915")
        end

        should "get the page count" do
          assert_equal(1, @site.image_urls.size)
        end

        should "get the full size image url" do
          assert_equal("https://i.pximg.net/img-original/img/2014/10/29/09/27/19/46785915_p0.jpg", @site.image_url)
        end
      end

      context "fetching the commentary" do
        should "work when the description is blank" do
          get_source("https://www.pixiv.net/member_illust.php?mode=medium&illust_id=46337015")

          assert_equal("Illustration (PNG) - foo & bar", @site.dtext_artist_commentary_title)
          assert_equal("", @site.dtext_artist_commentary_desc)
        end

        should "convert illust links and member links to dtext" do
          get_source("https://www.pixiv.net/member_illust.php?mode=medium&illust_id=63421642")

          dtext_desc = %(foo 【pixiv #46337015 "»":[/posts?tags=pixiv:46337015]】bar 【pixiv #14901720 "»":[/posts?tags=pixiv:14901720]】\r\n\r\nbaz【"user/83739":[https://www.pixiv.net/member.php?id=83739] "»":[/artists?search%5Burl_matches%5D=https%3A%2F%2Fwww.pixiv.net%2Fmember.php%3Fid%3D83739]】)
          assert_equal(dtext_desc, @site.dtext_artist_commentary_desc)
        end
      end

      context "translating the tags" do
        setup do
          CurrentUser.user = FactoryGirl.create(:user)
          CurrentUser.ip_addr = "127.0.0.1"

          tags = {
            "comic" => "漫画",
            "scenery" => "風景",
            "i-19_(kantai_collection)" => "伊19",
            "mutsu_(kantai_collection)" => "陸奥",
            "fate/grand_order" => "Fate/GrandOrder",
            "fate" => "",
            "foo" => "",
          }

          tags.each do |tag, other_names|
            FactoryGirl.create(:tag, name: tag, post_count: 1)
            FactoryGirl.create(:wiki_page, title: tag, other_names: other_names)
          end

          @site = get_source("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46304614")
          @tags = @site.tags.map(&:first)
          @translated_tags = @site.translated_tags.map(&:first)
        end

        should "get the original tags" do
          assert_equal(%w[漫画 Fate/GrandOrder foo FOO 風景10users入り 伊19/陸奥 鉛筆], @tags)
        end

        should "translate the tag if it matches a wiki other name" do
          assert_includes(@tags, "漫画")
          assert_includes(@translated_tags, "comic")
        end

        should "return the same tag if it doesn't match a wiki other name but it does match a tag" do
          assert_includes(@tags, "foo")
          assert_includes(@translated_tags, "foo")
        end

        should "not translate tags for digital media" do
          assert_equal(false, @tags.include?("Photoshop"))
        end

        should "normalize 10users入り tags" do
          assert_includes(@tags, "風景10users入り")
          assert_includes(@translated_tags, "scenery")
        end

        should "split the base tag if it has no match" do
          assert_includes(@tags, "伊19/陸奥")
          assert_includes(@translated_tags, "i-19_(kantai_collection)")
          assert_includes(@translated_tags, "mutsu_(kantai_collection)")
        end

        should "not split the base tag if it has a match" do
          assert_includes(@tags, "Fate/GrandOrder")
          assert_includes(@translated_tags, "fate/grand_order")
          assert_equal(false, @translated_tags.grep("fate").any?)
        end
      end
    end
  end
end
