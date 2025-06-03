require "test_helper"

module Source::Tests::URL
  class NewgroundsUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://art.ngfiles.com/images/1254000/1254722_natthelich_pandora.jpg",
          "https://art.ngfiles.com/comments/57000/iu_57615_7115981.jpg",
          "https://art.ngfiles.com/thumbnails/1254000/1254985.png?f1588263349",
          "https://art.ngfiles.com/medium_views/5225000/5225108_220662_nanobutts_untitled-5225108.4a602f9525d0d55d8add3dcfb1485507.webp?f1700595860",
          "https://art.ngfiles.com/images/5225000/5225108_220662_nanobutts_untitled-5225108.4a602f9525d0d55d8add3dcfb1485507.webp?f1700595860",
          "https://uploads.ungrounded.net/alternate/1801000/1801343_alternate_165104.mp4?1639666238",
        ],
        page_urls: [
          "https://www.newgrounds.com/art/view/puddbytes/costanza-at-bat",
          "https://www.newgrounds.com/portal/view/830293",
        ],
        profile_urls: [
          "https://natthelich.newgrounds.com",
        ],
      )

      should_not_find_false_positives(
        profile_urls: [
          "https://www.newgrounds.com",
          "https://newgrounds.com",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://art.ngfiles.com/images/1033000/1033622_natthelich_fire-emblem-marth-plus-progress-pic.png?f1569487181",
                             page_url: "https://www.newgrounds.com/art/view/natthelich/fire-emblem-marth-plus-progress-pic",)

      url_parser_should_work("https://art.ngfiles.com/medium_views/5225000/5225108_220662_nanobutts_untitled-5225108.4a602f9525d0d55d8add3dcfb1485507.webp?f1700595860",
                             page_url: nil,)

      url_parser_should_work("https://art.ngfiles.com/images/1254000/1254722_natthelich_pandora.jpg",
                             page_url: "https://www.newgrounds.com/art/view/natthelich/pandora",)

      url_parser_should_work("https://art.ngfiles.com/images/1543000/1543982_natthelich_pandora-2.jpg?f1607971817",
                             page_url: "https://www.newgrounds.com/art/view/natthelich/pandora-2",)
    end
  end
end
