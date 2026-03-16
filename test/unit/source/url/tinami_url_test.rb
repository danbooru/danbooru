require "test_helper"

module Source::Tests::URL
  class TinamiUrlTest < ActiveSupport::TestCase
    context "Tinami URLs" do
      should be_image_url(
        "https://img.tinami.com/illust/img/287/497c8a9dc60e6.jpg",
        "https://img.tinami.com/comic/naomao/naomao_001_01.jpg",
        "https://www.tinami.com/view/tweet/card/461459",
      )

      should be_page_url(
        "https://www.tinami.com/view/461459",
      )

      should be_profile_url(
        "http://www.tinami.com/creator/profile/1624",
        "https://www.tinami.com/search/list?prof_id=1624",
      )

      should_not be_profile_url(
        "http://www.tinami.com/profile/1182",
      )
    end

    should parse_url("https://img.tinami.com/illust/img/287/497c8a9dc60e6.jpg").into(site_name: "Tinami")
  end
end
