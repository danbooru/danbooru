require 'test_helper'

module Downloads
  class ArtStationTest < ActiveSupport::TestCase
    context "a download for a (small) artstation image" do
      should "download the /4k/ image instead" do
        assert_downloaded(1_816_438, "https://cdnb3.artstation.com/p/assets/images/images/003/716/071/small/aoi-ogata-hate-city.jpg?1476754974")
      end
    end

    context "for an image where an original does not exist" do
      should "not try to download the original" do
        assert_downloaded(452_795, "https://cdna.artstation.com/p/assets/images/images/004/730/278/large/mendel-oh-dragonll.jpg")
      end
    end

    context "a download for an ArtStation image hosted on CloudFlare" do
      should "return the original file, not the polished file" do
        @asset = "https://cdnb.artstation.com/p/assets/images/images/003/716/071/large/aoi-ogata-hate-city.jpg?1476754974"
        assert_downloaded(1_816_438, @asset)
      end
    end

    context "a download for a https://$artist.artstation.com/projects/$id page" do
      should "download the original image instead" do
        assert_downloaded(210_709, "https://dantewontdie.artstation.com/projects/YZK5q")
      end
    end
  end
end
