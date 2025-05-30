require "test_helper"

module Source::Tests::URL
  class PixivFactoryUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://factory.pixiv.net/files/uploads/i/conceptual_drawing/3a6f3742-03b6-4968-9599-20dc2c0e1172/canvas_f2605b12ed.png",
          "https://factory.pixiv.net/resources/images/13760863/canvas",
          "https://factory.pixiv.net/_next/image?url=https%3A%2F%2Fimages.ctfassets.net%2F91hllu7j5j6t%2F55IY8dLGAZnQuRIdQQLtE9%2Fc4705fa83c046b5938beb6d2470550f8%2FThumbnail_hasuimo2.jpg&w=384&q=75",
          "https://images.ctfassets.net/91hllu7j5j6t/55IY8dLGAZnQuRIdQQLtE9/c4705fa83c046b5938beb6d2470550f8/Thumbnail_hasuimo2.jpg&w=384&q=75 (sample)",
        ],
        page_urls: [
          "https://factory.pixiv.net/palette/collections/imys_tachie#image-13760863",
          "https://factory.pixiv.net/palette/collections/imys_tachie",
        ],
      )
    end
  end
end
