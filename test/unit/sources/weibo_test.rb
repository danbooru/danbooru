require "test_helper"

module Sources
  class WeiboTest < ActiveSupport::TestCase
    setup do
      # Skip in CI to work around test failures due to rate limiting by Weibo.
      skip if ENV["CI"].present?
    end

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
        tags: [
          ["fgo", "https://s.weibo.com/weibo?q=%23fgo%23"],
          ["Alter组", "https://s.weibo.com/weibo?q=%23Alter组%23"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
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
        tags: [
          ["fgo", "https://s.weibo.com/weibo?q=%23fgo%23"],
          ["Alter组", "https://s.weibo.com/weibo?q=%23Alter组%23"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
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
        tags: [
          ["明日方舟", "https://s.weibo.com/weibo?q=%23明日方舟%23"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
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
        tags: [
          ["崩坏星穹铁道", "https://s.weibo.com/weibo?q=%23崩坏星穹铁道%23"],
          ["星穹铁道1.1", "https://s.weibo.com/weibo?q=%23星穹铁道1.1%23"],
          ["丹恒", "https://s.weibo.com/weibo?q=%23丹恒%23"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          "崩坏星穹铁道":[https://weibo.com/p/100808e1f868bf9980f09ab6908787d7eaf0f0] "#崩坏星穹铁道#":[https://s.weibo.com/weibo?q=%23崩坏星穹铁道%23] "#星穹铁道1.1#":[https://s.weibo.com/weibo?q=%23星穹铁道1.1%23] "#丹恒#":[https://s.weibo.com/weibo?q=%23丹恒%23]

          帕姆放映厅 | 不苟言笑，实力超群的列车护卫——「冷面小青龙」！ "帕姆的收藏夹的微博视频":[https://video.weibo.com/show?fid=1034:4914351942074379]
        EOS
      )
    end

    # XXX The video URL returns 404.
    context "A Weibo video with an empty playback_list" do
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
        dtext_artist_commentary_desc: <<~EOS.chomp
          猜猜看誰被偷拍了？[嘻嘻][嘻嘻] "sandymandy的秒拍视频":[https://video.weibo.com/show?fid=1034:067e5f60923993c936abe48f1b0a11e2]
        EOS
      )
    end

    context "A Weibo post with images and videos" do
      strategy_should_work(
        "https://weibo.com/2427303621/MxojLlLgQ",
        image_urls: [
          %r{http://f.video.weibocdn.com/o0/6UFmijY5lx083Tat3dUY010412005WK80E010.mp4\?Expires=.*&ssig=.*&KID=unistore,video},
          "https://wx2.sinaimg.cn/large/90adb6c5ly1hc0l7kfkooj20zk44gb29.jpg",
          %r{http://f.video.weibocdn.com/o0/o1opApPDlx083Tauz3te01041200aOTe0E010.mp4\?Expires=.*&ssig=.*&KID=unistore,video},
          "https://wx3.sinaimg.cn/large/90adb6c5ly1hc0l85w0aaj214072qnpe.jpg",
          %r{http://f.video.weibocdn.com/o0/8JvVQ4I5lx083TatVmHK010412006WqC0E010.mp4\?Expires=.*&ssig=.*&KID=unistore,video},
          "https://wx3.sinaimg.cn/large/90adb6c5ly1hc0l83x05ij21402s01kx.jpg",
          %r{http://f.video.weibocdn.com/o0/OyGhsHWNlx083TauIlJu01041200m8h90E010.mp4\?Expires=.*&ssig=.*&KID=unistore,video},
          %r{http://f.video.weibocdn.com/o0/rYbzvUcjlx083TatZhji01041200arLc0E010.mp4\?Expires=.*&ssig=.*&KID=unistore,video},
          %r{http://f.video.weibocdn.com/o0/Xq5qKYgVlx083TawknVK01041200O1lT0E010.mp4\?Expires=.*&ssig=.*&KID=unistore,video},
        ],
        media_files: [
          { file_size: 1_417_452 },
          { file_size: 1_371_134 },
          { file_size: 2_578_904 },
          { file_size: 2_808_379 },
          { file_size: 1_654_570 },
          { file_size: 1_130_906 },
          { file_size: 5_275_031 },
          { file_size: 2_489_994 },
          { file_size: 11_921_601 },
        ],
        page_url: "https://www.weibo.com/2427303621/MxojLlLgQ",
        profile_url: "https://www.weibo.com/u/2427303621",
        profile_urls: %w[https://www.weibo.com/u/2427303621],
        display_name: "痞影人科莱昂",
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          诚邀首页欣赏艺术，美到要我命🆘🤯[舔屏][舔屏][舔屏][awsl][awsl][awsl][awsl][awsl][awsl][awsl][awsl][awsl]
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
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: ""
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
        tags: [
          ["马上就上手的舰B", "https://s.weibo.com/weibo?q=%23马上就上手的舰B%23"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
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
        "https://weibo.com/5265069929/LiLnMENgs",
        image_urls: [],
        page_url: "https://www.weibo.com/5265069929/LiLnMENgs",
        profile_url: "https://www.weibo.com/u/5265069929",
        profile_urls: %w[https://www.weibo.com/u/5265069929],
        display_name: nil,
        other_names: [],
        tag_name: "weibo_5265069929",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: ""
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
        tags: [
          ["快递组", "https://s.weibo.com/weibo?q=%23快递组%23"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          "#快递组#":[https://s.weibo.com/weibo?q=%23快递组%23] 摸了
        EOS
      )
    end

    should "Parse Weibo URLs correctly" do
      assert_equal("https://www.weibo.com/3150932560/H4cFbeKKA", Source::URL.page_url("https://www.weibo.com/3150932560/H4cFbeKKA?from=page_1005053150932560_profile&wvr=6&mod=weibotime"))
      assert_equal("https://m.weibo.cn/detail/4242129997905387", Source::URL.page_url("https://photo.weibo.com/2125874520/wbphotos/large/mid/4242129997905387/pid/7eb64558ly1friyzhj44lj20dw2qxe81"))
      assert_equal("https://m.weibo.cn/status/4173757483008088", Source::URL.page_url("https://m.weibo.cn/status/4173757483008088?luicode=20000061&lfid=4170879204256635"))
      assert_equal("https://m.weibo.cn/detail/4098035921690224", Source::URL.page_url("https://tw.weibo.com/SEINEN/4098035921690224"))

      assert(Source::URL.image_url?("http://ww1.sinaimg.cn/large/69917555gw1f6ggdghk28j20c87lbhdt.jpg"))
      assert(Source::URL.image_url?("http://ww4.sinaimg.cn/mw690/77a2d531gw1f4u411ws3aj20m816fagg.jpg"))
      assert(Source::URL.image_url?("https://wx4.sinaimg.cn/orj360/e3930166gy1g546bz86cij20u00u040y.jpg"))
      assert(Source::URL.image_url?("https://wx1.sinaimg.cn/original/7004ec1cly1ge9dcbsw4lj20jg2ir7wh.jpg"))
      assert(Source::URL.image_url?("https://f.video.weibocdn.com/o0/wPhyi3dIlx086mr8Md3y01041200xT4N0E010.mp4?label=mp4_1080p&template=1080x1920.24.0&media_id=4914351942074379&tp=8x8A3El:YTkl0eM8&us=0&ori=1&bf=4&ot=v&ps=3lckmu&uid=3ZoTIp&ab=,3601-g32,8143-g0,8013-g0,3601-g32,3601-g37&Expires=1716316057&ssig=uW43Bg6Lo1&KID=unistore,video"))
      assert(Source::URL.image_url?("https://f.us.sinaimg.cn/003K8vB7lx07rz92ubWg010412002UHB0E010.mp4?label=mp4_1080p&template=1920x1080.20.0&media_id=4339747921802209&tp=8x8A3El:YTkl0eM8&us=0&ori=1&bf=4&ot=h&lp=00002g58dE&ps=mZ6WB&uid=zszavag&ab=13038-g0,&Expires=1716411960&ssig=qmkXwFd%2B1m&KID=unistore,video"))

      assert(Source::URL.page_url?("http://tw.weibo.com/1300957955/3786333853668537"))
      assert(Source::URL.page_url?("http://photo.weibo.com/2125874520/wbphotos/large/mid/4194742441135220/pid/7eb64558gy1fnbryb5nzoj20dw10419t"))
      assert(Source::URL.page_url?("http://weibo.com/3357910224/EEHA1AyJP"))
      assert(Source::URL.page_url?("https://www.weibo.com/5501756072/IF9fugHzj?from=page_1005055501756072_profile&wvr=6&mod=weibotime"))
      assert(Source::URL.page_url?("https://www.weibo.com/detail/4676597657371957"))
      assert(Source::URL.page_url?("https://m.weibo.cn/detail/4506950043618873"))
      assert(Source::URL.page_url?("https://m.weibo.cn/status/J33G4tH1B"))

      assert(Source::URL.profile_url?("https://www.weibo.com/u/5501756072"))
      assert(Source::URL.profile_url?("https://m.weibo.cn/u/5501756072"))
      assert(Source::URL.profile_url?("https://m.weibo.cn/profile/5501756072"))
      assert(Source::URL.profile_url?("https://www.weibo.com/p/1005055399876326"))
      assert(Source::URL.profile_url?("https://www.weibo.com/5501756072"))
      assert(Source::URL.profile_url?("https://www.weibo.com/endlessnsmt"))
      assert(Source::URL.profile_url?("https://www.weibo.com/4ubergine/photos"))
      assert(Source::URL.profile_url?("https://www.weibo.com/n/小小男爵不要坑"))

      refute(Source::URL.profile_url?("https://weibo.com/u/"))
    end
  end
end
