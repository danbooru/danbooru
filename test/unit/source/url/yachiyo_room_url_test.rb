require "test_helper"

module Source::Tests::URL
    class YachiyoRoomUrlTest < ActiveSupport::TestCase
        context "Yachiyo's room URLs" do
            should be_image_url(
                "https://d3icawwrjcmhat.cloudfront.net/prod/oekaki/1774796101015-w8euiu.png",
                "https://d3icawwrjcmhat.cloudfront.net/prod/oekaki/1775314224027-0ql3na.png",
            )

            should be_page_url(
                "https://yachiyo-room.com/oekaki/1059",
                "https://yachiyo-room.com/oekaki/1433",
            )

            should be_profile_url(
                "https://yachiyo-room.com/gallery?name=んぽょ。",
                "https://yachiyo-room.com/gallery?name=んぽょ。&name_mode=exact",
                "https://yachiyo-room.com/gallery?name=んぽょ。&name_mode=exact&from=2026-01-22",
            )

            should_not be_profile_url(
                "https://yachiyo-room.com/gallery?name=んぽょ。&name_mode=like",
                "https://yachiyo-room.com/gallery?name=んぽょ。&name_mode=like&from=2026-01-22",
            )
        end
    end
end
