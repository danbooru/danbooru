require "test_helper"

module Source::Tests::URL
  class CiEnUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://media.ci-en.jp/private/attachment/creator/00011019/62a643d6423c18ec1be16826d687cefb47d8304de928a07c6389f8188dfe6710/image-800.jpg?px-time=1700517240&px-hash=eb626eafb7e5733c96fb0891188848dac10cb84c",
          "https://media.ci-en.jp/private/attachment/creator/00011019/62a643d6423c18ec1be16826d687cefb47d8304de928a07c6389f8188dfe6710/upload/%E3%81%B0%E3%81%AB%E3%81%A3%E3%81%A1A.jpg?px-time=1700517240&px-hash=eb626eafb7e5733c96fb0891188848dac10cb84c",
          "https://media.ci-en.jp/public/article_cover/creator/00020980/a65e3c05e2082018f4f28e99e7bc69b67ae96bb6f40b4a4b580ca939f435430d/image-1280-c.jpg",
          "https://media.ci-en.jp/public/cover/creator/00013341/cc4ec0e58b9ad36c8f36aca9faee334239761b4b2969d379d6629a5e07a52a6c/image-990-c.jpg",
        ],
        page_urls: [
          "https://ci-en.jp/creator/922/article/23700",
          "https://ci-en.net/creator/11019/article/921762",
          "https://ci-en.dlsite.com/creator/5290/article/998146",
          "https://ci-en.jp/creator/922",
          "https://ci-en.net/creator/11019",
          "https://ci-en.dlsite.com/creator/5290",
          "https://ci-en.net/creator/11019/article/",
        ],
        profile_urls: [
          "https://ci-en.jp/creator/922",
          "https://ci-en.net/creator/11019",
          "https://ci-en.dlsite.com/creator/5290",
          "https://ci-en.net/creator/11019/article/",
        ],
      )

      should_not_find_false_positives(
        page_urls: [
          "https://media.ci-en.jp/private/attachment/creator/00011019/62a643d6423c18ec1be16826d687cefb47d8304de928a07c6389f8188dfe6710/image-web.jpg?px-time=1703968668&px-hash=9497dce5fa56c5081413ad1126e06d6f44f0ab3e",
          "https://media.ci-en.jp/public/cover/creator/00011019/ae96c79d7626c8127bfe9823111601d3b566977d19c3aa0409de4ef838f8dc12/image-990-c.jpg",
        ],
        profile_urls: [
          "https://ci-en.jp/creator/922/article/23700",
          "https://ci-en.net/creator/11019/article/921762",
          "https://ci-en.dlsite.com/creator/5290/article/998146",
          "https://ci-en.net/creator",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://ci-en.dlsite.com/creator/5290", page_url: "https://ci-en.net/creator/5290", profile_url: "https://ci-en.net/creator/5290")
      url_parser_should_work("https://ci-en.dlsite.com/creator/5290/article/998146", page_url: "https://ci-en.net/creator/5290/article/998146")

      url_parser_should_work("https://ci-en.jp/creator/922", page_url: "https://ci-en.net/creator/922", profile_url: "https://ci-en.net/creator/922")
      url_parser_should_work("https://ci-en.jp/creator/922/article/23700", page_url: "https://ci-en.net/creator/922/article/23700")

      url_parser_should_work("https://ci-en.net/creator/11019", creator_id: "11019", article_id: nil)
      url_parser_should_work("https://ci-en.net/creator/11019/article/921762", creator_id: "11019", article_id: "921762")

      url_parser_should_work("https://media.ci-en.jp/private/attachment/creator/00011019/62a643d6423c18ec1be16826d687cefb47d8304de928a07c6389f8188dfe6710/image-web.jpg?px-time=1703968668&px-hash=9497dce5fa56c5081413ad1126e06d6f44f0ab3e", creator_id: "11019")
      url_parser_should_work("https://media.ci-en.jp/public/cover/creator/00011019/ae96c79d7626c8127bfe9823111601d3b566977d19c3aa0409de4ef838f8dc12/image-990-c.jpg", creator_id: "11019")
    end
  end
end
