require "test_helper"

module Source::Tests::URL
  class SpinspinUrlTest < ActiveSupport::TestCase
    context "SpinSpin URLs" do
      should be_image_url(
        "https://d320v6c020sgby.cloudfront.net/1755495584110.png",
      )

      should be_page_url(
        "https://spin-spin.com/post/68a2bc7a619eacd84fb04cb4",
        "https://spinspin.net/post/68a2bc7a619eacd84fb04cb4",
      )

      should be_profile_url(
        "https://spin-spin.com/UhgMa",
        "https://spin-spin.com/UhgMa/request",
        "https://www.spin-spin.com/UhgMa",
        "https://spinspin.net/UhgMa",
      )

      should_not be_profile_url(
        "https://spin-spin.com",
      )

      should parse_url("https://spin-spin.com/post/68a2bc7a619eacd84fb04cb4").into(
        site_name: "SpinSpin",
        post_id: "68a2bc7a619eacd84fb04cb4",
        page_url: "https://spin-spin.com/post/68a2bc7a619eacd84fb04cb4",
        profile_url: nil,
      )

      should parse_url("https://spinspin.net/post/68a2bc7a619eacd84fb04cb4").into(
        page_url: "https://spin-spin.com/post/68a2bc7a619eacd84fb04cb4",
      )

      should parse_url("https://spinspin.net/UhgMa").into(
        site_name: "SpinSpin",
        username: "UhgMa",
        page_url: nil,
        profile_url: "https://spin-spin.com/UhgMa",
      )

      should parse_url("https://spin-spin.com/UhgMa/gift").into(
        username: "UhgMa",
        profile_url: "https://spin-spin.com/UhgMa",
      )

      should parse_url("https://d320v6c020sgby.cloudfront.net/1755495584110.png").into(
        site_name: "SpinSpin",
        page_url: nil,
        profile_url: nil,
      )
    end
  end
end
