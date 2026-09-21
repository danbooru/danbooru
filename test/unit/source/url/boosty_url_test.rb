require "test_helper"

module Source::Tests::URL
  class BoostyUrlTest < ActiveSupport::TestCase
    context "Boosty URLs" do
      should be_image_url(
        "https://images.boosty.to/image/ede74f96-b31b-4059-9f8d-8a3dd7314711",
        "https://images.boosty.to/image/ede74f96-b31b-4059-9f8d-8a3dd7314711?change_time=1716964397&mw=80",
        "https://images.boosty.to/image/ede74f96-b31b-4059-9f8d-8a3dd7314711?change_time=1716964397?mw=120&mh=120",
        "https://images.boosty.to/user/9186794/avatar?change_time=1706076492",
        "https://images.boosty.to/blog/9186794/cover?change_time=1768400706",
      )

      should be_page_url(
        "https://boosty.to/rebeccagod/posts/f76e3d79-39b5-42fa-b7a1-0f8dc5261654",
        "https://boosty.to/rebeccagod/blog/media/f76e3d79-39b5-42fa-b7a1-0f8dc5261654/ede74f96-b31b-4059-9f8d-8a3dd7314711",
      )

      should be_profile_url(
        "https://boosty.to/rebeccagod",
        "https://boosty.to/rebeccagod/about",
        "https://boosty.to/rebeccagod/about/media/015d83f0-60d6-4bb2-bd8c-9c211b2c5052?from=about_author",
      )

      should parse_url("https://images.boosty.to/image/ede74f96-b31b-4059-9f8d-8a3dd7314711?change_time=1716964397&mw=80").into(
        image_id: "ede74f96-b31b-4059-9f8d-8a3dd7314711",
        full_image_url: "https://images.boosty.to/image/ede74f96-b31b-4059-9f8d-8a3dd7314711",
      )

      should parse_url("https://images.boosty.to/user/9186794/avatar?change_time=1706076492").into(
        user_id: "9186794",
        full_image_url: "https://images.boosty.to/user/9186794/avatar",
      )

      should parse_url("https://boosty.to/rebeccagod/posts/f76e3d79-39b5-42fa-b7a1-0f8dc5261654").into(
        username: "rebeccagod",
        post_id: "f76e3d79-39b5-42fa-b7a1-0f8dc5261654",
        page_url: "https://boosty.to/rebeccagod/posts/f76e3d79-39b5-42fa-b7a1-0f8dc5261654",
        profile_url: "https://boosty.to/rebeccagod",
      )

      should parse_url("https://boosty.to/rebeccagod/blog/media/f76e3d79-39b5-42fa-b7a1-0f8dc5261654/ede74f96-b31b-4059-9f8d-8a3dd7314711").into(
        username: "rebeccagod",
        post_id: "f76e3d79-39b5-42fa-b7a1-0f8dc5261654",
        image_id: "ede74f96-b31b-4059-9f8d-8a3dd7314711",
        page_url: "https://boosty.to/rebeccagod/posts/f76e3d79-39b5-42fa-b7a1-0f8dc5261654",
      )

      should parse_url("https://boosty.to/rebeccagod").into(
        username: "rebeccagod",
        profile_url: "https://boosty.to/rebeccagod",
        page_url: nil,
      )
    end
  end
end
