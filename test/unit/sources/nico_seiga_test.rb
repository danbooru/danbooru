# encoding: UTF-8

require 'test_helper'

module Sources
  class NicoSeigaTest < ActiveSupport::TestCase
    context "The source site for nico seiga" do
      setup do
        VCR.use_cassette("source-nico-seiga-unit-test-1", :record => :new_episodes) do
          @site_1 = Sources::Site.new("http://lohas.nicoseiga.jp/priv/9a7b691a4696cd970e4e762fbb7c07c19b29f22b/1398877469/3329388")
          @site_1.get
        end

        VCR.use_cassette("source-nico-seiga-unit-test-2", :record => :new_episodes) do
          @site_2 = Sources::Site.new("http://seiga.nicovideo.jp/seiga/im3324796")
          @site_2.get
        end
      end

      should "get the profile" do
        assert_equal("http://seiga.nicovideo.jp/user/illust/17586868", @site_1.profile_url)
        assert_equal("http://seiga.nicovideo.jp/user/illust/341034?target=shunga", @site_2.profile_url)
      end

      should "get the artist name" do
        assert_equal("のちたしん", @site_1.artist_name)
        assert_equal("まから", @site_2.artist_name)
      end

      should "get the image url" do
        assert_equal("http://lohas.nicoseiga.jp/priv/6d168c4fb6eb2f1d522606e961704bd0a9271961/1398887476/3329388", @site_1.image_url)
        assert_equal("http://lohas.nicoseiga.jp/priv/eda0bab8cbab69d6aa884c28f1b1b45c61d88f30/1398887483/3324796", @site_2.image_url)
      end

      should "get the tags" do
        assert(@site_1.tags.size > 0)
        first_tag = @site_1.tags.first
        assert_equal(["ゲーム", "http://seiga.nicovideo.jp/tag/%E3%82%B2%E3%83%BC%E3%83%A0"], first_tag)

        assert(@site_2.tags.size > 0)
        first_tag = @site_2.tags.first
        assert_equal(["R-15", "http://seiga.nicovideo.jp/tag/R-15"], first_tag)
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
