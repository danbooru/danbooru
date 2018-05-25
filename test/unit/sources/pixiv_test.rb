require 'test_helper'

module Sources
  class PixivTest < ActiveSupport::TestCase
    def get_source(source)
      @site = Sources::Site.new(source)
      @site.get
      @site
    rescue Net::OpenTimeout
      skip "Remote connection to #{source} failed"
    end

    def setup
      super
      load_pixiv_tokens!
    end

    def teardown
      save_pixiv_tokens!
      super
    end
    
    context "in all cases" do
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
          assert_equal("https://i.pximg.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip", @site.file_url)
        end

        should "capture the frame data" do
          assert_equal(2, @site.ugoira_frame_data.size)
          if @site.ugoira_frame_data[0]["file"]
            assert_equal([{"file"=>"000000.jpg", "delay"=>125}, {"file"=>"000001.jpg", "delay"=>125}], @site.ugoira_frame_data)
          else
            assert_equal([{"delay_msec"=>125}, {"delay_msec"=>125}], @site.ugoira_frame_data)
          end
        end
      end

      context "A https://i.pximg.net/img-zip/ugoira/* source" do
        should "get the metadata" do
          @site = Sources::Site.new("https://i.pximg.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip")
          @site.get

          assert_equal("uroobnad2", @site.artist_name)
        end
      end

      context "fetching source data for a new manga image" do
        setup do
          get_source("https://www.pixiv.net/member_illust.php?mode=medium&illust_id=65981735")
        end

        should "get the profile" do
          assert_equal("http://www.pixiv.net/member.php?id=696859", @site.profile_url)
        end

        should "get the artist name" do
          assert_equal("uroobnad", @site.artist_name)
        end

        should "get the full size image url" do
          assert_equal("https://i.pximg.net/img-original/img/2017/11/21/05/12/37/65981735_p0.jpg", @site.image_url)
        end

        should "get the page count" do
          assert_equal(1, @site.image_urls.size)
        end

        should "get the tags" do
          pixiv_tags  = @site.tags.map(&:first)
          pixiv_links = @site.tags.map(&:last)

          assert_equal(%w[漫画 test], pixiv_tags)
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

      context "fetching source for an illustration with swapped illust_id/mode parameters" do
        setup do
          get_source("https://www.pixiv.net/member_illust.php?illust_id=64476642&mode=medium")
        end

        should "get the page count" do
          assert_equal(1, @site.image_urls.size)
        end

        should "get the full size image url" do
          assert_equal("https://i.pximg.net/img-original/img/2017/08/18/00/09/21/64476642_p0.jpg", @site.image_url)
        end        
      end

      context "fetching source data for a deleted work" do
        should "raise a bad id error" do
          assert_raise(::PixivApiClient::BadIDError) do
            get_source("https://i.pximg.net/img-original/img/2017/11/22/01/06/44/65991677_p0.png")
          end
        end
      end

      context "fetching the commentary" do
        should "work when the description is blank" do
          get_source("https://www.pixiv.net/member_illust.php?mode=medium&illust_id=65981746")

          assert_equal("title", @site.dtext_artist_commentary_title)
          assert_equal("desc", @site.dtext_artist_commentary_desc)
        end

        should "convert html to dtext" do
          get_source("https://www.pixiv.net/member_illust.php?mode=medium&illust_id=65985331")

          dtext_desc = "[b]bold[/b]\n[i]italic[/i]\nred"
          assert_equal(dtext_desc, @site.dtext_artist_commentary_desc)
        end

        should "convert illust links and member links to dtext" do
          get_source("https://www.pixiv.net/member_illust.php?mode=medium&illust_id=63421642")

          dtext_desc = %(foo 【pixiv #46337015 "»":[/posts?tags=pixiv:46337015]】bar 【pixiv #14901720 "»":[/posts?tags=pixiv:14901720]】\n\nbaz【"user/83739":[https://www.pixiv.net/member.php?id=83739] "»":[/artists?search%5Burl_matches%5D=https%3A%2F%2Fwww.pixiv.net%2Fmember.php%3Fid%3D83739]】)
          assert_equal(dtext_desc, @site.dtext_artist_commentary_desc)
        end
      end

      context "translating the tags" do
        setup do
          CurrentUser.user = FactoryBot.create(:user)
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
            FactoryBot.create(:tag, name: tag, post_count: 1)
            FactoryBot.create(:wiki_page, title: tag, other_names: other_names)
          end

          @site = get_source("https://www.pixiv.net/member_illust.php?mode=medium&illust_id=65981746")
          @tags = @site.tags.map(&:first)
          @translated_tags = @site.translated_tags.map(&:first)
        end

        should "get the original tags" do
          assert_equal(["test", "風景", "Fate/GrandOrder", "伊19/陸奥", "鉛筆", "風景10users入り", "foo", "FOO"], @tags)
        end

        should "translate the tag if it matches a wiki other name" do
          assert_includes(@tags, "風景")
          assert_includes(@translated_tags, "scenery")
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

        should "apply aliases to translated tags" do
          tohsaka_rin = FactoryBot.create(:tag, name: "tohsaka_rin")
          toosaka_rin = FactoryBot.create(:tag, name: "toosaka_rin")

          FactoryBot.create(:wiki_page, title: "tohsaka_rin", other_names: "遠坂凛")
          FactoryBot.create(:wiki_page, title: "toosaka_rin", other_names: "遠坂凛")
          FactoryBot.create(:tag_alias, antecedent_name: "tohsaka_rin", consequent_name: "toosaka_rin")

          assert_equal([toosaka_rin], @site.translate_tag("遠坂凛"))
        end

        should "not translate '1000users入り' to '1'" do
          FactoryBot.create(:tag, name: "1", post_count: 1)
          source = get_source("https://www.pixiv.net/member_illust.php?mode=medium&illust_id=60665428")
          tags = %w[Fate/GrandOrder グランブルーファンタジー 手袋 1000users入り]

          assert_equal(tags.sort, source.tags.map(&:first).sort)
          assert_equal(["fate/grand_order"], source.translated_tags.map(&:first))
        end
      end
    end
  end
end
