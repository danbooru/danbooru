require "test_helper"

module Sources
  class FoundationTest < ActiveSupport::TestCase
    context "The source for a Foundation picture" do
      setup do
        @post_url = "https://foundation.app/@dadachyo/~/103724"
        @post_with_video = "https://foundation.app/@huwari/~/88982"
        @image_url = "https://f8n-ipfs-production.imgix.net/QmPhpz6E9TFRpvdVTviM8Hy9o9rxrnPW5Ywj471NnSNkpi/nft.jpg"
        @image1 = Sources::Strategies.find(@post_url)
        @image2 = Sources::Strategies.find(@image_url)
        @image3 = Sources::Strategies.find(@post_with_video)
      end

      should "get the artist name" do
        assert_equal("dadachyo", @image1.artist_name)
        assert_equal("huwari", @image3.artist_name)
      end

      should "get the artist commentary title" do
        assert_equal("Rose tea", @image1.artist_commentary_title)
        assert_equal("bus", @image3.artist_commentary_title)
      end

      should "get profile url" do
        assert_equal("https://foundation.app/@dadachyo", @image1.profile_url)
        assert_equal("https://foundation.app/@huwari", @image3.profile_url)
      end

      should "get the image url" do
        assert_equal(@image_url, @image1.image_url)
        assert_equal(@image_url, @image2.image_url)
      end

      should "download an image" do
        assert_downloaded(13_908_349, @image1.image_url)
        assert_downloaded(13_908_349, @image2.image_url)
        assert_downloaded(13_391_766, @image3.image_url)
      end

      should "find the correct artist" do
        @artist = FactoryBot.create(:artist, name: "dadachyo", url_string: @image1.profile_url)
        assert_equal([@artist], @image1.artists)
      end

      should "not raise errors" do
        assert_nothing_raised { @image1.to_h }
        assert_nothing_raised { @image2.to_h }
        assert_nothing_raised { @image3.to_h }
      end
    end

    context "for a collection" do
      should "get the image urls" do
        assert_equal(
          ["https://f8n-ipfs-production.imgix.net/QmX4MotNAAj9Rcyew43KdgGDxU1QtXemMHoUTNacMLLSjQ/nft.png"],
          Sources::Strategies.find("https://foundation.app/@mochiiimo/~/97376").image_urls,
        )

        assert_equal(
          ["https://f8n-ipfs-production.imgix.net/QmX4MotNAAj9Rcyew43KdgGDxU1QtXemMHoUTNacMLLSjQ/nft.png"],
          Sources::Strategies.find("https://foundation.app/@mochiiimo/foundation/97376").image_urls,
        )

        assert_equal(
          ["https://f8n-production-collection-assets.imgix.net/0xFb0a8e1bB97fD7231Cd73c489dA4732Ae87995F0/4/nft.png"],
          Sources::Strategies.find("https://foundation.app/@KILLERGF/kgfgen/4").image_urls,
        )
      end
    end

    context "non-alphanumeric usernames" do
      should "still work" do
        case1 = Sources::Strategies.find("https://foundation.app/@brandon.dalmer/~/6792")
        case2 = Sources::Strategies.find("https://foundation.app/@~/~/6792")
        image = "https://f8n-ipfs-production.imgix.net/QmVnpe39qodMjTe8v3fijPfB1tjwhT8hgobtgLPtsangqc/nft.png"
        assert_nothing_raised { case1.to_h }
        assert_nothing_raised { case2.to_h }
        assert_equal(image, case1.image_url)
        assert_equal(image, case2.image_url)
      end
    end

    should "parse UTF-8 commentaries correctly" do
      source = Sources::Strategies.find("https://foundation.app/@SimaEnaga/~/107338")

      assert_equal(<<~EOS, source.dtext_artist_commentary_desc)
        【須佐之男尊/Susanoo-no-Mikoto】
        He is the youngest child of the three brothers and has older sister "Amaterasu" and older brother "Tsukuyomi". They are children whose father is "Izanagi" and mother is "Izanami".They live in the Land of gods known as "Takamagahara".
        He carried out a number of violence and caused trouble to people.
        As a result, he was expelled from Takamagahara and moved to the human world.

        【Meaning】
        There is a theory that "須佐/susa" is a word
        that means "凄まじい/susamajii (tremendous)" in Japanese.
        ”之/no” is  a conjunction "of".
        “男/o” means ”male”.
        ”尊/mikoto” is a word that after the name of a god or a noble (Lord; Highness).
        Colloquially, "The crazy guy." lol

        【Concept】
        He carries the bronze sword “Kusanagi-no Tsurugi”. This is one of the "three sacred treasures" and is the most famous sword in Japan. “Kusanagi-no Tsurugi” is dedicated to Atsuta Shrine in Aichi Prefecture, Japan.
        The sword  is now sealed and no one has seen it.

      EOS
    end
  end
end
