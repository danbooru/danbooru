require "test_helper"

module Source::Tests::Extractor
  class XiaohongshuExtractorTest < ActiveSupport::ExtractorTestCase
    context "A xhscdn.com sample image URL" do
      strategy_should_work(
        "http://sns-webpic-qc.xhscdn.com/202405050857/60985d4963cfb500a9b0838667eb3adc/1000g00828idf6nofk05g5ohki5uk137o8beqcv8!nd_dft_wgth_webp_3",
        image_urls: %w[https://ci.xiaohongshu.com/1000g00828idf6nofk05g5ohki5uk137o8beqcv8],
        media_files: [{ file_size: 561_862 }],
        page_url: nil,
      )
    end

    context "A ci.xiaohongshu.com full image URL" do
      strategy_should_work(
        "https://ci.xiaohongshu.com/1000g00828idf6nofk05g5ohki5uk137o8beqcv8",
        image_urls: %w[https://ci.xiaohongshu.com/1000g00828idf6nofk05g5ohki5uk137o8beqcv8],
        media_files: [{ file_size: 561_862 }],
        page_url: nil,
      )
    end

    context "A ci.xiaohongshu.com sample image URL" do
      strategy_should_work(
        "https://ci.xiaohongshu.com/1000g00828idf6nofk05g5ohki5uk137o8beqcv8?imageView2/2/w/100/h/100/q/75",
        image_urls: %w[https://ci.xiaohongshu.com/1000g00828idf6nofk05g5ohki5uk137o8beqcv8],
        media_files: [{ file_size: 561_862 }],
        page_url: nil,
      )
    end

    context "A ci.xiaohongshu.com/notes_pre_post sample image URL" do
      strategy_should_work(
        "https://ci.xiaohongshu.com/notes_pre_post/1040g3k031il3oqupga005nsgsmfg8ue6bq81dbg?imageView2/2/w/format/png",
        image_urls: %w[https://ci.xiaohongshu.com/notes_pre_post/1040g3k031il3oqupga005nsgsmfg8ue6bq81dbg],
        media_files: [{ file_size: 1_124_447 }],
        page_url: nil,
      )
    end

    context "A img.xiaohongshu.com avatar sample image URL" do
      strategy_should_work(
        "https://img.xiaohongshu.com/avatar/5b56be0014de415b2db830a6.jpg@160w_160h_92q_1e_1c_1x.jpg",
        image_urls: %w[https://img.xiaohongshu.com/avatar/5b56be0014de415b2db830a6.jpg],
        media_files: [{ file_size: 571_625 }],
        page_url: nil,
      )
    end

    context "A post with multiple images" do
      setup { skip "Xiaohongshu extractor requires credentials" unless Source::Extractor::Xiaohongshu.enabled? }

      strategy_should_work(
        "https://www.xiaohongshu.com/explore/674a802f0000000007029471?xsec_token=ABgt_jFg7t-LqYcRm3UlqAClF0o0f3BaJn3Ye5zUIYtms=",
        image_urls: %w[
          https://ci.xiaohongshu.com/1040g2sg31aqeccv4mo704a54lgjgfvujhe954v8
          https://ci.xiaohongshu.com/1040g2sg31aqeccv4mo7g4a54lgjgfvujfhua5oo
          https://ci.xiaohongshu.com/1040g2sg31aqeccv4mo804a54lgjgfvuj16g2iho
        ],
        media_files: [
          { file_size: 1_427_202 },
          { file_size: 699_830 },
          { file_size: 844_990 },
        ],
        page_url: "https://www.xiaohongshu.com/explore/674a802f0000000007029471?xsec_token=ABgt_jFg7t-LqYcRm3UlqAClF0o0f3BaJn3Ye5zUIYtms=",
        profile_url: "https://www.xiaohongshu.com/user/profile/5af06707db2e600283b2ffd3",
        profile_urls: %w[https://www.xiaohongshu.com/user/profile/5af06707db2e600283b2ffd3],
        display_name: "撸卜",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [
          ["绘画", "https://www.xiaohongshu.com/search_result?keyword=绘画"],
          ["明日方舟", "https://www.xiaohongshu.com/search_result?keyword=明日方舟"],
          ["铃兰", "https://www.xiaohongshu.com/search_result?keyword=铃兰"],
          ["忍冬", "https://www.xiaohongshu.com/search_result?keyword=忍冬"],
        ],
        dtext_artist_commentary_title: "妈妈的伞☂️",
        dtext_artist_commentary_desc: "\"#绘画\":[https://www.xiaohongshu.com/search_result?keyword=绘画] \"#明日方舟\":[https://www.xiaohongshu.com/search_result?keyword=明日方舟] \"#铃兰\":[https://www.xiaohongshu.com/search_result?keyword=铃兰] \"#忍冬\":[https://www.xiaohongshu.com/search_result?keyword=忍冬]",
      )
    end

    context "A post with user id in url" do
      setup { skip "Xiaohongshu extractor requires credentials" unless Source::Extractor::Xiaohongshu.enabled? }

      strategy_should_work(
        "https://www.xiaohongshu.com/user/profile/5af06707db2e600283b2ffd3/674a802f0000000007029471?xsec_token=ABgt_jFg7t-LqYcRm3UlqAClF0o0f3BaJn3Ye5zUIYtms=",
        image_urls: %w[
          https://ci.xiaohongshu.com/1040g2sg31aqeccv4mo704a54lgjgfvujhe954v8
          https://ci.xiaohongshu.com/1040g2sg31aqeccv4mo7g4a54lgjgfvujfhua5oo
          https://ci.xiaohongshu.com/1040g2sg31aqeccv4mo804a54lgjgfvuj16g2iho
        ],
        media_files: [
          { file_size: 1_427_202 },
          { file_size: 699_830 },
          { file_size: 844_990 },
        ],
        page_url: "https://www.xiaohongshu.com/user/profile/5af06707db2e600283b2ffd3/674a802f0000000007029471?xsec_token=ABgt_jFg7t-LqYcRm3UlqAClF0o0f3BaJn3Ye5zUIYtms=",
        profile_url: "https://www.xiaohongshu.com/user/profile/5af06707db2e600283b2ffd3",
        profile_urls: %w[https://www.xiaohongshu.com/user/profile/5af06707db2e600283b2ffd3],
        display_name: "撸卜",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [
          ["绘画", "https://www.xiaohongshu.com/search_result?keyword=绘画"],
          ["明日方舟", "https://www.xiaohongshu.com/search_result?keyword=明日方舟"],
          ["铃兰", "https://www.xiaohongshu.com/search_result?keyword=铃兰"],
          ["忍冬", "https://www.xiaohongshu.com/search_result?keyword=忍冬"],
        ],
        dtext_artist_commentary_title: "妈妈的伞☂️",
        dtext_artist_commentary_desc: "\"#绘画\":[https://www.xiaohongshu.com/search_result?keyword=绘画] \"#明日方舟\":[https://www.xiaohongshu.com/search_result?keyword=明日方舟] \"#铃兰\":[https://www.xiaohongshu.com/search_result?keyword=铃兰] \"#忍冬\":[https://www.xiaohongshu.com/search_result?keyword=忍冬]",
      )
    end

    context "A post with /spectrum/ image URLs" do
      setup { skip "Xiaohongshu extractor requires credentials" unless Source::Extractor::Xiaohongshu.enabled? }

      strategy_should_work(
        "https://www.xiaohongshu.com/explore/676692a9000000000b022e4d?xsec_token=ABp9YCBRRqv5v30dlFfxzHwyv1xk_xBquzQJZeoJf5H7g=",
        image_urls: %w[
          https://ci.xiaohongshu.com/spectrum/1040g0k031blr5gcag8005o752t9g90v028pbu80
          https://ci.xiaohongshu.com/spectrum/1040g0k031blr5mbl0c005o752t9g90v0ah6ctv0
          https://ci.xiaohongshu.com/spectrum/1040g0k031blr5mbl0c0g5o752t9g90v0r22nlj0
          https://ci.xiaohongshu.com/spectrum/1040g0k031blr5mbl0c105o752t9g90v0lp9ibqg
          https://ci.xiaohongshu.com/spectrum/1040g0k031blr5mbl0c1g5o752t9g90v0uc58cj0
          https://ci.xiaohongshu.com/spectrum/1040g0k031blr5mbl0c205o752t9g90v02hsbnk8
          https://ci.xiaohongshu.com/spectrum/1040g0k031blr5mbl0c2g5o752t9g90v0ff1s0s0
          https://ci.xiaohongshu.com/spectrum/1040g0k031blr5mbl0c305o752t9g90v0ke7vp40
          https://ci.xiaohongshu.com/spectrum/1040g0k031blr5mbl0c3g5o752t9g90v00g8uka8
          https://ci.xiaohongshu.com/spectrum/1040g0k031blr5mbl0c405o752t9g90v03m2llno
        ],
        media_files: [
          { file_size: 2_434_034 },
          { file_size: 1_543_097 },
          { file_size: 1_475_318 },
          { file_size: 1_552_256 },
          { file_size: 1_485_541 },
          { file_size: 1_512_886 },
          { file_size: 1_348_828 },
          { file_size: 1_531_060 },
          { file_size: 1_523_305 },
          { file_size: 1_613_587 },
        ],
        page_url: "https://www.xiaohongshu.com/explore/676692a9000000000b022e4d?xsec_token=ABp9YCBRRqv5v30dlFfxzHwyv1xk_xBquzQJZeoJf5H7g=",
        profile_url: "https://www.xiaohongshu.com/user/profile/60e5175300000000010083e0",
        profile_urls: %w[https://www.xiaohongshu.com/user/profile/60e5175300000000010083e0],
        display_name: "面包棍🥖",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [
          ["明日方舟", "https://www.xiaohongshu.com/search_result?keyword=明日方舟"],
          ["搬空罗德岛食堂", "https://www.xiaohongshu.com/search_result?keyword=搬空罗德岛食堂"],
          ["comike105", "https://www.xiaohongshu.com/search_result?keyword=comike105"],
          ["cpgz07", "https://www.xiaohongshu.com/search_result?keyword=cpgz07"],
        ],
        dtext_artist_commentary_title: "搬空食堂DLC全收录🍽",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          做完了两年的企划怎么不算是2023-2024小结呢……挺能画啊我自己！（叉会腰）

          整理了本DLC插图全收录的48P小图册，会参加年底的冬コミ（C105），如果有去CM的朋友欢迎来東7/U39b找我玩——！
          国内的话，因为还有食品补充和收纳盒的部分待制作所以会稍晚一点，预计首发会是明年二月广州CPG07，已火速申摊香菇莫辜负🙏
          "#明日方舟":[https://www.xiaohongshu.com/search_result?keyword=明日方舟] "#搬空罗德岛食堂":[https://www.xiaohongshu.com/search_result?keyword=搬空罗德岛食堂] "#comike105":[https://www.xiaohongshu.com/search_result?keyword=comike105] "#cpgz07":[https://www.xiaohongshu.com/search_result?keyword=cpgz07]
        EOS
      )
    end

    context "A video post" do
      setup { skip "Xiaohongshu extractor requires credentials" unless Source::Extractor::Xiaohongshu.enabled? }

      strategy_should_work(
        "https://www.xiaohongshu.com/explore/6789d20f000000001d011d4b?xsec_token=ABYRoRr3DGE29GWtiam4UBANcw79-RNRRc1VdpIJVdz1A=",
        image_urls: %w[https://sns-video-bd.xhscdn.com/spectrum/1040g0jg31co8l51912005nrar8808fbnkchvk1o],
        media_files: [{ file_size: 21_449_849 }],
        page_url: "https://www.xiaohongshu.com/explore/6789d20f000000001d011d4b?xsec_token=ABYRoRr3DGE29GWtiam4UBANcw79-RNRRc1VdpIJVdz1A=",
        profile_urls: %w[https://www.xiaohongshu.com/user/profile/5f6ada100000000001003d77],
        display_name: "✨Rocky",
        username: nil,
        tags: [
          ["锈湖", "https://www.xiaohongshu.com/search_result?keyword=锈湖"],
          ["锈湖系列", "https://www.xiaohongshu.com/search_result?keyword=锈湖系列"],
          ["锈湖天堂岛", "https://www.xiaohongshu.com/search_result?keyword=锈湖天堂岛"],
          ["锈湖旅馆", "https://www.xiaohongshu.com/search_result?keyword=锈湖旅馆"],
          ["同人", "https://www.xiaohongshu.com/search_result?keyword=同人"],
          ["锈湖同人", "https://www.xiaohongshu.com/search_result?keyword=锈湖同人"],
          ["rustylake", "https://www.xiaohongshu.com/search_result?keyword=rustylake"],
          ["fanart", "https://www.xiaohongshu.com/search_result?keyword=fanart"],
          ["插画", "https://www.xiaohongshu.com/search_result?keyword=插画"],
          ["二创", "https://www.xiaohongshu.com/search_result?keyword=二创"],
        ],
        dtext_artist_commentary_title: "◾️没有伟大的牺牲，就没有锈湖。",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          血色将至🩸There will be blood.
          🥲本来想做隐藏图的但是后面尝试发现只能做饱和度非常低的版本，效果很差，所以放弃啦~
          "#锈湖":[https://www.xiaohongshu.com/search_result?keyword=锈湖] "#锈湖系列":[https://www.xiaohongshu.com/search_result?keyword=锈湖系列] "#锈湖天堂岛":[https://www.xiaohongshu.com/search_result?keyword=锈湖天堂岛] "#锈湖旅馆":[https://www.xiaohongshu.com/search_result?keyword=锈湖旅馆] "#同人":[https://www.xiaohongshu.com/search_result?keyword=同人] "#锈湖同人":[https://www.xiaohongshu.com/search_result?keyword=锈湖同人] "#rustylake":[https://www.xiaohongshu.com/search_result?keyword=rustylake] "#fanart":[https://www.xiaohongshu.com/search_result?keyword=fanart] "#插画":[https://www.xiaohongshu.com/search_result?keyword=插画] "#二创":[https://www.xiaohongshu.com/search_result?keyword=二创]
        EOS
      )
    end

    context "A mixed post with videos and images" do
      setup { skip "Xiaohongshu extractor requires credentials" unless Source::Extractor::Xiaohongshu.enabled? }

      strategy_should_work(
        "https://www.xiaohongshu.com/explore/67a396a7000000002503cbd3?xsec_token=AB4LyC1SEvdhEyOhMoeo9jT30BdU1-uQcUDPBgukFMt4g=&xsec_source=pc_user",
        image_urls: %w[
          https://ci.xiaohongshu.com/1040g00831dhec8sn16005ps3g6f23fi49d2j5ao
          https://ci.xiaohongshu.com/1040g00831dhec8sn160g5ps3g6f23fi4fohe6vo
          http://sns-video-alos.xhscdn.com/stream/1/10/19/01e7a396a34b27470100500394d7049ff0_19.mp4
        ],
        media_files: [
          { file_size: 627_574 },
          { file_size: 294_766 },
          { file_size: 867_997 },
        ],
        page_url: "https://www.xiaohongshu.com/explore/67a396a7000000002503cbd3?xsec_token=AB4LyC1SEvdhEyOhMoeo9jT30BdU1-uQcUDPBgukFMt4g=",
        profile_url: "https://www.xiaohongshu.com/user/profile/6783819e000000000801be44",
        profile_urls: %w[https://www.xiaohongshu.com/user/profile/6783819e000000000801be44],
        display_name: "梦游蝴蝶的日常",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [
          ["Mbti", "https://www.xiaohongshu.com/search_result?keyword=Mbti"],
          ["infp", "https://www.xiaohongshu.com/search_result?keyword=infp"],
          ["小蝴蝶", "https://www.xiaohongshu.com/search_result?keyword=小蝴蝶"],
          ["生日快乐", "https://www.xiaohongshu.com/search_result?keyword=生日快乐"],
          ["mbti16人格", "https://www.xiaohongshu.com/search_result?keyword=mbti16人格"],
        ],
        dtext_artist_commentary_title: "小蝴蝶| 你会给玩偶过生日吗？",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "#Mbti":[https://www.xiaohongshu.com/search_result?keyword=Mbti] "#infp":[https://www.xiaohongshu.com/search_result?keyword=infp] "#小蝴蝶":[https://www.xiaohongshu.com/search_result?keyword=小蝴蝶] "#生日快乐":[https://www.xiaohongshu.com/search_result?keyword=生日快乐]

          很喜欢史迪仔，陪伴了七八年的玩偶，会抱着他说很多很多话。于是在没有人关心的夜晚，买了一个小蛋糕，拉上窗帘，大声歌唱，郑重其事给我的玩偶朋友过了生日。

          这种事情从5岁的我发生到25岁的我，可能只有善良温暖的INFP会一以贯之吧。

          "#mbti16人格":[https://www.xiaohongshu.com/search_result?keyword=mbti16人格]
          封面来自：九言绘一
        EOS
      )
    end

    context "A post on rednote.com" do
      setup { skip "Xiaohongshu extractor requires credentials" unless Source::Extractor::Xiaohongshu.enabled? }
    
      strategy_should_work(
        "https://www.rednote.com/explore/69d503c7000000001f007995?xsec_token=ABR7xc7xnydtN9Cqof7XXZDNQnk_bgI9LF753p_b_5IZg=",
        image_urls: %w[
          https://ci.xiaohongshu.com/notes_pre_post/1040g3k031ulmkboi2i6g5ohqnak0jie6odk9k0o
          https://ci.xiaohongshu.com/notes_pre_post/1040g3k031ulmkboi2i605ohqnak0jie6kit9f58
          https://ci.xiaohongshu.com/notes_pre_post/1040g3k031ulmkboi2i505ohqnak0jie6a6iu50o
        ],
        media_files: [
          { file_size: 3_439_122 },
          { file_size: 5_734_475 },
          { file_size: 2_344_734 },
        ],
        page_url: "https://www.xiaohongshu.com/explore/69d503c7000000001f007995?xsec_token=ABR7xc7xnydtN9Cqof7XXZDNQnk_bgI9LF753p_b_5IZg=",
        profile_url: "https://www.xiaohongshu.com/user/profile/623abaa8000000000201c9c6",
        profile_urls: %w[https://www.xiaohongshu.com/user/profile/623abaa8000000000201c9c6],
        display_name: "火叶叶",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [
          ["明日方舟终末地", "https://www.xiaohongshu.com/search_result?keyword=明日方舟终末地"],
          ["新潮起故渊离", "https://www.xiaohongshu.com/search_result?keyword=新潮起故渊离"],
          ["洛茜", "https://www.xiaohongshu.com/search_result?keyword=洛茜"],
          ["明日方舟终末地创作应援", "https://www.xiaohongshu.com/search_result?keyword=明日方舟终末地创作应援"],
          ["全世界最可爱的小狼宝宝", "https://www.xiaohongshu.com/search_result?keyword=全世界最可爱的小狼宝宝"],
        ],
        dtext_artist_commentary_title: "秘密基地里的洛茜和小管",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          扎小辫子的游戏对洛茜来说可能有点幼稚，但是对于管理员来说刚刚好！
          "#明日方舟终末地":[https://www.xiaohongshu.com/search_result?keyword=明日方舟终末地] "#新潮起故渊离":[https://www.xiaohongshu.com/search_result?keyword=新潮起故渊离] "#洛茜":[https://www.xiaohongshu.com/search_result?keyword=洛茜] "#明日方舟终末地创作应援":[https://www.xiaohongshu.com/search_result?keyword=明日方舟终末地创作应援] "#全世界最可爱的小狼宝宝":[https://www.xiaohongshu.com/search_result?keyword=全世界最可爱的小狼宝宝]
        EOS
      )
    end

    context "A deleted or nonexistent post" do
      setup { skip "Xiaohongshu extractor requires credentials" unless Source::Extractor::Xiaohongshu.enabled? }

      strategy_should_work(
        "https://www.xiaohongshu.com/explore/999999999",
        image_urls: %w[],
        media_files: [],
        page_url: "https://www.xiaohongshu.com/explore/999999999",
        profile_url: nil,
        profile_urls: %w[],
        display_name: nil,
        other_names: [],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end
  end
end
