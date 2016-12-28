require 'test_helper'

module Sources
  class TwitterTest < ActiveSupport::TestCase
    context "The source site for a restricted twitter" do
      setup do
        @site = Sources::Site.new("https://mobile.twitter.com/Strangestone/status/556440271961858051")
        @site.get
      end

      should "get the image url" do
        assert_equal("http://pbs.twimg.com/media/B7jfc1JCcAEyeJh.png:orig", @site.image_url)
      end
    end

    context "The source site for twitter" do
      setup do
        @site = Sources::Site.new("https://mobile.twitter.com/nounproject/status/540944400767922176")
        @site.get
      end

      should "get the profile" do
        assert_equal("https://twitter.com/nounproject", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("Noun Project", @site.artist_name)
      end

      should "get the image url" do
        assert_equal("http://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:orig", @site.image_url)
      end

      should "get the tags" do
        assert_equal([], @site.tags)
      end

      should "get the artist commentary" do
        assert_not_nil(@site.artist_commentary_desc)
      end

      should "convert a page into a json representation" do
        assert_nothing_raised do
          @site.to_json
        end
      end
    end
  end
end
