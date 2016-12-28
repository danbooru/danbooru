require 'test_helper'

module Downloads
  class TumblrTest < ActiveSupport::TestCase
    context "a download for a tumblr 500 sample" do
      setup do
        @source = "http://24.media.tumblr.com/fc328250915434e66e8e6a92773f79d0/tumblr_mf4nshfibc1s0oswoo1_500.jpg"
        @tempfile = Tempfile.new("danbooru-test")
        @download = Downloads::File.new(@source, @tempfile.path)
        @download.download!
      end

      should "instead change the source to the 1280 version" do
        assert_equal("http://24.media.tumblr.com/fc328250915434e66e8e6a92773f79d0/tumblr_mf4nshfibc1s0oswoo1_1280.jpg", @download.source)
      end

      should "instead download the 1280 version" do
        assert_equal(196_617, ::File.size(@tempfile.path))
      end
    end

    context "a download for a tumblr 500 image without a larger size" do
      setup do
        @source = "http://25.media.tumblr.com/tumblr_lxbzel2H5y1r9yjhso1_500.jpg"
        @tempfile = Tempfile.new("danbooru-test")
        @download = Downloads::File.new(@source, @tempfile.path)
        @download.download!
      end

      should "download the 500 version" do
        assert_equal(90_122, ::File.size(@tempfile.path))
      end
    end
  end
end
