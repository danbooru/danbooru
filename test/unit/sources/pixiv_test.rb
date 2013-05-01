# encoding: UTF-8

require 'test_helper'

module Sources
  class PixivTest < ActiveSupport::TestCase
    context "The source site for pixiv" do
      setup do
        VCR.use_cassette("source-pixiv-unit-test", :record => :new_episodes) do
          @site = Sources::Site.new("http://www.pixiv.net/member_illust.php?mode=big&illust_id=9646484")
        end
      end

      should "get the profile" do
        assert_equal("http://www.pixiv.net/member.php?id=4015", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("シビレ罠", @site.artist_name)
      end

      should "get the image url" do
        assert_equal("http://i1.pixiv.net/img01/img/nisieda/9646484.jpg", @site.image_url)
      end

      should "get the tags" do
        assert(@site.tags.size > 0)
        first_tag = @site.tags.first
        assert_equal(2, first_tag.size)
        assert(first_tag[0] =~ /./)
        assert(first_tag[1] =~ /search\.php/)
      end

      should "convert a page into a json representation" do
        assert_nothing_raised do
          @site.to_json
        end
      end
    end
  end
end
