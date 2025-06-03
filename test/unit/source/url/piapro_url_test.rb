require "test_helper"

module Source::Tests::URL
  class PiaproUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://cdn.piapro.jp/thumb_i/w2/w22xmltnyzcsrqxu_20240303200945_0250_0250.png",
          "https://cdn.piapro.jp/thumb_i/74/74w6x4s2s39aag5q_20240325172302_0860_0600.png",
          "https://cdn.piapro.jp/icon_u/626/1485626_20230224204244_0072.jpg",
          "https://dl.piapro.jp/image/w2/w22xmltnyzcsrqxu_20240303200945.png?response-content-disposition=attachment%3B%20filename%2A%3DUTF-8%27%27%25E7%2597%259B%25E3%2581%2584%25E7%2597%259B%25E3%2581%2584%25E7%2597%259B%25E3%2581%2584_nibiirooo__202404301346.png&Expires=1714452547&Signature=j3CPYYLRaTQcQqz6g-zvhOQfIeKnrxRBcxtW6sARJ7xlU3nnfkBAx44RjD6tzfjCH5c~t-50D-A4O9tjWKbRDZI9h3~qbYagz3MYcM-Do-PfMGHaNakpZ51F7fDRby-a7NFou8i4e9HpVJ0By1oTNo650ERbM2FPoZl6thOTfXhFK06pF5yd~lNk2UgaPNQpZJ3Ah4VgRhA~SIWlPkLBIdHjqHTBMtFAKZ-RrNhz3DXphxvAQyuQYjGJCL-UZXYzWGQK5Q73dim0~Y8TTI8eAQdWJLY7rwxtJ5D0zeh1Nue-YA-Tqo-b1mTbvcJrumLAAgT1AwmD~BfiOncRNs4XZw__&Key-Pair-Id=APKAIJPPZV4JCCSOERBA",
        ],
        page_urls: [
          "https://piapro.jp/t/_J0y",
          "http://piapro.jp/t/zXLG/20101206161601",
          "https://piapro.jp/content/w22xmltnyzcsrqxu",
        ],
        profile_urls: [
          "https://piapro.jp/nibiirooo_",
          "https://piapro.jp/my_page/?view=profile&pid=orzkakkokari",
          "https://piapro.jp/my_page/?pid=orzkakkokari",
          "https://piapro.jp/my_page/?piaproId=sakira",
        ],
      )

      should_not_find_false_positives(
        profile_urls: [
          "https://blog.piapro.net/2024/04/g2404291.html",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://cdn.piapro.jp/thumb_i/w2/w22xmltnyzcsrqxu_20240303200945_0250_0250.png",
                             page_url: "https://piapro.jp/content/w22xmltnyzcsrqxu",)

      url_parser_should_work("https://dl.piapro.jp/image/w2/w22xmltnyzcsrqxu_20240303200945.png?response-content-disposition=attachment%3B%20filename%2A%3DUTF-8%27%27%25E7%2597%259B%25E3%2581%2584%25E7%2597%259B%25E3%2581%2584%25E7%2597%259B%25E3%2581%2584_nibiirooo__202404301346.png&Expires=1714452547&Signature=j3CPYYLRaTQcQqz6g-zvhOQfIeKnrxRBcxtW6sARJ7xlU3nnfkBAx44RjD6tzfjCH5c~t-50D-A4O9tjWKbRDZI9h3~qbYagz3MYcM-Do-PfMGHaNakpZ51F7fDRby-a7NFou8i4e9HpVJ0By1oTNo650ERbM2FPoZl6thOTfXhFK06pF5yd~lNk2UgaPNQpZJ3Ah4VgRhA~SIWlPkLBIdHjqHTBMtFAKZ-RrNhz3DXphxvAQyuQYjGJCL-UZXYzWGQK5Q73dim0~Y8TTI8eAQdWJLY7rwxtJ5D0zeh1Nue-YA-Tqo-b1mTbvcJrumLAAgT1AwmD~BfiOncRNs4XZw__&Key-Pair-Id=APKAIJPPZV4JCCSOERBA",
                             page_url: "https://piapro.jp/content/w22xmltnyzcsrqxu",)

      url_parser_should_work("https://piapro.jp/my_page/?view=profile&pid=orzkakkokari",
                             profile_url: "https://piapro.jp/orzkakkokari",)

      url_parser_should_work("https://piapro.jp/my_page/?pid=orzkakkokari",
                             profile_url: "https://piapro.jp/orzkakkokari",)

      url_parser_should_work("https://piapro.jp/my_page/?piaproId=sakira",
                             profile_url: "https://piapro.jp/sakira",)
    end
  end
end
