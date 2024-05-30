require "test_helper"

module Sources
  class LofterTest < ActiveSupport::TestCase
    context "A lofter sample image url" do
      strategy_should_work(
        "https://imglf4.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJUFczb2RKSVlpMHJkNy9kc3BSQVQvQm5DNzB4eVhxay9nPT0.png?imageView&thumbnail=1680x0&quality=96&stripmeta=0",
        image_urls: %w[https://imglf4.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJUFczb2RKSVlpMHJkNy9kc3BSQVQvQm5DNzB4eVhxay9nPT0.png],
        media_files: [{ file_size: 2_739_443 }],
        page_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: ""
      )
    end

    context "A lofter post with commentary under <.ct .text>" do
      strategy_should_work(
        "https://gengar563.lofter.com/post/1e82da8c_1c98dae1b",
        image_urls: %w[
          https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJQ1RxY0lYaU1UUE9tQ0NvUE9rVXFpOFFEVzMwbnQ4aEFnPT0.jpg
          https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJRWlXYTRVOEpXTU9TSGt3TjBDQ0JFZVpZMEJtWjFneVNBPT0.png
          https://imglf6.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJR1d3Y2VvbTNTQlIvdFU1WWlqZHEzbjI4MFVNZVdoN3VBPT0.png
          https://imglf6.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJTi83NDRDUjNvd3hySGxEZFovd2hwbi9oaG9NQ1hOUkZ3PT0.png
          https://imglf4.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJUFczb2RKSVlpMHJkNy9kc3BSQVQvQm5DNzB4eVhxay9nPT0.png
          https://imglf4.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJSStJZE9RYnJURktHazdIVHNNMjQ5eFJldHVTQy9XbDB3PT0.png
          https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJSzFCWFlnUWgzb01DcUdpT1lreG5yQjJVMkhGS09HNGR3PT0.png
        ],
        media_files: [
          { file_size: 1_979_075 },
          { file_size: 3_399_671 },
          { file_size: 2_694_582 },
          { file_size: 3_438_507 },
          { file_size: 2_739_443 },
          { file_size: 3_827_991 },
          { file_size: 3_374_972 },
        ],
        page_url: "https://gengar563.lofter.com/post/1e82da8c_1c98dae1b",
        profile_urls: %w[https://gengar563.lofter.com],
        display_name: "续杯超盐酸",
        username: "gengar563",
        tags: [
          ["废弃盐酸处理厂", "https://www.lofter.com/tag/废弃盐酸处理厂"],
          ["jojo的奇妙冒险", "https://www.lofter.com/tag/jojo的奇妙冒险"],
          ["乔瑟夫乔斯达", "https://www.lofter.com/tag/乔瑟夫乔斯达"],
          ["瓦姆乌", "https://www.lofter.com/tag/瓦姆乌"],
          ["acdc", "https://www.lofter.com/tag/acdc"],
          ["卡兹", "https://www.lofter.com/tag/卡兹"],
          ["丝吉q", "https://www.lofter.com/tag/丝吉q"],
          ["西撒齐贝林", "https://www.lofter.com/tag/西撒齐贝林"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          发了三次发不出有毒……

          二部运动au 性转ac注意

          失去耐心.jpg
        EOS
      )
    end

    context "A lofter post with commentary under <.content .text>" do
      strategy_should_work(
        "https://yuli031458.lofter.com/post/3163d871_1cbdc5f6d",
        image_urls: %w[https://imglf5.lf127.net/img/Mm55d3lNK2tJUWpNTjVLN0MvaTRDc1UvQUFLMGszOHRvSjV6S3VSa1lwa3BDWUtVOWpBTHBnPT0.jpg],
        media_files: [{ file_size: 5_773_611 }],
        page_url: "https://yuli031458.lofter.com/post/3163d871_1cbdc5f6d",
        profile_urls: %w[https://yuli031458.lofter.com],
        display_name: "52hertzc",
        username: "yuli031458",
        tags: [
          ["明日方舟", "https://www.lofter.com/tag/明日方舟"],
          ["阿米娅", "https://www.lofter.com/tag/阿米娅"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "Amiya"
      )
    end

    context "A lofter post with commentary under <#post .description>" do
      strategy_should_work(
        "https://chengyeliuli.lofter.com/post/1d127639_2b6e850c8",
        image_urls: %w[https://imglf3.lf127.net/img/d28aeb098a69b1d2/ZmltbmVjOU9BRzFHVTVnTkNmc0V0NDlSRnNrdENIWWwyZkFreTJJd0duRT0.jpg],
        media_files: [{ file_size: 256_345 }],
        page_url: "https://chengyeliuli.lofter.com/post/1d127639_2b6e850c8",
        profile_urls: %w[https://chengyeliuli.lofter.com],
        display_name: "桃原",
        username: "chengyeliuli",
        tags: [
          ["卡涅利安", "https://www.lofter.com/tag/卡涅利安"],
          ["arknights", "https://www.lofter.com/tag/arknights"],
          ["明日方舟", "https://www.lofter.com/tag/明日方舟"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          練習

          画画卡姐～
        EOS
      )
    end

    context "A lofter post with commentary under <.m-post .cont .text>" do
      strategy_should_work(
        "https://qiuchenghanshuang.lofter.com/post/1f9d6464_2b736607b",
        image_urls: %w[
          https://imglf4.lf127.net/img/68d1578576f2e8a0/akFYeFo0L0VFMno5d0JuNHlwQ3VMdEFxYysyN1ZseVduNzFkbG9MdUlFVT0.jpg
          https://imglf6.lf127.net/img/9970d5715bd5f72a/akFYeFo0L0VFMno5d0JuNHlwQ3VMZ3QxbkttTHpHZERWZXlVS3FDNmtYcz0.jpg
        ],
        media_files: [
          { file_size: 648_715 },
          { file_size: 809_021 },
        ],
        page_url: "https://qiuchenghanshuang.lofter.com/post/1f9d6464_2b736607b",
        profile_urls: %w[https://qiuchenghanshuang.lofter.com],
        display_name: "秋某",
        username: "qiuchenghanshuang",
        tags: [
          ["缄默德克萨斯", "https://www.lofter.com/tag/缄默德克萨斯"],
          ["明日方舟", "https://www.lofter.com/tag/明日方舟"],
          ["德克萨斯", "https://www.lofter.com/tag/德克萨斯"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "过去与她擦肩而过"
      )
    end

    context "A lofter post with commentary under <.cnwrapper p:nth-child(2)>" do
      strategy_should_work(
        "https://sdz013.lofter.com/post/1ec04eca_1ccabb5df",
        image_urls: %w[
          https://imglf5.lf127.net/img/b57d91d0e107e2e6/Sytua1gwSUwyV1k3SXZxY3FiVGJvVW82Ny90bVVOeElEUmZ3bXFrbGlnST0.png
          https://imglf4.lf127.net/img/067bd19dd731b52f/Sytua1gwSUwyV1k3SXZxY3FiVGJvZWVFS25EUWVGR1FseCtkTHBFS2xzaz0.png
          https://imglf4.lf127.net/img/323e0e53fec354b8/Sytua1gwSUwyV1k3SXZxY3FiVGJvWWh2MjZSUHdvM3JNWndUS0pSSS9Gdz0.png
          https://imglf3.lf127.net/img/304d83b42234fa53/Sytua1gwSUwyV1k3SXZxY3FiVGJvY2xNK3FDQ2lTaDBOdU1lenhtNDJLaz0.png
        ],
        media_files: [
          { file_size: 244_982 },
          { file_size: 282_518 },
          { file_size: 1_830_804 },
          { file_size: 91_011 },
        ],
        page_url: "https://sdz013.lofter.com/post/1ec04eca_1ccabb5df",
        profile_urls: %w[https://sdz013.lofter.com],
        display_name: "SDZ",
        username: "sdz013",
        tags: [
          ["军团要塞2", "https://www.lofter.com/tag/军团要塞2"],
          ["TF2", "https://www.lofter.com/tag/TF2"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "本来是给外国朋友但是我销号了所以存下()"
      )
    end

    context "A lofter post with commentary under <.ct .txtcont>" do
      strategy_should_work(
        "https://okitagumi.lofter.com/post/1e69aeeb_fbb63ca",
        image_urls: %w[https://imglf4.lf127.net/img/d2ZIUXlGd2FraFNMMC9KUTNGdTFjVkZydjlsNUxhVyt2MHpUanhaeld5Vy8zZEQzUE5XMXhBPT0.jpg],
        media_files: [{ file_size: 154_620 }],
        page_url: "https://okitagumi.lofter.com/post/1e69aeeb_fbb63ca",
        profile_urls: %w[https://okitagumi.lofter.com],
        display_name: "3626151",
        username: "okitagumi",
        tags: [
          ["冲田组", "https://www.lofter.com/tag/冲田组"],
          ["加州清光", "https://www.lofter.com/tag/加州清光"],
          ["大和守安定", "https://www.lofter.com/tag/大和守安定"],
          ["原主与刀", "https://www.lofter.com/tag/原主与刀"],
          ["安清", "https://www.lofter.com/tag/安清"],
          ["清安", "https://www.lofter.com/tag/清安"],
          ["刀剑乱舞", "https://www.lofter.com/tag/刀剑乱舞"],
        ],
        dtext_artist_commentary_title: "冲田组原主与刀温馨向合志《金平糖》补货及预售通贩告知",
        dtext_artist_commentary_desc: <<~EOS.chomp
          非常感谢各位一直以来的支持和厚爱，冲田组原主与刀温馨向合志[b]《金平糖》二刷[/b]的通贩现货目前已经完售

          但由于淘宝上存在数家对《金平糖》进行盗印的不法商家，并且已经有数位受骗上当、购买了盗印的同好，为了不让这些无耻的盗印商得逞，我们决定继续对本子加印补货

          [b]淘宝通贩→[/b]"[b]※※※※[/b]":[https://item.taobao.com/item.htm?id=542050423915&qq-pf-to=pcqq.c2c]

          [b]本宣地址→[/b]"[b]※※※※[/b]":[http://okitagumi.lofter.com/post/1e69aeeb_e30959e]

          《金平糖》的通贩代理只有[b]@JACKPOT_印刷寄售社团[/b] 一家 ，除此之外全部都是盗印店，还请大家帮忙奔走相告( ´•̥×•̥` )

          补货预售期间，购买本子均会送两张特典小卡片。

          由于本次三刷补货并没有增加特典，内容也和之前完全一样，所以不再进行额外宣传。

          大家这份热忱令我们十分惊异，同时也深深感受到各位对冲田组的喜爱，谢谢每一位支持过《金平糖》的同好。

          今后也请多多指教【鞠躬

          占tag非常抱歉。
        EOS
      )
    end

    context "A photo-type lofter post with photo captions" do
      strategy_should_work(
        "https://honkai.lofter.com/post/1ff23f93_12d66a85b",
        image_urls: %w[
          https://imglf6.lf127.net/img/TjdteWU3UmU0SkpHOUVVV3RjK0MzdFNwTjlLeHkwbEdyc3FwRGZvblNFbWtyTW4xY0lqeEFBPT0.png
          https://imglf5.lf127.net/img/TjdteWU3UmU0SktNUXg5YTJ6UHhHYVp5WW5DbzZNbld4cFArZGxGSXZhbmxhR3cvR04weFVBPT0.png
          https://imglf5.lf127.net/img/TjdteWU3UmU0SktNUXg5YTJ6UHhHVy92V3lBeTZlRUxzMC9RditVc3BCSGxzYVlaMTBvWXlBPT0.png
          https://imglf3.lf127.net/img/TjdteWU3UmU0SktNUXg5YTJ6UHhHZmM3SzdBdGRWQmZScWtQYzR3YWlBcDB6RHZBSDBJbnFnPT0.png
          https://imglf6.lf127.net/img/TjdteWU3UmU0SktNUXg5YTJ6UHhHVWY1ZTVQVTNCaklscjF6M3ZyeUlrNWZEQldPR0tmY3h3PT0.png
          https://imglf6.lf127.net/img/TjdteWU3UmU0SktNUXg5YTJ6UHhHV3ZZbXB0UFVWUUEwUDk5aWJ3M25odGJtUFBTN0hTMkh3PT0.png
          https://imglf4.lf127.net/img/TjdteWU3UmU0SktNUXg5YTJ6UHhHWnpnSzBMTnJpL0h1ZmJuY1U4ZVlYRXNzaHJxMGVsc2l3PT0.png
          https://imglf6.lf127.net/img/TjdteWU3UmU0SktNUXg5YTJ6UHhHZHM4aHhCdW1xR2pOOHJDSng2WGxVYmdoS2h0Vkg1cVpnPT0.png
          https://imglf6.lf127.net/img/TjdteWU3UmU0SktNUXg5YTJ6UHhHVzlCRW5kSy9zSGpPait1QW9EZkRNMU91T3NCZWdqcnRRPT0.png
          https://imglf6.lf127.net/img/TjdteWU3UmU0SktZaGlOalFHeXdoREhDUXBYT3Z5YldkK3lXUHd5Z0l1OXdNNjhOUUNHRWlnPT0.png
        ],
        media_files: [
          { file_size: 7_046_333 },
          { file_size: 4_346_073 },
          { file_size: 4_423_483 },
          { file_size: 3_761_709 },
          { file_size: 4_608_582 },
          { file_size: 4_862_937 },
          { file_size: 3_859_898 },
          { file_size: 4_379_177 },
          { file_size: 3_962_693 },
          { file_size: 5_450_938 },
        ],
        page_url: "https://honkai.lofter.com/post/1ff23f93_12d66a85b",
        profile_urls: %w[https://honkai.lofter.com],
        display_name: "崩崩CG Collection",
        username: "honkai",
        tags: [
          ["崩坏学园2", "https://www.lofter.com/tag/崩坏学园2"],
          ["登陆CG", "https://www.lofter.com/tag/登陆CG"],
          ["琪亚娜", "https://www.lofter.com/tag/琪亚娜"],
          ["德丽莎", "https://www.lofter.com/tag/德丽莎"],
          ["布洛妮娅", "https://www.lofter.com/tag/布洛妮娅"],
          ["杏玛尔", "https://www.lofter.com/tag/杏玛尔"],
          ["雷电芽衣", "https://www.lofter.com/tag/雷电芽衣"],
          ["九霄", "https://www.lofter.com/tag/九霄"],
          ["希儿", "https://www.lofter.com/tag/希儿"],
          ["姬子", "https://www.lofter.com/tag/姬子"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          "[image]":[https://imglf6.lf127.net/img/TjdteWU3UmU0SkpHOUVVV3RjK0MzdFNwTjlLeHkwbEdyc3FwRGZvblNFbWtyTW4xY0lqeEFBPT0.png]

          "[image]":[https://imglf5.lf127.net/img/TjdteWU3UmU0SktNUXg5YTJ6UHhHYVp5WW5DbzZNbld4cFArZGxGSXZhbmxhR3cvR04weFVBPT0.png]

          Kiana Kaslana / 琪亚娜·卡斯兰娜

          "[image]":[https://imglf5.lf127.net/img/TjdteWU3UmU0SktNUXg5YTJ6UHhHVy92V3lBeTZlRUxzMC9RditVc3BCSGxzYVlaMTBvWXlBPT0.png]

          Raiden Mei / 雷电芽衣

          "[image]":[https://imglf3.lf127.net/img/TjdteWU3UmU0SktNUXg5YTJ6UHhHZmM3SzdBdGRWQmZScWtQYzR3YWlBcDB6RHZBSDBJbnFnPT0.png]

          Bronya Zaychik / 布洛妮娅·扎伊切克

          "[image]":[https://imglf6.lf127.net/img/TjdteWU3UmU0SktNUXg5YTJ6UHhHVWY1ZTVQVTNCaklscjF6M3ZyeUlrNWZEQldPR0tmY3h3PT0.png]

          Theresa Apocalypse / 德丽莎·阿波卡利斯

          "[image]":[https://imglf6.lf127.net/img/TjdteWU3UmU0SktNUXg5YTJ6UHhHV3ZZbXB0UFVWUUEwUDk5aWJ3M25odGJtUFBTN0hTMkh3PT0.png]

          Murata Himeko / 无量塔姬子

          "[image]":[https://imglf4.lf127.net/img/TjdteWU3UmU0SktNUXg5YTJ6UHhHWnpnSzBMTnJpL0h1ZmJuY1U4ZVlYRXNzaHJxMGVsc2l3PT0.png]

          Sin Mal / 杏·玛尔

          "[image]":[https://imglf6.lf127.net/img/TjdteWU3UmU0SktNUXg5YTJ6UHhHZHM4aHhCdW1xR2pOOHJDSng2WGxVYmdoS2h0Vkg1cVpnPT0.png]

          Seele Vollerei / 希儿·芙乐艾

          "[image]":[https://imglf6.lf127.net/img/TjdteWU3UmU0SktNUXg5YTJ6UHhHVzlCRW5kSy9zSGpPait1QW9EZkRNMU91T3NCZWdqcnRRPT0.png]

          Houraiji Kyuusyou / 蓬莱寺九霄

          "[image]":[https://imglf6.lf127.net/img/TjdteWU3UmU0SktZaGlOalFHeXdoREhDUXBYT3Z5YldkK3lXUHd5Z0l1OXdNNjhOUUNHRWlnPT0.png]

          Yssring Leavtruth / 伊瑟琳·利维休斯

          和风特辑1【第二部分请点这："和风特辑2":[https://honkai.lofter.com/post/1ff23f93_1c7d228e5]】
        EOS
      )
    end

    context "An answer-type lofter post" do
      strategy_should_work(
        "https://jiuhaotaiyangdeshexian.lofter.com/post/73f37cdf_2b86a4ae7",
        image_urls: %w[https://imglf4.lf127.net/img/767c7fec4d8e1f50/bnpEMS9YSVpSbzJNaFkvMmdtL3Q4b2IwM3lmY3NPWmZ3VFhMZ05Pb2RxRT0.jpg],
        media_files: [{ file_size: 854_991 }],
        page_url: "https://jiuhaotaiyangdeshexian.lofter.com/post/73f37cdf_2b86a4ae7",
        profile_urls: %w[https://jiuhaotaiyangdeshexian.lofter.com],
        display_name: "鸠号太阳的射线-",
        username: "jiuhaotaiyangdeshexian",
        tags: [],
        dtext_artist_commentary_title: "Q:老师！想问问最近会不会画ITZY？🥰🥰",
        dtext_artist_commentary_desc: "不好意思现在才看到！那就画一个荔枝猫猫吧😄"
      )
    end

    context "A video-type lofter post" do
      strategy_should_work(
        "https://wooden-brain.lofter.com/post/1e60de5b_1c9bf8efb",
        image_urls: %w[https://vodm2lzexwq.vod.126.net/vodm2lzexwq/Pc5jg1nL_3039990631_sd.mp4?resId=254486990bfa2cd7aa860229db639341_3039990631_1&sign=4j02HTHXqNfhaF%2B%2FO14Ny%2F9SMNZj%2FIjpJDCqXfYa4aM%3D],
        media_files: [{ file_size: 647_902 }],
        page_url: "https://wooden-brain.lofter.com/post/1e60de5b_1c9bf8efb",
        profile_urls: %w[https://wooden-brain.lofter.com],
        display_name: "依末",
        username: "wooden-brain",
        tags: [
          ["短视频", "https://www.lofter.com/tag/短视频"],
          ["明日方舟", "https://www.lofter.com/tag/明日方舟"],
          ["阿米娅", "https://www.lofter.com/tag/阿米娅"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "夏 日 活 动"
      )
    end

    context "A lofter post with the character U+00A0 in a tag" do
      strategy_should_work(
        "https://xingfulun16203.lofter.com/post/77a68dc4_2b9f0f00c",
        image_urls: %w[https://imglf4.lf127.net/img/b7c3e00acd19f7c0/azVib0c4ZHd2WVd6UEhkWG93c1QxRXM3V3VVM2pab0pqaXB3UFV4WG1tVT0.png],
        media_files: [{ file_size: 827_495 }],
        page_url: "https://xingfulun16203.lofter.com/post/77a68dc4_2b9f0f00c",
        profile_urls: %w[https://xingfulun16203.lofter.com],
        display_name: "高考去了",
        username: "xingfulun16203",
        tags: [
          ["夸奈", "https://www.lofter.com/tag/夸奈"],
          ["我推的孩子", "https://www.lofter.com/tag/我推的孩子"],
          ["夸奈24h:\u00A0海蓝苏打七夕特供", "https://www.lofter.com/tag/夸奈24h:\u00A0海蓝苏打七夕特供"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          【海蓝苏打七夕特供 13:14】

          cafe打工中但是得意猫猫

          上一棒 "@稚阳那样这些那些_":[https://www.lofter.com/mentionredirect.do?blogId=1949248035]

          下一棒 "@6663605":[https://www.lofter.com/mentionredirect.do?blogId=1264638962]
        EOS
      )
    end

    context "A uls.lofter.com/?h5url= URL" do
      strategy_should_work(
        "https://uls.lofter.com/?h5url=https%3A%2F%2Flesegeng.lofter.com%2Fpost%2F1f0aec07_2bbc5ce0b",
        image_urls: %w[https://imglf6.lf127.net/img/c1e3b9c3e508baaf/TTVWeTVSYWgxZ1pkdnluQnhlbC9Fc25Zd0hQZzN0ZUxuUjQzdVdzL2dYWT0.jpg],
        media_files: [{ file_size: 2_228_804 }],
        page_url: "https://lesegeng.lofter.com/post/1f0aec07_2bbc5ce0b",
        profile_urls: %w[https://lesegeng.lofter.com],
        display_name: "羔",
        username: "lesegeng",
        tags: [
          ["幻密", "https://www.lofter.com/tag/幻密"],
          ["apex", "https://www.lofter.com/tag/apex"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          泰俊欧巴🥰超绝可爱🔥有趣灵魂💖全能爱豆 ✨人间水蜜桃🍑 舞蹈天才💃🏻 快乐源泉😊 小甜豆‍🍬 人间治愈🍭 小精灵🧚‍♀️ 露脸即吸粉🎉 性格魅力无限♾️ 肩宽腿长🦾完美身材😛 肤白貌美🌸 笑容甜美💖 人间花仙子🥰 不断超越自己💃🏻 励志爱豆👐 完美爱豆来了🤚 快让开🔥 氛围美学大师🍬 实力吸粉🍑 镜头捕捉能力者📷 直拍匠人🔥 完美舞台表现力✨
        EOS
      )
    end

    context "A dead link" do
      strategy_should_work(
        "https://gxszdddd.lofter.com/post/322595b1_1ca5e6f66",
        image_urls: [],
        page_url: "https://gxszdddd.lofter.com/post/322595b1_1ca5e6f66",
        profile_urls: %w[https://gxszdddd.lofter.com],
        display_name: nil,
        username: "gxszdddd",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: ""
      )
    end

    should "Parse Lofter URLs correctly" do
      assert(Source::URL.image_url?("https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJSzFCWFlnUWgzb01DcUdpT1lreG5yQjJVMkhGS09HNGR3PT0.png?imageView&thumbnail=1680x0&quality=96&stripmeta=0"))
      assert(Source::URL.image_url?("http://imglf0.nosdn.127.net/img/cHl3bXNZdDRaaHBnNWJuN1Y4OXBqR01CeVBZSVNmU2FWZWtHc1h4ZTZiUGxlRzMwZnFDM1JnPT0.jpg "))
      assert(Source::URL.image_url?("https://vodm2lzexwq.vod.126.net/vodm2lzexwq/Pc5jg1nL_3039990631_sd.mp4?resId=254486990bfa2cd7aa860229db639341_3039990631_1&sign=4j02HTHXqNfhaF%2B%2FO14Ny%2F9SMNZj%2FIjpJDCqXfYa4aM%3D"))

      assert(Source::URL.page_url?("https://gengar563.lofter.com/post/1e82da8c_1c98dae1b"))
      assert(Source::URL.page_url?("https://gengar563.lofter.com/front/post/1e82da8c_1c98dae1b"))
      assert(Source::URL.page_url?("https://uls.lofter.com/?h5url=https%3A%2F%2Flesegeng.lofter.com%2Fpost%2F1f0aec07_2bbc5ce0b"))

      assert(Source::URL.profile_url?("https://www.lofter.com/front/blog/home-page/noshiqian"))
      assert(Source::URL.profile_url?("http://www.lofter.com/app/xiaokonggedmx"))
      assert(Source::URL.profile_url?("http://www.lofter.com/blog/semblance"))
      assert(Source::URL.profile_url?("http://gengar563.lofter.com"))
    end
  end
end
