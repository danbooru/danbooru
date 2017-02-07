require 'test_helper'

module Sources
  class ArtStationTest < ActiveSupport::TestCase
    context "The source site for an art station artwork page" do
      setup do
        @site = Sources::Site.new("https://jeyrain.artstation.com/artwork/04XA4")
        @site.get
      end

      should "get the image url" do
        assert_equal("https://cdna.artstation.com/p/assets/images/images/000/705/368/original/jey-rain-one1.jpg", @site.image_url.sub(/\?\d+/, ""))
      end

      should "get the profile" do
        assert_equal("https://www.artstation.com/artist/jeyrain", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("jeyrain", @site.artist_name)
      end

      should "get the tags" do
        assert_equal([], @site.tags)
      end

      should "get the artist commentary" do
        assert_equal("pink", @site.artist_commentary_title)
        assert_equal("", @site.artist_commentary_desc)
      end
    end
  end
end
