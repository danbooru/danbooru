require "test_helper"

module Source::Tests::URL
  class FanboxUrlTest < ActiveSupport::TestCase
    context "Fanbox URLs" do
      should be_image_url(
        "https://pixiv.pximg.net/c/936x600_90_a2_g5/fanbox/public/images/plan/4635/cover/L6AZNneFuHW6r25CHHlkpHg4.jpeg",
        "https://pixiv.pximg.net/c/400x400_90_a2_g5/fanbox/public/images/creator/1566167/profile/Ix6bnJmTaOAFZhXHLbWyIY1e.jpeg",
        "https://downloads.fanbox.cc/images/post/39714/JvjJal8v1yLgc5DPyEI05YpT.png",
      )

      should be_page_url(
        "https://www.fanbox.cc/@tsukiori/posts/1080657",
        "https://www.pixiv.net/fanbox/creator/1566167/post/39714",
        "https://omu001.fanbox.cc/posts/39714",
      )

      should be_profile_url(
        "https://www.pixiv.net/fanbox/creator/1566167",
        "https://pixiv.net/fanbox/creator/1566167",
        "https://www.pixiv.net/fanbox/member.php?user_id=3410642",
        "https://pixiv.net/fanbox/member.php?user_id=3410642",
        "https://omu001.fanbox.cc",
        "https://www.fanbox.cc/@tsukiori",
      )

      should_not be_profile_url(
        "https://www.fanbox.cc",
        "https://fanbox.cc",
      )

      should be_secondary_url(
        "https://www.pixiv.net/fanbox/creator/1566167",
        "https://www.pixiv.net/fanbox/member.php?user_id=3410642",
      )

      should_not be_secondary_url(
        "https://omu001.fanbox.cc",
        "https://www.fanbox.cc/@tsukiori",
      )

      should parse_url(
        "https://pixiv.pximg.net/c/400x400_90_a2_g5/fanbox/public/images/creator/1566167/profile/Ix6bnJmTaOAFZhXHLbWyIY1e.jpeg",
      ).into(
        page_url: "https://www.pixiv.net/fanbox/creator/1566167",
        user_id: "1566167",
      )

      should parse_url("https://fanbox.cc/@omu001").into(username: "omu001")
      should parse_url("https://www.fanbox.cc/@omu001").into(username: "omu001")

      should parse_url("https://www.fanbox.cc/@omu001/posts/39714").into(username: "omu001", work_id: "39714")
      should parse_url("https://fanbox.cc/@omu001/posts/39714").into(username: "omu001", work_id: "39714")
      should parse_url("https://omu001.fanbox.cc/posts/39714").into(username: "omu001", work_id: "39714")
    end

    should parse_url("https://pixiv.pximg.net/c/936x600_90_a2_g5/fanbox/public/images/plan/4635/cover/L6AZNneFuHW6r25CHHlkpHg4.jpeg").into(site_name: "Fanbox")
  end
end
