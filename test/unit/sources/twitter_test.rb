require 'test_helper'

module Sources
  class TwitterTest < ActiveSupport::TestCase
    context "An extended tweet" do
      should "extract the correct image url" do
        skip "Twitter key is not set" unless Danbooru.config.twitter_api_key
        @site = Sources::Strategies.find("https://twitter.com/onsen_musume_jp/status/865534101918330881")
        assert_equal(["https://pbs.twimg.com/media/DAL-ntWV0AEbhes.jpg:orig"], @site.image_urls)
      end

      should "extract all the image urls" do
        skip "Twitter key is not set" unless Danbooru.config.twitter_api_key
        @site = Sources::Strategies.find("https://twitter.com/aoimanabu/status/892370963630743552")

        urls = %w[
          https://pbs.twimg.com/media/DGJWp59UIAA_-en.jpg:orig
          https://pbs.twimg.com/media/DGJWqGLUwAAn2RL.jpg:orig
          https://pbs.twimg.com/media/DGJWqT_UMAAvmSK.jpg:orig
        ]

        assert_equal(urls, @site.image_urls)
      end
    end
    
    context "A video" do
      setup do
        skip "Twitter key is not set" unless Danbooru.config.twitter_api_key
        @site = Sources::Strategies.find("https://twitter.com/CincinnatiZoo/status/859073537713328129")
      end

      should "get the image url" do
        assert_equal("https://video.twimg.com/ext_tw_video/859073467769126913/pu/vid/1280x720/cPGgVROXHy3yrK6u.mp4", @site.image_url)
      end
    end

    context "An animated gif" do
      setup do
        skip "Twitter key is not set" unless Danbooru.config.twitter_api_key
        @site = Sources::Strategies.find("https://twitter.com/DaniStrawberry1/status/859435334765088769")
      end

      should "get the image url" do
        assert_equal("https://video.twimg.com/tweet_video/C-1Tns7WsAAqvqn.mp4", @site.image_url)
      end
    end

    context "A twitter summary card" do
      setup do
        skip "Twitter key is not set" unless Danbooru.config.twitter_api_key
        @site = Sources::Strategies.find("https://twitter.com/NatGeo/status/932700115936178177")
      end

      should "get the image url" do
        assert_equal("https://pmdvod.nationalgeographic.com/NG_Video/205/302/smpost_1510342850295.jpg", @site.image_url)
      end
    end

    context "A twitter summary card from twitter" do
      setup do
        skip "Twitter key is not set" unless Danbooru.config.twitter_api_key
        @site = Sources::Strategies.find("https://twitter.com/masayasuf/status/870734961778630656/photo/1")
      end

      should "get the image url" do
        skip "Find another url, the masayasuf tweet no longer exists"
        assert_equal("https://pbs.twimg.com/media/DBV40M2UIAAHYlt.jpg:orig", @site.image_url)
      end
    end

    context "A twitter summary card from twitter with a :large image" do
      setup do
        skip "Twitter key is not set" unless Danbooru.config.twitter_api_key
        @site = Sources::Strategies.find("https://twitter.com/aranobu/status/817736083567820800")
      end

      should "get the image url" do
        assert_equal("https://pbs.twimg.com/media/C1kt72yVEAEGpOv.jpg:orig", @site.image_url)
      end

      should "get the canonical url" do
        assert_equal("https://twitter.com/aranobu/status/817736083567820800", @site.canonical_url)
      end
    end

    context "The source site for a restricted twitter" do
      setup do
        skip "Twitter key is not set" unless Danbooru.config.twitter_api_key
        @site = Sources::Strategies.find("https://mobile.twitter.com/Strangestone/status/556440271961858051")
        
      end

      should "get the image url" do
        assert_equal("https://pbs.twimg.com/media/B7jfc1JCcAEyeJh.png:orig", @site.image_url)
      end
    end

    context "The source site for twitter" do
      setup do
        skip "Twitter key is not set" unless Danbooru.config.twitter_api_key
        @site = Sources::Strategies.find("https://mobile.twitter.com/nounproject/status/540944400767922176")
      end

      should "get the profile" do
        assert_equal("https://twitter.com/nounproject", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("nounproject", @site.artist_name)
      end

      should "get the image url" do
        assert_equal("https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:orig", @site.image_url)
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

    context "The source site for a direct image and a referer" do
      setup do
        skip "Twitter key is not set" unless Danbooru.config.twitter_api_key
        @site = Sources::Strategies.find("https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:large", "https://twitter.com/nounproject/status/540944400767922176")
      end

      should "get the artist name" do
        assert_equal("nounproject", @site.artist_name)
      end

      should "get the image url" do
        assert_equal("https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:orig", @site.image_url)
      end
    end

    context "The source site for a direct image url (pbs.twimg.com/media/*.jpg) without a referer url" do
      setup do
        skip "Twitter key is not set" unless Danbooru.config.twitter_api_key
        @site = Sources::Strategies.find("https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:large")
      end

      should "work" do
        assert_equal("https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:orig", @site.image_url)
        assert_equal(["https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:orig"], @site.image_urls)
        assert(@site.artist_name.blank?)
        assert(@site.profile_url.blank?)
        assert(@site.artists.empty?)
        assert(@site.tags.empty?)
        assert(@site.artist_commentary_desc.blank?)
        assert(@site.dtext_artist_commentary_desc.blank?)
        assert_nothing_raised { @site.to_h }
      end
    end

    context "The source site for a https://twitter.com/i/web/status/:id url" do
      setup do
        skip "Twitter key is not set" unless Danbooru.config.twitter_api_key
        @site = Sources::Strategies.find("https://twitter.com/i/web/status/943446161586733056")
      end

      should "fetch the source data" do
        assert_equal("https://twitter.com/motty08111213", @site.profile_url)
      end
    end

    context "A tweet" do
      setup do
        skip "Twitter key is not set" unless Danbooru.config.twitter_api_key
        @site = Sources::Strategies.find("https://twitter.com/noizave/status/875768175136317440")
      end

      should "convert urls, hashtags, and mentions to dtext" do
        desc = 'test "#foo":[https://twitter.com/hashtag/foo] "#ホワイトデー":[https://twitter.com/hashtag/ホワイトデー] "@noizave":[https://twitter.com/noizave]\'s blah http://www.example.com <>& 😀'
        assert_equal(desc, @site.dtext_artist_commentary_desc)
      end

      should "get the tags" do
        tags = [
          %w[foo https://twitter.com/hashtag/foo],
          %w[ホワイトデー https://twitter.com/hashtag/ホワイトデー],
        ]

        assert_equal(tags, @site.tags)
      end
    end
  end
end
