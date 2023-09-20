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
        dtext_artist_commentary_desc: <<~EOS.chomp
          发了三次发不出有毒……

          二部运动au  性转ac注意

          失去耐心.jpg
        EOS
      )
    end

    context "A lofter direct image url" do
      strategy_should_work(
        "https://imglf4.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJUFczb2RKSVlpMHJkNy9kc3BSQVQvQm5DNzB4eVhxay9nPT0.png?imageView&thumbnail=1680x0&quality=96&stripmeta=0",
        image_urls: ["https://imglf4.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJUFczb2RKSVlpMHJkNy9kc3BSQVQvQm5DNzB4eVhxay9nPT0.png"],
        profile_url: nil,
        media_files: [{ file_size: 2_739_443 }]
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
        dtext_artist_commentary_desc: <<~EOS.chomp
          練習

          画画卡姐～
        EOS
      )
    end

    context "A lofter post with commentary under <.m-post .cont .text>" do
      strategy_should_work(
        "https://qiuchenghanshuang.lofter.com/post/1f9d6464_2b736607b",
        image_urls: [
          "https://imglf4.lf127.net/img/68d1578576f2e8a0/akFYeFo0L0VFMno5d0JuNHlwQ3VMdEFxYysyN1ZseVduNzFkbG9MdUlFVT0.jpg",
          "https://imglf6.lf127.net/img/9970d5715bd5f72a/akFYeFo0L0VFMno5d0JuNHlwQ3VMZ3QxbkttTHpHZERWZXlVS3FDNmtYcz0.jpg",
        ],
        dtext_artist_commentary_desc: "过去与她擦肩而过"
      )
    end

    context "A lofter post with commentary under <.cnwrapper p:nth-child(2)>" do
      strategy_should_work(
        "https://sdz013.lofter.com/post/1ec04eca_1ccabb5df",
        image_urls: [
          "https://imglf5.lf127.net/img/b57d91d0e107e2e6/Sytua1gwSUwyV1k3SXZxY3FiVGJvVW82Ny90bVVOeElEUmZ3bXFrbGlnST0.png",
          "https://imglf4.lf127.net/img/067bd19dd731b52f/Sytua1gwSUwyV1k3SXZxY3FiVGJvZWVFS25EUWVGR1FseCtkTHBFS2xzaz0.png",
          "https://imglf4.lf127.net/img/323e0e53fec354b8/Sytua1gwSUwyV1k3SXZxY3FiVGJvWWh2MjZSUHdvM3JNWndUS0pSSS9Gdz0.png",
          "https://imglf3.lf127.net/img/304d83b42234fa53/Sytua1gwSUwyV1k3SXZxY3FiVGJvY2xNK3FDQ2lTaDBOdU1lenhtNDJLaz0.png",
        ],
        dtext_artist_commentary_desc: "本来是给外国朋友但是我销号了所以存下()"
      )
    end

    context "A lofter post with commentary under <.ct .txtcont>" do
      strategy_should_work(
        "https://okitagumi.lofter.com/post/1e69aeeb_fbb63ca",
        image_urls: [
          "https://imglf4.lf127.net/img/d2ZIUXlGd2FraFNMMC9KUTNGdTFjVkZydjlsNUxhVyt2MHpUanhaeld5Vy8zZEQzUE5XMXhBPT0.jpg",
        ],
        tag_name: "okitagumi",
        artist_name: "okitagumi",
        page_url: "https://okitagumi.lofter.com/post/1e69aeeb_fbb63ca",
        profile_url: "https://okitagumi.lofter.com",
        media_files: [{ file_size: 154_620 }],
        tags: [],
        dtext_artist_commentary_title: "冲田组原主与刀温馨向合志《金平糖》补货及预售通贩告知",
        dtext_artist_commentary_desc: <<~EOS.chomp
          非常感谢各位一直以来的支持和厚爱，冲田组原主与刀温馨向合志[b]《金平糖》二刷[/b]的通贩现货目前已经完售

          但由于淘宝上存在数家对《金平糖》进行盗印的不法商家，并且已经有数位受骗上当、购买了盗印的同好，为了不让这些无耻的盗印商得逞，我们决定继续对本子加印补货

          [b]淘宝通贩→[/b]"[b]※※※※[/b]":[https://item.taobao.com/item.htm?id=542050423915&qq-pf-to=pcqq.c2c]

          [b]本宣地址→[/b]"[b]※※※※[/b]":[https://okitagumi.lofter.com/post/1e69aeeb_e30959e]

          《金平糖》的通贩代理只有[b]@JACKPOT_印刷寄售社团[/b] 一家 ，除此之外全部都是盗印店，还请大家帮忙奔走相告( ´•̥×•̥` )

          补货预售期间，购买本子均会送两张特典小卡片。

          由于本次三刷补货并没有增加特典，内容也和之前完全一样，所以不再进行额外宣传。

          大家这份热忱令我们十分惊异，同时也深深感受到各位对冲田组的喜爱，谢谢每一位支持过《金平糖》的同好。

          今后也请多多指教【鞠躬

          占tag非常抱歉。
        EOS
      )
    end

    context "A lofter post with the character 0xA0 in a tag" do
      strategy_should_work(
        "https://xingfulun16203.lofter.com/post/77a68dc4_2b9f0f00c",
        image_urls: ["https://imglf4.lf127.net/img/b7c3e00acd19f7c0/azVib0c4ZHd2WVd6UEhkWG93c1QxRXM3V3VVM2pab0pqaXB3UFV4WG1tVT0.png"],
        tags: %w[夸奈 我推的孩子 夸奈24h:海蓝苏打七夕特供]
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
