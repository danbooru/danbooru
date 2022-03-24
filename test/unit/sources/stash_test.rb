require 'test_helper'

module Sources
  class StashTest < ActiveSupport::TestCase
    def setup
      super
      skip "DeviantArt API keys not set" unless Danbooru.config.deviantart_client_id.present?
    end

    context "A https://sta.sh/:id page url" do
      should "work" do
        @site = Sources::Strategies.find("https://sta.sh/0wxs31o7nn2")

        assert_equal("noizave", @site.artist_name)
        assert_equal("https://www.deviantart.com/noizave", @site.profile_url)

        assert_equal("A pepe", @site.artist_commentary_title)
        assert_equal("This is a test.", @site.artist_commentary_desc)

        assert_equal("https://sta.sh/0wxs31o7nn2", @site.page_url)
        assert_match("https://wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/83d3eb4d-13e5-4aea-a08f-8d4331d033c4/dcmga0s-a345a815-2436-4ab5-8941-492011e1bff6.png", @site.image_urls.sole)
      end
    end

    context "A https://orig00.deviantart.net/* image url" do
      context "with a https://sta.sh/:id referer" do
        should "work" do
          @site = Sources::Strategies.find("https://orig00.deviantart.net/0fd2/f/2018/252/9/c/a_pepe_by_noizave-dcmga0s.png", "https://sta.sh/0wxs31o7nn2")

          assert_equal("noizave", @site.artist_name)
          assert_equal("https://www.deviantart.com/noizave", @site.profile_url)

          assert_equal("A pepe", @site.artist_commentary_title)
          assert_equal("This is a test.", @site.artist_commentary_desc)

          assert_equal("https://sta.sh/0wxs31o7nn2", @site.page_url)
          assert_match("https://wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/83d3eb4d-13e5-4aea-a08f-8d4331d033c4/dcmga0s-a345a815-2436-4ab5-8941-492011e1bff6.png", @site.image_urls.sole)
        end
      end

      context "without a referer" do
        should "use the base deviantart strategy" do
          @site = Sources::Strategies.find("https://orig00.deviantart.net/0fd2/f/2018/252/9/c/a_pepe_by_noizave-dcmga0s.png")

          # if all we have is the image url, then we can't tell that this is really a sta.sh image.
          assert_equal("Deviant Art", @site.site_name)

          # this is the wrong page, but there's no way to know the correct sta.sh page without the referer.
          assert_equal("https://www.deviantart.com/noizave/art/A-Pepe-763305148", @site.page_url)
        end
      end
    end
  end
end
