require "test_helper"

module Downloads
  class TwitterTest < ActiveSupport::TestCase
    context "downloading a 'https://twitter.com/:user/status/:id' url containing a video" do
      should "download the largest video" do
        @source = "https://twitter.com/CincinnatiZoo/status/859073537713328129"
        @rewrite = "https://video.twimg.com/ext_tw_video/859073467769126913/pu/vid/1280x720/cPGgVROXHy3yrK6u.mp4"
        assert_rewritten(@rewrite, @source)
        assert_downloaded(8_602_983, @source)
      end
    end

    context "downloading a 'https://twitter.com/:user/status/:id/photo/:n' card url" do
      should "download the orig file" do
        @source = "https://twitter.com/masayasuf/status/870734961778630656/photo/1"
        @rewrite = "https://pbs.twimg.com/media/DBV40M2UIAAHYlt.jpg:orig"
        assert_rewritten(@rewrite, @source)
        assert_downloaded(788_206, @source)
      end
    end

    context "downloading a 'https://mobile.twitter.com/:user/status/:id/photo/:n' mobile url" do
      should "download the orig file" do
        @source = "https://mobile.twitter.com/Strangestone/status/556440271961858051"
        @rewrite = "https://pbs.twimg.com/media/B7jfc1JCcAEyeJh.png:orig"
        assert_rewritten(@rewrite, @source)
        assert_downloaded(280_150, @source)
      end
    end

    context "downloading a 'https://pbs.twimg.com/media/*:large' url" do
      should "download the orig file" do
        @source = "https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:large"
        @rewrite = "https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:orig"
        assert_rewritten(@rewrite, @source)
        assert_downloaded(9800, @source)
      end
    end
  end
end
