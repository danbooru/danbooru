require "test_helper"

module Source::Tests::URL
  class BilibiliUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg",
          "https://i0.hdslb.com/bfs/album/37f77871d417c76a08a9467527e9670810c4c442.gif",
          "https://album.biliimg.com/bfs/new_dyn/4cf244d3fb706a5726b6383143960931504164361.jpg",
        ],
        page_urls: [
          "https://t.bilibili.com/612214375070704555",
          "https://www.bilibili.com/opus/612214375070704555",
          "https://h.bilibili.com/8773541",
          "https://www.bilibili.com/read/cv7360489",
          "https://www.bilibili.com/video/BV1dY4y1u7Vi",
        ],
        profile_urls: [
          "https://space.bilibili.com/355143",
        ],
      )

      should_not_find_false_positives(
        profile_urls: [
          "https://space.bilibili.com",
        ],
        bad_sources: [
          "https://live.bilibili.com/blackboard/era/VSuE0f27CnXe3VSY.html",
          "https://live.bilibili.com/10049889?from=search&seid=8525275464641122982",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work(
        "https://www.bilibili.com/p/h5/8773541",
        page_url: "https://h.bilibili.com/8773541",
      )

      url_parser_should_work(
        "https://m.bilibili.com/dynamic/612214375070704555",
        page_url: "https://www.bilibili.com/opus/612214375070704555",
      )

      url_parser_should_work(
        "https://t.bilibili.com/612214375070704555",
        page_url: "https://www.bilibili.com/opus/612214375070704555",
      )

      url_parser_should_work(
        "https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg@1036w.webp",
        full_image_url: "https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg",
      )
      url_parser_should_work(
        "https://i0.hdslb.com/bfs/new_dyn/716a9733fc804d11d823cfacb7a3c78b11742550.jpg@208w_208h_1e_1c.webp",
        full_image_url: "https://i0.hdslb.com/bfs/new_dyn/716a9733fc804d11d823cfacb7a3c78b11742550.jpg",
      )
      url_parser_should_work(
        "https://i0.hdslb.com/bfs/album/37f77871d417c76a08a9467527e9670810c4c442.gif@1036w.webp",
        full_image_url: "https://i0.hdslb.com/bfs/album/37f77871d417c76a08a9467527e9670810c4c442.gif",
      )
      url_parser_should_work(
        "https://i0.hdslb.com/bfs/article/48e75b3871fa5ed62b4e3a16bf60f52f96b1b3b1.jpg@942w_1334h_progressive.webp",
        full_image_url: "https://i0.hdslb.com/bfs/article/48e75b3871fa5ed62b4e3a16bf60f52f96b1b3b1.jpg",
      )
      url_parser_should_work(
        "https://album.biliimg.com/bfs/article/48e75b3871fa5ed62b4e3a16bf60f52f96b1b3b1.jpg@942w_1334h_progressive.webp",
        full_image_url: "https://album.biliimg.com/bfs/article/48e75b3871fa5ed62b4e3a16bf60f52f96b1b3b1.jpg",
      )
      url_parser_should_work(
        "https://i0.hdslb.com/bfs/article/watermark/dccf0575ae604b5f96e9593a38241b897e10fc4b.png",
        full_image_url: "https://i0.hdslb.com/bfs/article/watermark/dccf0575ae604b5f96e9593a38241b897e10fc4b.png",
      )
    end
  end
end
