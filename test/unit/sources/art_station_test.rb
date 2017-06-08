require 'test_helper'

module Sources
  class ArtStationTest < ActiveSupport::TestCase
    context "The source site for an art station artwork page" do
      setup do
        @site = Sources::Site.new("https://www.artstation.com/artwork/04XA4")
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

    context "The source site for an art station projects page" do
      setup do
        @site = Sources::Site.new("https://dantewontdie.artstation.com/projects/YZK5q")
        @site.get
      end

      should "get the image url" do
        url = "https://cdna.artstation.com/p/assets/images/images/006/066/534/original/yinan-cui-reika.jpg?1495781565"
        assert_equal(url, @site.image_url)
      end

      should "get the profile" do
        assert_equal("https://www.artstation.com/artist/dantewontdie", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("dantewontdie", @site.artist_name)
      end

      should "get the tags" do
        assert_equal(%w[gantz reika], @site.tags.map(&:first))
      end

      should "get the artist commentary" do
        assert_equal("Reika ", @site.artist_commentary_title)
        assert_equal("From Gantz.", @site.artist_commentary_desc)
      end
    end

    context "The source site for a www.artstation.com/artwork/$slug page" do
      setup do
        @site = Sources::Site.new("https://www.artstation.com/artwork/cody-from-sf")
        @site.get
      end

      should "get the image url" do
        url = "https://cdna.artstation.com/p/assets/images/images/000/144/922/original/cassio-yoshiyaki-cody2backup2-yoshiyaki.jpg?1406314198"
        assert_equal(url, @site.image_url)
      end
    end

    context "The source site for a http://cdna.artstation.com/p/assets/... url" do
      setup do
        @url = "https://cdna.artstation.com/p/assets/images/images/006/029/978/large/amama-l-z.jpg"
        @ref = "https://www.artstation.com/artwork/4BWW2"
        @site = Sources::Site.new(@url, referer_url: @ref)
        @site.get
      end

      should "fetch the source data" do
        assert_equal("amama", @site.artist_name)
      end
    end

    context "The source site for an ArtStation gallery" do
      setup do
        @site = Sources::Site.new("https://www.artstation.com/artwork/BDxrA")
        @site.get
      end

      should "get only image urls, not video urls" do
        urls = %w[https://cdnb.artstation.com/p/assets/images/images/006/037/253/original/astri-lohne-sjursen-eva.jpg?1495573664]
        assert_equal(urls, @site.image_urls)
      end
    end
  end
end
