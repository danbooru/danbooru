require 'test_helper'

module Sources
  class NicoSeigaTest < ActiveSupport::TestCase
    def setup
      super
      setup_vcr
    end

    context "The source site for nico seiga" do
      setup do
        VCR.use_cassette("source-nico-seiga-unit-test-1", :record => :once) do
          @site_1 = Sources::Site.new("http://lohas.nicoseiga.jp/o/910aecf08e542285862954017f8a33a8c32a8aec/1433298801/4937663")
          @site_1.get
        end

        VCR.use_cassette("source-nico-seiga-unit-test-2", :record => :once) do
          @site_2 = Sources::Site.new("http://seiga.nicovideo.jp/seiga/im4937663")
          @site_2.get
        end
      end

      should "get the profile" do
        assert_equal("http://seiga.nicovideo.jp/user/illust/7017777", @site_1.profile_url)
        assert_equal("http://seiga.nicovideo.jp/user/illust/7017777", @site_2.profile_url)
      end

      should "get the artist name" do
        assert_equal("osamari", @site_1.artist_name)
        assert_equal("osamari", @site_2.artist_name)
      end

      should "get the image url" do
        assert_equal("http://lohas.nicoseiga.jp/priv/a5965feac9374c83b5b43b571c7ab1ddd1969f70/1464467609/4937663", @site_1.image_url)
        assert_equal("http://lohas.nicoseiga.jp/priv/4d8c2bd54c2b0bd57935b966dd64166a5d1c148a/1464467611/4937663", @site_2.image_url)
      end

      should "get the tags" do
        assert(@site_1.tags.size > 0)
        first_tag = @site_1.tags.first
        assert_equal(["アニメ", "http://seiga.nicovideo.jp/tag/%E3%82%A2%E3%83%8B%E3%83%A1"], first_tag)

        assert(@site_2.tags.size > 0)
        first_tag = @site_2.tags.first
        assert_equal(["アニメ", "http://seiga.nicovideo.jp/tag/%E3%82%A2%E3%83%8B%E3%83%A1"], first_tag)
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
