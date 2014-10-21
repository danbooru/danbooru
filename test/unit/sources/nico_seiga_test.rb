# encoding: UTF-8

require 'test_helper'

module Sources
  class NicoSeigaTest < ActiveSupport::TestCase
    context "The source site for nico seiga" do
      setup do
        VCR.use_cassette("source-nico-seiga-unit-test-1", :record => :none) do
          @site_1 = Sources::Site.new("http://lohas.nicoseiga.jp/priv/9a7b691a4696cd970e4e762fbb7c07c19b29f22b/1398877469/3329388")
          @site_1.get
        end

        VCR.use_cassette("source-nico-seiga-unit-test-2", :record => :none) do
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
        assert_equal("http://lohas.nicoseiga.jp/priv/63d3abda3e8c613f731869c3ba2c483564f8a2f3/1414023626/3329388", @site_1.image_url)
        assert_equal("http://lohas.nicoseiga.jp/priv/19c9c6504fca0e199c4cfa651475be8b93ab9e59/1414023628/3324796", @site_2.image_url)
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
