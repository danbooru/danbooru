require "test_helper"

module Source::Tests::URL
  class FanboxUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://pixiv.pximg.net/c/936x600_90_a2_g5/fanbox/public/images/plan/4635/cover/L6AZNneFuHW6r25CHHlkpHg4.jpeg",
          "https://pixiv.pximg.net/c/400x400_90_a2_g5/fanbox/public/images/creator/1566167/profile/Ix6bnJmTaOAFZhXHLbWyIY1e.jpeg",
          "https://downloads.fanbox.cc/images/post/39714/JvjJal8v1yLgc5DPyEI05YpT.png",
        ],
        page_urls: [
          "https://www.fanbox.cc/@tsukiori/posts/1080657",
          "https://www.pixiv.net/fanbox/creator/1566167/post/39714",
          "https://omu001.fanbox.cc/posts/39714",
        ],
        profile_urls: [
          "https://www.pixiv.net/fanbox/creator/1566167",
          "https://pixiv.net/fanbox/creator/1566167",
          "https://www.pixiv.net/fanbox/member.php?user_id=3410642",
          "https://pixiv.net/fanbox/member.php?user_id=3410642",
          "https://omu001.fanbox.cc",
          "https://www.fanbox.cc/@tsukiori",
        ],
      )

      should_not_find_false_positives(
        profile_urls: [
          "https://www.fanbox.cc",
          "https://fanbox.cc",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://pixiv.pximg.net/c/400x400_90_a2_g5/fanbox/public/images/creator/1566167/profile/Ix6bnJmTaOAFZhXHLbWyIY1e.jpeg",
                             page_url: "https://www.pixiv.net/fanbox/creator/1566167",
                             user_id: "1566167",)

      url_parser_should_work("https://fanbox.cc/@omu001", username: "omu001")
      url_parser_should_work("https://www.fanbox.cc/@omu001", username: "omu001")
      url_parser_should_work("https://www.fanbox.cc/@omu001/posts/39714", username: "omu001", work_id: "39714")
      url_parser_should_work("https://fanbox.cc/@omu001/posts/39714", username: "omu001", work_id: "39714")
      url_parser_should_work("https://omu001.fanbox.cc/posts/39714", username: "omu001", work_id: "39714")
    end
  end
end
