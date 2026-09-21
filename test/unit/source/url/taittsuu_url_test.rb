require "test_helper"

module Source::Tests::URL
  class TaittsuuUrlTest < ActiveSupport::TestCase
    context "Taittsuu URLs" do
      should be_image_url(
        "https://files.taittsuu-media.com/taiitsus/9/9532/8609d69324245020c588483a3a6f34382b01846e4fc2dc09.jpg",
        "https://files.taittsuu-media.com/profiles/94/53323c3e53b84b53d4ed105d55523297a338e4ed2d92f266.jpg?bd5ae6ec60",
      )

      should be_page_url(
        "https://taittsuu.com/users/razukichi/status/9532242",
      )

      should be_profile_url(
        "https://taittsuu.com/users/razukichi",
        "https://taittsuu.com/users/razukichi/",
      )

      should parse_url("https://taittsuu.com/users/razukichi/status/9532242").into(
        username: "razukichi",
        post_id: "9532242",
        page_url: "https://taittsuu.com/users/razukichi/status/9532242",
        profile_url: "https://taittsuu.com/users/razukichi",
      )

      should parse_url("https://taittsuu.com/users/razukichi").into(
        username: "razukichi",
        page_url: nil,
        profile_url: "https://taittsuu.com/users/razukichi",
      )

      should parse_url("https://files.taittsuu-media.com/taiitsus/9/9532/8609d69324245020c588483a3a6f34382b01846e4fc2dc09.jpg").into(
        username: nil,
        page_url: nil,
        profile_url: nil,
      )
    end
  end
end
