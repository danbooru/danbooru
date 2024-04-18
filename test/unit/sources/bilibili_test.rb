require 'test_helper'

module Sources
  class BilibiliTest < ActiveSupport::TestCase
    context "A t.bilibili.com/:id post" do
      strategy_should_work(
        "https://t.bilibili.com/686082748803186697",
        image_urls: %w[
          https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg
          https://i0.hdslb.com/bfs/new_dyn/4c6b93d5e85b8ed5b84c3f04909f195711742550.jpg
          https://i0.hdslb.com/bfs/new_dyn/e1a1e6be01b6c68f6610cdf1d127f38311742550.jpg
          https://i0.hdslb.com/bfs/new_dyn/9ff31bbe8005aa1b9c438e1b2e6ce81111742550.jpg
          https://i0.hdslb.com/bfs/new_dyn/716a9733fc804d11d823cfacb7a3c78b11742550.jpg
          https://i0.hdslb.com/bfs/new_dyn/fa42eaa6ee9cd2a896cadc41e16ab62b11742550.jpg
          https://i0.hdslb.com/bfs/new_dyn/fc9553ff7e4ad1185e0379b3ccf7e2d911742550.jpg
          https://i0.hdslb.com/bfs/new_dyn/da95475b858be577fc8c79bd22b7519e11742550.jpg
          https://i0.hdslb.com/bfs/new_dyn/60a3c652b362c54bc61ea3365258d1d111742550.jpg
        ],
        media_files: [
          { file_size: 1_536_450 },
          { file_size: 1_553_055 },
          { file_size: 5_015_957 },
          { file_size: 4_726_511 },
          { file_size: 3_554_557 },
          { file_size: 4_697_116 },
          { file_size: 4_359_527 },
          { file_size: 3_641_366 },
          { file_size: 6_552_286 },
        ],
        page_url: "https://t.bilibili.com/686082748803186697",
        profile_url: "https://space.bilibili.com/11742550",
        profile_urls: %w[https://space.bilibili.com/11742550],
        artist_name: "哈米伦的弄笛者",
        other_names: ["哈米伦的弄笛者"],
        tag_name: "bilibili_11742550",
        tags: %w[],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          "【崩坏3】少女，泳装，夏日时光！":[https://www.bilibili.com/video/BV1fB4y1Y7zt/] 新视频的图片分享！大家记得来康"[崩坏3_送你一朵花]":[https://i0.hdslb.com/bfs/emote/d8c665db9fdc69b3b90c71de3fe05536ac795409.png]
        EOS
      )
    end

    context "A www.bilibili.com/opus/:id post" do
      strategy_should_work(
        "https://www.bilibili.com/opus/686082748803186697",
        image_urls: %w[
          https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg
          https://i0.hdslb.com/bfs/new_dyn/4c6b93d5e85b8ed5b84c3f04909f195711742550.jpg
          https://i0.hdslb.com/bfs/new_dyn/e1a1e6be01b6c68f6610cdf1d127f38311742550.jpg
          https://i0.hdslb.com/bfs/new_dyn/9ff31bbe8005aa1b9c438e1b2e6ce81111742550.jpg
          https://i0.hdslb.com/bfs/new_dyn/716a9733fc804d11d823cfacb7a3c78b11742550.jpg
          https://i0.hdslb.com/bfs/new_dyn/fa42eaa6ee9cd2a896cadc41e16ab62b11742550.jpg
          https://i0.hdslb.com/bfs/new_dyn/fc9553ff7e4ad1185e0379b3ccf7e2d911742550.jpg
          https://i0.hdslb.com/bfs/new_dyn/da95475b858be577fc8c79bd22b7519e11742550.jpg
          https://i0.hdslb.com/bfs/new_dyn/60a3c652b362c54bc61ea3365258d1d111742550.jpg
        ],
        page_url: "https://t.bilibili.com/686082748803186697",
        profile_url: "https://space.bilibili.com/11742550",
        profile_urls: %w[https://space.bilibili.com/11742550],
        artist_name: "哈米伦的弄笛者",
        other_names: ["哈米伦的弄笛者"],
        tag_name: "bilibili_11742550",
        tags: %w[],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          "【崩坏3】少女，泳装，夏日时光！":[https://www.bilibili.com/video/BV1fB4y1Y7zt/] 新视频的图片分享！大家记得来康"[崩坏3_送你一朵花]":[https://i0.hdslb.com/bfs/emote/d8c665db9fdc69b3b90c71de3fe05536ac795409.png]
        EOS
      )
    end

    context "A t.bilibili.com:id repost" do
      strategy_should_work(
        "https://t.bilibili.com/723052706467414039?spm_id_from=333.999.0.0",
        image_urls: %w[
          https://i0.hdslb.com/bfs/new_dyn/fd40435a0ff15d2eed45da7c0f890bdf15817819.jpg
          https://i0.hdslb.com/bfs/new_dyn/1beb12760dc8790f7443515307225ad015817819.jpg
          https://i0.hdslb.com/bfs/new_dyn/113aacf139984f808721f50883e908b815817819.jpg
          https://i0.hdslb.com/bfs/new_dyn/ad1537c506b87ce2c30e19e4ef54204715817819.jpg
          https://i0.hdslb.com/bfs/new_dyn/4a098d62f90d17bf516e3edded670d5e15817819.jpg
          https://i0.hdslb.com/bfs/new_dyn/89397fe05083ee25879962afba60a70515817819.jpg
        ],
        media_files: [
          { file_size: 164_886 },
          { file_size: 268_756 },
          { file_size: 238_327 },
          { file_size: 155_331 },
          { file_size: 192_652 },
          { file_size: 422_392 },
        ],
        page_url: "https://t.bilibili.com/722702993036673113",
        profile_url: "https://space.bilibili.com/15817819",
        profile_urls: %w[https://space.bilibili.com/15817819],
        artist_name: "星尘Official",
        other_names: ["星尘Official"],
        tag_name: "bilibili_15817819",
        tags: %w[],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          "[星尘_比心]":[http://i0.hdslb.com/bfs/emote/fd8aa275d5d91cdf71410bc1a738415fd6e2ab86.png]
        EOS
      )
    end

    context "A text-only t.bilibili.com post with hashtags" do
      strategy_should_work(
        "https://t.bilibili.com/707554407156285477",
        image_urls: [],
        page_url: "https://t.bilibili.com/707554407156285477",
        profile_url: "https://space.bilibili.com/476720460",
        profile_urls: %w[https://space.bilibili.com/476720460],
        artist_name: "凯迪拉克官方",
        other_names: ["凯迪拉克官方"],
        tag_name: "bilibili_476720460",
        tags: [
          ["一起用原神痛车", "https://t.bilibili.com/topic/name/一起用原神痛车"],
          ["凯迪拉克原神联名座驾", "https://t.bilibili.com/topic/name/凯迪拉克原神联名座驾"],
          ["原神", "https://t.bilibili.com/topic/name/原神"],
          ["凯迪拉克原神联动", "https://t.bilibili.com/topic/name/凯迪拉克原神联动"],
          ["风起雷涌特别的旅途", "https://t.bilibili.com/topic/name/风起雷涌特别的旅途"],
          ["凯迪拉克CT4", "https://t.bilibili.com/topic/name/凯迪拉克CT4"],
          ["凯迪拉克XT4", "https://t.bilibili.com/topic/name/凯迪拉克XT4"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          风起雷涌，特别的旅途！ 芜湖～"[星星眼]":[https://i0.hdslb.com/bfs/emote/63c9d1a31c0da745b61cdb35e0ecb28635675db2.png]凯迪拉克诚邀各路达人参与"#一起用原神痛车#":[https://search.bilibili.com/all?keyword=%E4%B8%80%E8%B5%B7%E7%94%A8%E5%8E%9F%E7%A5%9E%E7%97%9B%E8%BD%A6]大赛，利用指定素材创作你心目中特别的旅途，上传别具创意的痛车设计或同人作品，一起瓜分10万大奖~ 还有还有！你们心心念念的"[打call]":[https://i0.hdslb.com/bfs/emote/431432c43da3ee5aab5b0e4f8931953e649e9975.png]凯迪拉克X原神 限定周边大放送哟！ 快点击上方话题页参与，一同解锁尘世新冒险！✿ヽ(°▽°)ノ✿ "#凯迪拉克原神联名座驾#":[https://search.bilibili.com/all?keyword=%E5%87%AF%E8%BF%AA%E6%8B%89%E5%85%8B%E5%8E%9F%E7%A5%9E%E8%81%94%E5%90%8D%E5%BA%A7%E9%A9%BE] "#原神#":[https://search.bilibili.com/all?keyword=%E5%8E%9F%E7%A5%9E] "#凯迪拉克原神联动#":[https://search.bilibili.com/all?keyword=%E5%87%AF%E8%BF%AA%E6%8B%89%E5%85%8B%E5%8E%9F%E7%A5%9E%E8%81%94%E5%8A%A8] "#风起雷涌特别的旅途#":[https://search.bilibili.com/all?keyword=%E9%A3%8E%E8%B5%B7%E9%9B%B7%E6%B6%8C%E7%89%B9%E5%88%AB%E7%9A%84%E6%97%85%E9%80%94] "#凯迪拉克CT4#":[https://search.bilibili.com/all?keyword=%E5%87%AF%E8%BF%AA%E6%8B%89%E5%85%8BCT4] "#凯迪拉克XT4#":[https://search.bilibili.com/all?keyword=%E5%87%AF%E8%BF%AA%E6%8B%89%E5%85%8BXT4]
        EOS
      )
    end

    context "A bilibili.com/read/:id post" do
      strategy_should_work(
        "https://www.bilibili.com/read/cv7360489",
        image_urls: %w[
          https://i0.hdslb.com/bfs/article/48e75b3871fa5ed62b4e3a16bf60f52f96b1b3b1.jpg
          https://i0.hdslb.com/bfs/article/72de3b6de4465fcb14c719354d8aeb55e93aa022.jpg
          https://i0.hdslb.com/bfs/article/f6f56a387517ecf3a721228f8da6b21ffbf92210.jpg
          https://i0.hdslb.com/bfs/article/7ac6fd23295eab8d3f62254187c34ae4867ea889.jpg
          https://i0.hdslb.com/bfs/article/f90d0110964e3794aca245b1a4b5d934156d231f.jpg
          https://i0.hdslb.com/bfs/article/b5a85177d15f3c53d06fae45ba53af3e64f7af14.jpg
          https://i0.hdslb.com/bfs/article/3ca6ec1056eb8dfb6e9fde732146b8244fd605ad.jpg
          https://i0.hdslb.com/bfs/article/1e860b392bef10f07e5abb7866e82998419f586a.jpg
          https://i0.hdslb.com/bfs/article/2d392a5ab0676e153355d850c13a93f16d5eb7a0.jpg
          https://i0.hdslb.com/bfs/article/e19cb5691afbe77c003b535759cda619b2d813cb.jpg
        ],
        media_files: [
          { file_size: 493_930 },
          { file_size: 282_419 },
          { file_size: 673_160 },
          { file_size: 1_152_435 },
          { file_size: 342_964 },
          { file_size: 1_151_382 },
          { file_size: 987_229 },
          { file_size: 695_666 },
          { file_size: 189_218 },
          { file_size: 5_434_169 },
        ],
        page_url: "https://www.bilibili.com/read/cv7360489/",
        profile_url: "https://space.bilibili.com/285452636",
        profile_urls: %w[https://space.bilibili.com/285452636],
        artist_name: "时光印记2016",
        other_names: ["时光印记2016"],
        tag_name: "bilibili_285452636",
        tags: [],
        dtext_artist_commentary_title: "斗罗大陆 4，觉醒后的古月娜（第一期）",
        dtext_artist_commentary_desc: <<~EOS.chomp
          超喜欢2345678910

          不定时更新，兴趣爱好！
        EOS
      )
    end

    context "A bilibili image url" do
      strategy_should_work(
        "https://i0.hdslb.com/bfs/activity-plat/static/2cf2b9af5d3c5781d611d6e36f405144/E738vcDvd3.png",
        image_urls: ["https://i0.hdslb.com/bfs/activity-plat/static/2cf2b9af5d3c5781d611d6e36f405144/E738vcDvd3.png"],
        media_files: [{ file_size: 515_583 }],
        page_url: nil,
        profile_url: nil,
        tag_name: nil
      )
    end

    context "A bilibili image url with embedded artist ID" do
      strategy_should_work(
        "https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg@1036w.webp",
        image_urls: ["https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg"],
        media_files: [{ file_size: 1_536_450 }],
        page_url: nil,
        profile_url: "https://space.bilibili.com/11742550",
        tag_name: "bilibili_11742550"
      )
    end

    context "A t.bilibili.com post with hashtags, mentions, emotes" do
      strategy_should_work(
        "https://t.bilibili.com/601343542258368998",
        image_urls: %w[https://i0.hdslb.com/bfs/album/fc95e4685aee6fdbe6b440e4fc1629a255c762aa.jpg],
        media_files: [{ file_size: 6_513_174 }],
        page_url: "https://t.bilibili.com/601343542258368998",
        profile_url: "https://space.bilibili.com/1383815813",
        profile_urls: %w[https://space.bilibili.com/1383815813],
        artist_name: "吉诺儿kino",
        other_names: ["吉诺儿kino"],
        tag_name: "bilibili_1383815813",
        tags: [
          ["吉诺儿kino", "https://t.bilibili.com/topic/name/吉诺儿kino"],
          ["唐九夏", "https://t.bilibili.com/topic/name/唐九夏"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          "#吉诺儿kino#":[https://search.bilibili.com/all?keyword=%E5%90%89%E8%AF%BA%E5%84%BFkino] "#唐九夏#":[https://search.bilibili.com/all?keyword=%E5%94%90%E4%B9%9D%E5%A4%8F] 今天是大雪！！今天也好冷啊"[冷]":[https://i0.hdslb.com/bfs/emote/cb0ebbd0668640f07ebfc0e03f7a18a8cd00b4ed.png] 之前在直播的时候说的，"@唐九夏还想再躺一下 ":[https://space.bilibili.com/1219196749/dynamic]的原创新曲《檐下雪》就快来啦！！歌肯定是很好听的，但最厉害的是这首曲子可是九夏作词的！！大家记得要来听啊啊啊！！！
        EOS
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
      assert(Source::URL.image_url?("https://album.biliimg.com/bfs/new_dyn/4cf244d3fb706a5726b6383143960931504164361.jpg"))

      assert(Source::URL.profile_url?("https://space.bilibili.com/355143"))

      assert_not(Source::URL.profile_url?("https://space.bilibili.com"))
    end
  end
end
