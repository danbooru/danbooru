require "test_helper"

module Source::Tests::URL
  class BilibiliUrlTest < ActiveSupport::TestCase
    context "Bilibili URLs" do
      should be_image_url(
        "https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg",
        "https://i0.hdslb.com/bfs/album/37f77871d417c76a08a9467527e9670810c4c442.gif",
        "https://album.biliimg.com/bfs/new_dyn/4cf244d3fb706a5726b6383143960931504164361.jpg",
      )

      should be_page_url(
        "https://t.bilibili.com/612214375070704555",
        "https://www.bilibili.com/opus/612214375070704555",
        "https://h.bilibili.com/8773541",
        "https://www.bilibili.com/read/cv7360489",
        "https://www.bilibili.com/video/BV1dY4y1u7Vi",
        "https://manga.bilibili.com/detail/mc33526",
        "https://www.bilibili.com/blackboard/era/yWPr7A7p6Z2z2LR1.html",
      )

      should be_profile_url(
        "https://space.bilibili.com/355143",
        "https://space.bilibili.com/476725595/video",
        "https://m.bilibili.com/space/355143",
      )

      should_not be_profile_url(
        "https://space.bilibili.com",
      )

      should_not be_bad_source(
        "https://live.bilibili.com/blackboard/era/VSuE0f27CnXe3VSY.html",
        "https://live.bilibili.com/10049889?from=search&seid=8525275464641122982",
        "https://manga.bilibili.com/detail/mc33526",
        "https://www.bilibili.com/blackboard/era/yWPr7A7p6Z2z2LR1.html",
      )

      should be_bad_source(
        "https://bili2233.cn/h5v55co",
        "https://b23.tv/h5v55co",
      )

      should parse_url("https://www.bilibili.com/p/h5/8773541").into(page_url: "https://h.bilibili.com/8773541")
      should parse_url("https://m.bilibili.com/dynamic/612214375070704555").into(page_url: "https://www.bilibili.com/opus/612214375070704555")
      should parse_url("https://t.bilibili.com/612214375070704555").into(page_url: "https://www.bilibili.com/opus/612214375070704555")

      should parse_url("https://space.bilibili.com/476725595/video").into(profile_url: "https://space.bilibili.com/476725595")
      should parse_url("https://m.bilibili.com/space/355143").into(profile_url: "https://space.bilibili.com/355143")

      should parse_url("https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg@1036w.webp").into(
        full_image_url: "https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg",
      )

      should parse_url("https://i0.hdslb.com/bfs/new_dyn/716a9733fc804d11d823cfacb7a3c78b11742550.jpg@208w_208h_1e_1c.webp").into(
        full_image_url: "https://i0.hdslb.com/bfs/new_dyn/716a9733fc804d11d823cfacb7a3c78b11742550.jpg",
      )

      should parse_url("https://i0.hdslb.com/bfs/album/37f77871d417c76a08a9467527e9670810c4c442.gif@1036w.webp").into(
        full_image_url: "https://i0.hdslb.com/bfs/album/37f77871d417c76a08a9467527e9670810c4c442.gif",
      )

      should parse_url("https://i0.hdslb.com/bfs/article/48e75b3871fa5ed62b4e3a16bf60f52f96b1b3b1.jpg@942w_1334h_progressive.webp").into(
        full_image_url: "https://i0.hdslb.com/bfs/article/48e75b3871fa5ed62b4e3a16bf60f52f96b1b3b1.jpg",
      )

      should parse_url("https://album.biliimg.com/bfs/article/48e75b3871fa5ed62b4e3a16bf60f52f96b1b3b1.jpg@942w_1334h_progressive.webp").into(
        full_image_url: "https://album.biliimg.com/bfs/article/48e75b3871fa5ed62b4e3a16bf60f52f96b1b3b1.jpg",
      )

      should parse_url("https://i0.hdslb.com/bfs/manga-static/27b89c0e99ba868111d9ed6344fb987447d0f6fd.png").into(
        full_image_url: "https://i0.hdslb.com/bfs/manga-static/27b89c0e99ba868111d9ed6344fb987447d0f6fd.png",
      )

      should parse_url("https://manga.bilibili.com/detail/mc33526").into(page_url: "https://manga.bilibili.com/detail/mc33526", manga_id: "33526")

      should parse_url("https://www.bilibili.com/blackboard/era/yWPr7A7p6Z2z2LR1.html").into(
        page_url: "https://www.bilibili.com/blackboard/era/yWPr7A7p6Z2z2LR1.html",
        blackboard_id: "yWPr7A7p6Z2z2LR1",
      )

      should parse_url("https://activity.hdslb.com/blackboard/static/d41d8cd98f00b204e9800998ecf8427e/6pvMXulEq2.mp4").into(
        full_image_url: "https://activity.hdslb.com/blackboard/static/d41d8cd98f00b204e9800998ecf8427e/6pvMXulEq2.mp4",
      )

      should parse_url("https://i0.hdslb.com/bfs/article/watermark/dccf0575ae604b5f96e9593a38241b897e10fc4b.png").into(
        full_image_url: "https://i0.hdslb.com/bfs/article/watermark/dccf0575ae604b5f96e9593a38241b897e10fc4b.png",
      )
    end

    should parse_url("https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg").into(site_name: "Bilibili")
  end
end
