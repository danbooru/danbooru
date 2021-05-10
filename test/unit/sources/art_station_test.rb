require 'test_helper'

module Sources
  class ArtStationTest < ActiveSupport::TestCase
    context "The source site for an art station artwork page" do
      setup do
        @site = Sources::Strategies.find("https://www.artstation.com/artwork/04XA4")
      end

      should "get the image url" do
        assert_equal("https://cdn.artstation.com/p/assets/images/images/000/705/368/4k/jey-rain-one1.jpg", @site.image_url.sub(/\?\d+/, ""))
      end

      should "get the preview url" do
        assert_equal("https://cdn.artstation.com/p/assets/images/images/000/705/368/small/jey-rain-one1.jpg", @site.preview_url.sub(/\?\d+/, ""))
      end

      should "get the canonical url" do
        assert_equal("https://jeyrain.artstation.com/projects/04XA4", @site.canonical_url)
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
        assert_equal("", @site.dtext_artist_commentary_desc)
      end
    end

    context "The source site for an art station projects page" do
      setup do
        @site = Sources::Strategies.find("https://dantewontdie.artstation.com/projects/YZK5q")
      end

      should "get the image url" do
        url = "https://cdn.artstation.com/p/assets/images/images/006/066/534/4k/yinan-cui-reika.jpg?1495781565"
        assert_equal(url, @site.image_url)
      end

      should "get the preview url" do
        url = "https://cdn.artstation.com/p/assets/images/images/006/066/534/small/yinan-cui-reika.jpg?1495781565"
        assert_equal(url, @site.preview_url)
      end

      should "get the canonical url" do
        assert_equal("https://dantewontdie.artstation.com/projects/YZK5q", @site.canonical_url)
      end

      should "get the profile" do
        assert_equal("https://www.artstation.com/dantewontdie", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("dantewontdie", @site.artist_name)
      end

      should "get the tags" do
        assert_equal(%w[gantz Reika], @site.tags.map(&:first))
        assert_equal(%w[gantz reika], @site.normalized_tags)
      end

      should "get the artist commentary" do
        assert_equal("Reika ", @site.artist_commentary_title)
        assert_equal("From Gantz.", @site.dtext_artist_commentary_desc)
      end
    end

    context "The source site for a www.artstation.com/artwork/$slug page" do
      setup do
        @site = Sources::Strategies.find("https://www.artstation.com/artwork/cody-from-sf")
      end

      should "get the image url" do
        url = "https://cdn.artstation.com/p/assets/images/images/000/144/922/4k/cassio-yoshiyaki-cody2backup2-yoshiyaki.jpg?1406314198"
        assert_equal(url, @site.image_url)
      end

      should "get the preview url" do
        url = "https://cdn.artstation.com/p/assets/images/images/000/144/922/small/cassio-yoshiyaki-cody2backup2-yoshiyaki.jpg?1406314198"
        assert_equal(url, @site.preview_url)
      end

      should "get the tags" do
        assert_equal(["Street Fighter", "Cody", "SF"].sort, @site.tags.map(&:first).sort)
        assert_equal(["street_fighter", "cody", "sf"].sort, @site.normalized_tags.sort)
      end
    end

    context "The source site for a http://cdn.artstation.com/p/assets/... url" do
      setup do
        @url = "https://cdna.artstation.com/p/assets/images/images/006/029/978/large/amama-l-z.jpg"
        @ref = "https://www.artstation.com/artwork/4BWW2"
      end

      context "with a referer" do
        should "work" do
          site = Sources::Strategies.find(@url, @ref)

          assert_equal("https://cdn.artstation.com/p/assets/images/images/006/029/978/4k/amama-l-z.jpg", site.image_url)
          assert_equal("https://amama.artstation.com/projects/4BWW2", site.page_url)
          assert_equal("https://amama.artstation.com/projects/4BWW2", site.canonical_url)
          assert_equal("https://www.artstation.com/amama", site.profile_url)
          assert_equal("amama", site.artist_name)
          assert_nothing_raised { site.to_h }
        end
      end

      context "without a referer" do
        should "work" do
          site = Sources::Strategies.find(@url)

          assert_equal("https://cdn.artstation.com/p/assets/images/images/006/029/978/4k/amama-l-z.jpg", site.image_url)
          assert_nil(site.page_url)
          assert_nil(site.profile_url)
          assert_nil(site.artist_name)
          assert_equal([], site.tags)
          assert_nothing_raised { site.to_h }
        end
      end
    end

    context "A 4k asset url" do
      context "without a referer" do
        should "work" do
          site = Sources::Strategies.find("https://cdna.artstation.com/p/assets/images/images/007/253/680/4k/ina-wong-demon-girl-done-ttd-comp.jpg?1504793833")

          assert_equal("https://cdn.artstation.com/p/assets/images/images/007/253/680/4k/ina-wong-demon-girl-done-ttd-comp.jpg?1504793833", site.image_url)
          assert_nothing_raised { site.to_h }
        end
      end
    end

    context "A cover url" do
      should "work" do
        url = "https://cdna.artstation.com/p/assets/covers/images/007/262/828/large/monica-kyrie-1.jpg?1504865060"
        site = Sources::Strategies.find(url)

        assert_equal("https://cdn.artstation.com/p/assets/covers/images/007/262/828/original/monica-kyrie-1.jpg?1504865060", site.image_url)
        assert_equal("https://cdn.artstation.com/p/assets/covers/images/007/262/828/small/monica-kyrie-1.jpg?1504865060", site.preview_url)
      end
    end

    context "The source site for an ArtStation gallery" do
      setup do
        @site = Sources::Strategies.find("https://www.artstation.com/artwork/BDxrA")
      end

      should "get only image urls, not video urls" do
        urls = %w[https://cdn.artstation.com/p/assets/images/images/006/037/253/4k/astri-lohne-sjursen-eva.jpg?1495573664]
        assert_equal(urls, @site.image_urls)
      end
    end

    context "A work that has been deleted" do
      should "work" do
        url = "https://fiship.artstation.com/projects/x8n8XT"
        site = Sources::Strategies.find(url)

        assert_equal("fiship", site.artist_name)
        assert_equal("https://www.artstation.com/fiship", site.profile_url)
        assert_equal(url, site.page_url)
        assert_equal(url, site.canonical_url)
        assert_nil(site.image_url)
        assert_nothing_raised { site.to_h }
      end
    end

    should "work for artists with underscores in their name" do
      site = Sources::Strategies.find("https://hosi_na.artstation.com/projects/3oEk3B")
      assert_equal("hosi_na", site.artist_name)
    end

    should "work for artists with dashes in their name" do
      site = Sources::Strategies.find("https://sa-dui.artstation.com/projects/DVERn")
      assert_equal("sa-dui", site.artist_name)
    end

    context "normalizing for source" do
      should "normalize correctly" do
        source1 = "https://www.artstation.com/artwork/ghost-in-the-shell-fandom"
        source2 = "https://anubis1982918.artstation.com/projects/qPVGP/"
        source3 = "https://dudeunderscore.artstation.com/projects/NoNmD?album_id=23041"

        assert_equal(source1, Sources::Strategies.normalize_source(source1))
        assert_equal("https://anubis1982918.artstation.com/projects/qPVGP", Sources::Strategies.normalize_source(source2))
        assert_equal("https://dudeunderscore.artstation.com/projects/NoNmD", Sources::Strategies.normalize_source(source3))
      end

      should "avoid normalizing unnormalizable urls" do
        bad_source1 = "http://cdna.artstation.com/p/assets/images/images/005/804/224/large/titapa-khemakavat-sa-dui-srevere.jpg?1493887236"
        bad_source2 = "https://www.artstation.com"
        assert_equal(bad_source1, Sources::Strategies.normalize_source(bad_source1))
        assert_equal(bad_source2, Sources::Strategies.normalize_source(bad_source2))
      end
    end
  end
end
