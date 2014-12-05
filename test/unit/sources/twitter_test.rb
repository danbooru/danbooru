require 'test_helper'

module Sources
  class TwitterTest < ActiveSupport::TestCase
    context "The source site for twitter" do
      setup do
        VCR.use_cassette("source-twitter-unit-test-1", :record => :none) do
          @site_1 = Sources::Site.new("https://mobile.twitter.com/nounproject/status/540944400767922176")
          @site_1.get
        end
      end

      should "get the profile" do
        assert_equal("https://twitter.com/nounproject", @site_1.profile_url)
      end

      should "get the artist name" do
        assert_equal("The Noun Project", @site_1.artist_name)
      end

      should "get the image url" do
        assert_equal("https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:large", @site_1.image_url)
      end

      should "get the tags" do
        assert_equal([], @site_1.tags)
      end

      should "convert a page into a json representation" do
        assert_nothing_raised do
          @site_1.to_json
        end
      end
    end
  end
end
