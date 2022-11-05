require "test_helper"

module Sources
  class LofterTest < ActiveSupport::TestCase
    context "A lofter post with commentary under <.ct .text>" do
      image_urls = %w[
        https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJQ1RxY0lYaU1UUE9tQ0NvUE9rVXFpOFFEVzMwbnQ4aEFnPT0.jpg
        https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJRWlXYTRVOEpXTU9TSGt3TjBDQ0JFZVpZMEJtWjFneVNBPT0.png
        https://imglf6.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJR1d3Y2VvbTNTQlIvdFU1WWlqZHEzbjI4MFVNZVdoN3VBPT0.png
        https://imglf6.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJTi83NDRDUjNvd3hySGxEZFovd2hwbi9oaG9NQ1hOUkZ3PT0.png
        https://imglf4.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJUFczb2RKSVlpMHJkNy9kc3BSQVQvQm5DNzB4eVhxay9nPT0.png
        https://imglf4.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJSStJZE9RYnJURktHazdIVHNNMjQ5eFJldHVTQy9XbDB3PT0.png
        https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJSzFCWFlnUWgzb01DcUdpT1lreG5yQjJVMkhGS09HNGR3PT0.png
      ]
      strategy_should_work(
        "https://gengar563.lofter.com/post/1e82da8c_1c98dae1b",
        image_urls: image_urls,
        artist_name: "gengar563",
        profile_url: "https://gengar563.lofter.com",
        dtext_artist_commentary_desc: /发了三次发不出有毒…… \n.*\n失去耐心.jpg/
      )
    end

    context "A lofter direct image url" do
      strategy_should_work(
        "https://imglf4.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJUFczb2RKSVlpMHJkNy9kc3BSQVQvQm5DNzB4eVhxay9nPT0.png?imageView&thumbnail=1680x0&quality=96&stripmeta=0",
        image_urls: ["https://imglf4.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJUFczb2RKSVlpMHJkNy9kc3BSQVQvQm5DNzB4eVhxay9nPT0.png"],
        profile_url: nil,
        download_size: 2_739_443
      )
    end

    context "A lofter post with commentary under <.content .text>" do
      strategy_should_work(
        "https://yuli031458.lofter.com/post/3163d871_1cbdc5f6d",
        image_urls: ["https://imglf5.lf127.net/img/Mm55d3lNK2tJUWpNTjVLN0MvaTRDc1UvQUFLMGszOHRvSjV6S3VSa1lwa3BDWUtVOWpBTHBnPT0.jpg"],
        tags: ["明日方舟", "阿米娅"],
        dtext_artist_commentary_desc: "Amiya"
      )
    end

    context "A lofter post with commentary under <#post .description>" do
      strategy_should_work(
        "https://chengyeliuli.lofter.com/post/1d127639_2b6e850c8",
        image_urls: ["https://imglf3.lf127.net/img/d28aeb098a69b1d2/ZmltbmVjOU9BRzFHVTVnTkNmc0V0NDlSRnNrdENIWWwyZkFreTJJd0duRT0.jpg"],
        dtext_artist_commentary_desc: /練習\s+画画卡姐～/
      )
    end

    context "A lofter post with commentary under <.m-post .cont .text>" do
      strategy_should_work(
        "https://qiuchenghanshuang.lofter.com/post/1f9d6464_2b736607b",
        image_urls: [
          "https://imglf4.lf127.net/img/68d1578576f2e8a0/akFYeFo0L0VFMno5d0JuNHlwQ3VMdEFxYysyN1ZseVduNzFkbG9MdUlFVT0.jpg",
          "https://imglf6.lf127.net/img/9970d5715bd5f72a/akFYeFo0L0VFMno5d0JuNHlwQ3VMZ3QxbkttTHpHZERWZXlVS3FDNmtYcz0.jpg",
        ],
        dtext_artist_commentary_desc: /过去与她擦肩而过/
      )
    end

    context "A dead link" do
      strategy_should_work(
        "https://gxszdddd.lofter.com/post/322595b1_1ca5e6f66",
        deleted: true
      )
    end

    should "Parse Lofter URLs correctly" do
      assert(Source::URL.image_url?("https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJSzFCWFlnUWgzb01DcUdpT1lreG5yQjJVMkhGS09HNGR3PT0.png?imageView&thumbnail=1680x0&quality=96&stripmeta=0"))
      assert(Source::URL.image_url?("http://imglf0.nosdn.127.net/img/cHl3bXNZdDRaaHBnNWJuN1Y4OXBqR01CeVBZSVNmU2FWZWtHc1h4ZTZiUGxlRzMwZnFDM1JnPT0.jpg "))

      assert(Source::URL.page_url?("https://gengar563.lofter.com/post/1e82da8c_1c98dae1b"))

      assert(Source::URL.profile_url?("https://www.lofter.com/front/blog/home-page/noshiqian"))
      assert(Source::URL.profile_url?("http://www.lofter.com/app/xiaokonggedmx"))
      assert(Source::URL.profile_url?("http://www.lofter.com/blog/semblance"))
      assert(Source::URL.profile_url?("http://gengar563.lofter.com"))
    end
  end
end
