require "test_helper"

module Source::Tests::URL
  class HuashijieUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://bsyimg.pandapaint.net/v2/work_cover/user/13649297/1714634091547.jpg",
          "https://bsyimgv2.pandapaint.net/v2/work_cover/user/14619015/1727160145437.jpg",
          "https://bsyimgv2.pandapaint.net/v2/work_cover/user/14619015/1713709783854.jpg?image_process=format,WEBP",
          "https://bsyimgv2.pandapaint.net/v2/album_cover/user/17873127/1736262275939.png?x-oss-process=style/work_cover&image_process=format,WEBP",
        ],
        page_urls: [
          "https://www.huashijie.art/work/detail/237016516",
          "https://huashijie.art/work/detail/237016516",
          "https://static.huashijie.art/w_d/235129335",
          "https://static.huashijie.art/hsj/wap/#/detail?workId=235129335",
        ],
        profile_urls: [
          "https://www.huashijie.art/user/index/13649297",
          "https://static.huashijie.art/hsj/wap/#/usercenter?userId=13649297",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work(
        "https://huashijie.art/work/detail/237016516",
        page_url: "https://www.huashijie.art/work/detail/237016516",
      )

      url_parser_should_work(
        "https://static.huashijie.art/w_d/235129335",
        page_url: "https://www.huashijie.art/work/detail/235129335",
      )

      url_parser_should_work(
        "https://static.huashijie.art/hsj/wap/#/detail?workId=235129335",
        page_url: "https://www.huashijie.art/work/detail/235129335",
      )

      url_parser_should_work(
        "https://static.huashijie.art/hsj/wap/#/usercenter?userId=13649297",
        profile_url: "https://www.huashijie.art/user/index/13649297",
      )

      url_parser_should_work(
        "https://bsyimgv2.pandapaint.net/v2/work_cover/user/14619015/1713709783854.jpg?image_process=format,WEBP",
        full_image_url: "https://bsyimgv2.pandapaint.net/v2/work_cover/user/14619015/1713709783854.jpg",
      )
      url_parser_should_work(
        "https://bsyimgv2.pandapaint.net/v2/album_cover/user/17873127/1736262275939.png?x-oss-process=style/work_cover&image_process=format,WEBP",
        full_image_url: "https://bsyimgv2.pandapaint.net/v2/album_cover/user/17873127/1736262275939.png",
      )
      url_parser_should_work(
        "https://bsyimg.pandapaint.net/v2/work_cover/user/13649297/1714634091547.jpg",
        full_image_url: "https://bsyimg.pandapaint.net/v2/work_cover/user/13649297/1714634091547.jpg",
      )
    end
  end
end
