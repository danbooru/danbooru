# encoding: UTF-8

require 'test_helper'

module Sources
  class NicoSeigaTest < ActiveSupport::TestCase
    context "The source site for nico seiga" do
      setup do
        VCR.use_cassette("source-nico-seiga-unit-test-1", :record => :new_episodes) do
          @site_1 = Sources::Site.new("http://lohas.nicoseiga.jp/priv/3329388?e=1375906127&h=dc01a9bfc7d1745d700aa8022314b9c3e8c145dd")
        end

        VCR.use_cassette("source-nico-seiga-unit-test-2", :record => :new_episodes) do
          @site_2 = Sources::Site.new("http://seiga.nicovideo.jp/seiga/im3324796")
        end
      end

      should "get the profile" do
        assert_equal("http://seiga.nicovideo.jp/user/illust/17586868", @site_1.profile_url)
        assert_equal("http://seiga.nicovideo.jp/user/illust/341034", @site_2.profile_url)
      end

      should "get the artist name" do
        assert(@site_1.artist_name =~ /./)
        assert(@site_2.artist_name =~ /./)
      end

      should "get the image url" do
        assert_equal("http://lohas.nicoseiga.jp/thumb/3329388i?", @site_1.image_url)
        assert_equal("http://lohas.nicoseiga.jp/thumb/3324796i?", @site_2.image_url)
      end

      should "get the tags" do
        assert(@site_1.tags.size > 0)
        first_tag = @site_1.tags.first
        assert_equal(2, first_tag.size)
        assert(first_tag[0] =~ /./)

        assert(@site_2.tags.size > 0)
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
