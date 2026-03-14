require "test_helper"

module Source::Tests::URL
  class NewgroundsUrlTest < ActiveSupport::TestCase
    context "Newgrounds URLs" do
      should be_image_url(
        "https://art.ngfiles.com/images/1254000/1254722_natthelich_pandora.jpg",
        "https://art.ngfiles.com/comments/57000/iu_57615_7115981.jpg",
        "https://art.ngfiles.com/thumbnails/1254000/1254985.png?f1588263349",
        "https://art.ngfiles.com/medium_views/5225000/5225108_220662_nanobutts_untitled-5225108.4a602f9525d0d55d8add3dcfb1485507.webp?f1700595860",
        "https://art.ngfiles.com/images/5225000/5225108_220662_nanobutts_untitled-5225108.4a602f9525d0d55d8add3dcfb1485507.webp?f1700595860",
        "https://uploads.ungrounded.net/alternate/1801000/1801343_alternate_165104.mp4?1639666238",
      )

      should be_page_url(
        "https://www.newgrounds.com/art/view/puddbytes/costanza-at-bat",
        "https://www.newgrounds.com/portal/view/830293",
      )

      should be_profile_url(
        "https://natthelich.newgrounds.com",
      )

      should_not be_profile_url(
        "https://www.newgrounds.com",
        "https://newgrounds.com",
      )

      should parse_url("https://art.ngfiles.com/images/1033000/1033622_natthelich_fire-emblem-marth-plus-progress-pic.png?f1569487181").into(
        page_url: "https://www.newgrounds.com/art/view/natthelich/fire-emblem-marth-plus-progress-pic",
      )

      should parse_url("https://art.ngfiles.com/medium_views/5225000/5225108_220662_nanobutts_untitled-5225108.4a602f9525d0d55d8add3dcfb1485507.webp?f1700595860").into(
        page_url: nil,
      )

      should parse_url("https://art.ngfiles.com/images/1254000/1254722_natthelich_pandora.jpg").into(
        page_url: "https://www.newgrounds.com/art/view/natthelich/pandora",
      )

      should parse_url("https://art.ngfiles.com/images/1543000/1543982_natthelich_pandora-2.jpg?f1607971817").into(
        page_url: "https://www.newgrounds.com/art/view/natthelich/pandora-2",
      )
    end
  end
end
