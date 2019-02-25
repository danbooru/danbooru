require 'test_helper'

module Sources
  class NicoSeigaTest < ActiveSupport::TestCase
    context "The source site for nico seiga" do
      setup do
        @site = Sources::Strategies.find("http://seiga.nicovideo.jp/watch/mg316708", "http://seiga.nicovideo.jp/watch/mg316708")
      end

      should "find the image urls" do
        assert_equal(["https://seiga.nicovideo.jp/image/source/8100968", "https://seiga.nicovideo.jp/image/source/8100969", "https://seiga.nicovideo.jp/image/source/8100970", "https://seiga.nicovideo.jp/image/source/8100971", "https://seiga.nicovideo.jp/image/source/8100972", "https://seiga.nicovideo.jp/image/source/8100973", "https://seiga.nicovideo.jp/image/source/8100974", "https://seiga.nicovideo.jp/image/source/8100975"], @site.image_urls)
      end

      should "find the page url" do
        assert_equal("http://seiga.nicovideo.jp/watch/mg316708", @site.page_url)
      end

      should "find the artist name" do
        assert_not_nil(@site.artist_name)
      end
    end
  end
end
