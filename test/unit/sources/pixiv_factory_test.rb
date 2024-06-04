# frozen_string_literal: true

require "test_helper"

module Sources
  class PixivFactoryTest < ActiveSupport::TestCase
    context "Pixiv Factory:" do
      context "A factory.pixiv.net/files/* sample image URL" do
        strategy_should_work(
          "https://factory.pixiv.net/files/uploads/i/conceptual_drawing/3a6f3742-03b6-4968-9599-20dc2c0e1172/lightweight_f2605b12ed.png ",
          image_urls: %w[https://factory.pixiv.net/files/uploads/i/conceptual_drawing/3a6f3742-03b6-4968-9599-20dc2c0e1172/canvas_f2605b12ed.png],
          media_files: [{ file_size: 321_775 }],
          page_url: nil
        )
      end

      context "A factory.pixiv.net/resources/* sample image URL" do
        strategy_should_work(
          "https://factory.pixiv.net/resources/images/13760863/thumb ",
          image_urls: %w[https://factory.pixiv.net/resources/images/13760863/canvas],
          media_files: [{ file_size: 154_526 }],
          page_url: nil
        )
      end

      context "A factory.pixiv.net/_next/image sample image URL" do
        strategy_should_work(
          "https://factory.pixiv.net/_next/image?url=https%3A%2F%2Fimages.ctfassets.net%2F91hllu7j5j6t%2F55IY8dLGAZnQuRIdQQLtE9%2Fc4705fa83c046b5938beb6d2470550f8%2FThumbnail_hasuimo2.jpg&w=384&q=75       ",
          image_urls: %w[https://images.ctfassets.net/91hllu7j5j6t/55IY8dLGAZnQuRIdQQLtE9/c4705fa83c046b5938beb6d2470550f8/Thumbnail_hasuimo2.jpg],
          media_files: [{ file_size: 463_787 }],
          page_url: nil
        )
      end

      context "A images.ctfassets.net sample image URL" do
        strategy_should_work(
          "https://images.ctfassets.net/91hllu7j5j6t/55IY8dLGAZnQuRIdQQLtE9/c4705fa83c046b5938beb6d2470550f8/Thumbnail_hasuimo2.jpg?w=384&q=75",
          image_urls: %w[https://images.ctfassets.net/91hllu7j5j6t/55IY8dLGAZnQuRIdQQLtE9/c4705fa83c046b5938beb6d2470550f8/Thumbnail_hasuimo2.jpg],
          media_files: [{ file_size: 463_787 }],
          page_url: nil
        )
      end

      context "A factory.pixiv.net/files/* full image URL" do
        strategy_should_work(
          "https://factory.pixiv.net/files/uploads/i/conceptual_drawing/3a6f3742-03b6-4968-9599-20dc2c0e1172/canvas_f2605b12ed.png ",
          image_urls: %w[https://factory.pixiv.net/files/uploads/i/conceptual_drawing/3a6f3742-03b6-4968-9599-20dc2c0e1172/canvas_f2605b12ed.png],
          media_files: [{ file_size: 321_775 }],
          page_url: nil
        )
      end

      context "A collections page" do
        strategy_should_work(
          "https://factory.pixiv.net/palette/collections/scenery_of_reminiscence",
          image_urls: %w[
            https://factory.pixiv.net/resources/images/12919732/canvas
            https://factory.pixiv.net/resources/images/12919731/canvas
            https://factory.pixiv.net/resources/images/12919730/canvas
            https://factory.pixiv.net/resources/images/12919729/canvas
            https://factory.pixiv.net/resources/images/12919728/canvas
          ],
          media_files: [
            { file_size: 279_274 },
            { file_size: 284_930 },
            { file_size: 402_698 },
            { file_size: 209_317 },
            { file_size: 233_752 },
          ],
          page_url: "https://factory.pixiv.net/palette/collections/scenery_of_reminiscence",
          profile_urls: [],
          display_name: "mocha",
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "追憶の風景",
          dtext_artist_commentary_desc: "美麗な風景・背景イラストが魅力のmochaのイラストを使って、あなただけのオリジナルグッズが簡単につくれます。数多くのアイテムラインナップから選ぶお好きなアイテムで、美しい世界観を身近に感じられる日々を過ごしてみませんか？ 心を奪われるようなイラストは必見です！"
        )
      end

      context "A single image from a collection" do
        strategy_should_work(
          "https://factory.pixiv.net/palette/collections/scenery_of_reminiscence#image-12919732",
          image_urls: %w[https://factory.pixiv.net/resources/images/12919732/canvas],
          media_files: [{ file_size: 279_274 }],
          page_url: "https://factory.pixiv.net/palette/collections/scenery_of_reminiscence#image-12919732",
          profile_urls: %w[],
          display_name: "mocha",
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "追憶の風景",
          dtext_artist_commentary_desc: "美麗な風景・背景イラストが魅力のmochaのイラストを使って、あなただけのオリジナルグッズが簡単につくれます。数多くのアイテムラインナップから選ぶお好きなアイテムで、美しい世界観を身近に感じられる日々を過ごしてみませんか？ 心を奪われるようなイラストは必見です！"
        )
      end

      context "A deleted or nonexistent collection" do
        strategy_should_work(
          "https://factory.pixiv.net/palette/collections/bad",
          image_urls: [],
          page_url: "https://factory.pixiv.net/palette/collections/bad",
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "Parse URLs correctly" do
        assert(Source::URL.image_url?("https://factory.pixiv.net/files/uploads/i/conceptual_drawing/3a6f3742-03b6-4968-9599-20dc2c0e1172/canvas_f2605b12ed.png"))
        assert(Source::URL.image_url?("https://factory.pixiv.net/resources/images/13760863/canvas"))
        assert(Source::URL.image_url?("https://factory.pixiv.net/_next/image?url=https%3A%2F%2Fimages.ctfassets.net%2F91hllu7j5j6t%2F55IY8dLGAZnQuRIdQQLtE9%2Fc4705fa83c046b5938beb6d2470550f8%2FThumbnail_hasuimo2.jpg&w=384&q=75"))
        assert(Source::URL.image_url?("https://images.ctfassets.net/91hllu7j5j6t/55IY8dLGAZnQuRIdQQLtE9/c4705fa83c046b5938beb6d2470550f8/Thumbnail_hasuimo2.jpg&w=384&q=75 (sample)"))

        assert(Source::URL.page_url?("https://factory.pixiv.net/palette/collections/imys_tachie#image-13760863"))
        assert(Source::URL.page_url?("https://factory.pixiv.net/palette/collections/imys_tachie"))
      end
    end
  end
end
