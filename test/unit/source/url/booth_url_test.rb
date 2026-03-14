require "test_helper"

module Source::Tests::URL
  class BoothUrlTest < ActiveSupport::TestCase
    context "Booth URLs" do
      should be_image_url(
        "https://booth.pximg.net/8bb9e4e3-d171-4027-88df-84480480f79d/i/2864768/00cdfef0-e8d5-454b-8554-4885a7e4827d_base_resized.jpg",
        "https://s2.booth.pm/b242a7bd-0747-48c4-891d-9e8552edd5d7/i/3746752/52dbee27-7ad2-4048-9c1d-827eee36625c_base_resized.jpg",
        "https://s.booth.pm/1c9bc77f-8ac1-4fa4-94e5-839772ab72cb/i/750997/774dc881-ce6e-45c6-871b-f6c3ca6914d5.png",
        "https://booth.pximg.net/users/3193929/icon_image/5be9eff4-1d9e-4a79-b097-33c1cd4ad314.png",
        "https://s2.booth.pm/8bb9e4e3-d171-4027-88df-84480480f79d/3d70de06-8e7c-444e-b8eb-a8a95bf20638.png",
      )

      should be_page_url(
        "https://booth.pm/en/items/2864768",
        "https://re-face.booth.pm/items/3435711",
      )

      should be_profile_url(
        "https://re-face.booth.pm",
      )

      should_not be_profile_url(
        "https://www.booth.pm",
        "https://booth.pm",
      )

      should parse_url("https://booth.pximg.net/c/300x300_a2_g5/8bb9e4e3-d171-4027-88df-84480480f79d/i/2864768/00cdfef0-e8d5-454b-8554-4885a7e4827d_base_resized.jpg").into(
        user_uuid: "8bb9e4e3-d171-4027-88df-84480480f79d",
        work_id: "2864768",
        full_image_url: nil,
        candidate_full_image_urls: [
          "https://booth.pximg.net/8bb9e4e3-d171-4027-88df-84480480f79d/i/2864768/00cdfef0-e8d5-454b-8554-4885a7e4827d.png",
          "https://booth.pximg.net/8bb9e4e3-d171-4027-88df-84480480f79d/i/2864768/00cdfef0-e8d5-454b-8554-4885a7e4827d.jpg",
          "https://booth.pximg.net/8bb9e4e3-d171-4027-88df-84480480f79d/i/2864768/00cdfef0-e8d5-454b-8554-4885a7e4827d.jpeg",
        ],
        page_url: "https://booth.pm/en/items/2864768",
        api_url: "https://booth.pm/en/items/2864768.json",
      )

      should parse_url("https://booth.pximg.net/c/128x128/users/3193929/icon_image/5be9eff4-1d9e-4a79-b097-33c1cd4ad314_base_resized.jpg").into(
        user_id: "3193929",
        full_image_url: nil,
        candidate_full_image_urls: [
          "https://booth.pximg.net/users/3193929/icon_image/5be9eff4-1d9e-4a79-b097-33c1cd4ad314.png",
          "https://booth.pximg.net/users/3193929/icon_image/5be9eff4-1d9e-4a79-b097-33c1cd4ad314.jpg",
          "https://booth.pximg.net/users/3193929/icon_image/5be9eff4-1d9e-4a79-b097-33c1cd4ad314.jpeg",
        ],
      )

      should parse_url("https://s2.booth.pm/8bb9e4e3-d171-4027-88df-84480480f79d/3d70de06-8e7c-444e-b8eb-a8a95bf20638_base_resized.jpg").into(
        user_uuid: "8bb9e4e3-d171-4027-88df-84480480f79d",
        full_image_url: nil,
        candidate_full_image_urls: [
          "https://s2.booth.pm/8bb9e4e3-d171-4027-88df-84480480f79d/3d70de06-8e7c-444e-b8eb-a8a95bf20638.png",
          "https://s2.booth.pm/8bb9e4e3-d171-4027-88df-84480480f79d/3d70de06-8e7c-444e-b8eb-a8a95bf20638.jpg",
          "https://s2.booth.pm/8bb9e4e3-d171-4027-88df-84480480f79d/3d70de06-8e7c-444e-b8eb-a8a95bf20638.jpeg",
        ],
      )

      should parse_url("https://re-face.booth.pm/items/3435711").into(
        username: "re-face",
        work_id: "3435711",
        page_url: "https://booth.pm/en/items/3435711",
        api_url: "https://booth.pm/en/items/3435711.json",
        profile_url: "https://re-face.booth.pm",
      )

      should parse_url("https://re-face.booth.pm/item_lists/m4ZTWzb8").into(
        username: "re-face",
        profile_url: "https://re-face.booth.pm",
        api_url: nil,
        candidate_full_image_urls: [],
      )
    end
  end
end
