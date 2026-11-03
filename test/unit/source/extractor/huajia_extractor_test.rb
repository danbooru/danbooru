require "test_helper"

module Source::Tests::Extractor
  class HuajiaExtractorTest < ActiveSupport::ExtractorTestCase
    context "A Huajia sample image url" do
      strategy_should_work(
        "https://huajia.fp.ps.netease.com/file/66438c2ecacb41c36cbdd2efaN19wMFy05?fop=imageView/2/w/300/f/webp",
        image_urls: %w[https://huajia.fp.ps.netease.com/file/66438c2ecacb41c36cbdd2efaN19wMFy05],
        media_files: [{ file_size: 3_131_672 }],
        page_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A Huajia work" do
      strategy_should_work(
        "https://huajia.163.com/main/works/rOpdeMW8",
        image_urls: %w[https://huajia.fp.ps.netease.com/file/663089604035725a9af3e5f34JAsQteB05],
        media_files: [{ file_size: 130_859 }],
        page_url: "https://huajia.163.com/main/works/rOpdeMW8",
        profile_urls: %w[https://huajia.163.com/main/profile/08nqxj4r],
        display_name: "瓶装咸鱼",
        username: nil,
        published_at: Time.parse("2024-04-30T06:02:09.000000Z"),
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "An animated Huajia work" do
      strategy_should_work(
        "https://huajia.163.com/main/works/EXO5o6KB",
        image_urls: %w[https://huajia.fp.ps.netease.com/file/68732bdd0f4c1d0a3852c3cby2LKJszF06],
        media_files: [{ file_size: 264_382 }],
        profile_url: "https://huajia.163.com/main/profile/L8JwqDWB",
        display_name: "凤梨酥酥",
        username: nil,
        published_at: Time.parse("2025-07-13T03:45:35.000000Z"),
        updated_at: nil,
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A Huajia goods with HEIC" do
      strategy_should_work(
        "https://huajia.163.com/main/goods/details/6B443KbB",
        image_urls: %w[
          https://huajia.fp.ps.netease.com/file/68724ebfdc56c5d0d7195f56PvqA0Bgx06
          https://huajia.fp.ps.netease.com/file/68724ec14357f3151e2ab007zfhuF7mj06
          https://huajia.fp.ps.netease.com/file/68a55b1be0a9716cbfa159ddTRQ0H9Iu06
          https://huajia.fp.ps.netease.com/file/6891817d377ba070d24d1abb8EW2shoA06
          https://huajia.fp.ps.netease.com/file/68a1f2e66d05d47345969551NqCqusmp06
          https://huajia.fp.ps.netease.com/file/68ca2feb87612429e8aaf37f6m07Ygs506
        ],
        media_files: [
          { file_size: 754_148 },
          { file_size: 8_792_017 },
          { file_size: 2_891_640 },
          { file_size: 742_138 },
          { file_size: 737_768 },
          { file_size: 3_037_520 },
        ],
        page_url: "https://huajia.163.com/main/goods/details/6B443KbB",
        profile_urls: %w[https://huajia.163.com/main/profile/VBRoQPOE],
        display_name: "60号小豆鲨",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "【加急24h】仿大川双人半身",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          加急版，不太擅长西幻类复杂服设
          ①固定背景+黑色线稿版，复杂小物看情况➕5-20r，简单的不用加钱
          ②工期为确认接单后1天内
          ③有不接的角色/企划，随时可能增减，详细请看主页动态
          ④请尽量提供动作要求/角色性格以避免ooc！！
          ⑤约稿请三思！！！不论出没出草稿，退稿都需付20%的跑单费，并且拉黑永不交易！
          ⑥约稿流程：草稿→成图
          ⚠不接商用，无料×1.5，自印随意，均无数量限制
        EOS
      )
    end

    context "A Huajia goods with GIF" do
      strategy_should_work(
        "https://huajia.163.com/main/goods/details/vE7jk9OB",
        image_urls: %w[
          https://huajia.fp.ps.netease.com/file/69bb7abde5fa8e66539a7f3dD8EhqrKa07
          https://huajia.fp.ps.netease.com/file/69a662bd9aa7bac87d9593c14OhuAm3h07
          https://huajia.fp.ps.netease.com/file/6778c2c0414c2243f3ad3e79MA1xiwdE06
          https://huajia.fp.ps.netease.com/file/676baac6fc8a03b6fde804c0agjmSjub06
          https://huajia.fp.ps.netease.com/file/676bac89704478f217b2e771KSI9ZJiq06
          https://huajia.fp.ps.netease.com/file/676bac516972c0f723696b4a0zB5yz3O06
          https://huajia.fp.ps.netease.com/file/676bac88bef42428182ad9c7tQ6Io3Yb06
        ],
        media_files: [
          { file_size: 347_062 },
          { file_size: 444_768 },
          { file_size: 496_969 },
          { file_size: 385_295 },
          { file_size: 414_308 },
          { file_size: 610_943 },
          { file_size: 538_206 },
        ],
        page_url: "https://huajia.163.com/main/goods/details/vE7jk9OB",
        profile_urls: %w[https://huajia.163.com/main/profile/Rrwo1oqr],
        display_name: "牙牙DH",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "❤️72h会动的小Q人！",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          有时开限量特价，可以蹲蹲捏
          节日的时候会改节日窗但是需要相关主题麻烦说一下，不然我可能就画成日常窗了(♡>𖥦<)/♥

          💡标价为单人
          👉🏻无料自印随意
          液化二改随意但不要发给我👈🏻

          下单后请看自动回复

          我很爽反正不知道老板你爽不爽
          一键出图可以带动作（不一定画得来
          细节不画！
          设定画错可改
          会画一个眨眼小动图，其他的全看发挥，随便动动，有想要的可以提，不复杂都可以满足滴
          默认展示
          贴贴双人×2，多人×多
          不管什么设定基本都可以哐哐画~
        EOS
      )
    end

    context "A Huajia commission with only character settings" do
      strategy_should_work(
        "https://huajia.163.com/main/projects/details/V82ZD9z8",
        image_urls: [],
        media_files: [],
        page_url: "https://huajia.163.com/main/projects/details/V82ZD9z8",
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "给小鱼约点图…",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          比较想吃点大头/服设之类的……能画人鱼/双人互动的大大欢迎！
          当然其他业务也都可，会优先挑比较戳我的画风来吃🥺🙌🏻🙌🏻
          有两个形态，大人们可以提前说明想画白的/黑的。
        EOS
      )
    end

    context "A Huajjia commission with no images" do
      strategy_should_work(
        "https://huajia.163.com/main/projects/details/pB01DejE",
        image_urls: [],
        media_files: [],
        page_url: "https://huajia.163.com/main/projects/details/pB01DejE",
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "蹲蹲能画黑色哥特长裙oc的小画师",
        dtext_artist_commentary_desc: "偏好御姐或者成熟冷脸少女类型，更倾向于半身or全身，oc头发和新服设是全身黑，不过服设会一版白色的方便你看清结构，先攒攒小画手，遇到喜欢的会来约ovo",
      )
    end

    context "A Huajia commission with a description image" do
      strategy_should_work(
        "https://huajia.163.com/main/projects/details/d8Yz6g0B",
        image_urls: %w[https://huajia.fp.ps.netease.com/file/6ae93813b0188ed3da81ae8fFHBxw3ld07],
        media_files: [{ file_size: 143_264 }],
        page_url: "https://huajia.163.com/main/projects/details/d8Yz6g0B",
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "古风服设",
        dtext_artist_commentary_desc: "不要太儒雅的版型，想要江湖气或者偏日常的设计，会加毛领子的大欢迎，孩子性格比较跳脱希望衣服也能野一点，超预算也可以例图够牛逼就行，希望花纹和配饰会有一些特色，最好擅长画成男的",
      )
    end

    context "A Huajia character setting" do
      strategy_should_work(
        "https://huajia.163.com/main/characterSetting/details/WEXKjKoB",
        image_urls: [],
        media_files: [],
        page_url: "https://huajia.163.com/main/characterSetting/details/WEXKjKoB",
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end
  end
end
