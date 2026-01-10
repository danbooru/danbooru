require "test_helper"

module Source::Tests::Extractor
  class MihuashiExtractorTest < ActiveSupport::TestCase
    context "A Mihuashi sample image url" do
      strategy_should_work(
        "https://image-assets.mihuashi.com/pfop/permanent/4329541|-2024/07/12/18/Fu2oKtHkplA-waTASBzUpF6EozkB.jpg!artwork.detail",
        image_urls: %w[https://image-assets.mihuashi.com/permanent/4329541|-2024/07/12/18/Fu2oKtHkplA-waTASBzUpF6EozkB.jpg],
        media_files: [{ file_size: 3_832_210 }],
        page_url: nil,
        profile_url: nil,
        display: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A Mihuashi work" do
      strategy_should_work(
        "https://www.mihuashi.com/artworks/15092919",
        image_urls: %w[https://image-assets.mihuashi.com/permanent/29105|-2024/05/29/16/FuE-9jWo-aPKXOq2KP2ZsR5Nxnqa.jpg],
        media_files: [{ file_size: 597_376 }],
        page_url: "https://www.mihuashi.com/artworks/15092919",
        profile_url: "https://www.mihuashi.com/profiles/29105",
        profile_urls: [
          "https://www.mihuashi.com/users/spirtie",
          "https://www.mihuashi.com/profiles/29105",
        ],
        username: "spirtie",
        tags: [
          ["日系", "https://www.mihuashi.com/search?tab=artwork&q=日系"],
          ["厚涂", "https://www.mihuashi.com/search?tab=artwork&q=厚涂"],
          ["插图", "https://www.mihuashi.com/search?tab=artwork&q=插图"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A Mihuashi work with GIF" do
      strategy_should_work(
        "https://www.mihuashi.com/artworks/13693110",
        image_urls: %w[https://image-assets.mihuashi.com/permanent/321972|-2024/03/10/10/FuMarkKYoykuY3yCrPA7d8lrF3U6.gif],
        media_files: [{ file_size: 1_145_184 }],
        profile_url: "https://www.mihuashi.com/profiles/321972",
        username: "yuyuco",
        tags: [
          ["日系", "https://www.mihuashi.com/search?tab=artwork&q=日系"],
          ["Q版", "https://www.mihuashi.com/search?tab=artwork&q=Q版"],
          ["萌系", "https://www.mihuashi.com/search?tab=artwork&q=萌系"],
          ["表情包", "https://www.mihuashi.com/search?tab=artwork&q=表情包"],
          ["GIF", "https://www.mihuashi.com/search?tab=artwork&q=GIF"],
          ["meme", "https://www.mihuashi.com/search?tab=artwork&q=meme"],
          ["碧蓝档案", "https://www.mihuashi.com/search?tab=artwork&q=碧蓝档案"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A Mihuashi stall" do
      strategy_should_work(
        "https://www.mihuashi.com/stalls/71664",
        image_urls: [
          "https://image-assets.mihuashi.com/permanent/532464|-2022/06/16/13/FtdFrMGUhkBG16Ou6g7Rr2cHLroy.jpg",
          "https://image-assets.mihuashi.com/permanent/532464|-2022/06/16/13/FtujtqU-s3kR3zOcJeGdJTFaOdLd.jpg",
          "https://image-assets.mihuashi.com/permanent/532464|-2022/08/14/13/FoS45kvnZAuuldCm1RfQBYNCEtpq.jpg",
        ],
        media_files: [
          { file_size: 1_675_148 },
          { file_size: 363_940 },
          { file_size: 3_586_679 },
        ],
        page_url: "https://www.mihuashi.com/stalls/71664",
        profile_url: "https://www.mihuashi.com/profiles/532464",
        profile_urls: [
          "https://www.mihuashi.com/users/黑石肆维",
          "https://www.mihuashi.com/profiles/532464",
        ],
        username: "黑石肆维",
        tags: [],
        dtext_artist_commentary_title: "印象QQ服",
        dtext_artist_commentary_desc: "封面这样的一身服设，拍下请提供设定图，会根据设定绘制印象服设，可以指定风格元素等！\n如想约两件及以上可以拍一个橱窗然后改价！\n流程：草稿-成图（修改意见请尽量在草稿提出，成图后就不能作大面积调整啦抱歉！（颜色成图后也可以随便改））\n\n备注：默认可以二转二改，商用需×3，有需要可以提供透明底线稿，草稿可以推翻重画两次（废稿会回收），小改次数不限，过程中如果觉得不满意到无法进行修改的程度随时可以沟通退稿，我真的很好说话，有意见尽管提出就好！！！\n\n感谢每位约稿的老板！！！",
      )
    end

    context "A Mihuashi project with no images" do
      strategy_should_work(
        "https://www.mihuashi.com/projects/4277264",
        image_urls: [],
        media_files: [],
        profile_url: nil,
        profile_urls: [],
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "💖五仁2025个人企划",
        dtext_artist_commentary_desc: "2025年五仁企划留档",
      )
    end

    context "A Mihuashi project with only character card" do
      strategy_should_work(
        "https://www.mihuashi.com/projects/4558342",
        image_urls: [],
        media_files: [],
        profile_url: nil,
        profile_urls: [],
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "Amorolvido的2025年企💐🪦🕯️",
        dtext_artist_commentary_desc: "Amorolvido的2025年全年企划\n提供了5套设定（1原设+4服设）\n应征可以明确表示想画哪一个o(≧v≦)o\n感谢大家对Amor的喜欢🥺😚❤️\n祝大家25年心想事成万事如意喔",
      )
    end

    context "A Mihuashi project with example images" do
      strategy_should_work(
        "https://www.mihuashi.com/projects/3187367",
        image_urls: [
          "https://image-assets.mihuashi.com/permanent/549773|-2024/06/28/21/FgeSbP72PUkTjP07aQ2pozIi2pzA.png",
          "https://image-assets.mihuashi.com/permanent/549773|-2024/06/28/21/FvBRLIIyGWDDmVNMPev_Y4cUT2YU.png",
        ],
        media_files: [
          { file_size: 2_366_137 },
          { file_size: 3_860_918 },
        ],
        profile_url: nil,
        profile_urls: [],
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "墨殇离歌Project宣传图-多人互动",
        dtext_artist_commentary_desc: "OC企划宣传图-日系二次元多人宣传图。报价为单张商断报价相信价格根据具体细节沟通确定。详细需求会以文件形式发送给画师，欢迎应征",
      )
    end

    context "A Mihuashi project that requires login" do
      strategy_should_work(
        "https://www.mihuashi.com/projects/6401121",
        image_urls: [],
        media_files: [],
        profile_url: nil,
        profile_urls: [],
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A Mihuashi character card" do
      strategy_should_work(
        "https://www.mihuashi.com/character-card/4dc65278776db4741a897d7445f48a6b57ce251c/project",
        image_urls: %w[https://image-assets.mihuashi.com/permanent/7161154|-2025/07/12/18/FgDo1GzzwLfGrO-nwSRTmF5x4Gsw_3401.jpg],
        media_files: [{ file_size: 869_674 }],
        page_url: "https://www.mihuashi.com/character-card/4dc65278776db4741a897d7445f48a6b57ce251c",
        profile_url: nil,
        profile_urls: [],
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "1",
        dtext_artist_commentary_desc: "还原，细致",
      )
    end

    context "A Mihuashi character card with example images" do
      strategy_should_work(
        "https://www.mihuashi.com/character-card/3728832b46de73a631371f7914e1823c95004eb7/project",
        image_urls: [
          "https://image-assets.mihuashi.com/permanent/56929|-2024/10/29/12/ljTHvro-VMk2CBTcpOTRusozYp9s_4355.png",
          "https://image-assets.mihuashi.com/permanent/56929|-2024/10/29/12/FkLd_1HidSLiAM9X8NTAefZjXzpp_4351.jpg",
          "https://image-assets.mihuashi.com/permanent/56929|-2024/10/29/12/ljTHvro-VMk2CBTcpOTRusozYp9s_4358.png",
          "https://image-assets.mihuashi.com/permanent/56929|-2024/10/29/12/ltB8l115fhfah3Ki8nllqA9_Uqr0_4355.png",
        ],
        media_files: [
          { file_size: 4_824_337 },
          { file_size: 532_969 },
          { file_size: 4_824_337 },
          { file_size: 5_166_208 },
        ],
        profile_url: nil,
        profile_urls: [],
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "一些可以使用的元素",
        dtext_artist_commentary_desc: "生命之流是图1绿色的流动的线，菲拉是图二的黑色斗篷",
      )
    end

    context "A Mihuashi activity work" do
      strategy_should_work(
        "https://www.mihuashi.com/activities/houkai3-stigmata/artworks/8523",
        image_urls: %w[https://activity-assets.mihuashi.com/2019/06/16/07/1icxr2tlafwxdwry4puu55zi6v9d1u0t/1icxr2tlafwxdwry4puu55zi6v9d1u0t.png],
        media_files: [{ file_size: 8_296_841 }],
        page_url: "https://www.mihuashi.com/activities/houkai3-stigmata/artworks/8523?type=lsly",
        profile_url: "https://www.mihuashi.com/profiles/16150",
        profile_urls: [
          "https://www.mihuashi.com/users/悪の箱",
          "https://www.mihuashi.com/profiles/16150",
        ],
        username: "悪の箱",
        tags: [],
        dtext_artist_commentary_title: "粉蓝夏日泳装",
        dtext_artist_commentary_desc: "成年人也想吹泡泡~(´-ω-`)【粉蓝萝莉的设计真的很棒！！",
      )
    end

    context "A Mihuashi activity work with multiple images" do
      strategy_should_work(
        "https://www.mihuashi.com/activities/jw3-exterior-12/artworks/10515?type=zjjh",
        image_urls: [
          "https://activity-assets.mihuashi.com/2021/07/04/01/FvJ4MjqshV3u2etTc_8-gD4vFfy-.jpg",
          "https://activity-assets.mihuashi.com/2021/07/04/01/FgPagYyKnA-DDGpqVr8lgda0dx-h.jpg",
          "https://activity-assets.mihuashi.com/2021/07/04/01/FiShox3Y97DikJuPKelQF-VldEYI.jpg",
          "https://activity-assets.mihuashi.com/2021/07/04/01/FomTWNvkUblg28rJANmTyeRwL8k4.jpg",
          "https://activity-assets.mihuashi.com/2021/07/04/01/lkbHCi8Lb_A2Us-ifVqB4Shnjai_.jpg",
        ],
        media_files: [
          { file_size: 838_313 },
          { file_size: 693_836 },
          { file_size: 903_642 },
          { file_size: 758_627 },
          { file_size: 1_336_968 },
        ],
        page_url: "https://www.mihuashi.com/activities/jw3-exterior-12/artworks/10515?type=zjjh",
        profile_url: "https://www.mihuashi.com/profiles/492",
        profile_urls: [
          "https://www.mihuashi.com/users/CR",
          "https://www.mihuashi.com/profiles/492",
        ],
        username: "CR",
        tags: [],
        dtext_artist_commentary_title: "纸仙云鹤",
        dtext_artist_commentary_desc: "这套时装灵感来自于中国传统剪纸文化，结合了仙鹤和祥云的元素。\n红色的宣纸上剪裁出仙鹤在祥云中飞翔的图案，希望给大家带来温暖的感觉。",
      )
    end

    context "A Mihuashi work by a user with name changes" do
      strategy_should_work(
        "https://www.mihuashi.com/artworks/13982141",
        image_urls: %w[https://image-assets.mihuashi.com/permanent/109517|-2024/03/26/16/FtXN5dkc5qiWjatvcUBCNsq2yAzM.jpg],
        media_files: [{ file_size: 510_468 }],
        page_url: "https://www.mihuashi.com/artworks/13982141",
        profile_urls: %w[https://www.mihuashi.com/profiles/109517 https://www.mihuashi.com/users/破嗝嗝],
        display_name: nil,
        username: "破嗝嗝",
        other_names: %w[破嗝嗝 Og-pogg],
        tags: [
          ["日系", "https://www.mihuashi.com/search?tab=artwork&q=日系"],
          ["平涂", "https://www.mihuashi.com/search?tab=artwork&q=平涂"],
          ["Q版", "https://www.mihuashi.com/search?tab=artwork&q=Q版"],
          ["插图", "https://www.mihuashi.com/search?tab=artwork&q=插图"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "蔚蓝档案小桃",
      )
    end
  end
end
