require "test_helper"

module Source::Tests::URL
  class PixivComicUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        page_urls: [
          "https://comic.pixiv.net/magazines/317",
          "https://comic.pixiv.net/works/10137",
          "https://comic.pixiv.net/viewer/stories/162153",
          "https://comic.pixiv.net/novel/works/3877",
          "https://comic.pixiv.net/novel/viewer/stories/11588",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://public-img-comic.pximg.net/images/magazine_cover/e772MnFuZZ5oQsadLQ2b/317.jpg?20240120120001",
                             page_url: "https://comic.pixiv.net/magazines/317",)

      url_parser_should_work("https://public-img-comic.pximg.net/images/magazine_logo/e772MnFuZZ5oQsadLQ2b/317.png?20240120120001",
                             page_url: "https://comic.pixiv.net/magazines/317",)

      url_parser_should_work("https://img-comic.pximg.net/c/q90_gridshuffle32:32/images/page/162153/iMnq837lBFlyCIpIstcp/1.jpg?20240112151247",
                             page_url: "https://comic.pixiv.net/viewer/stories/162153",)

      url_parser_should_work("https://img-comic.pximg.net/images/page/9869/V52hshKjl05juBvdbHJ5/2.jpg?20151030104009",
                             page_url: "https://comic.pixiv.net/viewer/stories/9869",)

      url_parser_should_work("https://public-img-comic.pximg.net/c!/f=webp:auto,w=96,q=75/images/story_thumbnail/92O1JVc8DrrTTTfKdl2R/167869.jpg?20240426131638",
                             page_url: "https://comic.pixiv.net/viewer/stories/167869",)

      url_parser_should_work("https://public-img-comic.pximg.net/c!/q=90,f=webp%3Ajpeg/images/work_thumbnail/10137.jpg?20240217160416",
                             page_url: "https://comic.pixiv.net/works/10137",)

      url_parser_should_work("https://public-img-comic.pximg.net/c!/w=200,f=webp%3Ajpeg/images/work_main/10137.jpg?20240217160416",
                             page_url: "https://comic.pixiv.net/works/10137",)

      url_parser_should_work("https://public-img-comic.pximg.net/images/work_main/10137.jpg?20240217160416",
                             page_url: "https://comic.pixiv.net/works/10137",)

      url_parser_should_work("https://img-comic.pximg.net/images/work_main/10137.jpg?20240217160416",
                             page_url: "https://comic.pixiv.net/works/10137",)

      url_parser_should_work("https://img-novel.pximg.net/c!/f=webp:auto,w=384,q=75/img-novel/work_main/BJruKIb2nWvhTadwsL68/3877.jpg?20240430174032",
                             page_url: "https://comic.pixiv.net/novel/works/3877",)

      url_parser_should_work("https://img-novel.pximg.net/img-novel/page/11588/GRqnlQ258aa3CFxpRIys/1.jpg?20240426103009",
                             page_url: "https://comic.pixiv.net/novel/viewer/stories/11588",)
    end
  end
end
