require 'test_helper'

module Sources
  class TwitterTest < ActiveSupport::TestCase
    context "A video" do
      setup do
        @site = Sources::Site.new("https://twitter.com/CincinnatiZoo/status/859073537713328129")
        @site.get
      end

      should "get the image url" do
        assert_equal("https://video.twimg.com/ext_tw_video/859073467769126913/pu/vid/1280x720/cPGgVROXHy3yrK6u.mp4", @site.image_url)
      end
    end

    context "An animated gif" do
      setup do
        @site = Sources::Site.new("https://twitter.com/DaniStrawberry1/status/859435334765088769")
        @site.get
      end

      should "get the image url" do
        assert_equal("https://video.twimg.com/tweet_video/C-1Tns7WsAAqvqn.mp4", @site.image_url)
      end
    end

    context "A twitter summary card" do
      setup do
        @site = Sources::Site.new("https://twitter.com/NatGeo/status/787654447937847296")
        @site.get
      end

      should "get the image url" do
        assert_equal("http://yourshot.nationalgeographic.com/u/fQYSUbVfts-T7odkrFJckdiFeHvab0GWOfzhj7tYdC0uglagsDcUxj3Tf7HBF3kZEj7S5m-zeDmZP6DBxBJlyJX_1mFp-hGf4JPt97xp0QJkwf4po1MmnZH73WC3a2Pa1Ky62C-v0cYXTur3-QwD3Pz5UI_cKIi81GABTXII8VwKUopxlNW2MYAR8kPYU2IoUhOjlvVefNcLYI74J-0IpI4tHDXE/", @site.image_url)
      end
    end

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
