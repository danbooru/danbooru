# encoding: UTF-8

require 'test_helper'

module Sources
  class NicoSeigaTest < ActiveSupport::TestCase
    context "The source site for nico seiga" do
      setup do
        # Sources::Strategies::NicoSeiga.new("http://lohas.nicoseiga.jp/priv/2853566?e=1361296671&h=794b3686b02edfd64c22ed2f99a4c55650371854")
        @site = Sources::Site.new("http://seiga.nicovideo.jp/seiga/im1464351?track=ranking")
        @site.get
      end

      should "get the profile" do
        assert_equal("http://seiga.nicovideo.jp/user/illust/20446930?target=seiga", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("rariemonn", @site.artist_name)
      end

      should "get the image url" do
        assert_equal("http://seiga.nicovideo.jp/image/source?id=1464351", @site.image_url)
      end

      should "get the tags" do
        assert(@site.tags.size > 0)
        first_tag = @site.tags.first
        assert_equal(2, first_tag.size)
        assert(first_tag[0] =~ /./)
      end

      should "convert a page into a json representation" do
        assert_nothing_raised do
          @site.to_json
        end
      end
    end
  end
end
