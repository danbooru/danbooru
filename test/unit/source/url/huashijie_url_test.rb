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
          "https://bsyimg.pandapaint.net/v2/pd_cover/public/1749455200182.png",
          "https://bsyimgv2.pandapaint.net/v2/pd_cover/public/1749455200182.png?x-oss-process=style/work_cover&image_process=format,WEBP",
          "https://bsyimg.pandapaint.net/background/2020/02/03/3bf1e9b0f9174e5a8be3631f3053dc25.jpg",
          "https://bsyimgv2.pandapaint.net/avatar/2020/12/10/7c417b5b730c47f083a631d6bdf424ce.jpg?x-oss-process=style/work_cover_med&image_process=format,WEBP",
        ],
        page_urls: [
          "https://www.huashijie.art/work/detail/237016516",
          "https://huashijie.art/work/detail/237016516",
          "https://static.huashijie.art/w_d/235129335",
          "https://static.pandapaint.net/w_d/235129335",
          "https://static.huashijie.art/hsj/wap/#/detail?workId=235129335",
          "https://www.huashijie.art/market/detail/325593",
          "https://static.huashijie.art/s_pd/325923",
          "https://static.huashijie.art/newmarket/#/product/detail/325923",
          "https://static.huashijie.art/newmarket/?share=1&navbar=0#/product/detail/325923",
          "https://static.huashijie.art/newmarket/?share=1&navbar=0#/product/ratedetail/325987",
        ],
        profile_urls: [
          "https://www.huashijie.art/user/index/13649297",
          "https://static.huashijie.art/hsj/wap/#/usercenter?userId=13649297",
          "https://static.pandapaint.net/pagesart/wap/#/usercenter?userId=13649297",
          "https://www.huashijie.art/user/shop/2381713",
          "https://static.huashijie.art/newmarket/#/usercenter/9780156",
          "https://static.huashijie.art/newmarket/?navbar=0&swapeback=0#/usercenter/9780156?share=1",
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
        "https://static.huashijie.art/s_pd/325923",
        page_url: "https://www.huashijie.art/market/detail/325923",
      )
      url_parser_should_work(
        "https://static.huashijie.art/newmarket/#/product/detail/325923",
        page_url: "https://www.huashijie.art/market/detail/325923",
      )
      url_parser_should_work(
        "https://static.huashijie.art/newmarket/?share=1&navbar=0#/product/detail/325923",
        page_url: "https://www.huashijie.art/market/detail/325923",
      )

      url_parser_should_work(
        "https://static.huashijie.art/hsj/wap/#/usercenter?userId=13649297",
        profile_url: "https://www.huashijie.art/user/index/13649297",
      )
      url_parser_should_work(
        "https://static.huashijie.art/newmarket/#/usercenter/9780156",
        profile_url: "https://www.huashijie.art/user/index/9780156",
      )
      url_parser_should_work(
        "https://static.huashijie.art/newmarket/?navbar=0&swapeback=0#/usercenter/9780156?share=1",
        profile_url: "https://www.huashijie.art/user/index/9780156",
      )

      url_parser_should_work(
        "https://bsyimgv2.pandapaint.net/v2/work_cover/user/14619015/1713709783854.jpg?image_process=format,WEBP",
        full_image_url: "https://bsyimgv2.pandapaint.net/v2/work_cover/user/14619015/1713709783854.jpg",
        profile_url: "https://www.huashijie.art/user/index/14619015",
      )
      url_parser_should_work(
        "https://bsyimgv2.pandapaint.net/v2/album_cover/user/17873127/1736262275939.png?x-oss-process=style/work_cover&image_process=format,WEBP",
        full_image_url: "https://bsyimgv2.pandapaint.net/v2/album_cover/user/17873127/1736262275939.png",
        profile_url: "https://www.huashijie.art/user/index/17873127",
      )
      url_parser_should_work(
        "https://bsyimg.pandapaint.net/v2/work_cover/user/13649297/1714634091547.jpg",
        full_image_url: "https://bsyimg.pandapaint.net/v2/work_cover/user/13649297/1714634091547.jpg",
        profile_url: "https://www.huashijie.art/user/index/13649297",
      )
      url_parser_should_work(
        "https://bsyimgv2.pandapaint.net/v2/pd_cover/public/1749455200182.png?x-oss-process=style/work_cover&image_process=format,WEBP",
        full_image_url: "https://bsyimgv2.pandapaint.net/v2/pd_cover/public/1749455200182.png",
      )
    end
  end
end
