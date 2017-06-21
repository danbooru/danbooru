require 'test_helper'

module Downloads
  class TumblrTest < ActiveSupport::TestCase
    context "a download for a tumblr 500 sample" do
      should "instead download the 1280 version" do
        @source = "http://24.media.tumblr.com/fc328250915434e66e8e6a92773f79d0/tumblr_mf4nshfibc1s0oswoo1_500.jpg"
        assert_rewritten("http://24.media.tumblr.com/fc328250915434e66e8e6a92773f79d0/tumblr_mf4nshfibc1s0oswoo1_1280.jpg", @source)
        assert_downloaded(196_617, @source)
      end
    end

    context "a download for a tumblr 500 image without a larger size" do
      should "download the 500 version" do
        @source = "http://25.media.tumblr.com/tumblr_lxbzel2H5y1r9yjhso1_500.jpg"
        assert_downloaded(90_122, @source)
      end
    end
  end
end
