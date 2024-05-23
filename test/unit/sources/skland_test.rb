# frozen_string_literal: true

require "test_helper"

module Sources
  class SklandTest < ActiveSupport::TestCase
    context "Skland:" do
      context "A sample image URL" do
        strategy_should_work(
          "https://bbs.hycdn.cn/image/2024/04/29/576904/1dc98f0a6780ddcbc107d77bfdba673f.webp?x-oss-process=style/item_style",
          image_urls: %w[https://bbs.hycdn.cn/image/2024/04/29/576904/1dc98f0a6780ddcbc107d77bfdba673f.webp],
          media_files: [{ file_size: 320_016 }],
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
          "https://web.hycdn.cn/skland/site/assets/img/homeMainFirst.472886.png",
          image_urls: %w[https://web.hycdn.cn/skland/site/assets/img/homeMainFirst.472886.png],
          media_files: [{ file_size: 2_822_481 }],
          page_url: nil,
          profile_url: nil,
          profile_urls: %w[],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "An article with multiple images" do
        strategy_should_work(
          "https://www.skland.com/article?id=1913385",
          image_urls: %w[
            https://bbs.hycdn.cn/image/2024/05/09/263068/ebcbe681d2ebcf1546b6c14ded3cef27.webp
            https://bbs.hycdn.cn/image/2024/05/09/263068/00d747c36102572dcfb7d22ade796303.webp
            https://bbs.hycdn.cn/image/2024/05/09/263068/bc1a86dea473a3d6e5e57bd0be1982e7.webp
            https://bbs.hycdn.cn/image/2024/05/09/263068/16dafba2404803e2a30d659e95c15d5a.webp
            https://bbs.hycdn.cn/image/2024/05/09/263068/4bd6141edbb20c9231418040177d8e40.webp
          ],
          media_files: [
            { file_size: 447_334 },
            { file_size: 449_490 },
            { file_size: 530_368 },
            { file_size: 609_362 },
            { file_size: 51_398 },
          ],
          page_url: "https://www.skland.com/article?id=1913385",
          profile_urls: [],
          display_name: "煌色的凯喵",
          username: nil,
          tags: [
            ["阿米娅", "https://skland.com"],
          ],
          dtext_artist_commentary_title: "（转载，已授权）ヤモリ老师兔兔合集",
          dtext_artist_commentary_desc: <<~EOS.chomp
            看起来很快就要对牢博下手的样子

            特：日防夜防，家贼难防😨

            普：还有高手?😅

            凯：被小妹狠狠偷了家，这下样衰了😭

            博：噫，没关系的🤗，四个我都是一样的——😇！！
          EOS
        )
      end

      context "An article with a video" do
        strategy_should_work(
          "https://www.skland.com/article?id=1957041",
          image_urls: [%r{https://skland-vod.hycdn.cn/302baa34192071efbfae5017f0e90102/507915004148ecaf55d6244e88e976f5-ld.m3u8\?auth_key=.*}],
          media_files: [{ file_size: 2_239 }],
          page_url: "https://www.skland.com/article?id=1957041",
          profile_url: nil,
          profile_urls: %w[],
          display_name: "D咸鱼仔",
          username: nil,
          tags: [
            ["明日方舟", "https://skland.com"],
            ["鸿雪", "https://skland.com"],
            ["至简", "https://skland.com"],
          ],
          dtext_artist_commentary_title: "鸿雪大战小杜林！",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A commentary containing emojis and an image" do
        strategy_should_work(
          "https://www.skland.com/article?id=1624373",
          image_urls: %w[https://bbs.hycdn.cn/image/2024/02/24/636267/02a9b6efe9083d8c53476363704c67e9.webp],
          media_files: [{ file_size: 147_202 }],
          page_url: "https://www.skland.com/article?id=1624373",
          profile_urls: [],
          display_name: "Whisperain买外敷",
          username: nil,
          tags: [
            ["互助问答", "https://skland.com"],
          ],
          dtext_artist_commentary_title: "国际服新号求好友",
          dtext_artist_commentary_desc: <<~EOS.chomp
            絮雨买外敷#2243

            去年开的号，号上没几个好友:amiya-1__amiya_wuwu:
          EOS
        )
      end

      context "A deleted or nonexistent article" do
        strategy_should_work(
          "https://www.skland.com/article?id=999999999",
          image_urls: [],
          page_url: "https://www.skland.com/article?id=999999999",
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "Parse URLs correctly" do
        assert(Source::URL.image_url?("https://bbs.hycdn.cn/image/2024/04/29/576904/1dc98f0a6780ddcbc107d77bfdba673f.webp"))
        assert(Source::URL.image_url?("https://skland-vod.hycdn.cn/302baa34192071efbfae5017f0e90102/ceae138088e6ffb74cde2f255256f43d-sd-00004.ts?auth_key=1716481288-d3ee979fabcb40ba81081ceb020d6c61-0-3fe9870a677988387d250723b318776b"))
        assert(Source::URL.image_url?("https://skland-vod.hycdn.cn/302baa34192071efbfae5017f0e90102/507915004148ecaf55d6244e88e976f5-ld.m3u8?auth_key=1716481288-b59e656f4e32461d97c85ab666158512-0-9083e6744ad7e3e28c7231767731f2ea"))
        assert(Source::URL.image_url?("https://web.hycdn.cn/skland/site/assets/img/homeMainFirst.472886.png"))

        assert(Source::URL.page_url?("https://www.skland.com/article?id=1827735"))
        assert(Source::URL.page_url?("https://www.skland.com/h/detail?id=1827735"))
        assert(Source::URL.page_url?("https://m.skland.com/article?id=1827735"))
      end
    end
  end
end
