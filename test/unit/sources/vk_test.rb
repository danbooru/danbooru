# frozen_string_literal: true

require "test_helper"

module Sources
  class VkTest < ActiveSupport::TestCase
    context "Vk:" do
      context "An /impg/ sample image URL" do
        strategy_should_work(
          "https://sun9-69.userapi.com/impg/VJBWV0vYZJLRhFBkQxaVtVo9_givXP6BycJJow/RBoOQ0nHMNc.jpg?size=1200x1600&quality=96&sign=73e562b2f74629cba714f7a348d0e815&type=album",
          image_urls: %w[https://pp.userapi.com/VJBWV0vYZJLRhFBkQxaVtVo9_givXP6BycJJow/RBoOQ0nHMNc.jpg],
          media_files: [{ file_size: 885_368 }],
          page_url: nil
        )
      end

      context "An /impf/ sample image URL" do
        strategy_should_work(
          "https://sun9-20.userapi.com/impf/c836729/v836729326/1f25a/N3g5QzPZBbM.jpg?size=800x800&quality=96&sign=06bcfc21a2980b0ff1f59129a25c0ceb&type=album",
          image_urls: %w[https://pp.userapi.com/c836729/v836729326/1f25a/N3g5QzPZBbM.jpg],
          media_files: [{ file_size: 161_573 }],
          page_url: nil
        )
      end

      context "A full image URL" do
        strategy_should_work(
          "https://sun9-5.userapi.com/c855416/v855416689/142081/zu0CJ7Su5KY.jpg",
          image_urls: %w[https://pp.userapi.com/c855416/v855416689/142081/zu0CJ7Su5KY.jpg],
          media_files: [{ file_size: 288_978 }],
          page_url: nil
        )
      end

      context "A document post" do
        strategy_should_work(
          "https://vk.com/doc495199190_630536868",
          image_urls: [%r{https://pp.userapi.com/c235131/u495199190/docs/d59/\h{12}/Strakh_Pakhnet_Lyubovyu.png}],
          media_files: [{ file_size: 1_437_077 }],
          page_url: "https://vk.com/doc495199190_630536868" # XXX wrong?
        )
      end

      context "A wall post with multiple images" do
        strategy_should_work(
          "https://m.vk.com/wall-221992613_185",
          image_urls: %w[
            https://pp.userapi.com/s_kMfsy7Qj_py62caQzNR2_FLy5SxUK7ZQHOjg/uC_wMQYmIXM.jpg
            https://pp.userapi.com/s8VzARdY0Pcw0U8YihMRRYVq_VzMnz32Z4uLtg/kVMjKVbZcOM.jpg
          ],
          media_files: [
            { file_size: 857_665 },
            { file_size: 874_676 },
          ],
          page_url: "https://vk.com/wall-221992613_185",
          profile_url: "https://vk.com/tarry221992613",
          profile_urls: %w[https://vk.com/tarry221992613 https://vk.com/wall-221992613],
          display_name: "tarry",
          username: "tarry221992613",
          tag_name: "tarry221992613",
          other_names: ["tarry", "tarry221992613"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            Покидайте свои любимые песни. Хочу свой плейлист пополнить 🙏🙏

            А ещё я заболела... и скорее всего несколько недель не будет новых рисунков (*꒦ິ꒳꒦ີ)
          EOS
        )
      end

      context "A wall post with tags" do
        strategy_should_work(
          "https://vk.com/enigmasblog?w=wall-185765571_2635",
          image_urls: %w[https://pp.userapi.com/siTuBegBFdZC_kJlWv7-Fh6aUxDJSA7_9UfUZg/-M9dO8OYt00.jpg],
          media_files: [{ file_size: 128_227 }],
          page_url: "https://vk.com/wall-185765571_2635",
          profile_url: "https://vk.com/enigmasblog",
          profile_urls: %w[https://vk.com/enigmasblog https://vk.com/wall-185765571],
          display_name: "- Resident Σnigma -",
          username: "enigmasblog",
          tag_name: "enigmasblog",
          other_names: ["- Resident Σnigma -", "enigmasblog"],
          tags: [
            ["Fullart", "https://vk.com/enigmasblog/Fullart"],
            ["Pixelart", "https://vk.com/feed?section=search&q=%23Pixelart"],
            ["Hokuto_no_ken", "https://vk.com/feed?section=search&q=%23Hokuto_no_ken"],
          ],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            Забыл поделиться этим до первого апреля, лол.

            "#Fullart@enigmasblog":[https://vk.com/enigmasblog/Fullart]
            "#Pixelart":[https://vk.com/feed?section=search&q=%23Pixelart]
            "#Hokuto_no_ken":[https://vk.com/feed?section=search&q=%23Hokuto_no_ken]
          EOS
        )
      end

      context "A wall post with an outgoing link to an external site in the commentary" do
        strategy_should_work(
          "https://m.vk.com/wall-165878884_230",
          image_urls: %w[https://pp.userapi.com/c849120/v849120385/34f5f/9VpcCPb7UvQ.jpg],
          media_files: [{ file_size: 238_048 }],
          page_url: "https://vk.com/wall-165878884_230",
          profile_url: "https://vk.com/prearts",
          profile_urls: %w[https://vk.com/prearts https://vk.com/wall-165878884],
          display_name: "Фан-арты «Pretty Series»",
          username: "prearts",
          tag_name: "prearts",
          other_names: ["Фан-арты «Pretty Series»", "prearts"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            Автор работы: KiraTwins
            https://goo.gl/rqpZFN
          EOS
        )
      end

      context "A wall post that isn't public (has blurred images)" do
        strategy_should_work(
          "https://vk.com/wall194141788_4201",
          image_urls: %w[https://pp.userapi.com/2L02V38IP1iWspsi94sQAweTDTaUmWfxh61sew/rLrtCBesrQM.jpg],
          media_files: [{ file_size: 281_015 }],
          page_url: "https://vk.com/wall194141788_4201",
          profile_url: "https://vk.com/id194141788",
          profile_urls: %w[https://vk.com/id194141788 https://vk.com/wall194141788],
          display_name: "Andrey Tkachenko",
          username: "id194141788",
          tag_name: "id194141788",
          other_names: ["Andrey Tkachenko", "id194141788"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            Таинственный гость.
          EOS
        )
      end

      # XXX Doesn't get the song.
      context "A wall post with an attached song" do
        strategy_should_work(
          "https://vk.com/wall-143305139_11128",
          image_urls: %w[https://pp.userapi.com/VJBWV0vYZJLRhFBkQxaVtVo9_givXP6BycJJow/RBoOQ0nHMNc.jpg],
          media_files: [{ file_size: 885_368 }],
          page_url: "https://vk.com/wall-143305139_11128",
          profile_url: "https://vk.com/zuomerika",
          profile_urls: %w[https://vk.com/zuomerika https://vk.com/wall-143305139],
          display_name: "◈Сансей / Zuomerika",
          username: "zuomerika",
          tag_name: "zuomerika",
          other_names: ["◈Сансей / Zuomerika", "zuomerika"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: "гриб."
        )
      end

      # For reposts we intentionally don't include the images or commentary belonging to the other post.
      context "A wall post that is a repost of another post" do
        strategy_should_work(
          "https://vk.com/wall-111670353_64467",
          image_urls: [],
          media_files: [],
          page_url: "https://vk.com/wall-111670353_64467",
          profile_url: "https://vk.com/sgips",
          profile_urls: %w[https://vk.com/sgips https://vk.com/wall-111670353],
          display_name: "Секретный гараж | Параллельный СССР",
          username: "sgips",
          tag_name: "sgips",
          other_names: ["Секретный гараж | Параллельный СССР", "sgips"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A wall post with an attached doc file that is an image" do
        strategy_should_work(
          "https://vk.com/wall-191516762_1706",
          image_urls: [%r{https://pp.userapi.com/c235131/u495199190/docs/d59/\h{12}/Strakh_Pakhnet_Lyubovyu.png}],
          media_files: [{ file_size: 1_437_077 }],
          page_url: "https://vk.com/wall-191516762_1706",
          profile_urls: %w[https://vk.com/cloppppi https://vk.com/wall-191516762],
          display_name: "cloospi (архив)",
          username: "cloppppi",
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: "the smell of fear..."
        )
      end

      context "A wall post with multiple attached doc files" do
        strategy_should_work(
          "https://vk.com/raw_files_raw?w=wall-184253008_27",
          image_urls: [
            "https://pp.userapi.com/bDB7jkzI-jt-AH4PYJSaSu4fgcZkk6LmkS8kOQ/MUr1-PtWzeE.jpg",
            "https://pp.userapi.com/AcpmintgwJ8ZhbYqGLcTODDHp0JESS3SwA81JA/vTyhIPllNqg.jpg",
            "https://pp.userapi.com/6_9o9t6Edk2ZmK3dmXphXuu4sjOMsnflqjnJPw/YJQ237Sddy4.jpg",
            "https://pp.userapi.com/11RZLv9b-6pLrXjyvpJ9bZRC2uqI3u9bnMvZrg/VpVaJMQjFLY.jpg",
            "https://pp.userapi.com/Z8rYUU0dAWLmrpa1xtfunVDrG9vvsNM2ytUI_Q/XhdUKOkaaak.jpg",
            %r{https://pp.userapi.com/c536436/u421323995/docs/d7/\h{12}/Sasha03811.nef},
            %r{https://pp.userapi.com/c536436/u421323995/docs/d46/\h{12}/Sasha03842.nef},
            %r{https://pp.userapi.com/c536436/u421323995/docs/d22/\h{12}/Sasha03843.nef},
            %r{https://pp.userapi.com/c536436/u421323995/docs/d21/\h{12}/Sasha03853.nef},
            %r{https://pp.userapi.com/c536436/u421323995/docs/d21/\h{12}/Sasha03869.nef},
          ],
          media_files: [
            { file_size: 2_192_319 },
            { file_size: 1_913_740 },
            { file_size: 1_986_074 },
            { file_size: 2_479_632 },
            { file_size: 1_895_220 },
            { file_size: 30_718_276 },
            { file_size: 32_408_170 },
            { file_size: 32_466_480 },
            { file_size: 31_945_458 },
            { file_size: 30_055_220 },
          ],
          page_url: "https://vk.com/wall-184253008_27",
          profile_url: "https://vk.com/raw_files_raw",
          profile_urls: %w[https://vk.com/raw_files_raw https://vk.com/wall-184253008],
          display_name: "Raw bank | РАВ БАНК",
          username: "raw_files_raw",
          tag_name: "raw_files_raw",
          other_names: ["Raw bank | РАВ БАНК", "raw_files_raw"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            Ph: Александр Волков
            Инстаграм https://instagram.com/alexsandr_volkow
          EOS
        )
      end

      context "A wall post with a `w` param" do
        strategy_should_work(
          "https://vk.com/public191516762?w=wall-191516762_2283",
          image_urls: [%r{https://pp.userapi.com/c236331/u495199190/docs/d20/\h{12}/gift_1.png}],
          media_files: [{ file_size: 4_252_200 }],
          page_url: "https://vk.com/wall-191516762_2283",
          profile_urls: %w[https://vk.com/cloppppi https://vk.com/wall-191516762],
          display_name: "cloospi (архив)",
          username: "cloppppi",
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            моя первая полноценная работа в цвете

            гифт для "лучшей хорни лисы":[https://vk.com/awful_queen]
          EOS
        )
      end

      context "A photo post" do
        strategy_should_work(
          "https://vk.com/photo-111670353_456283040",
          image_urls: %w[https://pp.userapi.com/c845418/v845418711/ee7ae/sUnnv5p1mcA.jpg],
          media_files: [{ file_size: 309_615 }],
          page_url: "https://vk.com/photo-111670353_456283040",
          profile_url: "https://vk.com/a.a.maltsev",
          profile_urls: %w[https://vk.com/a.a.maltsev https://vk.com/wall10879681],
          display_name: "Alexander Maltsev",
          username: "a.a.maltsev",
          tag_name: "a.a.maltsev",
          other_names: ["Alexander Maltsev", "a.a.maltsev"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A photo in a comment on a wall post (mobile version)" do
        strategy_should_work(
          "https://m.vk.com/photo-143305139_457245182?list=wall-143305139_11133",
          image_urls: %w[https://pp.userapi.com/cVSC2N_f8Gdou4EA6NspTDPTd3SRKpcaFUZ_tQ/VfhBKGBr30g.jpg],
          media_files: [{ file_size: 268_873 }],
          page_url: "https://vk.com/?z=photo-143305139_457245182/wall-143305139_11133",
          profile_url: "https://vk.com/thekilluuu",
          profile_urls: %w[https://vk.com/thekilluuu https://vk.com/wall327582849],
          display_name: "Fyodor Bestuzhev",
          username: "thekilluuu",
          tag_name: "thekilluuu",
          other_names: ["Fyodor Bestuzhev", "thekilluuu"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A photo in a comment on a wall post (desktop version)" do
        strategy_should_work(
          "https://vk.com/wall-143305139_11128?z=photo-143305139_457245182%2Fwall-143305139_11133",
          image_urls: %w[https://pp.userapi.com/cVSC2N_f8Gdou4EA6NspTDPTd3SRKpcaFUZ_tQ/VfhBKGBr30g.jpg],
          media_files: [{ file_size: 268_873 }],
          page_url: "https://vk.com/?z=photo-143305139_457245182/wall-143305139_11133"
        )
      end

      context "A deleted or nonexistent wall post" do
        strategy_should_work(
          "https://vk.com/wall-999999999999_9999999999",
          image_urls: [],
          page_url: "https://vk.com/wall-999999999999_9999999999",
          profile_url: nil,
          profile_urls: %w[https://vk.com/wall-999999999999],
          display_name: nil,
          username: nil,
          tag_name: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A deleted or nonexistent photo post" do
        strategy_should_work(
          "https://vk.com/photo-999999999999_9999999999",
          image_urls: [],
          page_url: "https://vk.com/photo-999999999999_9999999999",
          profile_url: nil,
          profile_urls: [],
          display_name: nil,
          username: nil,
          tag_name: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "Parse URLs correctly" do
        assert(Source::URL.image_url?("https://sun9-69.userapi.com/impg/VJBWV0vYZJLRhFBkQxaVtVo9_givXP6BycJJow/RBoOQ0nHMNc.jpg?size=1200x1600&quality=96&sign=73e562b2f74629cba714f7a348d0e815&type=album"))

        assert(Source::URL.page_url?("https://vk.com/wall-185765571_2635"))
        assert(Source::URL.page_url?("https://vk.com/wall194141788_4201"))
        assert(Source::URL.page_url?("https://vk.com/photo-185765571_457240497?list=album-185765571_00"))
        assert(Source::URL.page_url?("https://vk.com/public191516762?w=wall-191516762_2283"))
        assert(Source::URL.page_url?("https://vk.com/enigmasblog?w=wall-185765571_2636"))
        assert(Source::URL.page_url?("https://vk.com/sgips?z=album-111670353_227001377"))
        assert(Source::URL.page_url?("https://vk.com/sgips?z=photo-111670353_457285023%2Fwall-111670353_64279"))
        assert(Source::URL.page_url?("https://vk.com/the.dark.mangaka?z=video-162468097_456239018%2Fvideos-162468097%2Fpl_-162468097_-2"))
        assert(Source::URL.page_url?("https://vk.com/@sgips-tri-istorii-o-lovce"))

        assert(Source::URL.profile_url?("https://vk.com/wall-185765571"))
        assert(Source::URL.profile_url?("https://vk.com/wall194141788"))
        assert(Source::URL.profile_url?("https://vk.com/enigmasblog"))
        assert(Source::URL.profile_url?("https://vk.com/enigmasblog/Fullart"))
        assert(Source::URL.profile_url?("https://vk.com/video/@sgips"))
        assert(Source::URL.profile_url?("https://vk.com/clips/sgips"))
        assert(Source::URL.profile_url?("https://vk.com/@sgips"))
        assert(Source::URL.profile_url?("https://vk.com/enigmasblog"))
        assert(Source::URL.profile_url?("https://vk.com/id194141788"))
      end
    end
  end
end
