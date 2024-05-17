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
        other_names: ["阿尔托莉雅厨"],
        tag_name: "weibo_5501756072",
        tags: [
          ["fgo", "https://s.weibo.com/weibo/fgo"],
          ["Alter组", "https://s.weibo.com/weibo/Alter组"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          "#fgo#":[https://m.weibo.cn/search?containerid=231522type%3D1%26t%3D10%26q%3D%23fgo%23&isnewpage=1&luicode=20000061&lfid=4506950043618873]"#Alter组#":[https://m.weibo.cn/search?containerid=231522type%3D1%26t%3D10%26q%3D%23Alter%E7%BB%84%23&luicode=20000061&lfid=4506950043618873] 变装潜入搜查→夫妻感
          作者：nipi "@saberchankawaii":[https://www.weibo.com/n/saberchankawaii] "网页链接":[https://weibo.cn/sinaurl?u=https%3A%2F%2Ftwitter.com%2Fsaberchankawaii%2Fstatus%2F1263110113625178112%3Fs%3D21]
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
        page_url: "https://www.weibo.com/5501756072/J2UNKfbqV",
        profile_url: "https://www.weibo.com/u/5501756072",
        profile_urls: %w[https://www.weibo.com/u/5501756072],
        display_name: "阿尔托莉雅厨",
        other_names: ["阿尔托莉雅厨"],
        tag_name: "weibo_5501756072",
        tags: [
          ["fgo", "https://s.weibo.com/weibo/fgo"],
          ["Alter组", "https://s.weibo.com/weibo/Alter组"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          "#fgo#":[https://m.weibo.cn/search?containerid=231522type%3D1%26t%3D10%26q%3D%23fgo%23&isnewpage=1&luicode=20000061&lfid=4506950043618873]"#Alter组#":[https://m.weibo.cn/search?containerid=231522type%3D1%26t%3D10%26q%3D%23Alter%E7%BB%84%23&luicode=20000061&lfid=4506950043618873] 变装潜入搜查→夫妻感
          作者：nipi "@saberchankawaii":[https://www.weibo.com/n/saberchankawaii] "网页链接":[https://weibo.cn/sinaurl?u=https%3A%2F%2Ftwitter.com%2Fsaberchankawaii%2Fstatus%2F1263110113625178112%3Fs%3D21]
          授权见评，请勿二传
        EOS
      )
    end

    context "A Weibo post with video" do
      strategy_should_work(
        "https://www.weibo.com/5501756072/IF9fugHzj",
        image_urls: [%r{https://f.video.weibocdn.com/HPzdmCB4lx07CNYTsq0U01041200wd320E010.mp4\?label=mp4_720p&template=1280x720.25.0&trans_finger=1f0da16358befad33323e3a1b7f95fc9&ori=0&ps=1BThihd3VLAY5R&Expires=.*&ssig=.*&KID=unistore,video}],
        media_files: [{ file_size: 7_676_656 }],
        page_url: "https://www.weibo.com/5501756072/IF9fugHzj",
        profile_url: "https://www.weibo.com/u/5501756072",
        profile_urls: %w[https://www.weibo.com/u/5501756072],
        display_name: "阿尔托莉雅厨",
        other_names: ["阿尔托莉雅厨"],
        tag_name: "weibo_5501756072",
        tags: [
          ["明日方舟", "https://s.weibo.com/weibo/明日方舟"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          "#明日方舟#":[https://m.weibo.cn/search?containerid=231522type%3D1%26t%3D10%26q%3D%23%E6%98%8E%E6%97%A5%E6%96%B9%E8%88%9F%23&extparam=%23%E6%98%8E%E6%97%A5%E6%96%B9%E8%88%9F%23&luicode=20000061&lfid=4498070043980729] Jazz up!
          作者：DAIRIN "@DAIRIN75929273":[https://www.weibo.com/n/DAIRIN75929273] "网页链接":[https://weibo.cn/sinaurl?u=https%3A%2F%2Ftwitter.com%2FDAIRIN75929273%2Fstatus%2F1254382963732606977%3Fs%3D20]
          授权见评，请勿二传 "阿尔托莉雅厨的微博视频":[https://video.weibo.com/show?fid=1034:4498069178482724]
        EOS
      )
    end

    context "A direct image sample Weibo upload" do
      strategy_should_work(
        "https://wx3.sinaimg.cn/mw690/a00fa34cly1gf62g2n8z3j21yu2jo1ky.jpg",
        image_urls: %w[https://wx3.sinaimg.cn/large/a00fa34cly1gf62g2n8z3j21yu2jo1ky.jpg],
        media_files: [{ file_size: 2_421_067 }],
        page_url: nil,
        profile_url: nil,
        profile_urls: %w[],
        display_name: nil,
        other_names: [],
        tag_name: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: ""
      )
    end

    context "A multi-page Weibo upload" do
      strategy_should_work(
        "https://wx1.sinaimg.cn/large/7eb64558gy1fnbryriihwj20dw104wtu.jpg",
        referer: "https://photo.weibo.com/2125874520/wbphotos/large/mid/4194742441135220/pid/7eb64558gy1fnbryb5nzoj20dw10419t",
        image_urls: %w[https://wx1.sinaimg.cn/large/7eb64558gy1fnbryriihwj20dw104wtu.jpg],
        media_files: [{ file_size: 325_842 }],
        page_url: "https://www.weibo.com/2125874520/FDKGo4Lk0",
        profile_url: "https://www.weibo.com/u/2125874520",
        profile_urls: %w[https://www.weibo.com/u/2125874520],
        display_name: "偷菜佬TC",
        other_names: ["偷菜佬TC"],
        tag_name: "weibo_2125874520",
        tags: [
          ["马上就上手的舰B", "https://s.weibo.com/weibo/马上就上手的舰B"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          "#马上就上手的舰B#":[https://m.weibo.cn/search?containerid=231522type%3D1%26t%3D10%26q%3D%23%E9%A9%AC%E4%B8%8A%E5%B0%B1%E4%B8%8A%E6%89%8B%E7%9A%84%E8%88%B0B%23&luicode=20000061&lfid=4194742441135220] 第六波九宫格咯。
          第一波（"网页链接":[https://weibo.com/2125874520/FmyWsjGlA?type=comment#_rnd1515586781642]）
          第二波（"网页链接":[https://weibo.com/2125874520/FrhpUAtde?type=comment#_rnd1515586659305]）
          第三波（"网页链接":[https://weibo.com/2125874520/FvxNtwXqS?type=comment#_rnd1515586658718]）
          第四波（"网页链接":[https://weibo.com/2125874520/Fz1V7wOTf?from=page_1005052125874520_profile&wvr=6&mod=weibotime&type=comment#_rnd1515588106590]）
          第五波（"网页链接":[https://weibo.com/2125874520/FBkTEfLTj?from=page_1005052125874520_profile&wvr=6&mod=weibotime&type=comment#_rnd1515586677812]）
        EOS
      )
    end

    context "A deleted or not existing Weibo picture" do
      strategy_should_work(
        "https://weibo.com/5265069929/LiLnMENgs",
        image_urls: [],
        page_url: nil,
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
        other_names: ["号布谷鸟"],
        tag_name: "weibo_6582241007",
        tags: [
          ["快递组", "https://s.weibo.com/weibo/快递组"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          "#快递组#":[https://m.weibo.cn/search?containerid=231522type%3D1%26t%3D10%26q%3D%23%E5%BF%AB%E9%80%92%E7%BB%84%23&extparam=%23%E5%BF%AB%E9%80%92%E7%BB%84%23&luicode=20000061&lfid=4767694689143828] 摸了
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
