require "test_helper"

module Source::Tests::Extractor
  class HuashijieExtractorTest < ActiveSupport::ExtractorTestCase
    context "A Huashijie sample image url" do
      strategy_should_work(
        "https://bsyimgv2.pandapaint.net/v2/album_cover/user/17873127/1736262275939.png?x-oss-process=style/work_cover&image_process=format,WEBP",
        image_urls: %w[https://bsyimgv2.pandapaint.net/v2/album_cover/user/17873127/1736262275939.png],
        media_files: [{ file_size: 57_469 }],
        page_url: nil,
        profile_url: "https://www.huashijie.art/user/index/17873127",
        display_name: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A https://www.huashijie.art/work/detail/:id url" do
      strategy_should_work(
        "https://www.huashijie.art/work/detail/236710740",
        image_urls: [
          "http://bsyimg.pandapaint.net/v2/work_cover/user/13649297/1751901251442.jpg",
          "http://bsyimg.pandapaint.net/v2/work_cover/user/13649297/1751901252452.jpg",
        ],
        media_files: [
          { file_size: 63_176 },
          { file_size: 62_615 },
        ],
        page_url: "https://www.huashijie.art/work/detail/236710740",
        profile_urls: %w[https://www.huashijie.art/user/index/13649297],
        display_name: "天童爱丽丝实名上网",
        tag_name: "huashijie_13649297",
        tags: [
          ["二创", "https://www.huashijie.art/topic/20"],
          ["万能画题", "https://www.huashijie.art/topic/272198"],
          ["经验+10，岂不美哉", "https://www.huashijie.art/topic/204826"],
          ["去他妈标签", "https://www.huashijie.art/topic/58645"],
          ["伊蕾娜", "https://www.huashijie.art/topic/252115"],
          ["魔女之旅", "https://www.huashijie.art/topic/199343"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "给亲友画的",
      )
    end

    context "A Huashijie video post" do
      strategy_should_work(
        "https://www.huashijie.art/work/detail/236780608",
        image_urls: ["http://bsyimg.pandapaint.net/v2/video/user/13236644/1751972885632.mp4"],
        media_files: [{ file_size: 19_211_353 }],
        profile_url: "https://www.huashijie.art/user/index/13236644",
        display_name: "耑江古木",
        artist_commentary_desc: "结企了还没画完，于是草草结尾\n【提取音频的软件到期了，所以没差声音】\n有声版↓[随便点哪个都行，都一样]\nxhs：http://xhslink.com/a/00kvjQHh4RCgb \nB站：https://b23.tv/3UUFwcH\ndy：https://v.douyin.com/znwIiWQwdiU",
      )
    end

    context "A hidden Huashijie post" do
      strategy_should_work(
        "https://www.huashijie.art/work/detail/202993620",
        image_urls: %w[http://bsyimg.pandapaint.net/v2/work_cover/user/14619015/1716385980581.jpg],
        media_files: [{ file_size: 542_602 }],
        page_url: "https://www.huashijie.art/work/detail/202993620",
        profile_urls: %w[https://www.huashijie.art/user/index/14619015],
        display_name: "就叫阿金",
        tags: [
          ["二创", "https://www.huashijie.art/topic/20"],
          ["明日方舟", "https://www.huashijie.art/topic/946"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "我掐指一算，这应该是我第一次花这么大精力去画“线稿”\n确定线稿后有种操作空间变小的感觉，不能像之前样随意了，但是这样确实能更快确定完要画的元素\n现在想象不出填完固有色有什么好效果，希望不会画崩🙏🙏🙏",
      )
    end

    context "A Huashijie product" do
      strategy_should_work(
        "https://www.huashijie.art/market/detail/325347",
        image_urls: %w[http://bsyimgv2.pandapaint.net/v2/pd_cover/public/1749929498693.png],
        media_files: [{ file_size: 1_859_721 }],
        page_url: "https://www.huashijie.art/market/detail/325347",
        profile_urls: %w[https://www.huashijie.art/user/index/15452779],
        display_name: "小翟翟翟翟",
        tags: [],
        dtext_artist_commentary_title: "漫画分镜插画第二弹(7月排单",
        dtext_artist_commentary_desc: "就是漫画风格的分镜图中可以出现三个人物，一个大头特写和一个全身简单绘画，一个小q在后面。\n7月6号到8号左右开始开稿。",
      )
    end

    context "A Huashijie product with GIFs" do
      strategy_should_work(
        "https://www.huashijie.art/market/detail/324633",
        image_urls: [
          "http://bsyimgv2.pandapaint.net/v2/pd_cover/public/1743220693607.gif",
          "http://bsyimgv2.pandapaint.net/v2/pd_cover/public/1743423127058.gif",
          "http://bsyimgv2.pandapaint.net/v2/pd_cover/public/1749315551038.gif",
        ],
        media_files: [
          { file_size: 237_447 },
          { file_size: 936_275 },
          { file_size: 155_897 },
        ],
        profile_url: "https://www.huashijie.art/user/index/9071946",
        display_name: "Cheerful_Ano",
        dtext_artist_commentary_title: "Q版+动图",
        dtext_artist_commentary_desc: "由于本人工作繁忙，画的非常慢，请谅解。\n不要催稿！非常慢！要排单！要等！少则半个月多则三个月！没出草稿前，可以随时退款。\n提供完整的清晰的设定！\n暂时不接文设！不接AI设定！\n拍前联系我！需要先看设定~\n偏好可爱的色彩丰富的略复杂的设定\n四帧动图。",
      )
    end
  end
end
