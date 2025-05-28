require "test_helper"

module Source::Tests::URL
  class PixivSketchUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://img-sketch.pixiv.net/uploads/medium/file/4463372/8906921629213362989.jpg ",
          "https://img-sketch.pximg.net/c!/w=540,f=webp:jpeg/uploads/medium/file/4463372/8906921629213362989.jpg",
          "https://img-sketch.pixiv.net/c/f_540/uploads/medium/file/9986983/8431631593768139653.jpg",
        ],
        page_urls: [
          "https://sketch.pixiv.net/items/5835314698645024323",
        ],
        profile_urls: [
          "https://sketch.pixiv.net/@user_ejkv8372",
        ],
      )
    end
  end
end
