# encoding: UTF-8

require 'test_helper'

module Sources
  class PixivTest < ActiveSupport::TestCase
    context "The source site for pixiv" do
      setup do
        VCR.use_cassette("source-pixiv-unit-test", :record => :once) do
          @site = Sources::Site.new("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46212123")
          @site.get
        end
      end

      should "get the profile" do
        assert_equal("http://www.pixiv.net/member.php?id=4713734", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("D-Savio", @site.artist_name)
      end

      should "get the old-style image url" do
        assert_equal("http://i1.pixiv.net/img109/img/baka_narue/46212123.jpg", @site.image_url)
      end

      should "get the tags" do
        assert(@site.tags.size == 9)

        first_tag = @site.tags.first
        assert_equal(first_tag[0], "このは")
        assert(first_tag[1] =~ /search\.php/)
      end

      should "be tagged オリジナル if the post is in the Original category, even when オリジナル isn't one of the Pixiv tags" do
        last_tag = @site.tags.last

        assert_equal(last_tag[0], "オリジナル")
        assert(last_tag[1] =~ /search\.php/)
      end

      should "convert a page into a json representation" do
        assert_nothing_raised do
          @site.to_json
        end
      end
    end
  end
end
