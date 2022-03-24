require "test_helper"

module Sources
  class FoundationTest < ActiveSupport::TestCase
    context "The source for a Foundation picture" do
      setup do
        @post_url = "https://foundation.app/@dadachyo/~/103724"
        @post_with_video = "https://foundation.app/@huwari/~/88982"
        @image_url = "https://f8n-ipfs-production.imgix.net/QmPhpz6E9TFRpvdVTviM8Hy9o9rxrnPW5Ywj471NnSNkpi/nft.jpg"
        @image1 = Source::Extractor.find(@post_url)
        @image2 = Source::Extractor.find(@image_url)
        @image3 = Source::Extractor.find(@post_with_video)
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
        assert_equal(["https://foundation.app/@dadachyo", "https://foundation.app/0xb4D9073800c7935351ACDC1e46F0CF670853eA99"], @image1.profile_urls)

        assert_equal("https://foundation.app/@huwari", @image3.profile_url)
        assert_equal(["https://foundation.app/@huwari", "https://foundation.app/0xaa2f2eDE4D502F59b3706d2E2dA873C8A00A3d4d"], @image3.profile_urls)
      end

      should "get the image url" do
        assert_equal([@image_url], @image1.image_urls)
        assert_equal([@image_url], @image2.image_urls)
      end

      should "download an image" do
        assert_downloaded(13_908_349, @image1.image_urls.sole)
        assert_downloaded(13_908_349, @image2.image_urls.sole)
        assert_downloaded(13_391_766, @image3.image_urls.sole)
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

    context "for a foundation.app/@username/foo-bar-1234 URL" do
      should "work" do
        page_url = "https://foundation.app/@asuka111art/dinner-with-cats-82426"
        image_url = "https://f8n-ipfs-production.imgix.net/Qma7Lz2LfFb4swoqzr1V43oRGh9xikgigM11g3EukdU61R/nft.png"
        source = Source::Extractor.find(page_url)

        assert_equal("asuka111art", source.artist_name)
        assert_equal(["https://foundation.app/@asuka111art", "https://foundation.app/0x9A94f94626352566e0A9105F1e3DA0439E3e3783"], source.profile_urls)
        assert_equal([image_url], source.image_urls)
        assert_equal(%w[2d anime illustration digital fantasy], source.tags.map(&:first))
      end
    end

    context "for a f8n-production-collection-assets.imgix.net URL" do
      should "work" do
        image_url = "https://f8n-production-collection-assets.imgix.net/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/128711/QmcBfbeCMSxqYB3L1owPAxFencFx3jLzCPFx6xUBxgSCkH/nft.png?q=80&auto=format%2Ccompress&cs=srgb&h=640"
        source = Source::Extractor.find(image_url)

        assert_equal("mochiiimo", source.artist_name)
        assert_equal(["https://foundation.app/@mochiiimo", "https://foundation.app/0x7E2ef75C0C09b2fc6BCd1C68B6D409720CcD58d2"], source.profile_urls)
        assert_equal(["https://f8n-ipfs-production.imgix.net/QmcBfbeCMSxqYB3L1owPAxFencFx3jLzCPFx6xUBxgSCkH/nft.png"], source.image_urls)
        assert_equal(%w[anime landscape girl cat 2d illustration matcrewnft], source.tags.map(&:first))
      end
    end

    context "for a collection" do
      should "get the image urls" do
        assert_equal(
          ["https://f8n-ipfs-production.imgix.net/QmX4MotNAAj9Rcyew43KdgGDxU1QtXemMHoUTNacMLLSjQ/nft.png"],
          Source::Extractor.find("https://foundation.app/@mochiiimo/~/97376").image_urls,
        )

        assert_equal(
          ["https://f8n-ipfs-production.imgix.net/QmX4MotNAAj9Rcyew43KdgGDxU1QtXemMHoUTNacMLLSjQ/nft.png"],
          Source::Extractor.find("https://foundation.app/@mochiiimo/foundation/97376").image_urls,
        )

        assert_equal(
          ["https://f8n-production-collection-assets.imgix.net/0xFb0a8e1bB97fD7231Cd73c489dA4732Ae87995F0/4/nft.png"],
          Source::Extractor.find("https://foundation.app/@KILLERGF/kgfgen/4").image_urls,
        )
      end
    end

    context "non-alphanumeric usernames" do
      should "still work" do
        case1 = Source::Extractor.find("https://foundation.app/@brandon.dalmer/~/6792")
        case2 = Source::Extractor.find("https://foundation.app/@~/~/6792")
        image = "https://f8n-ipfs-production.imgix.net/QmVnpe39qodMjTe8v3fijPfB1tjwhT8hgobtgLPtsangqc/nft.png"
        assert_nothing_raised { case1.to_h }
        assert_nothing_raised { case2.to_h }
        assert_equal([image], case1.image_urls)
        assert_equal([image], case2.image_urls)
      end
    end

    should "parse UTF-8 commentaries correctly" do
      source = Source::Extractor.find("https://foundation.app/@SimaEnaga/~/107338")

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
