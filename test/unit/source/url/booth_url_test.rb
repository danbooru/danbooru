require "test_helper"

module Source::Tests::URL
  class BoothUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://booth.pximg.net/8bb9e4e3-d171-4027-88df-84480480f79d/i/2864768/00cdfef0-e8d5-454b-8554-4885a7e4827d_base_resized.jpg",
          "https://s2.booth.pm/b242a7bd-0747-48c4-891d-9e8552edd5d7/i/3746752/52dbee27-7ad2-4048-9c1d-827eee36625c_base_resized.jpg",
          "https://s.booth.pm/1c9bc77f-8ac1-4fa4-94e5-839772ab72cb/i/750997/774dc881-ce6e-45c6-871b-f6c3ca6914d5.png",
          "https://booth.pximg.net/users/3193929/icon_image/5be9eff4-1d9e-4a79-b097-33c1cd4ad314.png",
          "https://s2.booth.pm/8bb9e4e3-d171-4027-88df-84480480f79d/3d70de06-8e7c-444e-b8eb-a8a95bf20638.png",
        ],
        page_urls: [
          "https://booth.pm/en/items/2864768",
          "https://re-face.booth.pm/items/3435711",
        ],
        profile_urls: [
          "https://re-face.booth.pm",
        ],
      )

      should_not_find_false_positives(
        profile_urls: [
          "https://www.booth.pm",
          "https://booth.pm",
        ],
      )
    end
  end
end
