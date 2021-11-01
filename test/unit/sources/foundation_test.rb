require "test_helper"

module Sources
  class FoundationTest < ActiveSupport::TestCase
    context "The source for a Foundation picture" do
      setup do
        @post_url = "https://foundation.app/@dadachyo/~/103724"
        @image_url = "https://f8n-ipfs-production.imgix.net/QmPhpz6E9TFRpvdVTviM8Hy9o9rxrnPW5Ywj471NnSNkpi/nft.jpg"
        @image1 = Sources::Strategies.find(@post_url)
        @image2 = Sources::Strategies.find(@image_url)
      end

      should "get the artist name" do
        assert_equal("dadachyo", @image1.artist_name)
      end

      should "get the artist commentary title" do
        assert_equal("Rose tea", @image1.artist_commentary_title)
      end

      should "get profile url" do
        assert_equal("https://foundation.app/@dadachyo", @image1.profile_url)
      end

      should "get the image url" do
        assert_equal(@image_url, @image1.image_url)
        assert_equal(@image_url, @image2.image_url)
      end

      should "download an image" do
        assert_downloaded(13_908_349, @image1.image_url)
        assert_downloaded(13_908_349, @image2.image_url)
      end

      should "find the correct artist" do
        @artist = FactoryBot.create(:artist, name: "dadachyo", url_string: @image1.profile_url)
        assert_equal([@artist], @image1.artists)
      end

      should "not raise errors" do
        assert_nothing_raised { @image1.to_h }
        assert_nothing_raised { @image2.to_h }
      end
    end
  end
end
