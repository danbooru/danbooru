require 'test_helper'

module Sources
  class NicoSeigaTest < ActiveSupport::TestCase
    def setup
      super
      @record = false
      setup_vcr
    end

    context "The source site for nico seiga" do
      setup do
        VCR.use_cassette("sources-nico-test/1", :record => @vcr_record_option) do
          @site_1 = Sources::Site.new("http://lohas.nicoseiga.jp/o/910aecf08e542285862954017f8a33a8c32a8aec/1433298801/4937663")
          @site_1.get
        end

        VCR.use_cassette("sources-nico-test/2", :record => @vcr_record_option) do
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
        assert_match(/^http:\/\/lohas\.nicoseiga\.jp\/priv\//, @site_1.image_url)
        assert_match(/^http:\/\/lohas\.nicoseiga\.jp\/priv\//, @site_2.image_url)
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
