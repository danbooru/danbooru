require 'test_helper'

module Downloads
  class ArtStationTest < ActiveSupport::TestCase
    context "a download for a (small) artstation image" do
      setup do
        @asset = "https://cdnb3.artstation.com/p/assets/images/images/003/716/071/small/aoi-ogata-hate-city.jpg?1476754974"
        @large = "https://cdnb3.artstation.com/p/assets/images/images/003/716/071/large/aoi-ogata-hate-city.jpg?1476754974"
        @download = Downloads::File.new(@asset)
      end

      should "download the large image instead" do
        @download.download!
        assert_equal(@large, @download.downloaded_source)
      end
    end

    context "for an image where an original does not exist" do
      setup do
        @asset = "https://cdna.artstation.com/p/assets/images/images/004/730/278/large/mendel-oh-dragonll.jpg"
        @download = Downloads::File.new(@asset)
      end

      should "not try to download the original" do
        @download.download!
        assert_equal(@asset, @download.downloaded_source)
      end
    end

    context "a download for an ArtStation image hosted on CloudFlare" do
      setup do
        @asset = "https://cdnb.artstation.com/p/assets/images/images/003/716/071/large/aoi-ogata-hate-city.jpg?1476754974"
      end

      should "return the original file, not the polished file" do
        assert_downloaded(517_706, @asset) # polished size: 502_052
      end
    end

    context "a download for a https://$artist.artstation.com/projects/$id page" do
      setup do
        @source = "https://dantewontdie.artstation.com/projects/YZK5q"
        @norm = "https://www.artstation.com/artwork/YZK5q"
        @asset = "https://cdna.artstation.com/p/assets/images/images/006/066/534/large/yinan-cui-reika.jpg?1495781565"
        @download = Downloads::File.new(@source)
      end

      should "download the original image instead" do
        @download.download!

        assert_equal(@norm, @download.source)
        assert_equal(@asset, @download.downloaded_source)
      end
    end
  end
end
