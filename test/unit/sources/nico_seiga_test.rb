require 'test_helper'

module Sources
  class NicoSeigaTest < ActiveSupport::TestCase
    context "The source site for nico seiga" do
      setup do
        VCR.use_cassette("source-nico-seiga-unit-test-1", :record => :none) do
          @site_1 = Sources::Site.new("http://lohas.nicoseiga.jp/o/59c833da35d7bc6586a8292103e5e38c9df23b7c/1417762099/4496506")
          @site_1.get
        end

        VCR.use_cassette("source-nico-seiga-unit-test-2", :record => :none) do
          @site_2 = Sources::Site.new("http://seiga.nicovideo.jp/seiga/im4496506")
          @site_2.get
        end
      end

      should "get the profile" do
        assert_equal("http://seiga.nicovideo.jp/user/illust/18302053", @site_1.profile_url)
        assert_equal("http://seiga.nicovideo.jp/user/illust/18302053", @site_2.profile_url)
      end

      should "get the artist name" do
        assert_equal("ポテち", @site_1.artist_name)
        assert_equal("ポテち", @site_2.artist_name)
      end

      should "get the image url" do
        assert_equal("http://lohas.nicoseiga.jp/priv/99d2b59c51e74b93c41cce3ea82137365f88dcff/1417763778/4496506", @site_1.image_url)
        assert_equal("http://lohas.nicoseiga.jp/priv/f28fa72d148505b4f4dc2a72cf5f52d2ecba66b7/1417763873/4496506", @site_2.image_url)
      end

      should "get the tags" do
        assert(@site_1.tags.size > 0)
        first_tag = @site_1.tags.first
        assert_equal(["オリジナル", "http://seiga.nicovideo.jp/tag/%E3%82%AA%E3%83%AA%E3%82%B8%E3%83%8A%E3%83%AB"], first_tag)

        assert(@site_2.tags.size > 0)
        first_tag = @site_2.tags.first
        assert_equal(["オリジナル", "http://seiga.nicovideo.jp/tag/%E3%82%AA%E3%83%AA%E3%82%B8%E3%83%8A%E3%83%AB"], first_tag)
      end

      should "convert a page into a json representation" do
        assert_nothing_raised do
          @site_1.to_json
        end
        assert_nothing_raised do
          @site_2.to_json
        end
      end
    end
  end
end
