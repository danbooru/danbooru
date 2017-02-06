require 'test_helper'

module Downloads
  class ArtStationTest < ActiveSupport::TestCase
    context "a download for a (small) artstation image" do
      setup do
        @source = "https://cdnb3.artstation.com/p/assets/images/images/003/716/071/large/aoi-ogata-hate-city.jpg?1476754974"
        @tempfile = Tempfile.new("danbooru-test")
        @download = Downloads::File.new(@source, @tempfile.path)
        @download.download!
      end

      should "download the large image instead" do
        assert_equal("https://cdnb3.artstation.com/p/assets/images/images/003/716/071/original/aoi-ogata-hate-city.jpg?1476754974", @download.source)
      end
    end
  end
end
