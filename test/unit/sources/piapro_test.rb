# frozen_string_literal: true

require "test_helper"

module Sources
  class PiaproTest < ActiveSupport::TestCase
    context "Piapro:" do
      context "A sample image URL" do
        strategy_should_work(
          "https://cdn.piapro.jp/thumb_i/w2/w22xmltnyzcsrqxu_20240303200945_0860_0600.png",
          image_urls: [%r{https://dl.piapro.jp/image/w2/w22xmltnyzcsrqxu_20240303200945.png\?response-content-disposition=attachment%3B%20filename%2A%3DUTF-8%27%27%25E7%2597%259B%25E3%2581%2584%25E7%2597%259B%25E3%2581%2584%25E7%2597%259B%25E3%2581%2584_nibiirooo__.*.png&Expires=.*&Signature=.*&Key-Pair-Id=APKAIJPPZV4JCCSOERBA}],
          media_files: [{ file_size: 2_627_543 }],
          page_url: "https://piapro.jp/content/w22xmltnyzcsrqxu",
          profile_url: "https://piapro.jp/nibiirooo_",
          profile_urls: %w[https://piapro.jp/nibiirooo_],
          display_name: "鈍色",
          username: "nibiirooo_",
          tag_name: "nibiirooo",
          other_names: ["鈍色", "nibiirooo_"],
          tags: [
            ["#ダーク", "https://piapro.jp/content_list/?view=image&tag=%23ダーク"],
            ["#ダークイラスト", "https://piapro.jp/content_list/?view=image&tag=%23ダークイラスト"],
            ["#デジタル", "https://piapro.jp/content_list/?view=image&tag=%23デジタル"],
            ["#デジタルイラスト", "https://piapro.jp/content_list/?view=image&tag=%23デジタルイラスト"],
            ["#暗闇", "https://piapro.jp/content_list/?view=image&tag=%23暗闇"],
            ["#闇", "https://piapro.jp/content_list/?view=image&tag=%23闇"],
            ["#キャラクター", "https://piapro.jp/content_list/?view=image&tag=%23キャラクター"],
          ],
          dtext_artist_commentary_title: "痛い痛い痛い",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A Piapro /t/ post" do
        strategy_should_work(
          "https://piapro.jp/t/Oq1h",
          image_urls: [%r{https://dl.piapro.jp/image/74/74w6x4s2s39aag5q_20240325172302.png\?response-content-disposition=attachment%3B%20filename%2A%3DUTF-8%27%27%25E6%25B6%2599_Akechannogohan_.*.png&Expires=.*&Signature=.*&Key-Pair-Id=APKAIJPPZV4JCCSOERBA}],
          media_files: [{ file_size: 733_073 }],
          page_url: "https://piapro.jp/content/74w6x4s2s39aag5q",
          profile_url: "https://piapro.jp/Akechannogohan",
          profile_urls: %w[https://piapro.jp/Akechannogohan],
          display_name: "みんなのごはん",
          username: "Akechannogohan",
          tag_name: "akechannogohan",
          other_names: ["みんなのごはん", "Akechannogohan"],
          tags: [
            ["#初音ミク", "https://piapro.jp/content_list/?view=image&tag=%23初音ミク"],
          ],
          dtext_artist_commentary_title: "涙",
          dtext_artist_commentary_desc: <<~EOS.chomp
            泣いちゃった、みくさん
            泣いてない差分あり(別投稿)
          EOS
        )
      end

      context "A Piapro /content/ post" do
        strategy_should_work(
          "https://piapro.jp/content/c3qyoafiphej1ze4",
          image_urls: [%r{https://dl.piapro.jp/image/c3/c3qyoafiphej1ze4_20080916145553.jpg\?response-content-disposition=attachment%3B%20filename%2A%3DUTF-8%27%27miku-002_senra_spiral_.*.jpg&Expires=.*&Signature=.*&Key-Pair-Id=APKAIJPPZV4JCCSOERBA}],
          media_files: [{ file_size: 420_769 }],
          page_url: "https://piapro.jp/content/c3qyoafiphej1ze4",
          profile_url: "https://piapro.jp/senra_spiral",
          profile_urls: %w[https://piapro.jp/senra_spiral],
          display_name: "senra_spiral",
          username: "senra_spiral",
          tag_name: "senra_spiral",
          other_names: ["senra_spiral"],
          tags: [
            ["#初音ミク", "https://piapro.jp/content_list/?view=image&tag=%23初音ミク"],
            ["#ＳＧイラスト", "https://piapro.jp/content_list/?view=image&tag=%23ＳＧイラスト"],
          ],
          dtext_artist_commentary_title: "miku-002",
          dtext_artist_commentary_desc: "ＳＧイラスト"
        )
      end

      context "A Piapro post with an external link in the commentary" do
        strategy_should_work(
          "https://piapro.jp/t/3ELH",
          image_urls: [%r{https://dl.piapro.jp/image/oa/oavlpswezkf6qbz6_20110802012124.jpg\?response-content-disposition=attachment%3B%20filename%2A%3DUTF-8%27%27%25E3%2581%258A%25E3%2581%25A3%25E3%2581%25B1%25E3%2581%2584%25E3%2581%25AE%25E6%2597%25A5%25E3%2581%25A0%25E3%2581%25A3%25E3%2581%259F%25E3%2582%2589%25E3%2581%2597%25E3%2581%2584_urushizawa_.*.jpg&Expires=.*&Signature=.*&Key-Pair-Id=APKAIJPPZV4JCCSOERBA}],
          media_files: [{ file_size: 214_223 }],
          page_url: "https://piapro.jp/content/oavlpswezkf6qbz6",
          profile_url: "https://piapro.jp/urushizawa",
          profile_urls: %w[https://piapro.jp/urushizawa],
          display_name: "漆沢貴之",
          username: "urushizawa",
          tag_name: "urushizawa",
          other_names: ["漆沢貴之", "urushizawa"],
          tags: [
            ["#巡音ルカ", "https://piapro.jp/content_list/?view=image&tag=%23巡音ルカ"],
            ["#おっぱい", "https://piapro.jp/content_list/?view=image&tag=%23おっぱい"],
            ["#セウト", "https://piapro.jp/content_list/?view=image&tag=%23セウト"],
          ],
          dtext_artist_commentary_title: "おっぱいの日だったらしい",
          dtext_artist_commentary_desc: <<~EOS.chomp
            国連も認めるおっぱいの日（<http://bit.ly/obhXVP>）だったらしいのでおっぱい描きます。手ブラですけど
          EOS
        )
      end

      context "A Piapro audio post" do
        strategy_should_work(
          "https://piapro.jp/t/vL-W",
          image_urls: [%r{https://dl.piapro.jp/audio/6x/6xytf62fxl4w15m7_20240430135355.mp3\?response-content-disposition=attachment%3B%20filename%2A%3DUTF-8%27%27%25E3%2581%25B5%25E3%2581%259F%25E3%2582%258A%25E3%2581%25BC%25E3%2581%25A3%25E3%2581%25A1%2520-%2520%25E3%2583%2584%25E3%2583%25A6%25E3%2583%258E%25E3%2582%25B5%25E3%2582%25AF%25E3%2583%25A9%2520%2528off%2520vocal%2529_to_you_no_.*.mp3&Expires=.*&Signature=.*&Key-Pair-Id=APKAIJPPZV4JCCSOERBA}],
          media_files: [{ file_size: 4_244_559 }],
          page_url: "https://piapro.jp/content/6xytf62fxl4w15m7",
          profile_url: "https://piapro.jp/to_you_no",
          profile_urls: %w[https://piapro.jp/to_you_no],
          display_name: "ツユノサクラ",
          username: "to_you_no",
          tag_name: "to_you_no",
          other_names: ["ツユノサクラ", "to_you_no"],
          tags: [
            ["#可不", "https://piapro.jp/content_list/?view=image&tag=%23可不"],
            ["#オリジナル曲", "https://piapro.jp/content_list/?view=image&tag=%23オリジナル曲"],
          ],
          dtext_artist_commentary_title: "ふたりぼっち - ツユノサクラ (off vocal)",
          dtext_artist_commentary_desc: "Youtube→<https://youtu.be/5vhznF6fR4w>"
        )
      end

      context "A Piapro text post" do
        strategy_should_work(
          "https://piapro.jp/t/QAbp",
          image_urls: [],
          page_url: "https://piapro.jp/content/oznxx3s5vgih0jkf",
          profile_url: "https://piapro.jp/mkuk210403",
          profile_urls: %w[https://piapro.jp/mkuk210403],
          display_name: "雨輝",
          username: "mkuk210403",
          tag_name: "mkuk210403",
          other_names: ["雨輝", "mkuk210403"],
          tags: [
            ["#応募用", "https://piapro.jp/content_list/?view=image&tag=%23応募用"],
          ],
          dtext_artist_commentary_title: "御伽彼方",
          dtext_artist_commentary_desc: "応募用"
        )
      end

      context "A Piapro 3D post" do
        strategy_should_work(
          "https://piapro.jp/t/R5Hj",
          image_urls: [%r{https://dl.piapro.jp/3dm/q8/q80isn7j0u8xpvjp_20240101173805.zip\?response-content-disposition=attachment%3B%20filename%2A%3DUTF-8%27%27%25E5%2588%259D%25E9%259F%25B3%25E3%2583%259F%25E3%2582%25AF%25EF%25BC%25A0%25E3%2582%2580%25EF%25BD%259E%25E3%2581%25B6Ver23_muuubu_.*.zip&Expires=.*&Signature=.*&Key-Pair-Id=APKAIJPPZV4JCCSOERBA}],
          media_files: [{ file_size: 12_767_675 }],
          page_url: "https://piapro.jp/content/q80isn7j0u8xpvjp",
          profile_url: "https://piapro.jp/muuubu",
          profile_urls: %w[https://piapro.jp/muuubu],
          display_name: "む～ぶ",
          username: "muuubu",
          tag_name: "muuubu",
          other_names: ["む～ぶ", "muuubu"],
          tags: [
            ["#初音ミク", "https://piapro.jp/content_list/?view=image&tag=%23初音ミク"],
            ["#ＭＭＤ", "https://piapro.jp/content_list/?view=image&tag=%23ＭＭＤ"],
          ],
          dtext_artist_commentary_title: "初音ミク＠む～ぶVer23",
          dtext_artist_commentary_desc: <<~EOS.chomp
            のんびりですが色々追加していこうと思ってるので
            よろしくお願いします。

            2023/9/16 公開
            2023/9/17 不具合修正（readme記載）
            2023/11/30 各部修正
          EOS
        )
      end

      context "A deleted or nonexistent Piapro post" do
        strategy_should_work(
          "https://piapro.jp/t/ZZZZZ",
          image_urls: [],
          page_url: "https://piapro.jp/t/ZZZZZ",
          profile_url: nil,
          profile_urls: %w[],
          display_name: nil,
          username: nil,
          tag_name: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "parse Piapro URLs correctly" do
        assert(Source::URL.image_url?("https://cdn.piapro.jp/thumb_i/w2/w22xmltnyzcsrqxu_20240303200945_0250_0250.png"))
        assert(Source::URL.image_url?("https://cdn.piapro.jp/thumb_i/74/74w6x4s2s39aag5q_20240325172302_0860_0600.png"))
        assert(Source::URL.image_url?("https://cdn.piapro.jp/icon_u/626/1485626_20230224204244_0072.jpg"))
        assert(Source::URL.image_url?("https://dl.piapro.jp/image/w2/w22xmltnyzcsrqxu_20240303200945.png?response-content-disposition=attachment%3B%20filename%2A%3DUTF-8%27%27%25E7%2597%259B%25E3%2581%2584%25E7%2597%259B%25E3%2581%2584%25E7%2597%259B%25E3%2581%2584_nibiirooo__202404301346.png&Expires=1714452547&Signature=j3CPYYLRaTQcQqz6g-zvhOQfIeKnrxRBcxtW6sARJ7xlU3nnfkBAx44RjD6tzfjCH5c~t-50D-A4O9tjWKbRDZI9h3~qbYagz3MYcM-Do-PfMGHaNakpZ51F7fDRby-a7NFou8i4e9HpVJ0By1oTNo650ERbM2FPoZl6thOTfXhFK06pF5yd~lNk2UgaPNQpZJ3Ah4VgRhA~SIWlPkLBIdHjqHTBMtFAKZ-RrNhz3DXphxvAQyuQYjGJCL-UZXYzWGQK5Q73dim0~Y8TTI8eAQdWJLY7rwxtJ5D0zeh1Nue-YA-Tqo-b1mTbvcJrumLAAgT1AwmD~BfiOncRNs4XZw__&Key-Pair-Id=APKAIJPPZV4JCCSOERBA"))

        assert(Source::URL.page_url?("https://piapro.jp/t/_J0y"))
        assert(Source::URL.page_url?("http://piapro.jp/t/zXLG/20101206161601"))
        assert(Source::URL.page_url?("https://piapro.jp/content/w22xmltnyzcsrqxu"))
        assert(Source::URL.page_url?("https://piapro.jp/content/w22xmltnyzcsrqxu"))

        assert(Source::URL.profile_url?("https://piapro.jp/nibiirooo_"))
        assert(Source::URL.profile_url?("https://piapro.jp/my_page/?view=profile&pid=orzkakkokari"))
        assert(Source::URL.profile_url?("https://piapro.jp/my_page/?pid=orzkakkokari"))
        assert(Source::URL.profile_url?("https://piapro.jp/my_page/?piaproId=sakira"))
        assert_not(Source::URL.profile_url?("https://blog.piapro.net/2024/04/g2404291.html"))

        assert_equal("https://piapro.jp/content/w22xmltnyzcsrqxu", Source::URL.page_url("https://cdn.piapro.jp/thumb_i/w2/w22xmltnyzcsrqxu_20240303200945_0250_0250.png"))
        assert_equal("https://piapro.jp/content/w22xmltnyzcsrqxu", Source::URL.page_url("https://dl.piapro.jp/image/w2/w22xmltnyzcsrqxu_20240303200945.png?response-content-disposition=attachment%3B%20filename%2A%3DUTF-8%27%27%25E7%2597%259B%25E3%2581%2584%25E7%2597%259B%25E3%2581%2584%25E7%2597%259B%25E3%2581%2584_nibiirooo__202404301346.png&Expires=1714452547&Signature=j3CPYYLRaTQcQqz6g-zvhOQfIeKnrxRBcxtW6sARJ7xlU3nnfkBAx44RjD6tzfjCH5c~t-50D-A4O9tjWKbRDZI9h3~qbYagz3MYcM-Do-PfMGHaNakpZ51F7fDRby-a7NFou8i4e9HpVJ0By1oTNo650ERbM2FPoZl6thOTfXhFK06pF5yd~lNk2UgaPNQpZJ3Ah4VgRhA~SIWlPkLBIdHjqHTBMtFAKZ-RrNhz3DXphxvAQyuQYjGJCL-UZXYzWGQK5Q73dim0~Y8TTI8eAQdWJLY7rwxtJ5D0zeh1Nue-YA-Tqo-b1mTbvcJrumLAAgT1AwmD~BfiOncRNs4XZw__&Key-Pair-Id=APKAIJPPZV4JCCSOERBA"))
        assert_equal("https://piapro.jp/orzkakkokari", Source::URL.profile_url("https://piapro.jp/my_page/?view=profile&pid=orzkakkokari"))
        assert_equal("https://piapro.jp/orzkakkokari", Source::URL.profile_url("https://piapro.jp/my_page/?pid=orzkakkokari"))
        assert_equal("https://piapro.jp/sakira", Source::URL.profile_url("https://piapro.jp/my_page/?piaproId=sakira"))
      end
    end
  end
end
