require 'test_helper'

module Downloads
  class DeviantArtTest < ActiveSupport::TestCase
    context "a download for a deviant art html page" do
      setup do
        @source = "http://mochikko.deviantart.com/art/RESOLUTION-339610451"
        @tempfile = Tempfile.new("danbooru-test")
        @download = Downloads::File.new(@source, @tempfile.path)
        VCR.use_cassette("download-deviant-art-html", :record => :new_episodes) do
          @download.download!
        end
      end

      should "set the direct image link as the source" do
        assert_equal("http://www.deviantart.com/download/339610451/resolution_by_mochikko-d5m713n.jpg?token=f828643e6e86a658e80f362745a0b20e20880fc6&ts=1414021578", @download.source)
      end

      should "work" do
        assert_equal(255_683, ::File.size(@tempfile.path))
      end
    end

    context "a download for a deviant art thumbnail" do
      setup do
        @source = "http://fc03.deviantart.net/fs71/200H/f/2012/330/e/7/resolution_by_mochikko-d5m713n.jpg"
        @tempfile = Tempfile.new("danbooru-test")
        @download = Downloads::File.new(@source, @tempfile.path)
        VCR.use_cassette("download-deviant-art-thumb", :record => :none) do
          @download.download!
        end
      end

      should "instead download the original version" do
        assert_equal("http://fc03.deviantart.net/fs71/f/2012/330/e/7/resolution_by_mochikko-d5m713n.jpg", @download.source)
      end

      should "work" do
        assert_equal(255_683, ::File.size(@tempfile.path))
      end
    end
  end
end
