require 'test_helper'

module Sources
  class ArtStationTest < ActiveSupport::TestCase
    context "The source site for an art station artwork page" do
      setup do
        @site = Sources::Strategies.find("https://www.artstation.com/artwork/04XA4")
      end

      should "get the image url" do
        assert_equal("https://cdna.artstation.com/p/assets/images/images/000/705/368/large/jey-rain-one1.jpg", @site.image_url.sub(/\?\d+/, ""))
      end

      should "get the profile" do
        assert_equal("https://www.artstation.com/jeyrain", @site.profile_url)
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
        @site = Sources::Strategies.find("https://dantewontdie.artstation.com/projects/YZK5q")
      end

      should "get the image url" do
        url = "https://cdna.artstation.com/p/assets/images/images/006/066/534/large/yinan-cui-reika.jpg?1495781565"
        assert_equal(url, @site.image_url)
      end

      should "get the profile" do
        assert_equal("https://www.artstation.com/dantewontdie", @site.profile_url)
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
        @site = Sources::Strategies.find("https://www.artstation.com/artwork/cody-from-sf")
      end

      should "get the image url" do
        url = "https://cdna.artstation.com/p/assets/images/images/000/144/922/large/cassio-yoshiyaki-cody2backup2-yoshiyaki.jpg?1406314198"
        assert_equal(url, @site.image_url)
      end
    end

    context "The source site for a http://cdna.artstation.com/p/assets/... url" do
      setup do
        @url = "https://cdna.artstation.com/p/assets/images/images/006/029/978/large/amama-l-z.jpg"
        @ref = "https://www.artstation.com/artwork/4BWW2"
        @site = Sources::Strategies.find(@url, @ref)
      end

      should "fetch the source data" do
        assert_equal("amama", @site.artist_name)
      end
    end

    context "The source site for an ArtStation gallery" do
      setup do
        @site = Sources::Strategies.find("https://www.artstation.com/artwork/BDxrA")
      end

      should "get only image urls, not video urls" do
        urls = %w[https://cdnb.artstation.com/p/assets/images/images/006/037/253/large/astri-lohne-sjursen-eva.jpg?1495573664]
        assert_equal(urls, @site.image_urls)
      end
    end
  end
end
