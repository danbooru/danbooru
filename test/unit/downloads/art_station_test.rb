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
        assert_equal("https://cdnb3.artstation.com/p/assets/images/images/003/716/071/large/aoi-ogata-hate-city.jpg?1476754974", @download.source)
      end
    end

    context "for an image where an original does not exist" do
      setup do
        @source = "https://cdna.artstation.com/p/assets/images/images/004/730/278/large/mendel-oh-dragonll.jpg"
        @tempfile = Tempfile.new("danbooru-test")
        @download = Downloads::File.new(@source, @tempfile.path)
        @download.download!
      end

      should "not try to download the original" do
        assert_equal("https://cdna.artstation.com/p/assets/images/images/004/730/278/large/mendel-oh-dragonll.jpg", @download.source)
      end
    end

    context "a download for an ArtStation image hosted on CloudFlare" do
      should "return the original file, not the polished file" do
        @source = "https://cdnb.artstation.com/p/assets/images/images/003/716/071/large/aoi-ogata-hate-city.jpg?1476754974"
        assert_downloaded(517_706, @source) # polished size: 502_052
      end
    end

    context "a download for a https://$artist.artstation.com/projects/$id page" do
      setup do
        @source = "https://dantewontdie.artstation.com/projects/YZK5q"
        @tempfile = Tempfile.new("danbooru-test")
        @download = Downloads::File.new(@source, @tempfile.path)
        @download.download!
      end

      should "download the original image instead" do
        assert_equal("https://cdna.artstation.com/p/assets/images/images/006/066/534/large/yinan-cui-reika.jpg?1495781565", @download.source)
      end
    end
  end
end
