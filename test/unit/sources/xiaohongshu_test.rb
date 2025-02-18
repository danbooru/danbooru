# frozen_string_literal: true

require "test_helper"

module Sources
  class XiaohongshuTest < ActiveSupport::TestCase
    context "Xiaohongshu:" do
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

      context "A img.xiaohongshu.com avatar sample image URL" do
        strategy_should_work(
          "https://img.xiaohongshu.com/avatar/5b56be0014de415b2db830a6.jpg@160w_160h_92q_1e_1c_1x.jpg",
          image_urls: %w[https://img.xiaohongshu.com/avatar/5b56be0014de415b2db830a6.jpg],
          media_files: [{ file_size: 571_625 }],
          page_url: nil,
        )
      end

      context "A post with multiple images" do
        strategy_should_work(
          "https://www.xiaohongshu.com/explore/676692a9000000000b022e4d?xsec_token=ABp9YCBRRqv5v30dlFfxzHw8HBaoViPhFHlY2eTE035AM=",
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
            { file_size: 2_432_700 },
            { file_size: 1_543_097 },
            { file_size: 1_475_318 },
            { file_size: 1_552_256 },
            { file_size: 1_485_541 },
            { file_size: 1_512_886 },
            { file_size: 1_348_828 },
            { file_size: 1_531_060 },
            { file_size: 1_523_305 },
            { file_size: 1_613_587 }
          ],
          page_url: "https://www.xiaohongshu.com/user/profile/60e5175300000000010083e0/676692a9000000000b022e4d?xsec_token=ABp9YCBRRqv5v30dlFfxzHw8HBaoViPhFHlY2eTE035AM=",
          profile_urls: %w[https://www.xiaohongshu.com/user/profile/60e5175300000000010083e0],
          display_name: "面包棍棍",
          username: nil,
          tags: [
            ["明日方舟", "https://www.xiaohongshu.com/search_result/?keyword=明日方舟"],
            ["搬空罗德岛食堂", "https://www.xiaohongshu.com/search_result/?keyword=搬空罗德岛食堂"],
            ["comike105", "https://www.xiaohongshu.com/search_result/?keyword=comike105"],
            ["cpgz07", "https://www.xiaohongshu.com/search_result/?keyword=cpgz07"],
          ],
          dtext_artist_commentary_title: "搬空食堂DLC全收录🍽",
          dtext_artist_commentary_desc: <<~EOS.chomp
            做完了两年的企划怎么不算是2023-2024小结呢……挺能画啊我自己！（叉会腰）

            整理了本DLC插图全收录的48P小图册，会参加年底的冬コミ（C105），如果有去CM的朋友欢迎来東7/U39b找我玩——！
            国内的话，因为还有食品补充和收纳盒的部分待制作所以会稍晚一点，预计首发会是明年二月广州CPG07，已火速申摊香菇莫辜负🙏
            "#明日方舟":[https://www.xiaohongshu.com/search_result?keyword=%25E6%2598%258E%25E6%2597%25A5%25E6%2596%25B9%25E8%2588%259F&type=54&source=web_note_detail_r10] "#搬空罗德岛食堂":[https://www.xiaohongshu.com/search_result?keyword=%25E6%2590%25AC%25E7%25A9%25BA%25E7%25BD%2597%25E5%25BE%25B7%25E5%25B2%259B%25E9%25A3%259F%25E5%25A0%2582&type=54&source=web_note_detail_r10] "#comike105":[https://www.xiaohongshu.com/search_result?keyword=comike105&type=54&source=web_note_detail_r10] "#cpgz07":[https://www.xiaohongshu.com/search_result?keyword=cpgz07&type=54&source=web_note_detail_r10]
          EOS
        )
      end

      context "A post with /spectrum/ image URLs" do
        strategy_should_work(
          "https://www.xiaohongshu.com/explore/650293e4000000001e022308",
          image_urls: %w[
            https://ci.xiaohongshu.com/spectrum/1040g0k030p06mpo4k0005ovbk4n9t3fq5ms4iu0
            https://ci.xiaohongshu.com/spectrum/1040g0k030p06mpkdju005ovbk4n9t3fqveguc70
          ],
          media_files: [
            { file_size: 1_164_038 },
            { file_size: 930_250 },
          ],
          page_url: "https://www.xiaohongshu.com/explore/650293e4000000001e022308",
          profile_url: "https://www.xiaohongshu.com/user/profile/63eba12e0000000027028dfa",
          profile_urls: %w[https://www.xiaohongshu.com/user/profile/63eba12e0000000027028dfa],
          display_name: "三水吉吉",
          username: nil,
          tags: [
            ["绘画", "https://www.xiaohongshu.com/search_result/?keyword=绘画"],
            ["私人稿件禁止使用", "https://www.xiaohongshu.com/search_result/?keyword=私人稿件禁止使用"],
            ["立绘", "https://www.xiaohongshu.com/search_result/?keyword=立绘"],
          ],
          dtext_artist_commentary_title: "一对立绘",
          dtext_artist_commentary_desc: <<~EOS.chomp
            最近画图动力大大up，真的很努力在稿了！！ #绘画[话题]# #私人稿件禁止使用[话题]# #立绘[话题]#
            ps：暂不接稿~
          EOS
        )
      end

      context "A video post" do
        strategy_should_work(
          "https://www.xiaohongshu.com/explore/662cb841000000000d030cbd",
          image_urls: %w[https://sns-video-bd.xhscdn.com/pre_post/1040g2t03123bm2b13q6g5o56b7k085i9gkig2ho],
          media_files: [{ file_size: 31_213_453 }],
          page_url: "https://www.xiaohongshu.com/explore/662cb841000000000d030cbd",
          profile_url: "https://www.xiaohongshu.com/user/profile/60a659e80000000001001649",
          profile_urls: %w[https://www.xiaohongshu.com/user/profile/60a659e80000000001001649],
          display_name: "白歌",
          username: nil,
          tags: [
            ["崩坏星穹铁道创作者激励计划", "https://www.xiaohongshu.com/search_result/?keyword=崩坏星穹铁道创作者激励计划"],
            ["崩坏星穹铁道", "https://www.xiaohongshu.com/search_result/?keyword=崩坏星穹铁道"],
            ["星穹铁道生日会", "https://www.xiaohongshu.com/search_result/?keyword=星穹铁道生日会"],
            ["开拓时间到", "https://www.xiaohongshu.com/search_result/?keyword=开拓时间到"],
          ],
          dtext_artist_commentary_title: "第一次看到砂金输的这么惨，青雀深藏不露啊",
          dtext_artist_commentary_desc: <<~EOS.chomp
            第一次看到砂金输的这么惨，青雀深藏不露啊#崩坏星穹铁道创作者激励计划[话题]# #崩坏星穹铁道[话题]# #星穹铁道生日会[话题]# #开拓时间到[话题]#
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
          dtext_artist_commentary_desc: ""
        )
      end

      should "Parse URLs correctly" do
        assert(Source::URL.image_url?("http://sns-webpic-qc.xhscdn.com/202405050857/60985d4963cfb500a9b0838667eb3adc/1000g00828idf6nofk05g5ohki5uk137o8beqcv8!nd_dft_wgth_webp_3"))
        assert(Source::URL.image_url?("https://ci.xiaohongshu.com/1000g00828idf6nofk05g5ohki5uk137o8beqcv8"))
        assert(Source::URL.image_url?("https://sns-avatar-qc.xhscdn.com/avatar/1040g2jo30s5tg4ugig605ohki5uk137o34ug2fo"))

        assert(Source::URL.page_url?("https://www.xiaohongshu.com/explore/6421b331000000002702901f"))
        assert(Source::URL.page_url?("https://www.xiaohongshu.com/user/profile/6234917d0000000010008cf8/6421b331000000002702901f"))
        assert(Source::URL.page_url?("https://www.xiaohongshu.com/discovery/item/65880524000000000700a643"))

        assert(Source::URL.profile_url?("https://www.xiaohongshu.com/user/profile/6234917d0000000010008cf8"))
      end
    end
  end
end
