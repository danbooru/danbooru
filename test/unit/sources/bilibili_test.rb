require 'test_helper'

module Sources
  class BilibiliTest < ActiveSupport::TestCase
    context "A t.bilibili.com/:id post" do
      strategy_should_work(
        "https://t.bilibili.com/686082748803186697",
        image_urls: [
          "https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/4c6b93d5e85b8ed5b84c3f04909f195711742550.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/e1a1e6be01b6c68f6610cdf1d127f38311742550.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/9ff31bbe8005aa1b9c438e1b2e6ce81111742550.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/716a9733fc804d11d823cfacb7a3c78b11742550.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/fa42eaa6ee9cd2a896cadc41e16ab62b11742550.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/fc9553ff7e4ad1185e0379b3ccf7e2d911742550.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/da95475b858be577fc8c79bd22b7519e11742550.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/60a3c652b362c54bc61ea3365258d1d111742550.jpg",
        ],
        page_url: "https://t.bilibili.com/686082748803186697",
        artist_name: "哈米伦的弄笛者",
        other_names: ["哈米伦的弄笛者"],
        tag_name: "bilibili_11742550",
        profile_url: "https://space.bilibili.com/11742550",
        tags: [],
        artist_commentary_title: nil,
        dtext_artist_commentary_desc: "\"【崩坏3】少女，泳装，夏日时光！\":[https://www.bilibili.com/video/BV1fB4y1Y7zt/]  新视频的图片分享！大家记得来康 https://i0.hdslb.com/bfs/emote/d8c665db9fdc69b3b90c71de3fe05536ac795409.png "
      )
    end

    context "A www.bilibili.com/opus/:id post" do
      strategy_should_work(
        "https://www.bilibili.com/opus/686082748803186697",
        image_urls: [
          "https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/4c6b93d5e85b8ed5b84c3f04909f195711742550.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/e1a1e6be01b6c68f6610cdf1d127f38311742550.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/9ff31bbe8005aa1b9c438e1b2e6ce81111742550.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/716a9733fc804d11d823cfacb7a3c78b11742550.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/fa42eaa6ee9cd2a896cadc41e16ab62b11742550.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/fc9553ff7e4ad1185e0379b3ccf7e2d911742550.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/da95475b858be577fc8c79bd22b7519e11742550.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/60a3c652b362c54bc61ea3365258d1d111742550.jpg",
        ],
        page_url: "https://t.bilibili.com/686082748803186697",
        artist_name: "哈米伦的弄笛者",
        other_names: ["哈米伦的弄笛者"],
        tag_name: "bilibili_11742550",
        profile_url: "https://space.bilibili.com/11742550",
        tags: [],
        artist_commentary_title: nil,
        dtext_artist_commentary_desc: "\"【崩坏3】少女，泳装，夏日时光！\":[https://www.bilibili.com/video/BV1fB4y1Y7zt/]  新视频的图片分享！大家记得来康 https://i0.hdslb.com/bfs/emote/d8c665db9fdc69b3b90c71de3fe05536ac795409.png "
      )
    end

    context "A t.bilibili.com:id repost" do
      strategy_should_work(
        "https://t.bilibili.com/723052706467414039?spm_id_from=333.999.0.0",
        image_urls: [
          "https://i0.hdslb.com/bfs/new_dyn/fd40435a0ff15d2eed45da7c0f890bdf15817819.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/1beb12760dc8790f7443515307225ad015817819.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/113aacf139984f808721f50883e908b815817819.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/ad1537c506b87ce2c30e19e4ef54204715817819.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/4a098d62f90d17bf516e3edded670d5e15817819.jpg",
          "https://i0.hdslb.com/bfs/new_dyn/89397fe05083ee25879962afba60a70515817819.jpg",
        ],
        page_url: "https://t.bilibili.com/722702993036673113",
        artist_name: "星尘Official",
        other_names: ["星尘Official"],
        tag_name: "bilibili_15817819",
        profile_url: "https://space.bilibili.com/15817819",
        tags: [],
        artist_commentary_desc: " http://i0.hdslb.com/bfs/emote/fd8aa275d5d91cdf71410bc1a738415fd6e2ab86.png "
      )
    end

    context "A text-only t.bilibili.com post with hashtags" do
      strategy_should_work(
        "https://t.bilibili.com/707554407156285477",
        image_urls: [],
        profile_url: "https://space.bilibili.com/476720460",
        tags: [
          ["一起用原神痛车", "https://t.bilibili.com/topic/name/一起用原神痛车"],
          ["凯迪拉克原神联名座驾", "https://t.bilibili.com/topic/name/凯迪拉克原神联名座驾"],
          ["原神", "https://t.bilibili.com/topic/name/原神"],
          ["凯迪拉克原神联动", "https://t.bilibili.com/topic/name/凯迪拉克原神联动"],
          ["风起雷涌特别的旅途", "https://t.bilibili.com/topic/name/风起雷涌特别的旅途"],
          ["凯迪拉克CT4", "https://t.bilibili.com/topic/name/凯迪拉克CT4"],
          ["凯迪拉克XT4", "https://t.bilibili.com/topic/name/凯迪拉克XT4"],
        ]
      )
    end

    context "A h.bilibili.com/:id post" do
      strategy_should_work(
        "https://h.bilibili.com/83341894",
        image_urls: [
          "https://i0.hdslb.com/bfs/album/669c0974a2a7508cbbb60b185eddaa0ccf8c5b7a.jpg",
          "https://i0.hdslb.com/bfs/album/de8043c382b9eb022519380bf6b570285ea3bf81.gif",
          "https://i0.hdslb.com/bfs/album/0ea658d4a9b2323665b6a5b6df6eff0e23e98c22.gif",
          "https://i0.hdslb.com/bfs/album/6448067578847d7006c6a94ffc56d6fde30b8b1e.gif",
          "https://i0.hdslb.com/bfs/album/ef2a9939264ff1e98cb4653c5b427c1d32e5ff24.gif",
          "https://i0.hdslb.com/bfs/album/6198a9290219be0775d214cfa16afb02e8b357f7.gif",
        ],
        artist_commentary_title: nil,
        artist_name: "明日方舟",
        other_names: ["明日方舟"],
        profile_url: "https://space.bilibili.com/161775300",
        page_url: "https://h.bilibili.com/83341894",
        tag_name: "bilibili_161775300",
        artist_commentary_desc: "#明日方舟#\n【新增服饰】\n//灿阳朝露 SD01 - 临光\nMARTHE [珊瑚海岸/CoralCoast]灿阳朝露系列泳衣01款。贴身、透气、轻便，专为夏日而生。\n\n即使是耀骑士，在海边的太阳前依旧要涂好防晒霜竖起遮阳伞。 ​​​​ "
      )
    end

    context "A bilibili.com/read/:id post" do
      strategy_should_work(
        "https://www.bilibili.com/read/cv7360489",
        image_urls: [
          "https://i0.hdslb.com/bfs/article/48e75b3871fa5ed62b4e3a16bf60f52f96b1b3b1.jpg",
          "https://i0.hdslb.com/bfs/article/72de3b6de4465fcb14c719354d8aeb55e93aa022.jpg",
          "https://i0.hdslb.com/bfs/article/f6f56a387517ecf3a721228f8da6b21ffbf92210.jpg",
          "https://i0.hdslb.com/bfs/article/7ac6fd23295eab8d3f62254187c34ae4867ea889.jpg",
          "https://i0.hdslb.com/bfs/article/f90d0110964e3794aca245b1a4b5d934156d231f.jpg",
          "https://i0.hdslb.com/bfs/article/b5a85177d15f3c53d06fae45ba53af3e64f7af14.jpg",
          "https://i0.hdslb.com/bfs/article/3ca6ec1056eb8dfb6e9fde732146b8244fd605ad.jpg",
          "https://i0.hdslb.com/bfs/article/1e860b392bef10f07e5abb7866e82998419f586a.jpg",
          "https://i0.hdslb.com/bfs/article/2d392a5ab0676e153355d850c13a93f16d5eb7a0.jpg",
          "https://i0.hdslb.com/bfs/article/e19cb5691afbe77c003b535759cda619b2d813cb.jpg",
        ],
        page_url: "https://www.bilibili.com/read/cv7360489",
        artist_name: "时光印记2016",
        other_names: ["时光印记2016"],
        tag_name: "bilibili_285452636",
        profile_url: "https://space.bilibili.com/285452636",
        artist_commentary_title: "斗罗大陆 4，觉醒后的古月娜（第一期）",
        dtext_artist_commentary_desc: "\n\n超喜欢2345678910\n\n不定时更新，兴趣爱好！\n\n",
        tags: []
      )
    end

    context "A bilibili image url" do
      strategy_should_work(
        "https://i0.hdslb.com/bfs/activity-plat/static/2cf2b9af5d3c5781d611d6e36f405144/E738vcDvd3.png",
        image_urls: ["https://i0.hdslb.com/bfs/activity-plat/static/2cf2b9af5d3c5781d611d6e36f405144/E738vcDvd3.png"],
        profile_url: "",
        artist_id: nil,
        page_url: nil,
      )
    end

    context "A bilibili image url with embedded artist ID" do
      strategy_should_work(
        "https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg@1036w.webp",
        image_urls: ["https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg"],
        artist_id: "11742550",
        profile_url: "https://space.bilibili.com/11742550"
      )
    end

    should "Parse Bilibili URLs correctly" do
      assert_equal("https://h.bilibili.com/8773541", Source::URL.page_url("https://www.bilibili.com/p/h5/8773541"))
      assert_equal("https://t.bilibili.com/612214375070704555", Source::URL.page_url("https://m.bilibili.com/dynamic/612214375070704555"))
      assert_equal("https://t.bilibili.com/612214375070704555", Source::URL.page_url("https://www.bilibili.com/opus/612214375070704555"))

      assert(Source::URL.page_url?("https://t.bilibili.com/612214375070704555"))
      assert(Source::URL.page_url?("https://www.bilibili.com/opus/612214375070704555"))
      assert(Source::URL.page_url?("https://h.bilibili.com/8773541"))
      assert(Source::URL.page_url?("https://www.bilibili.com/read/cv7360489"))
      assert(Source::URL.page_url?("https://www.bilibili.com/video/BV1dY4y1u7Vi"))

      assert(Source::URL.image_url?("https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg"))
      assert(Source::URL.image_url?("https://i0.hdslb.com/bfs/album/37f77871d417c76a08a9467527e9670810c4c442.gif"))

      assert(Source::URL.profile_url?("https://space.bilibili.com/355143"))

      assert_not(Source::URL.profile_url?("https://space.bilibili.com"))
    end
  end
end
