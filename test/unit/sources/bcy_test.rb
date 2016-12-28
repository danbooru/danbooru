require 'test_helper'

module Sources
  class BCYTest < ActiveSupport::TestCase
    def setup
      super
      @record = false
      setup_vcr
    end

    context "bcy.net: fetch source data" do
      setup do
        @work = "http://bcy.net/illust/detail/76491/919312"
        @source = Sources::Site.new(@work)

        cassette = "sources-bcy-test/#{@work.gsub(/[\.:\/]/, "-").gsub(/-+/, "-")}"
        VCR.use_cassette(cassette, :record => @vcr_record_option) { @source.get }

        @artist_name = "Haselnuts"
        @unique_id = "1374009"
        @profile_url = "http://bcy.net/u/1374009"
        @image_url = "http://img9.bcyimg.com/drawer/76491/post/c04f6/c63112f0b12511e691db2d08ae08b1d2.png"
        @image_urls = %w[
          http://img9.bcyimg.com/drawer/76491/post/c04f6/c63112f0b12511e691db2d08ae08b1d2.png
          http://img9.bcyimg.com/drawer/76491/post/c04f6/335aac00b12711e691db2d08ae08b1d2.gif
          http://img9.bcyimg.com/drawer/76491/post/c04f6/33efc010b12711e691db2d08ae08b1d2.jpeg
          http://img9.bcyimg.com/drawer/76491/post/c04f6/342e28a0b12711e691db2d08ae08b1d2.jpg
        ]
        @page_count = 4
        @artcomm_title = "multiple work"
        @artcomm_desc = "test commentary please ignore"
        @tags = [
          %w[东方Project http://bcy.net/circle/index/3771],
          %w[欧美        http://bcy.net/tags/name/欧美],
          %w[黑丝        http://bcy.net/tags/name/黑丝],
          %w[金闪闪      http://bcy.net/illust/listhotcharacter/776],
          ["瓦丝琪", ""],
          ["黑影", ""],
        ]
      end

      should "get the artist name" do
        assert_equal(@artist_name, @source.artist_name)
      end

      should "get the profile url" do
        assert_equal(@profile_url, @source.profile_url)
      end

      should "get the artist id" do
        assert_equal(@unique_id, @source.unique_id)
      end

      should "get the gallery page count" do
        assert_equal(@page_count, @source.page_count)
      end

      should "get the artist commentary title" do
        assert_equal(@artcomm_title, @source.artist_commentary_title)
      end

      should "get the artist commentary description" do
        assert_equal(@artcomm_desc, @source.artist_commentary_desc)
      end

      should "get the tags" do
        assert_equal(@tags, @source.tags)
      end

      should "get the image url" do
        assert_equal(@image_url, @source.image_url)
      end

      should "get the image urls" do
        assert_equal(@image_urls, @source.image_urls)
      end
    end
  end
end
