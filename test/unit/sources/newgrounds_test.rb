require 'test_helper'

module Sources
  class NewGroundsTest < ActiveSupport::TestCase
    context "The source for a newgrounds picture" do
      setup do
        @url = "https://www.newgrounds.com/art/view/natthelich/d-d-light-domain-cleric-nathaniel-8"
        @image_url = "https://art.ngfiles.com/images/1138000/1138016_natthelich_d-d-light-domain-cleric-nathaniel-8.png?f1578591058"
        @comment = "https://art.ngfiles.com/comments/84000/iu_84427_7115981.jpg"
        @image_1 = Sources::Strategies.find(@url)
        @image_2 = Sources::Strategies.find(@image_url)
        @image_3 = Sources::Strategies.find(@comment, @url)
      end

      should "get the artist name" do
        assert_equal("natthelich", @image_1.artist_name)
        assert_equal("natthelich", @image_2.artist_name)
        assert_equal("natthelich", @image_3.artist_name)
      end

      should "get the artist commentary title" do
        assert_equal("D&D - Light Domain Cleric, Nathaniel", @image_1.artist_commentary_title)
        assert_equal("D&D - Light Domain Cleric, Nathaniel", @image_2.artist_commentary_title)
        assert_equal("D&D - Light Domain Cleric, Nathaniel", @image_3.artist_commentary_title)
      end

      should "get profile url" do
        assert_equal("https://natthelich.newgrounds.com", @image_1.profile_url)
        assert_equal("https://natthelich.newgrounds.com", @image_2.profile_url)
        assert_equal("https://natthelich.newgrounds.com", @image_3.profile_url)
      end

      should "get the image urls" do
        assert_match(%r{https://art.ngfiles.com/images/1138000/1138016_natthelich_d-d-light-domain-cleric-nathaniel-8.png}i, @image_1.image_url)
        assert_includes(@image_1.image_urls, @comment)

        assert_match(%r{https://art.ngfiles.com/images/1138000/1138016_natthelich_d-d-light-domain-cleric-nathaniel-8.png}i, @image_2.image_url)
        assert_equal(@comment, @image_3.image_url)
      end

      should "get the canonical url" do
        assert_equal(@url, @image_1.canonical_url)
        assert_equal(@url, @image_2.canonical_url)
        assert_equal(@url, @image_3.canonical_url)
      end

      should "download an image" do
        assert_downloaded(1195723, @image_1.image_url)
        assert_downloaded(1195723, @image_2.image_url)
        assert_downloaded(158058, @image_3.image_url)
      end

      should "get the tags" do
        tags = [
          %w[cleric https://www.newgrounds.com/search/conduct/art?match=tags&tags=cleric],
          %w[nathaniel https://www.newgrounds.com/search/conduct/art?match=tags&tags=nathaniel],
          %w[oc https://www.newgrounds.com/search/conduct/art?match=tags&tags=oc]
        ]

        assert_equal(tags, @image_1.tags)
        assert_equal(tags, @image_2.tags)
        assert_equal(tags, @image_3.tags)
      end

      should "find the right artist" do
        artist_1 = create(:artist, name: "natthelich1", url_string: "https://natthelich.newgrounds.com/art")
        artist_2 = create(:artist, name: "natthelich2", url_string: "https://www.newgrounds.com/art/view/natthelich/fire-emblem-marth-plus-progress-pic")
        artist_3 = create(:artist, name: "bad_artist", url_string: "https://www.newgrounds.com/art")

        assert_equal([artist_1, artist_2], @image_1.artists)
        assert_equal([artist_1, artist_2], @image_2.artists)
        assert_equal([artist_1, artist_2], @image_3.artists)

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
