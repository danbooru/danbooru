require "test_helper"

module Source::Tests::Extractor
  class HuajiaExtractorTest < ActiveSupport::ExtractorTestCase
    context "A Huajia sample image url" do
      strategy_should_work(
        "https://huajia.fp.ps.netease.com/file/66438c2ecacb41c36cbdd2efaN19wMFy05?fop=imageView/2/w/300/f/webp",
        image_urls: %w[https://huajia.fp.ps.netease.com/file/66438c2ecacb41c36cbdd2efaN19wMFy05],
        media_files: [{ file_size: 3_131_672 }],
        page_url: nil,
        profile_url: nil,
        display: nil,
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
          加价服务清单
          加一个人人物（双人互动） ¥30
          商用 x1.5

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
        "https://huajia.163.com/main/projects/details/1rxjP93B",
        image_urls: [],
        media_files: [],
        profile_url: nil,
        display_name: nil,
        dtext_artist_commentary_title: "想吃平价小零食😋🤲🏻（拖家带口版）",
        dtext_artist_commentary_desc: "想要出图快的😭🫳🏻🫳🏻 🥬的😭 预算10~80其实是",
      )
    end

    context "A Huajjia commission with no images" do
      strategy_should_work(
        "https://huajia.163.com/main/projects/details/LBpxo0wB",
        image_urls: [],
        media_files: [],
        profile_url: nil,
        display_name: nil,
        dtext_artist_commentary_title: "［文手老师来］我想要建设一个梦女角色",
        dtext_artist_commentary_desc: "是1999中阿莱夫的梦女\n想要约文设，要求尽量贴合我现实中的性格\n外貌可以随意设计\n预算无上限，价格合理就好，必须有一定文字与设计功底，拒绝坐地起价\n希望可以有一点耐心，我打字慢\n过程流畅，作品高质￼我会狠狠打奶茶钱",
      )
    end

    context "A Huajia commission with a description image" do
      strategy_should_work(
        "https://huajia.163.com/main/projects/details/K85e1RO8",
        image_urls: %w[https://huajia.fp.ps.netease.com/file/687273cd28649e056788f746SCrk3M6r06],
        media_files: [{ file_size: 215_082 }],
        profile_url: nil,
        display_name: nil,
        dtext_artist_commentary_title: "我想约古早插",
        dtext_artist_commentary_desc: "看对眼我就约（不要模版）🥴",
      )
    end

    context "A Huajia character setting" do
      strategy_should_work(
        "https://huajia.163.com/main/characterSetting/details/WEXKjKoB",
        image_urls: [],
        media_files: [],
        profile_urls: %w[],
        display_name: nil,
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end
  end
end
