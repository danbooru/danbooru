require 'test_helper'

module Sources
  class TwitterTest < ActiveSupport::TestCase
    setup do
      Danbooru.config.stubs(:twitter_api_key).returns("xxx")
      Danbooru.config.stubs(:twitter_api_secret).returns("xxx")
    end
    
    context "The source site for a restricted twitter" do
      setup do
        VCR.use_cassette("source-twitter-unit-test-2", :record => :none) do
          @site = Sources::Site.new("https://mobile.twitter.com/Strangestone/status/556440271961858051")
          @site.get
        end
      end

      should "get the image url" do
        assert_equal("http://pbs.twimg.com/media/B7jfc1JCcAEyeJh.png:large", @site.image_url)
      end
    end

    context "The source site for twitter" do
      setup do
        VCR.use_cassette("source-twitter-unit-test-1", :record => :none) do
          @site = Sources::Site.new("https://mobile.twitter.com/nounproject/status/540944400767922176")
          @site.get
        end
      end

      should "get the profile" do
        assert_equal("https://twitter.com/nounproject", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("The Noun Project", @site.artist_name)
      end

      should "get the image url" do
        assert_equal("http://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:large", @site.image_url)
      end

      should "get the tags" do
        assert_equal([], @site.tags)
      end

      should "convert a page into a json representation" do
        assert_nothing_raised do
          @site.to_json
        end
      end
    end
  end
end
