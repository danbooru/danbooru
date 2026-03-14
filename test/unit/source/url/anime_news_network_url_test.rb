require "test_helper"

module Source::Tests::URL
  class AnimeNewsNetworkUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should "set the profile url" do
        url = Source::URL.parse("https://www.animenewsnetwork.com/encyclopedia/people.php?id=17056")
        assert_equal("Anime News Network", url.site_name)
        assert_equal("https://www.animenewsnetwork.com/encyclopedia/people.php?id=17056", url.profile_url)
      end
    end
  end
end
