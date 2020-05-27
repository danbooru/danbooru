require 'test_helper'

module Sources
  class HentaiFoundryTest < ActiveSupport::TestCase
    context "The source for a hentai foundry picture" do
      setup do
        @image_1 = Sources::Strategies.find("https://www.hentai-foundry.com/pictures/user/Afrobull/795025/kuroeda")
        @image_2 = Sources::Strategies.find("https://pictures.hentai-foundry.com/a/Afrobull/795025/Afrobull-795025-kuroeda.png")
      end

      should "get the illustration id" do
        assert_equal("795025", @image_1.illust_id)
        assert_equal("795025", @image_2.illust_id)
      end

      should "get the artist name" do
        assert_equal("Afrobull", @image_1.artist_name)
        assert_equal("Afrobull", @image_2.artist_name)
      end

      should "get the artist commentary title" do
        assert_equal("kuroeda", @image_1.artist_commentary_title)
        assert_equal("kuroeda", @image_2.artist_commentary_title)
      end

      should "get profile url" do
        assert_equal("https://www.hentai-foundry.com/user/Afrobull", @image_1.profile_url)
        assert_equal("https://www.hentai-foundry.com/user/Afrobull", @image_2.profile_url)
      end

      should "get the image url" do
        assert_equal("https://pictures.hentai-foundry.com/a/Afrobull/795025/Afrobull-795025-kuroeda.png", @image_1.image_url)
        assert_equal("https://pictures.hentai-foundry.com/a/Afrobull/795025/Afrobull-795025-kuroeda.png", @image_2.image_url)
      end

      should "get the canonical url" do
        assert_equal("https://pictures.hentai-foundry.com/a/Afrobull/795025/Afrobull-795025-kuroeda.png", @image_1.canonical_url)
        assert_equal("https://pictures.hentai-foundry.com/a/Afrobull/795025/Afrobull-795025-kuroeda.png", @image_2.canonical_url)
      end

      should "download an image" do
        assert_downloaded(1_349_887, @image_1.image_url)
        assert_downloaded(1_349_887, @image_2.image_url)
      end

      should "get the tags" do
        assert_equal([["elf", "https://www.hentai-foundry.com/search/index?query=elf&search_in=keywords"]], @image_1.tags)
        assert_equal([["elf", "https://www.hentai-foundry.com/search/index?query=elf&search_in=keywords"]], @image_2.tags)
      end

      should "find the correct artist" do
        @artist = FactoryBot.create(:artist, name: "Afrobull", url_string: @image_1.url)
        assert_equal([@artist], @image_1.artists)
        assert_equal([@artist], @image_2.artists)
      end
    end

    context "An artist profile url" do
      setup do
        @site = Sources::Strategies.find("https://www.hentai-foundry.com/user/Afrobull/profile")
      end

      should "get the profile url" do
        assert_equal("https://www.hentai-foundry.com/user/Afrobull", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("Afrobull", @site.artist_name)
      end

      should "get the normalized url" do
        assert_equal("https://www.hentai-foundry.com/user/Afrobull", @site.normalize_for_artist_finder)
      end
    end

    context "A deleted picture" do
      setup do
        @image = Sources::Strategies.find("https://www.hentai-foundry.com/pictures/user/faustsketcher/279498")
        @artist = FactoryBot.create(:artist, name: "faustsketcher", url_string: @image.url)
      end

      should "still find the artist name" do
        assert_equal("faustsketcher", @image.artist_name)
        assert_equal("https://www.hentai-foundry.com/user/faustsketcher", @image.profile_url)
        assert_equal([@artist], @image.artists)
      end
    end

    context "normalizing for source" do
      should "normalize correctly" do
        source1 = "http://pictures.hentai-foundry.com//a/AnimeFlux/219123.jpg"
        source2 = "http://pictures.hentai-foundry.com/a/AnimeFlux/219123/Mobile-Suit-Equestria-rainbow-run.jpg"
        source3 = "http://www.hentai-foundry.com/pictures/user/Ganassa/457176/LOL-Swimsuit---Caitlyn-reworked-nude-ver."

        assert_equal("https://www.hentai-foundry.com/pictures/user/AnimeFlux/219123", Sources::Strategies.normalize_source(source1))
        assert_equal("https://www.hentai-foundry.com/pictures/user/AnimeFlux/219123", Sources::Strategies.normalize_source(source2))
        assert_equal("https://www.hentai-foundry.com/pictures/user/Ganassa/457176", Sources::Strategies.normalize_source(source3))
      end

      should "avoid normalizing unnormalizable urls" do
        bad_source = "https://pictures.hentai-foundry.com/a/AnimeFlux"
        assert_equal(bad_source, Sources::Strategies.normalize_source(bad_source))
      end
    end
  end
end
