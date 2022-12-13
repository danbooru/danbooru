require 'test_helper'

module Sources
  class StashTest < ActiveSupport::TestCase
    def setup
      super
      skip "DeviantArt API keys not set" unless Danbooru.config.deviantart_client_id.present?
    end

    context "A https://sta.sh/:id url" do
      strategy_should_work(
        "https://sta.sh/0wxs31o7nn2",
        image_urls: [%r{\Ahttps://wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/83d3eb4d-13e5-4aea-a08f-8d4331d033c4/dcmga0s-a345a815-2436-4ab5-8941-492011e1bff6.png}],
        page_url: "https://sta.sh/0wxs31o7nn2",
        artist_name: "noizave",
        profile_url: "https://www.deviantart.com/noizave",
        artist_commentary_title: "A pepe",
        artist_commentary_desc: "This is a test."
      )
    end

    context "A https://orig00.deviantart.net/* image url with a https://sta.sh/:id referer" do
      strategy_should_work(
        "https://orig00.deviantart.net/0fd2/f/2018/252/9/c/a_pepe_by_noizave-dcmga0s.png",
        image_urls: [%r{\Ahttps://wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/83d3eb4d-13e5-4aea-a08f-8d4331d033c4/dcmga0s-a345a815-2436-4ab5-8941-492011e1bff6.png}],
        referer: "https://sta.sh/0wxs31o7nn2",
        page_url: "https://sta.sh/0wxs31o7nn2",
        artist_name: "noizave",
        profile_url: "https://www.deviantart.com/noizave",
        artist_commentary_title: "A pepe",
        artist_commentary_desc: "This is a test."
      )
    end

    context "A https://orig00.deviantart.net/* image url without the referer" do
      strategy_should_work(
        "https://orig00.deviantart.net/0fd2/f/2018/252/9/c/a_pepe_by_noizave-dcmga0s.png",
        # if all we have is the image url, then we can't tell that this is really a sta.sh image.
        site_name: "Deviant Art",
        # this is the wrong page, but there's no way to know the correct sta.sh page without the referer.
        page_url: "https://www.deviantart.com/noizave/art/A-Pepe-763305148"
      )
    end
  end
end
