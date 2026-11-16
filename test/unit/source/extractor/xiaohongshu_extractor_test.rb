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

    context "A source with no page URL" do
      strategy_should_work(
        "https://ci.xiaohongshu.com/1000g00828idf6nofk05g5ohki5uk137o8beqcv8",
        image_urls: %w[https://ci.xiaohongshu.com/1000g00828idf6nofk05g5ohki5uk137o8beqcv8],
        media_files: [{ file_size: 561_862 }],
        page_url: nil,
      )
    end

    context "A post with multiple images" do
      strategy_should_work(
        "https://www.xiaohongshu.com/explore/6af5d369000000001603281a?xsec_token=ABJSeoMlAYSt8M0LLAvHiAF0BeMNRpTOVmnPjX7knOzI4=",
        image_urls: %w[
          https://ci.xiaohongshu.com/notes_pre_post/1040g3k8327fo5ssa7gcg5ohqnak0jie6kpnthn8
          https://ci.xiaohongshu.com/1040g008327fo5sl56q5g5ohqnak0jie6bfs2q0o
        ],
        media_files: [
          { file_size: 3_787_156 },
          { file_size: 333_894 },
        ],
        page_url: "https://www.xiaohongshu.com/explore/6af5d369000000001603281a?xsec_token=ABJSeoMlAYSt8M0LLAvHiAF0BeMNRpTOVmnPjX7knOzI4=",
        profile_url: "https://www.xiaohongshu.com/user/profile/623abaa8000000000201c9c6",
        profile_urls: %w[https://www.xiaohongshu.com/user/profile/623abaa8000000000201c9c6],
        display_name: "火叶叶",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [
          ["明日方舟终末地", "https://www.xiaohongshu.com/search_result?keyword=明日方舟终末地"],
          ["明日方舟终末地创作应援", "https://www.xiaohongshu.com/search_result?keyword=明日方舟终末地创作应援"],
          ["烟语", "https://www.xiaohongshu.com/search_result?keyword=烟语"],
          ["终末地丹青渡", "https://www.xiaohongshu.com/search_result?keyword=终末地丹青渡"],
          ["薯薯的四号谷地", "https://www.xiaohongshu.com/search_result?keyword=薯薯的四号谷地"],
          ["塔卫二通讯", "https://www.xiaohongshu.com/search_result?keyword=塔卫二通讯"],
        ],
        dtext_artist_commentary_title: "下班别忘记带她最爱吃的桂花米糕",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          陈千语做完酸辣汤急头白脸地打包了一份桂花米糕就回帝江号种植室找李织烟了
          其实此线稿十一之前就画完了，但是碰上秋促玩了个昏天黑地于是现在才填完坑哈哈（
          p2neta了一些懂自懂的帝后，产品1.6一句话都没说上我一点也没破防也不着急也不难受也不痛苦也不伤心也不哀嚎也不扭曲也不爬行也不阴暗也不悲伤……
          "#明日方舟终末地":[https://www.xiaohongshu.com/search_result?keyword=明日方舟终末地] "#明日方舟终末地创作应援":[https://www.xiaohongshu.com/search_result?keyword=明日方舟终末地创作应援] "#烟语":[https://www.xiaohongshu.com/search_result?keyword=烟语] "#终末地丹青渡":[https://www.xiaohongshu.com/search_result?keyword=终末地丹青渡] "#薯薯的四号谷地":[https://www.xiaohongshu.com/search_result?keyword=薯薯的四号谷地] "#塔卫二通讯":[https://www.xiaohongshu.com/search_result?keyword=塔卫二通讯]
        EOS
      )
    end

    context "A post with user id in url" do
      strategy_should_work(
        "https://www.xiaohongshu.com/user/profile/623abaa8000000000201c9c6/6af2e8850000000022038600?xsec_token=AB8gckcRPuWL0Y50U9clOxH6rEXF2-hNGelhwvD7cefxM=",
        image_urls: %w[https://ci.xiaohongshu.com/1040g008327ct1cas786g5ohqnak0jie6brk9fpg],
        media_files: [{ file_size: 2_516_000 }],
        page_url: "https://www.xiaohongshu.com/user/profile/623abaa8000000000201c9c6/6af2e8850000000022038600?xsec_token=AB8gckcRPuWL0Y50U9clOxH6rEXF2-hNGelhwvD7cefxM=",
        profile_url: "https://www.xiaohongshu.com/user/profile/623abaa8000000000201c9c6",
        profile_urls: %w[https://www.xiaohongshu.com/user/profile/623abaa8000000000201c9c6],
        display_name: "火叶叶",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [
          ["明日方舟终末地", "https://www.xiaohongshu.com/search_result?keyword=明日方舟终末地"],
          ["终末地丹青渡", "https://www.xiaohongshu.com/search_result?keyword=终末地丹青渡"],
          ["明日方舟终末地创作应援", "https://www.xiaohongshu.com/search_result?keyword=明日方舟终末地创作应援"],
          ["终末地明河", "https://www.xiaohongshu.com/search_result?keyword=终末地明河"],
          ["塔卫二通讯", "https://www.xiaohongshu.com/search_result?keyword=塔卫二通讯"],
          ["薯薯的四号谷地", "https://www.xiaohongshu.com/search_result?keyword=薯薯的四号谷地"],
        ],
        dtext_artist_commentary_title: "缘缘庄农副产品展示会欢迎您",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          缘缘庄举办了农产品展览会，热心市民夜明河先生与管理员参观武陵大呆瓜（右一）并展示自己的参展产品。
          本来想对个轴夜师傅卡池开的时候发的结果没想到遇到了换季感冒😭。。。
          "#明日方舟终末地":[https://www.xiaohongshu.com/search_result?keyword=明日方舟终末地] "#终末地丹青渡":[https://www.xiaohongshu.com/search_result?keyword=终末地丹青渡] "#明日方舟终末地创作应援":[https://www.xiaohongshu.com/search_result?keyword=明日方舟终末地创作应援] "#终末地明河":[https://www.xiaohongshu.com/search_result?keyword=终末地明河] "#塔卫二通讯":[https://www.xiaohongshu.com/search_result?keyword=塔卫二通讯] "#薯薯的四号谷地":[https://www.xiaohongshu.com/search_result?keyword=薯薯的四号谷地]
        EOS
      )
    end

    context "A post with /spectrum/ image URLs" do
      strategy_should_work(
        "https://www.xiaohongshu.com/explore/6a716dd20000000025010d76?xsec_token=ABVUE0qMoBlpEOUXiq_G6BgZNbMijqpvdcc0g91_yUPZs=",
        image_urls: %w[
          https://ci.xiaohongshu.com/spectrum/1040g34o323eejfhu6s805ohqnak0jie64h1rld8
          https://ci.xiaohongshu.com/spectrum/1040g0k0323eejhce6u005ohqnak0jie6nfmhnk8
        ],
        media_files: [
          { file_size: 651_591 },
          { file_size: 654_053 },
        ],
        page_url: "https://www.xiaohongshu.com/explore/6a716dd20000000025010d76?xsec_token=ABVUE0qMoBlpEOUXiq_G6BgZNbMijqpvdcc0g91_yUPZs=",
        profile_url: "https://www.xiaohongshu.com/user/profile/623abaa8000000000201c9c6",
        profile_urls: %w[https://www.xiaohongshu.com/user/profile/623abaa8000000000201c9c6],
        display_name: "火叶叶",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [
          ["边狱巴士", "https://www.xiaohongshu.com/search_result?keyword=边狱巴士"],
          ["箱璐", "https://www.xiaohongshu.com/search_result?keyword=箱璐"],
          ["lcb16", "https://www.xiaohongshu.com/search_result?keyword=lcb16"],
        ],
        dtext_artist_commentary_title: "和李箱先生/鸿璐君一起听音乐🎧",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          给我的女神大人@薄米花 画的生贺，画了女神最爱的蝶句酱[心花烂漫unlock][心花烂漫unlock]
          祝包菜大师生日快乐，新的一岁万事顺心工作顺利产品大麦！！希望能和大师一起画一辈子画，小的誓死永远追随女神大人！
          "#边狱巴士":[https://www.xiaohongshu.com/search_result?keyword=边狱巴士] "#箱璐":[https://www.xiaohongshu.com/search_result?keyword=箱璐] "#lcb16":[https://www.xiaohongshu.com/search_result?keyword=lcb16]
        EOS
      )
    end

    context "A video post" do
      strategy_should_work(
        "https://www.xiaohongshu.com/explore/6ad8d03f00000000330358db?xsec_token=ABsQcc_jPv3Vsw8xAvfwBxUDlpvJILwrsva4iBqtKzjQ8=",
        image_urls: %w[https://sns-video-bd.xhscdn.com/pre_post/1040g0cg326jdl6vlkq005ohqnak0jie6tc29g5o],
        media_files: [{ file_size: 17_787_642 }],
        page_url: "https://www.xiaohongshu.com/explore/6ad8d03f00000000330358db?xsec_token=ABsQcc_jPv3Vsw8xAvfwBxUDlpvJILwrsva4iBqtKzjQ8=",
        profile_url: "https://www.xiaohongshu.com/user/profile/623abaa8000000000201c9c6",
        profile_urls: %w[https://www.xiaohongshu.com/user/profile/623abaa8000000000201c9c6],
        display_name: "火叶叶",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [
          ["明日方舟终末地", "https://www.xiaohongshu.com/search_result?keyword=明日方舟终末地"],
          ["终末地丹青渡", "https://www.xiaohongshu.com/search_result?keyword=终末地丹青渡"],
          ["终末地卡缪", "https://www.xiaohongshu.com/search_result?keyword=终末地卡缪"],
          ["明日方舟终末地创作应援", "https://www.xiaohongshu.com/search_result?keyword=明日方舟终末地创作应援"],
          ["塔卫二通讯", "https://www.xiaohongshu.com/search_result?keyword=塔卫二通讯"],
          ["薯薯的四号谷地", "https://www.xiaohongshu.com/search_result?keyword=薯薯的四号谷地"],
        ],
        dtext_artist_commentary_title: "桌宠分享|卡缪",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          卡缪的搓了有翅膀和无翅膀两种，按一下就会展开翅膀，还多做了眨眼差分[棒R][棒R]
          邀请各位来按压这个小番茄蝙蝠！
          "#明日方舟终末地":[https://www.xiaohongshu.com/search_result?keyword=明日方舟终末地] "#终末地丹青渡":[https://www.xiaohongshu.com/search_result?keyword=终末地丹青渡] "#终末地卡缪":[https://www.xiaohongshu.com/search_result?keyword=终末地卡缪] "#明日方舟终末地创作应援":[https://www.xiaohongshu.com/search_result?keyword=明日方舟终末地创作应援] "#塔卫二通讯":[https://www.xiaohongshu.com/search_result?keyword=塔卫二通讯] "#薯薯的四号谷地":[https://www.xiaohongshu.com/search_result?keyword=薯薯的四号谷地]
        EOS
      )
    end

    context "A mixed post with videos and images" do
      strategy_should_work(
        "https://www.xiaohongshu.com/explore/67a396a7000000002503cbd3?xsec_token=CB3oB2uxOz4N-_klB-4pbVlrdBYp_24ofOwSJG_lQLGhM=",
        image_urls: %w[
          https://ci.xiaohongshu.com/1040g00831dhec8sn16005ps3g6f23fi49d2j5ao
          https://ci.xiaohongshu.com/1040g00831dhec8sn160g5ps3g6f23fi4fohe6vo
          http://sns-v11.rednotecdn.com/stream/1/10/19/01e7a396a34b27470100500394d7049ff0_19.mp4
        ],
        media_files: [
          { file_size: 491_868 },
          { file_size: 116_350 },
          { file_size: 867_997 },
        ],
        page_url: "https://www.xiaohongshu.com/explore/67a396a7000000002503cbd3?xsec_token=CB3oB2uxOz4N-_klB-4pbVlrdBYp_24ofOwSJG_lQLGhM=",
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
      strategy_should_work(
        "https://www.rednote.com/explore/6af2e8850000000022038600?xsec_token=AB8gckcRPuWL0Y50U9clOxH6rEXF2-hNGelhwvD7cefxM=",
        image_urls: %w[https://ci.xiaohongshu.com/1040g008327ct1cas786g5ohqnak0jie6brk9fpg],
        media_files: [{ file_size: 2_516_000 }],
        page_url: "https://www.xiaohongshu.com/explore/6af2e8850000000022038600?xsec_token=AB8gckcRPuWL0Y50U9clOxH6rEXF2-hNGelhwvD7cefxM=",
        profile_url: "https://www.xiaohongshu.com/user/profile/623abaa8000000000201c9c6",
        profile_urls: %w[https://www.xiaohongshu.com/user/profile/623abaa8000000000201c9c6],
        display_name: "火叶叶",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [
          ["明日方舟终末地", "https://www.xiaohongshu.com/search_result?keyword=明日方舟终末地"],
          ["终末地丹青渡", "https://www.xiaohongshu.com/search_result?keyword=终末地丹青渡"],
          ["明日方舟终末地创作应援", "https://www.xiaohongshu.com/search_result?keyword=明日方舟终末地创作应援"],
          ["终末地明河", "https://www.xiaohongshu.com/search_result?keyword=终末地明河"],
          ["塔卫二通讯", "https://www.xiaohongshu.com/search_result?keyword=塔卫二通讯"],
          ["薯薯的四号谷地", "https://www.xiaohongshu.com/search_result?keyword=薯薯的四号谷地"],
        ],
        dtext_artist_commentary_title: "缘缘庄农副产品展示会欢迎您",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          缘缘庄举办了农产品展览会，热心市民夜明河先生与管理员参观武陵大呆瓜（右一）并展示自己的参展产品。
          本来想对个轴夜师傅卡池开的时候发的结果没想到遇到了换季感冒😭。。。
          "#明日方舟终末地":[https://www.xiaohongshu.com/search_result?keyword=明日方舟终末地] "#终末地丹青渡":[https://www.xiaohongshu.com/search_result?keyword=终末地丹青渡] "#明日方舟终末地创作应援":[https://www.xiaohongshu.com/search_result?keyword=明日方舟终末地创作应援] "#终末地明河":[https://www.xiaohongshu.com/search_result?keyword=终末地明河] "#塔卫二通讯":[https://www.xiaohongshu.com/search_result?keyword=塔卫二通讯] "#薯薯的四号谷地":[https://www.xiaohongshu.com/search_result?keyword=薯薯的四号谷地]
        EOS
      )
    end

    context "A deleted or nonexistent post" do
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
