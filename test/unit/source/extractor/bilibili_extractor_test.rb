require "test_helper"

module Source::Tests::Extractor
  class BilibiliExtractorTest < ActiveSupport::TestCase
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
          { file_size: 1_553_059 },
          { file_size: 5_015_961 },
          { file_size: 4_726_515 },
          { file_size: 3_554_561 },
          { file_size: 4_697_120 },
          { file_size: 4_359_531 },
          { file_size: 3_641_370 },
          { file_size: 6_552_290 },
        ],
        page_url: "https://www.bilibili.com/opus/686082748803186697",
        profile_url: "https://space.bilibili.com/11742550",
        profile_urls: %w[https://space.bilibili.com/11742550],
        display_name: "哈米伦的弄笛者",
        other_names: ["哈米伦的弄笛者"],
        tag_name: "bilibili_11742550",
        tags: %w[],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        page_url: "https://www.bilibili.com/opus/686082748803186697",
        profile_url: "https://space.bilibili.com/11742550",
        profile_urls: %w[https://space.bilibili.com/11742550],
        display_name: "哈米伦的弄笛者",
        other_names: ["哈米伦的弄笛者"],
        tag_name: "bilibili_11742550",
        tags: %w[],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "【崩坏3】少女，泳装，夏日时光！":[https://www.bilibili.com/video/BV1fB4y1Y7zt/] 新视频的图片分享！大家记得来康"[崩坏3_送你一朵花]":[https://i0.hdslb.com/bfs/emote/d8c665db9fdc69b3b90c71de3fe05536ac795409.png]
        EOS
      )
    end

    context "A www.bilibili.com/opus/:id large cover post" do
      strategy_should_work(
        "https://www.bilibili.com/opus/1067620623766781959",
        image_urls: %w[http://i0.hdslb.com/bfs/new_dyn/1a93adf45c9b7854f49e841f1f0ec82e2300677.jpg],
        media_files: [{ file_size: 20_108_077 }],
        page_url: "https://www.bilibili.com/opus/1067620623766781959",
        profile_urls: %w[https://space.bilibili.com/2300677],
        display_name: "SA小飒",
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "【百日绘day44】 玲纱",
        dtext_artist_commentary_desc: "甜点部乐队之后肯定就是玲纱啦～最近看\"@Kieed \":[https://space.bilibili.com/25589919/dynamic]老师的直播学到了很多，非常喜欢老师的图，太好看了！！\"[给心心]\":[https://i0.hdslb.com/bfs/emote/1597302b98827463f5b75c7cac1f29ea6ce572c4.png]\"[给心心]\":[https://i0.hdslb.com/bfs/emote/1597302b98827463f5b75c7cac1f29ea6ce572c4.png]\"[给心心]\":[https://i0.hdslb.com/bfs/emote/1597302b98827463f5b75c7cac1f29ea6ce572c4.png]",
      )
    end

    context "A t.bilibili.com/:id quote-post" do
      strategy_should_work(
        "https://t.bilibili.com/723052706467414039?spm_id_from=333.999.0.0",
        image_urls: [],
        page_url: "https://t.bilibili.com/723052706467414039",
        profile_urls: %w[https://space.bilibili.com/355143],
        display_name: "原子Dan",
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "[海伊_打call]":[http://i0.hdslb.com/bfs/emote/462e4aa7dba54497f3692ad445ff31c3c176474d.png]//"@海伊Official":[https://space.bilibili.com/277698869/dynamic]:平行四界作词课预计寒假开始，以下是大纲及介绍"[星尘_比心]":[http://i0.hdslb.com/bfs/emote/fd8aa275d5d91cdf71410bc1a738415fd6e2ab86.png]"[海伊_比心]":[http://i0.hdslb.com/bfs/emote/c548b527593a3d21e5082c26abbf61c63701f11a.png]
        EOS
      )
    end

    context "A text-only t.bilibili.com post with hashtags" do
      strategy_should_work(
        "https://t.bilibili.com/707554407156285477",
        image_urls: [],
        page_url: "https://www.bilibili.com/opus/707554407156285477",
        profile_url: "https://space.bilibili.com/476720460",
        profile_urls: %w[https://space.bilibili.com/476720460],
        display_name: "凯迪拉克官方",
        other_names: ["凯迪拉克官方"],
        tag_name: "bilibili_476720460",
        tags: [
          ["一起用原神痛车", "https://search.bilibili.com/all?keyword=一起用原神痛车"],
          ["凯迪拉克原神联名座驾", "https://search.bilibili.com/all?keyword=凯迪拉克原神联名座驾"],
          ["原神", "https://search.bilibili.com/all?keyword=原神"],
          ["凯迪拉克原神联动", "https://search.bilibili.com/all?keyword=凯迪拉克原神联动"],
          ["风起雷涌特别的旅途", "https://search.bilibili.com/all?keyword=风起雷涌特别的旅途"],
          ["凯迪拉克CT4", "https://search.bilibili.com/all?keyword=凯迪拉克CT4"],
          ["凯迪拉克XT4", "https://search.bilibili.com/all?keyword=凯迪拉克XT4"],
          ["一起用原神痛车", "https://www.bilibili.com/v/topic/detail/?topic_id=58016"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          风起雷涌，特别的旅途！
          芜湖～"[星星眼]":[https://i0.hdslb.com/bfs/emote/63c9d1a31c0da745b61cdb35e0ecb28635675db2.png]凯迪拉克诚邀各路达人参与"#一起用原神痛车#":[https://search.bilibili.com/all?keyword=%E4%B8%80%E8%B5%B7%E7%94%A8%E5%8E%9F%E7%A5%9E%E7%97%9B%E8%BD%A6]大赛，利用指定素材创作你心目中特别的旅途，上传别具创意的痛车设计或同人作品，一起瓜分10万大奖~
          还有还有！你们心心念念的"[打call]":[https://i0.hdslb.com/bfs/emote/431432c43da3ee5aab5b0e4f8931953e649e9975.png]凯迪拉克X原神 限定周边大放送哟！
          快点击上方话题页参与，一同解锁尘世新冒险！✿ヽ(°▽°)ノ✿
          "#凯迪拉克原神联名座驾#":[https://search.bilibili.com/all?keyword=%E5%87%AF%E8%BF%AA%E6%8B%89%E5%85%8B%E5%8E%9F%E7%A5%9E%E8%81%94%E5%90%8D%E5%BA%A7%E9%A9%BE] "#原神#":[https://search.bilibili.com/all?keyword=%E5%8E%9F%E7%A5%9E] "#凯迪拉克原神联动#":[https://search.bilibili.com/all?keyword=%E5%87%AF%E8%BF%AA%E6%8B%89%E5%85%8B%E5%8E%9F%E7%A5%9E%E8%81%94%E5%8A%A8] "#风起雷涌特别的旅途#":[https://search.bilibili.com/all?keyword=%E9%A3%8E%E8%B5%B7%E9%9B%B7%E6%B6%8C%E7%89%B9%E5%88%AB%E7%9A%84%E6%97%85%E9%80%94] "#凯迪拉克CT4#":[https://search.bilibili.com/all?keyword=%E5%87%AF%E8%BF%AA%E6%8B%89%E5%85%8BCT4] "#凯迪拉克XT4#":[https://search.bilibili.com/all?keyword=%E5%87%AF%E8%BF%AA%E6%8B%89%E5%85%8BXT4]
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
          { file_size: 493_934 },
          { file_size: 282_419 },
          { file_size: 673_160 },
          { file_size: 1_152_435 },
          { file_size: 342_968 },
          { file_size: 1_151_382 },
          { file_size: 987_229 },
          { file_size: 695_666 },
          { file_size: 189_222 },
          { file_size: 5_434_173 },
        ],
        page_url: "https://www.bilibili.com/opus/428178320677065986",
        profile_url: "https://space.bilibili.com/285452636",
        profile_urls: %w[https://space.bilibili.com/285452636],
        display_name: "花田里的碴",
        other_names: ["花田里的碴"],
        tag_name: "bilibili_285452636",
        tags: [],
        dtext_artist_commentary_title: "斗罗大陆 4，觉醒后的古月娜（第一期）",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "[Image]":[https://i0.hdslb.com/bfs/article/48e75b3871fa5ed62b4e3a16bf60f52f96b1b3b1.jpg]

          超喜欢

          "[Image]":[https://i0.hdslb.com/bfs/article/72de3b6de4465fcb14c719354d8aeb55e93aa022.jpg]

          2

          "[Image]":[https://i0.hdslb.com/bfs/article/f6f56a387517ecf3a721228f8da6b21ffbf92210.jpg]

          3

          "[Image]":[https://i0.hdslb.com/bfs/article/7ac6fd23295eab8d3f62254187c34ae4867ea889.jpg]

          4

          "[Image]":[https://i0.hdslb.com/bfs/article/f90d0110964e3794aca245b1a4b5d934156d231f.jpg]

          5

          "[Image]":[https://i0.hdslb.com/bfs/article/b5a85177d15f3c53d06fae45ba53af3e64f7af14.jpg]

          6

          "[Image]":[https://i0.hdslb.com/bfs/article/3ca6ec1056eb8dfb6e9fde732146b8244fd605ad.jpg]

          7

          "[Image]":[https://i0.hdslb.com/bfs/article/1e860b392bef10f07e5abb7866e82998419f586a.jpg]

          8

          "[Image]":[https://i0.hdslb.com/bfs/article/2d392a5ab0676e153355d850c13a93f16d5eb7a0.jpg]

          9

          "[Image]":[https://i0.hdslb.com/bfs/article/e19cb5691afbe77c003b535759cda619b2d813cb.jpg]

          10

          不定时更新，兴趣爱好！
        EOS
      )
    end

    context "A bilibili.com/read/:id post with /watermark/ image URLs" do
      strategy_should_work(
        "https://www.bilibili.com/read/cv10137473",
        image_urls: %w[
          https://i0.hdslb.com/bfs/article/watermark/7e52215ee182b02bda3d9f6b6aac4007a5d65171.png
          https://i0.hdslb.com/bfs/article/watermark/ad00dbd28f53723a0f833a301969a31b5ac0ba06.png
          https://i0.hdslb.com/bfs/article/watermark/25427e45717c371cc77b2235e4c20151435e5305.png
          https://i0.hdslb.com/bfs/article/watermark/dccf0575ae604b5f96e9593a38241b897e10fc4b.png
          https://i0.hdslb.com/bfs/article/875d230b773b7f4810fdecdd2acc75f2b55f2724.png
        ],
        media_files: [
          { file_size: 256_343 },
          { file_size: 173_741 },
          { file_size: 173_201 },
          { file_size: 184_165 },
          { file_size: 1_111_444 },
        ],
        page_url: "https://www.bilibili.com/opus/498661195017002415",
        profile_urls: %w[https://space.bilibili.com/413748120],
        display_name: "VirtuaReal",
        username: nil,
        tags: [
          ["出道新闻", "https://search.bilibili.com/all?keyword=出道新闻"],
          ["虚拟UP主", "https://search.bilibili.com/all?keyword=虚拟UP主"],
          ["VTUBER", "https://search.bilibili.com/all?keyword=VTUBER"],
          ["VUP", "https://search.bilibili.com/all?keyword=VUP"],
          ["VirtuaReal", "https://search.bilibili.com/all?keyword=VirtuaReal"],
        ],
        dtext_artist_commentary_title: "VirtuaReal Project新成员公布！长期开启招募中~",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          VirtuaReal新一期成员来啦！

          废话不说，上正文——

          新成员介绍

          * 勾檀Mayumi

          "[Image]":[https://i0.hdslb.com/bfs/article/watermark/7e52215ee182b02bda3d9f6b6aac4007a5d65171.png]

          勾檀Mayumi

          对于勾檀她究竟是“原本就是金毛的小狗狗”还是“她只是被装上了这样的配件吧你这个lsp！”到底哪边才对的讨论，已经在我们内部进行很久了。我们对她的身体很感兴趣，但出于各种各样的原因最终还是放弃了解剖她的计划。

          一来，没有人会对一个初见时满身伤痕的女孩有着大过保护欲的伤害欲，二来......经过一段时间的相处我们发现她似乎已经身有所属了——她总是把一个叫做master的人挂在嘴边，而她一直确信为master带来快乐，帮助master解决问题和困扰便是她的存在意义。

          为了让她知道世界上并不是只有master的存在，我们一致决定让这个打游戏唱歌都不太行的少女去进行直播活动，只有面对更多的人，她才能慢慢的自信起来或者在走偏的道路上愈发不可收拾吧。

          虽然她接受的理由是为了给master带来更多的快乐，但总之结果是这样就好了吧。

          //space.bilibili.com/690608693的个人空间："网页链接":[https://space.bilibili.com/690608693]

          * 犬童Kendou

          "[Image]":[https://i0.hdslb.com/bfs/article/watermark/ad00dbd28f53723a0f833a301969a31b5ac0ba06.png]

          犬童Kendou

          天堂在左地狱在右，从小便生活在天堂里的犬童对自己的生活非常的满意，它庆幸自己没有生在隔壁那个既没有帅哥与帅哥相恋也没有彰显少年深厚友谊杂志发售的地狱。作为天堂的看门犬，它也从未料到自己会因为摸鱼这点事情而被踹到人间来。

          虽说它并不在意呆在这个能第一手获得更多不可描述之画本的人间，但在这地方可没有人给它无端的投食，而它也并不打算重操旧业的去为普通人看大门。

          在久经思量后，它决定做一名好文明的布道者，通过直播这一似乎在人间十分火热的手段把自己满脑子的货都分享给大家，以此来得到更多的共鸣者和支持者。

          希望动物保护协会不会早日将其进行安置。——某听过布道的不知名红脸群众。

          "犬童Kendou":[https://space.bilibili.com/690608701]的个人空间："网页链接":[https://space.bilibili.com/690608701]

          * 九十九Tsukumo

          "[Image]":[https://i0.hdslb.com/bfs/article/watermark/25427e45717c371cc77b2235e4c20151435e5305.png]

          九十九Tsukumo

          这位来自于隐秘黑手党的继承者完全没有一点大小姐脾气，甚至在她和我们的对话中，我们的某位黑道片爱好者同僚因为幻想破灭而流下了泪水。毕竟一心想要用自个儿的钱买地种田的人切实是庞大黑手党的千金这件事也太让人难以相信了。

          而除此以外，九十九小姐的各类习惯简直让人大跌眼镜。她在这个年纪已经习得一手好茶艺与咖啡研磨技术，而比起格斗技的她明确表示自己对音乐尤其是爵士乐更加感兴趣。

          这位酷到爆的小姐并不希望利用家里的东西达成自己的目的——这太不黑手党了，但或许我们该为此感到庆幸，至少她没有用刀而是用直播这一和平的手段来达到她那可以说是和黑手党八竿子打不着的梦想了。

          "九十九Tsukumo":[https://space.bilibili.com/690608702]的个人空间："网页链接":[https://space.bilibili.com/690608702]

          * 蕾米Remi

          "[Image]":[https://i0.hdslb.com/bfs/article/watermark/dccf0575ae604b5f96e9593a38241b897e10fc4b.png]

          蕾米Remi

          我们对于这只自行从水族馆逃命而出的海兔小姐十分的敬佩，在如今这个兽娘被逮住就基本就宣告一生完蛋的奇特时代，如果不是出于责任心就算是我们大概也忍不住把她监禁起来吧。

          我们旁敲侧击了这位小姐好多次，最终成功的让她明白自个儿想要在人类社会立足是很麻烦的，至少不是每天做光合作用与仰泳就可以活下去的。而更加为难的是，她非常希望与某个“不知名的声音”（听说她们还是他们已经见面了，也不知道是什么关系）一起住进海景房，也因此才来找到我们寻求帮助。

          在我们的各方面思量下，最终我们为她架设起了最好的设备，想来这位海兔小姐的声音一定能让她直播间里的少年少女们为之愉悦吧。

          "蕾米Remi":[https://space.bilibili.com/690608687]的个人空间："网页链接":[https://space.bilibili.com/690608687]

          [hr]

          VirtuaReal Project [b]长期开启招募中[/b]！只需要你轻轻扫描以下链接上传答题卡和短视频， 就有机会加入VirtuaReal Project，来经历这场“宛如魔法般的体验“！

          以下招募信息[b]长期有效[/b]，欢迎有趣的你随时加入！

          报名资格

          * 年满18岁
          * 热爱分享，性格外向
          * 有一技之长（直播、游戏、唱歌、跳舞、琴棋书画、谈天说地等等）
          * 如果你满足以上条件，热切期待和你产生连接！

          报名方法

          * 请在 vup.link/join 填写答题卡

          "[Image]":[https://i0.hdslb.com/bfs/article/875d230b773b7f4810fdecdd2acc75f2b55f2724.png]

          招募方式

          * 第一轮：资料审查
          * 第二轮：电话/面谈（仅限通过第一轮的小伙伴）
          * 第三轮：现场测试
          * 第四轮：签约

          其他

          * 报名和甄选不收取任何费用，请放心！
          * 报名链接长期开放，欢迎有趣的你随时加入！
          * 欢迎全国各地以及海外小伙伴前来面试！
          * 如有问题，请随时戳我们的官方账号VirtuaReal咨询！
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
        tag_name: nil,
      )
    end

    context "A bilibili image url with embedded artist ID" do
      strategy_should_work(
        "https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg@1036w.webp",
        image_urls: ["https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg"],
        media_files: [{ file_size: 1_536_450 }],
        page_url: nil,
        profile_url: "https://space.bilibili.com/11742550",
        tag_name: "bilibili_11742550",
      )
    end

    context "A t.bilibili.com post with hashtags, mentions, emotes" do
      strategy_should_work(
        "https://t.bilibili.com/601343542258368998",
        image_urls: %w[https://i0.hdslb.com/bfs/album/fc95e4685aee6fdbe6b440e4fc1629a255c762aa.jpg],
        media_files: [{ file_size: 6_513_174 }],
        page_url: "https://www.bilibili.com/opus/601343542258368998",
        profile_url: "https://space.bilibili.com/1383815813",
        profile_urls: %w[https://space.bilibili.com/1383815813],
        display_name: "吉诺儿kino",
        other_names: ["吉诺儿kino"],
        tag_name: "bilibili_1383815813",
        tags: [
          ["吉诺儿kino", "https://search.bilibili.com/all?keyword=吉诺儿kino"],
          ["唐九夏", "https://search.bilibili.com/all?keyword=唐九夏"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "#吉诺儿kino#":[https://search.bilibili.com/all?keyword=%E5%90%89%E8%AF%BA%E5%84%BFkino] "#唐九夏#":[https://search.bilibili.com/all?keyword=%E5%94%90%E4%B9%9D%E5%A4%8F] 今天是大雪！！今天也好冷啊"[冷]":[https://i0.hdslb.com/bfs/emote/cb0ebbd0668640f07ebfc0e03f7a18a8cd00b4ed.png] 之前在直播的时候说的，"@唐九夏还想再躺一下 ":[https://space.bilibili.com/1219196749/dynamic]的原创新曲《檐下雪》就快来啦！！歌肯定是很好听的，但最厉害的是这首曲子可是九夏作词的！！大家记得要来听啊啊啊！！！
        EOS
      )
    end

    context "A t.bilibili.com/:id quote-post with images" do
      strategy_should_work(
        "https://t.bilibili.com/914119403116691463",
        image_urls: %w[
          http://i0.hdslb.com/bfs/new_dyn/09fff9c0e6e17d8d03c3f34454f121c4880227.gif
          http://i0.hdslb.com/bfs/new_dyn/5ff62932401e4943e0813e40b7411157880227.gif
          http://i0.hdslb.com/bfs/new_dyn/39eddb1325f86188a886ae708fdefa43880227.jpg
        ],
        media_files: [
          { file_size: 1_604_415 },
          { file_size: 1_686_471 },
          { file_size: 621_792 },
        ],
        page_url: "https://t.bilibili.com/914119403116691463",
        profile_urls: %w[https://space.bilibili.com/880227],
        display_name: "绅士老鱼",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          同人图+表情包我就放在这里啦"[脱单doge]":[https://i0.hdslb.com/bfs/emote/bf7e00ecab02171f8461ee8cf439c73db9797748.png]
          5000赞咱就更新下一期佩佩的绘画视频！
          感谢大家的支持！！
        EOS
      )
    end
  end
end
