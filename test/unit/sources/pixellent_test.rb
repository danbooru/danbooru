# frozen_string_literal: true

require "test_helper"

module Sources
  class PixellentTest < ActiveSupport::TestCase
    context "Pixellent:" do
      context "A sample image URL" do
        strategy_should_work(
          "https://firebasestorage.googleapis.com/v0/b/pixellent.appspot.com/o/users%2FDdO7LioRiUNuEoh7Z3wbJwuFqY53%2Fposts%2F4St7seQpouY8bm5z9MJJ%2Fimages%2Fthumbnail-d1280.jpg?alt=media&v1705580498316",
          image_urls: %w[https://firebasestorage.googleapis.com/v0/b/pixellent.appspot.com/o/users%2FDdO7LioRiUNuEoh7Z3wbJwuFqY53%2Fposts%2F4St7seQpouY8bm5z9MJJ%2Fimages%2Foriginal?alt=media],
          media_files: [{ file_size: 11_023_071 }],
          page_url: "https://pixellent.me/p/4St7seQpouY8bm5z9MJJ",
          profile_urls: %w[https://pixellent.me/@hinagikumonnme https://pixellent.me/@u-DdO7LioRiUNuEoh7Z3wbJwuFqY53],
          display_name: "ひなぎくもんめ",
          username: "hinagikumonnme",
          tags: [
            ["フリーナ", "https://pixellent.me/tag/フリーナ"],
            ["原神", "https://pixellent.me/tag/原神"],
            ["genshinimpact", "https://pixellent.me/tag/genshinimpact"],
            ["furina", "https://pixellent.me/tag/furina"],
          ],
          dtext_artist_commentary_title: "どやりフリーナちゃん",
          dtext_artist_commentary_desc: <<~EOS.chomp
            神様してるときの得意げな表情が大好きだったので水神なフリーナちゃんを描きました〜！🌸✒️
            必死に取り繕ってるとこもすごく可愛かったですよね…！！

            "#フリーナ":[https://pixellent.me/tag/フリーナ] "#原神":[https://pixellent.me/tag/原神] "#genshinImpact":[https://pixellent.me/tag/genshinImpact] "#Furina":[https://pixellent.me/tag/Furina]
          EOS
        )
      end

      context "A post" do
        strategy_should_work(
          "https://pixellent.me/p/4St7seQpouY8bm5z9MJJ",
          image_urls: %w[https://firebasestorage.googleapis.com/v0/b/pixellent.appspot.com/o/users%2FDdO7LioRiUNuEoh7Z3wbJwuFqY53%2Fposts%2F4St7seQpouY8bm5z9MJJ%2Fimages%2Foriginal?alt=media],
          media_files: [{ file_size: 11_023_071 }],
          page_url: "https://pixellent.me/p/4St7seQpouY8bm5z9MJJ",
          profile_urls: %w[https://pixellent.me/@hinagikumonnme https://pixellent.me/@u-DdO7LioRiUNuEoh7Z3wbJwuFqY53],
          display_name: "ひなぎくもんめ",
          username: "hinagikumonnme",
          tags: [
            ["フリーナ", "https://pixellent.me/tag/フリーナ"],
            ["原神", "https://pixellent.me/tag/原神"],
            ["genshinimpact", "https://pixellent.me/tag/genshinimpact"],
            ["furina", "https://pixellent.me/tag/furina"],
          ],
          dtext_artist_commentary_title: "どやりフリーナちゃん",
          dtext_artist_commentary_desc: <<~EOS.chomp
            神様してるときの得意げな表情が大好きだったので水神なフリーナちゃんを描きました〜！🌸✒️
            必死に取り繕ってるとこもすごく可愛かったですよね…！！

            "#フリーナ":[https://pixellent.me/tag/フリーナ] "#原神":[https://pixellent.me/tag/原神] "#genshinImpact":[https://pixellent.me/tag/genshinImpact] "#Furina":[https://pixellent.me/tag/Furina]
          EOS
        )
      end

      context "A post with fullwidth hashtag characters (＃) in the commentary" do
        strategy_should_work(
          "https://pixellent.me/p/lEcK4ocNTMOegcHVOX09",
          image_urls: %w[https://firebasestorage.googleapis.com/v0/b/pixellent.appspot.com/o/users%2FyYxYHDmsbSWwrd5P01PaHi82ho93%2Fposts%2FlEcK4ocNTMOegcHVOX09%2Fimages%2Foriginal?alt=media],
          media_files: [{ file_size: 17_648_559 }],
          page_url: "https://pixellent.me/p/lEcK4ocNTMOegcHVOX09",
          profile_urls: %w[https://pixellent.me/@d_o_k_a_a_a https://pixellent.me/@u-yYxYHDmsbSWwrd5P01PaHi82ho93],
          display_name: "ドカ/DOKA",
          username: "d_o_k_a_a_a",
          tags: [
            ["さくらみこ", "https://pixellent.me/tag/さくらみこ"],
            ["miko_art", "https://pixellent.me/tag/miko_art"],
            ["ホロライブ", "https://pixellent.me/tag/ホロライブ"],
            ["バーチャルyoutuber", "https://pixellent.me/tag/バーチャルyoutuber"],
            ["女の子", "https://pixellent.me/tag/女の子"],
          ],
          dtext_artist_commentary_title: "みこち",
          dtext_artist_commentary_desc: <<~EOS.chomp
            落書きで始まって作品になったイラストです、、、
            描けば描くほど、心の奥深くから分からない欲が湧き出て、執拗に要素を追加していきました

            そして、みこちチャンネル登録200万人おめでとうございますー！

            X：https://twitter.com/d_o_k_a_a_a/status/1777679797877121462

            "#さくらみこ":[https://pixellent.me/tag/さくらみこ] "#miko_Art":[https://pixellent.me/tag/miko_Art] "#ホロライブ":[https://pixellent.me/tag/ホロライブ] "#バーチャルYouTuber":[https://pixellent.me/tag/バーチャルYouTuber] "#女の子":[https://pixellent.me/tag/女の子]
          EOS
        )
      end

      context "A deleted or nonexistent post" do
        strategy_should_work(
          "https://pixellent.me/p/bad",
          image_urls: [],
          page_url: "https://pixellent.me/p/bad",
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "Parse URLs correctly" do
        assert(Source::URL.image_url?("https://firebasestorage.googleapis.com/v0/b/pixellent.appspot.com/o/users%2FUbwtLvQnfEcV4d4IhAFztXXghR03%2Fposts%2Fs89Uq4Zwq8CVHQhpQ26B%2Fimages%2Fthumbnail-full.jpg?alt=media"))

        assert(Source::URL.page_url?("https://pixellent.me/p/s89Uq4Zwq8CVHQhpQ26B"))

        assert(Source::URL.profile_url?("https://pixellent.me/@u-UbwtLvQnfEcV4d4IhAFztXXghR03"))
        assert(Source::URL.profile_url?("https://pixellent.me/@shina"))
      end
    end
  end
end
