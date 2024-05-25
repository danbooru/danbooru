# frozen_string_literal: true

require "test_helper"

module Sources
  class MiyousheTest < ActiveSupport::TestCase
    context "Hoyolab:" do
      context "A sample image URL" do
        strategy_should_work(
          "https://upload-os-bbs.hoyolab.com/upload/2022/12/25/58551199/3356bf88b08fdc8aaa5b5e6b26f70d23_5122589414918681540.jpg?x-oss-process=image%2Fauto-orient%2C0%2Finterlace%2C1%2Fformat%2Cwebp%2Fquality%2Cq_80",
          image_urls: %w[https://upload-os-bbs.hoyolab.com/upload/2022/12/25/58551199/3356bf88b08fdc8aaa5b5e6b26f70d23_5122589414918681540.jpg],
          media_files: [{ file_size: 661_715 }],
          page_url: nil,
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "An article with multiple images" do
        strategy_should_work(
          "https://www.hoyolab.com/article/14554718",
          image_urls: %w[
            https://upload-os-bbs.hoyolab.com/upload/2022/12/25/58551199/3356bf88b08fdc8aaa5b5e6b26f70d23_5122589414918681540.jpg
            https://upload-os-bbs.hoyolab.com/upload/2022/12/25/58551199/67aa02fbcd7feaa931df41989d43b360_405579748740677012.jpg
            https://upload-os-bbs.hoyolab.com/upload/2022/12/25/58551199/65eec1f5fd064313896c812b9bb32a60_768205588714510918.jpg
            https://upload-os-bbs.hoyolab.com/upload/2022/12/25/58551199/acd14e604abead89c79852652ba322dc_1088999719166092107.jpg
          ],
          media_files: [
            { file_size: 661_715 },
            { file_size: 525_007 },
            { file_size: 518_905 },
            { file_size: 504_342 },
          ],
          page_url: "https://www.hoyolab.com/article/14554718",
          profile_url: "https://www.hoyolab.com/accountCenter/postList?id=58551199",
          profile_urls: %w[https://www.hoyolab.com/accountCenter/postList?id=58551199],
          display_name: "seelnon",
          username: nil,
          tags: [
            ["Fan Art", "https://www.hoyolab.com/topicDetail/5"],
            ["Genshin Impact", "https://www.hoyolab.com/topicDetail/1008"],
            ["Amber", "https://www.hoyolab.com/topicDetail/435"],
          ],
          dtext_artist_commentary_title: "Amber, Solitude",
          dtext_artist_commentary_desc: <<~EOS.chomp
            Was practicing textures and vibrancy. All that red is just abstract stuff to fit RWB colour scheme, Amber is fine =)
          EOS
        )
      end

      context "An article with images in the commentary" do
        strategy_should_work(
          "https://www.hoyolab.com/article/23063798",
          image_urls: %w[
            https://upload-os-bbs.hoyolab.com/upload/2023/11/17/16bb1762812903fd7b409ca878d91d36_1990117926016059378.jpg
            https://upload-os-bbs.hoyolab.com/upload/2023/11/17/a726071d3ba441d17b5946856ddbee8b_7273652058433671632.jpg
          ],
          media_files: [
            { file_size: 156_875 },
            { file_size: 274_038 },
          ],
          page_url: "https://www.hoyolab.com/article/23063798",
          profile_urls: %w[https://www.hoyolab.com/accountCenter/postList?id=1015537],
          display_name: "Genshin Impact Official",
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "Genshin Impact ｜ Paimon's Paintings  XXVIII Emojis Now Available!",
          dtext_artist_commentary_desc: <<~EOS.chomp
            "[image]":[https://upload-os-bbs.hoyolab.com/upload/2023/11/17/16bb1762812903fd7b409ca878d91d36_1990117926016059378.jpg]

            Greetings, Travelers! The latest emojis from Genshin Impact are now available on HoYoLAB~

            Paimon's Paintings include a collection of chibi emojis of various Genshin Impact characters. We hope you like them! Paimon will continue to paint more cute emojis for everyone~

            "[image]":[https://upload-os-bbs.hoyolab.com/upload/2023/11/17/a726071d3ba441d17b5946856ddbee8b_7273652058433671632.jpg]
          EOS
        )
      end

      context "A deleted or nonexistent article" do
        strategy_should_work(
          "https://www.hoyolab.com/article/999999999",
          image_urls: [],
          page_url: "https://www.hoyolab.com/article/999999999",
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end
    end

    context "Miyoushe:" do
      context "A sample image URL" do
        strategy_should_work(
          "https://upload-bbs.miyoushe.com/upload/2022/09/14/73731802/2e25565bd6fa86d86b581e151e9778ac_8107601733815763725.jpg?x-oss-process=image/resize,s_600/quality,q_80/auto-orient,0/interlace,1/format,jpg",
          image_urls: %w[https://upload-bbs.mihoyo.com/upload/2022/09/14/73731802/2e25565bd6fa86d86b581e151e9778ac_8107601733815763725.jpg],
          media_files: [{ file_size: 5_710_223 }],
          page_url: nil,
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "An unknown image URL" do
        strategy_should_work(
          "https://act-upload.mihoyo.com/sr-wiki/2023/12/12/279865110/71407be63242f3b5ef6c73cbd12a4d0b_708709569307330375.png",
          image_urls: %w[https://act-upload.mihoyo.com/sr-wiki/2023/12/12/279865110/71407be63242f3b5ef6c73cbd12a4d0b_708709569307330375.png],
          media_files: [{ file_size: 5_798_937 }],
          page_url: nil,
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "An article with multiple images" do
        strategy_should_work(
          "https://www.miyoushe.com/bh3/article/53114504",
          image_urls: %w[
            https://upload-bbs.miyoushe.com/upload/2024/05/23/294793394/92df40e3acb32327011e2f5ca6f5dcfa_316472910014603594.jpg
            https://upload-bbs.miyoushe.com/upload/2024/05/23/294793394/917a84d26a5184e19d6d7e52634a4790_8492679095619953214.png
            https://upload-bbs.miyoushe.com/upload/2024/05/23/294793394/0431a25f29897661179e12090e558767_1193816014887204670.png
          ],
          media_files: [
            { file_size: 406_346 },
            { file_size: 1_579_722 },
            { file_size: 940_149 },
          ],
          page_url: "https://www.miyoushe.com/bh3/article/53114504",
          profile_urls: %w[https://www.miyoushe.com/sr/accountCenter/postList?id=294793394],
          display_name: "好楠好楠好",
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "大月下的一个废稿",
          dtext_artist_commentary_desc: "第二张是透明底 自印随意"
        )
      end

      context "An article with a video" do
        strategy_should_work(
          "https://www.miyoushe.com/wd/article/53120694",
          image_urls: [%r{https://prod-vod-sign.miyoushe.com/ooKvbeTisEJIQWJ35PqPsGMFC9iyz4h1gQzAAN\?auth_key=.*}],
          media_files: [{ file_size: 7_292_955 }],
          page_url: "https://www.miyoushe.com/wd/article/53120694",
          profile_urls: %w[https://www.miyoushe.com/sr/accountCenter/postList?id=6013613],
          display_name: "静电灰猫",
          username: nil,
          tags: [
            ["全员", "https://www.miyoushe.com/sr/topicDetail/260"],
          ],
          dtext_artist_commentary_title: "什么，是牛叉叉乐队",
          dtext_artist_commentary_desc: <<~EOS.chomp
            随着大家会的乐器越来越多，这个梗也到了可以玩的成熟的时机了呢！
            主唱当然是知更鸟………………（捂嘴）

            参考了崩铁的网页活动，音频使用了官方的忒弥斯年会视频~
          EOS
        )
      end

      context "A commentary that has structured_content" do
        strategy_should_work(
          "https://www.miyoushe.com/ys/article/7529945",
          image_urls: %w[
            https://upload-bbs.miyoushe.com/upload/2021/07/16/76387920/d711db5e7548c5092ae493c8f0f141b4_1463840908667281597.jpg
            https://upload-bbs.miyoushe.com/upload/2021/07/16/76387920/9beea07fc1df8afd0147f412e5e7c192_1333319342413172376.png
            https://upload-bbs.miyoushe.com/upload/2021/07/16/76387920/e5305c5d2da19c1a163ca0ed2558d376_3003504897984041373.jpg
            https://upload-bbs.miyoushe.com/upload/2021/07/16/76387920/f7d080f1ac7a2e8bec5a4a1acd79c441_8735645332234191790.jpg
            https://upload-bbs.miyoushe.com/upload/2021/07/23/76387920/881477afe200dca3cae9ebbaaf406214_4799848910151994455.png
          ],
          media_files: [
            { file_size: 68_660 },
            { file_size: 2_324_348 },
            { file_size: 209_989 },
            { file_size: 143_100 },
            { file_size: 6_183 },
          ],
          page_url: "https://www.miyoushe.com/ys/article/7529945",
          profile_urls: %w[https://www.miyoushe.com/sr/accountCenter/postList?id=76387920],
          display_name: "迷路的史莱姆酱",
          username: nil,
          tags: [
            ["提瓦特冒险记", "https://www.miyoushe.com/sr/topicDetail/406"],
          ],
          dtext_artist_commentary_title: "【已开奖】提瓦特冒险记·第十七期",
          dtext_artist_commentary_desc: <<~EOS.chomp
            "[image]":[https://upload-bbs.miyoushe.com/upload/2021/07/16/76387920/d711db5e7548c5092ae493c8f0f141b4_1463840908667281597.jpg]

            姆，旅行者们中午好呀~

            酱酱现在在稻妻姆，还有了一个大发现——路边有个从没见过的装置，上面的指针还会晃来晃去！听丘丘人说，通过这样的装置往往能发现宝藏。姆，有宝藏！酱酱想要快点找到它><

            顺着指针的方向往前看，不远处的草丛好像有动静姆，难道那里就是藏宝点吗？宝藏——酱酱来啦——

            姆，雷酱为什么会在这里(｡ŏ_ŏ)

            "[image]":[https://upload-bbs.miyoushe.com/upload/2021/07/16/76387920/9beea07fc1df8afd0147f412e5e7c192_1333319342413172376.png]

            原来这个装置把雷酱当成宝藏了么？酱酱想不明白…这样的话，装置会不会也认为酱酱是宝藏呢？

            酱酱在稻妻遇到了很多不懂的东西呢，等旅行者们来到稻妻冒险，可以帮酱酱解答这些疑问吗？说起来，旅行者们来到稻妻后有什么计划吗，分享给酱酱听一听吧~

            [b]第十七期的讨论主题是：[/b]

            [b]来到稻妻后，旅行者们想做的第一件事是什么呢？告诉酱酱吧！[/b]

            [b]【活动时间】[/b]

            2021年7月17日-7月19日23:59

            开奖时间：7月23日，在本活动帖内更新获奖名单

            [b]【参与方式】[/b]

            活动期间内，在帖子内[b]分享来到稻妻之后想做的第一件事[/b]，即视为参与成功。

            [b]【活动奖励】[/b]

            [b]随机角色立牌*10[/b]

            酱酱会从成功参与活动的旅行者中随机抽选10名赠送周边奖励哦~

            [b]【注意事项】[/b]

            1.请旅行者关注系统通知，周边中奖信息会出现在里面哦，若周边获奖者在通知发出后未在指定时间前完成地址填写，则视为放弃奖励。如果旅行者获得了周边奖励，请按照以下步骤填写地址："【填写地址教程】":[https://bbs.mihoyo.com/ys/article/48940]。

            2.若旅行者的回复内容与本次活动无关，或直接使用本帖内的示意图回复，将会被视为无效回复。

            [b]【活动实体奖励】[/b]

            "[image]":[https://upload-bbs.miyoushe.com/upload/2021/07/16/76387920/e5305c5d2da19c1a163ca0ed2558d376_3003504897984041373.jpg]

            "[image]":[https://upload-bbs.miyoushe.com/upload/2021/07/16/76387920/f7d080f1ac7a2e8bec5a4a1acd79c441_8735645332234191790.jpg]

            [hr]

            ▲[b]随机角色立牌[/b]

            "[image]":[https://upload-bbs.miyoushe.com/upload/2021/07/23/76387920/881477afe200dca3cae9ebbaaf406214_4799848910151994455.png]

            恭喜以上获奖旅行者，周边奖励将在45个工作日内发货；请旅行者注意查收奖励通知，并在规定时间范围内按照以下步骤填写地址："【填写地址教程】":[https://bbs.mihoyo.com/ys/article/48940]。若获奖者在通知发出后未在指定时间前完成地址填写，则视为放弃奖励。
          EOS
        )
      end

      context "A commentary that doesn't have structured_content" do
        strategy_should_work(
          "https://www.miyoushe.com/bh3/article/6361416",
          image_urls: %w[
            https://upload-bbs.miyoushe.com/upload/2021/05/24/74986891/7d4dbda18529f58d7df8c305042de46d_1567042328575150606.jpg
            https://upload-bbs.miyoushe.com/upload/2021/05/24/74986891/d348737fc3c063c6e1093a6a17975b26_9068924321001023591.jpg
          ],
          media_files: [
            { file_size: 972_709 },
            { file_size: 957_106 },
          ],
          page_url: "https://www.miyoushe.com/bh3/article/6361416",
          profile_urls: %w[https://www.miyoushe.com/sr/accountCenter/postList?id=74986891],
          display_name: "大懒鸭鸭",
          username: nil,
          tags: [
            ["同人图", "https://www.miyoushe.com/sr/topicDetail/53"],
            ["希儿", "https://www.miyoushe.com/sr/topicDetail/93"],
          ],
          dtext_artist_commentary_title: "黑希",
          dtext_artist_commentary_desc: <<~EOS.chomp
            太弱小了，根本不会画，心情不好就这样吧
          EOS
        )
      end

      context "A deleted or nonexistent article" do
        strategy_should_work(
          "https://www.miyoushe.com/sr/article/999999999",
          image_urls: [],
          page_url: "https://www.miyoushe.com/sr/article/999999999",
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "Parse URLs correctly" do
        assert(Source::URL.image_url?("https://upload-bbs.miyoushe.com/upload/2022/09/14/73731802/2e25565bd6fa86d86b581e151e9778ac_8107601733815763725.jpg"))
        assert(Source::URL.image_url?("https://upload-bbs.mihoyo.com/upload/2022/09/14/73731802/2e25565bd6fa86d86b581e151e9778ac_8107601733815763725.jpg"))
        assert(Source::URL.image_url?("https://upload-os-bbs.hoyolab.com/upload/2022/12/25/58551199/3356bf88b08fdc8aaa5b5e6b26f70d23_5122589414918681540.jpg"))
        assert(Source::URL.image_url?("https://prod-vod-sign.miyoushe.com/ooKvbeTisEJIQWJ35PqPsGMFC9iyz4h1gQzAAN?auth_key=1716561874-d87f81457c-0-fdd0dd6514dd0e6f612a312448908500"))
        assert(Source::URL.image_url?("https://act-upload.mihoyo.com/sr-wiki/2023/12/12/279865110/71407be63242f3b5ef6c73cbd12a4d0b_708709569307330375.png"))
        assert(Source::URL.image_url?("https://webstatic.mihoyo.com/upload/event/2023/08/10/40131b779e708c2f9f464ea7424e8773_4631307118561606922.jpg"))

        assert(Source::URL.page_url?("https://bbs.mihoyo.com/bh3/article/28939887"))
        assert(Source::URL.page_url?("https://www.miyoushe.com/bh3/article/28939887"))
        assert(Source::URL.page_url?("https://m.bbs.mihoyo.com/bh3?channel=miyousheluodi%2F#/article/27266673"))
        assert(Source::URL.page_url?("https://m.miyoushe.com/bh3?channel=miyousheluodi%2F#/article/27266673"))
        assert(Source::URL.page_url?("https://www.hoyolab.com/article/14554718"))
        assert(Source::URL.page_url?("https://m.hoyolab.com/#/article/28583736?utm_source=sns&utm_medium=twitter&utm_id=2"))

        assert(Source::URL.profile_url?("https://bbs.mihoyo.com/bh3/accountCenter/postList?id=73731802"))
        assert(Source::URL.profile_url?("https://www.miyoushe.com/bh3/accountCenter/postList?id=73731802"))
        assert(Source::URL.profile_url?("https://www.miyoushe.com/sr/accountCenter/replyList?id=73731802"))
        assert(Source::URL.profile_url?("https://m.miyoushe.com/bh3/#/accountCenter/0?id=275785895"))
        assert(Source::URL.profile_url?("https://www.hoyolab.com/accountCenter/postList?id=58551199"))
      end
    end
  end
end
