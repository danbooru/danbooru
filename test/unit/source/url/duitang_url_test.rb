require "test_helper"

module Source::Tests::URL
  class DuitangUrlTest < ActiveSupport::TestCase
    context "Duitang URLs" do
      should be_image_url(
        "https://c-ssl.dtstatic.com/uploads/item/201812/02/20181202220613_cqgwb.jpg",
        "https://a-ssl.dtstatic.com/uploads/blog/202201/10/20220110201344_a992a.jpg",
        "https://c-ssl.dtstatic.com/uploads/item/201812/02/20181202220613_cqgwb.thumb.400_0.jpg",
        "https://img4.duitang.com/uploads/item/201812/02/20181202220613_cqgwb.jpeg",
      )

      should be_page_url(
        "https://www.duitang.com/blog/?id=1026135391",
      )

      should be_profile_url(
        "https://www.duitang.com/people/?id=9044306",
      )

      should parse_url("https://c-ssl.dtstatic.com/uploads/item/201812/02/20181202220613_cqgwb.thumb.400_0.jpg").into(
        full_image_url: "https://c-ssl.dtstatic.com/uploads/item/201812/02/20181202220613_cqgwb.jpg",
      )

      should parse_url("https://c-ssl.dtstatic.com/uploads/avatar/202012/15/20201215234506_75e25.thumb.200_200_c.jpg").into(
        full_image_url: "https://c-ssl.dtstatic.com/uploads/avatar/202012/15/20201215234506_75e25.jpg",
      )

      should parse_url("https://www.duitang.com/blog/?id=1026135391").into(
        page_url: "https://www.duitang.com/blog/?id=1026135391",
      )

      should parse_url("https://www.duitang.com/people/?id=9044306").into(
        profile_url: "https://www.duitang.com/people/?id=9044306",
      )

      should parse_url("https://www.duitang.com/album/?id=81953329").into(
        album_id: "81953329",
        page_url: nil,
      )
    end
  end
end
