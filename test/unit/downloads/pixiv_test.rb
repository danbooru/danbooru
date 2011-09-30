require 'test_helper'

module Downloads
  class PixivTest < ActiveSupport::TestCase
    context "a download for a pixiv manga page" do
      setup do
        @source = "http://img65.pixiv.net/img/kiyoringo/21755794_p2.png"
        @tempfile = Tempfile.new("danbooru-test")
        @download = Downloads::File.new(@source, @tempfile.path)
        @download.download!
      end
    
      should "instead download the big version" do
        assert_equal("http://img65.pixiv.net/img/kiyoringo/21755794_big_p2.png", @download.source)
      end
    end
    
    context "a download for a small image" do
      setup do
        @source = "http://img02.pixiv.net/img/wanwandoh/4348318_m.jpg"
        @tempfile = Tempfile.new("danbooru-test")
        @download = Downloads::File.new(@source, @tempfile.path)
        @download.download!
      end
      
      should "instead download the original version" do
        assert_equal("http://img02.pixiv.net/img/wanwandoh/4348318.jpg", @download.source)
      end
      
      should "work" do
        assert_equal(185778, ::File.size(@tempfile.path))
      end
    end
  end
end
