require 'test_helper'

module Sources
  class NullTest < ActiveSupport::TestCase
    context "A source from an unknown site" do
      setup do
        @site = Sources::Strategies.find("http://oremuhax.x0.com/yoro1603.jpg", "http://oremuhax.x0.com/yo125.htm")
      end

      should "be handled by the null strategy" do
        assert(@site.is_a?(Sources::Strategies::Null))
      end

      should "find the metadata" do
        assert_equal("oremuhax.x0.com", @site.site_name)
        assert_equal(["http://oremuhax.x0.com/yoro1603.jpg"], @site.image_urls)
        assert_equal("http://oremuhax.x0.com/yoro1603.jpg", @site.image_url)
        assert_equal("http://oremuhax.x0.com/yoro1603.jpg", @site.canonical_url)
        assert_equal("", @site.artist_name)
        assert_equal("", @site.profile_url)
        assert_nothing_raised { @site.to_h }
      end

      should "find the artist" do
        a1 = FactoryBot.create(:artist, name: "test1", url_string: "http://oremuhax.x0.com")
        a2 = FactoryBot.create(:artist, name: "test2", url_string: "http://google.com")

        assert_equal([a1], @site.artists)
      end
    end
  end
end
