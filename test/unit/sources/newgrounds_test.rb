require 'test_helper'

module Sources
  class NewGroundsTest < ActiveSupport::TestCase
    context "The source for a newgrounds picture" do
      setup do
        @url = "https://www.newgrounds.com/art/view/hcnone/sephiroth"
        @image_url = "https://art.ngfiles.com/images/1539000/1539538_hcnone_sephiroth.png?f1607668234"
        @image_1 = Sources::Strategies.find(@url)
        @image_2 = Sources::Strategies.find(@image_url)
      end

      should "get the artist name" do
        assert_equal("hcnone", @image_1.artist_name)
        assert_equal("hcnone", @image_2.artist_name)
      end

      should "get the artist commentary title" do
        assert_equal("Sephiroth", @image_1.artist_commentary_title)
        assert_equal("Sephiroth", @image_2.artist_commentary_title)
      end

      should "get profile url" do
        assert_equal("https://hcnone.newgrounds.com", @image_1.profile_url)
        assert_equal("https://hcnone.newgrounds.com", @image_2.profile_url)
      end

      should "get the image urls" do
        assert_match(@image_url, @image_1.image_url)
        assert_equal(@image_url, @image_2.image_url)
      end

      should "get the canonical url" do
        assert_equal(@url, @image_1.canonical_url)
        assert_equal(@url, @image_2.canonical_url)
      end

      should "download an image" do
        assert_downloaded(4224, @image_1.image_url)
        assert_downloaded(4224, @image_2.image_url)
      end

      should "get the tags" do
        tags = [
          %w[sephiroth https://www.newgrounds.com/search/conduct/art?match=tags&tags=sephiroth],
          %w[supersmashbros https://www.newgrounds.com/search/conduct/art?match=tags&tags=supersmashbros],
        ]

        assert_equal(tags, @image_1.tags)
        assert_equal(tags, @image_2.tags)
      end

      should "find the right artist" do
        artist_1 = create(:artist, name: "hcnone1", url_string: "https://hcnone.newgrounds.com/art")
        artist_2 = create(:artist, name: "hcnone2", url_string: "https://www.newgrounds.com/art/view/hcnone/sephiroth")
        artist_3 = create(:artist, name: "bad_artist", url_string: "https://www.newgrounds.com/art")

        assert_equal([artist_1, artist_2], @image_1.artists)
        assert_equal([artist_1, artist_2], @image_2.artists)

        assert_not_equal([artist_3], @image_1.artists)
      end
    end

    context "A deleted or not existing picture" do
      setup do
        @fake_1 = Sources::Strategies.find("https://www.newgrounds.com/art/view/ThisUser/DoesNotExist")
        @artist_1 = create(:artist, name: "thisuser", url_string: "https://thisuser.newgrounds.com")

        @fake_2 = Sources::Strategies.find("https://www.newgrounds.com/art/view/natthelich/nopicture")
        @artist_2 = create(:artist, name: "natthelich", url_string: "https://natthelich.newgrounds.com")

        @fake_3 = Sources::Strategies.find("https://www.newgrounds.com/art/view/theolebrave/sensitive-pochaco")
        @artist_3 = create(:artist, name: "taffytoad", url_string: "https://taffytoad.newgrounds.com")
      end

      should "still find the artist name" do
        assert_equal("thisuser", @fake_1.artist_name)
        assert_equal([@artist_1], @fake_1.artists)
        assert_equal("https://thisuser.newgrounds.com", @fake_1.profile_url)

        assert_equal("natthelich", @fake_2.artist_name)
        assert_equal([@artist_2], @fake_2.artists)

        assert_equal([@artist_3], @fake_3.artists)
      end
    end

    context "normalizing for source" do
      should "normalize correctly" do
        source = "https://art.ngfiles.com/images/1033000/1033622_natthelich_fire-emblem-marth-plus-progress-pic.png?f1569487181"

        assert_equal("https://www.newgrounds.com/art/view/natthelich/fire-emblem-marth-plus-progress-pic", Sources::Strategies.normalize_source(source))
      end

      should "avoid normalizing unnormalizable urls" do
        bad_source = "https://art.ngfiles.com/comments/57000/iu_57615_7115981.jpg"
        assert_equal(bad_source, Sources::Strategies.normalize_source(bad_source))
      end
    end
  end
end
