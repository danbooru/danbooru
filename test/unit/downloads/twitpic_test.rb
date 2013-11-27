require 'test_helper'

module Downloads
  class TwitpicTest < ActiveSupport::TestCase
    context "a download for a twitpic html page" do
      setup do
        @source = "http://twitpic.com/cpprns"
        @tempfile = Tempfile.new("danbooru-test")
        @download = Downloads::File.new(@source, @tempfile.path)
        VCR.use_cassette("download-twitpic-html", :record => :new_episodes) do
          @download.download!
        end
      end

      should "set the direct image link as the source" do
        assert_equal("http://d3j5vwomefv46c.cloudfront.net/photos/large/768786760.jpg?1368245083", @download.source)
      end

      should "work" do
        assert_equal(89_409, ::File.size(@tempfile.path))
      end
    end

    context "a download for a twitpic thumbnail" do
      setup do
        @source = "http://d3j5vwomefv46c.cloudfront.net/photos/thumb/768786760.jpg?1368245083"
        @tempfile = Tempfile.new("danbooru-test")
        @download = Downloads::File.new(@source, @tempfile.path)
        VCR.use_cassette("download-twitpic-thumb", :record => :new_episodes) do
          @download.download!
        end
      end

      should "instead download the original version" do
        assert_equal("http://d3j5vwomefv46c.cloudfront.net/photos/large/768786760.jpg?1368245083", @download.source)
      end

      should "work" do
        assert_equal(89_409, ::File.size(@tempfile.path))
      end
    end
  end
end
