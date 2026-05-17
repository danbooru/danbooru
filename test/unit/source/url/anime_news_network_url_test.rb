require "test_helper"

module Source::Tests::URL
  class AnimeNewsNetworkUrlTest < ActiveSupport::TestCase
    context "AnimeNewsNetwork URLs" do
      should parse_url("https://www.animenewsnetwork.com/encyclopedia/people.php?id=17056").into(
        site_name: "Anime News Network",
        profile_url: "https://www.animenewsnetwork.com/encyclopedia/people.php?id=17056",
      )
    end
  end
end
