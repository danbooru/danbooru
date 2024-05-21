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
          "https://www.xiaohongshu.com/explore/66200ed0000000001c008538",
          image_urls: %w[
            https://ci.xiaohongshu.com/1040g008311n01khrnk005ortooqnru0rsc2ko0o
            https://ci.xiaohongshu.com/1040g008311n01khrnk205ortooqnru0rva292bo
            https://ci.xiaohongshu.com/1040g008311n01khrnk305ortooqnru0rp5tic5g
          ],
          media_files: [
            { file_size: 598_968 },
            { file_size: 594_026 },
            { file_size: 603_928 },
          ],
          page_url: "https://www.xiaohongshu.com/explore/66200ed0000000001c008538",
          profile_url: "https://www.xiaohongshu.com/user/profile/637dc635000000001f01f81b",
          profile_urls: %w[https://www.xiaohongshu.com/user/profile/637dc635000000001f01f81b],
          display_name: "MG_G",
          other_names: ["MG_G"],
          tags: [
            ["军舰", "https://www.xiaohongshu.com/search_result/?keyword=军舰"],
            ["画画", "https://www.xiaohongshu.com/search_result/?keyword=画画"],
            ["procreate", "https://www.xiaohongshu.com/search_result/?keyword=procreate"],
            ["德军", "https://www.xiaohongshu.com/search_result/?keyword=德军"],
            ["海军", "https://www.xiaohongshu.com/search_result/?keyword=海军"],
          ],
          dtext_artist_commentary_title: "沙恩霍斯特号战列舰",
          dtext_artist_commentary_desc: <<~EOS.chomp
            沙恩霍斯特永远向前！
            （最喜欢的军舰，尤其是北角海战涂装的沙恩真的是太帅了）
            KM成员记得4月20日到9月30日期间佩戴白色的帽子哦
            #军舰[话题]# #画画[话题]# #procreate[话题]# #德军[话题]# #海军[话题]#
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
