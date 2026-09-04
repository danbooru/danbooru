require "test_helper"

module Source::Tests::Extractor
  class WeiboExtractorTest < ActiveSupport::ExtractorTestCase
    context "A Weibo post with multiple pictures" do
      strategy_should_work(
        "https://www.weibo.com/5501756072/J2UNKfbqV?type=comment#_rnd1590548401855",
        image_urls: %w[
          https://wx1.sinaimg.cn/large/0060kO5aly1gezsyt5xvhj30ok0sgtc9.jpg
          https://wx3.sinaimg.cn/large/0060kO5aly1gezsyuaas1j30go0sgjtj.jpg
          https://wx3.sinaimg.cn/large/0060kO5aly1gezsys1ai9j30gi0sg0v9.jpg
        ],
        media_files: [
          { file_size: 134_721 },
          { file_size: 84_124 },
          { file_size: 97_878 },
        ],
        page_url: "https://www.weibo.com/5501756072/J2UNKfbqV",
        profile_url: "https://www.weibo.com/u/5501756072",
        profile_urls: %w[https://www.weibo.com/u/5501756072],
        display_name: "阿尔托莉雅厨",
        username: nil,
        published_at: Time.parse("2020-05-21T01:21:27.000000Z"),
        updated_at: nil,
        tags: [
          ["fgo", "https://s.weibo.com/weibo?q=%23fgo%23"],
          ["Alter组", "https://s.weibo.com/weibo?q=%23Alter组%23"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "#fgo#":[https://s.weibo.com/weibo?q=%23fgo%23]"#Alter组#":[https://s.weibo.com/weibo?q=%23Alter组%23] 变装潜入搜查→夫妻感
          作者：nipi "@saberchankawaii":[https://www.weibo.com/n/saberchankawaii] "网页链接":[https://twitter.com/saberchankawaii/status/1263110113625178112?s=21]
          授权见评，请勿二传
        EOS
      )
    end

    context "A m.weibo.cn/detail url" do
      strategy_should_work(
        "https://m.weibo.cn/detail/4506950043618873",
        image_urls: %w[
          https://wx1.sinaimg.cn/large/0060kO5aly1gezsyt5xvhj30ok0sgtc9.jpg
          https://wx3.sinaimg.cn/large/0060kO5aly1gezsyuaas1j30go0sgjtj.jpg
          https://wx3.sinaimg.cn/large/0060kO5aly1gezsys1ai9j30gi0sg0v9.jpg
        ],
        media_files: [
          { file_size: 134_721 },
          { file_size: 84_124 },
          { file_size: 97_878 },
        ],
        page_url: "https://www.weibo.com/5501756072/J2UNKfbqV",
        profile_url: "https://www.weibo.com/u/5501756072",
        profile_urls: %w[https://www.weibo.com/u/5501756072],
        display_name: "阿尔托莉雅厨",
        username: nil,
        published_at: Time.parse("2020-05-21T01:21:27.000000Z"),
        updated_at: nil,
        tags: [
          ["fgo", "https://s.weibo.com/weibo?q=%23fgo%23"],
          ["Alter组", "https://s.weibo.com/weibo?q=%23Alter组%23"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "#fgo#":[https://s.weibo.com/weibo?q=%23fgo%23]"#Alter组#":[https://s.weibo.com/weibo?q=%23Alter组%23] 变装潜入搜查→夫妻感
          作者：nipi "@saberchankawaii":[https://www.weibo.com/n/saberchankawaii] "网页链接":[https://twitter.com/saberchankawaii/status/1263110113625178112?s=21]
          授权见评，请勿二传
        EOS
      )
    end

    context "A Weibo post with a 720p video" do
      strategy_should_work(
        "https://www.weibo.com/5501756072/IF9fugHzj",
        image_urls: [%r{https://f.video.weibocdn.com/HPzdmCB4lx07CNYTsq0U01041200wd320E010.mp4\?Expires=.*&ssig=.*&KID=unistore,video}],
        media_files: [{ file_size: 7_676_656 }],
        page_url: "https://www.weibo.com/5501756072/IF9fugHzj",
        profile_url: "https://www.weibo.com/u/5501756072",
        profile_urls: %w[https://www.weibo.com/u/5501756072],
        display_name: "阿尔托莉雅厨",
        username: nil,
        published_at: Time.parse("2020-04-26T13:15:31.000000Z"),
        updated_at: nil,
        tags: [
          ["明日方舟", "https://s.weibo.com/weibo?q=%23明日方舟%23"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "#明日方舟#":[https://s.weibo.com/weibo?q=%23明日方舟%23] Jazz up!
          作者：DAIRIN "@DAIRIN75929273":[https://www.weibo.com/n/DAIRIN75929273] "网页链接":[https://twitter.com/DAIRIN75929273/status/1254382963732606977?s=20]
          授权见评，请勿二传 "阿尔托莉雅厨的微博视频":[https://video.weibo.com/show?fid=1034:4498069178482724]
        EOS
      )
    end

    context "A Weibo post with a 1080p video" do
      strategy_should_work(
        "https://www.weibo.com/7817290049/N62KL5MpJ",
        image_urls: [%r{https://f.video.weibocdn.com/o0/wPhyi3dIlx086mr8Md3y01041200xT4N0E010.mp4\?Expires=.*&ssig=.*&KID=unistore,video}],
        media_files: [{ file_size: 8_076_541 }],
        page_url: "https://www.weibo.com/7817290049/N62KL5MpJ",
        profile_url: "https://www.weibo.com/u/7817290049",
        profile_urls: %w[https://www.weibo.com/u/7817290049],
        display_name: "帕姆的收藏夹",
        username: nil,
        published_at: Time.parse("2023-06-19T10:04:11.000000Z"),
        updated_at: nil,
        tags: [
          ["崩坏星穹铁道", "https://s.weibo.com/weibo?q=%23崩坏星穹铁道%23"],
          ["星穹铁道1.1", "https://s.weibo.com/weibo?q=%23星穹铁道1.1%23"],
          ["丹恒", "https://s.weibo.com/weibo?q=%23丹恒%23"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "崩坏星穹铁道":[https://weibo.com/p/100808e1f868bf9980f09ab6908787d7eaf0f0] "#崩坏星穹铁道#":[https://s.weibo.com/weibo?q=%23崩坏星穹铁道%23] "#星穹铁道1.1#":[https://s.weibo.com/weibo?q=%23星穹铁道1.1%23] "#丹恒#":[https://s.weibo.com/weibo?q=%23丹恒%23]

          帕姆放映厅 | 不苟言笑，实力超群的列车护卫——「冷面小青龙」！ "帕姆的收藏夹的微博视频":[https://video.weibo.com/show?fid=1034:4914351942074379]
        EOS
      )
    end

    # XXX The video URL returns 404.
    context "A Weibo video with an empty playback_list" do
      setup do
        skip "Deleted post"
      end

      strategy_should_work(
        "https://weibo.com/1501933722/4142890299009993",
        image_urls: [%r{http://f.us.sinaimg.cn/004zstGKlx07dAHg4ZVu010f01000OOl0k01.mp4\?Expires=.*&ssig=.*&KID=unistore,video}],
        page_url: "https://www.weibo.com/1501933722/4142890299009993",
        profile_url: "https://www.weibo.com/u/1501933722",
        profile_urls: %w[https://www.weibo.com/u/1501933722],
        display_name: "sandymandy",
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          猜猜看誰被偷拍了？"[嘻嘻]":[https://face.t.sinajs.cn/t4/appstyle/expression/ext/normal/8e/201810_xixi_mobile.png]

          "[嘻嘻]":[https://face.t.sinajs.cn/t4/appstyle/expression/ext/normal/8e/201810_xixi_mobile.png]

          "sandymandy的秒拍视频":[https://video.weibo.com/show?fid=1034:067e5f60923993c936abe48f1b0a11e2]
        EOS
      )
    end

    context "A Weibo post with images and videos" do
      strategy_should_work(
        "https://www.weibo.com/7730797357/QwMGajLGz",
        image_urls: [
          %r{https://f.video.weibocdn.com/u0/Sz1k1Kd5gx08wblzDeSs01041200pI7I0E010.mp4\?Expires=.*&ssig=.*&KID=unistore,video},
          "https://wx4.sinaimg.cn/large/008rbDxXgy1ibc2dalzz2j31z4140kjl.jpg",
        ],
        media_files: [
          { file_size: 6_127_814 },
          { file_size: 1_622_702 },
        ],
        page_url: "https://www.weibo.com/7730797357/QwMGajLGz",
        profile_url: "https://www.weibo.com/u/7730797357",
        profile_urls: %w[https://www.weibo.com/u/7730797357],
        display_name: "鸣潮",
        username: nil,
        published_at: Time.parse("2026-03-19T03:00:02.000000Z"),
        updated_at: nil,
        tags: [
          ["鸣潮3.2版本", "https://s.weibo.com/weibo?q=%23鸣潮3.2版本%23"],
          ["鸣潮西格莉卡", "https://s.weibo.com/weibo?q=%23鸣潮西格莉卡%23"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "鸣潮":[https://weibo.com/p/100808805d326c8383e31ed5f47088acce6b77] "#鸣潮3.2版本#":[https://s.weibo.com/weibo?q=%23鸣潮3.2版本%23] "#鸣潮西格莉卡#":[https://s.weibo.com/weibo?q=%23鸣潮西格莉卡%23]
          “语义落下的时候，符文就会亮起来。”

          《鸣潮》3.2版本「于影中启明的决心」已开启！
          ——————————————————
          关注"@鸣潮":[https://www.weibo.com/n/鸣潮] 并转发本条内容，我们会抽取10位漂泊者送出「鸣潮共鸣者主题PV定格亚克力立牌（随机款）」*1，截止至3月26日20:00。
          ——————————————————
          下载游戏："网页链接":[https://mc.kurogames.com] "抽奖详情":[https://lottery.media.weibo.com/lottery/h5/history/list?mid=5278136224711539]
        EOS
      )
    end

    context "A direct image sample Weibo upload" do
      strategy_should_work(
        "https://wx3.sinaimg.cn/mw690/a00fa34cly1gf62g2n8z3j21yu2jo1ky.jpg",
        image_urls: %w[https://wx3.sinaimg.cn/large/a00fa34cly1gf62g2n8z3j21yu2jo1ky.jpg],
        media_files: [{ file_size: 2_421_067 }],
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

    context "A single image from a multi-image Weibo post" do
      strategy_should_work(
        "https://wx1.sinaimg.cn/large/7eb64558gy1fnbryriihwj20dw104wtu.jpg",
        referer: "https://photo.weibo.com/2125874520/wbphotos/large/mid/4194742441135220/pid/7eb64558gy1fnbryb5nzoj20dw10419t",
        image_urls: %w[https://wx1.sinaimg.cn/large/7eb64558gy1fnbryriihwj20dw104wtu.jpg],
        media_files: [{ file_size: 325_842 }],
        page_url: "https://www.weibo.com/2125874520/FDKGo4Lk0",
        profile_url: "https://www.weibo.com/u/2125874520",
        profile_urls: %w[https://www.weibo.com/u/2125874520],
        display_name: "偷菜佬TC",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [
          ["马上就上手的舰B", "https://s.weibo.com/weibo?q=%23马上就上手的舰B%23"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "#马上就上手的舰B#":[https://s.weibo.com/weibo?q=%23马上就上手的舰B%23] 第六波九宫格咯。
          第一波（"网页链接":[https://weibo.com/2125874520/FmyWsjGlA?type=comment#_rnd1515586781642]）
          第二波（"网页链接":[https://weibo.com/2125874520/FrhpUAtde?type=comment#_rnd1515586659305]）
          第三波（"网页链接":[https://weibo.com/2125874520/FvxNtwXqS?type=comment#_rnd1515586658718]）
          第四波（"网页链接":[https://weibo.com/2125874520/Fz1V7wOTf?from=page_1005052125874520_profile&wvr=6&mod=weibotime&type=comment#_rnd1515588106590]）
          第五波（"网页链接":[https://weibo.com/2125874520/FBkTEfLTj?from=page_1005052125874520_profile&wvr=6&mod=weibotime&type=comment#_rnd1515586677812]）
        EOS
      )
    end

    context "A deleted or not existing Weibo post" do
      strategy_should_work(
        "https://www.weibo.com/6476636003/Ks2qO3Hfy",
        image_urls: [],
        page_url: "https://www.weibo.com/6476636003/Ks2qO3Hfy",
        profile_urls: %w[https://www.weibo.com/u/6476636003],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A share.api.weibo.cn/share/:id URL" do
      strategy_should_work(
        "https://share.api.weibo.cn/share/304950356,4767694689143828.html",
        image_urls: %w[https://wx3.sinaimg.cn/large/007bspzxly1h23na4y0hhj32982pinpd.jpg],
        media_files: [{ file_size: 1_781_330 }],
        page_url: "https://www.weibo.com/6582241007/Lsp2YCmJ6",
        profile_url: "https://www.weibo.com/u/6582241007",
        profile_urls: %w[https://www.weibo.com/u/6582241007],
        display_name: "号布谷鸟",
        username: nil,
        published_at: Time.parse("2022-05-10T13:47:36.000000Z"),
        updated_at: nil,
        tags: [
          ["快递组", "https://s.weibo.com/weibo?q=%23快递组%23"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "#快递组#":[https://s.weibo.com/weibo?q=%23快递组%23] 摸了
        EOS
      )
    end
  end
end
