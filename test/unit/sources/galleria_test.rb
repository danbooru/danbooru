# frozen_string_literal: true

require "test_helper"

module Sources
  class GalleriaTest < ActiveSupport::TestCase
    context "Galleria:" do
      context "A Galleria sample image URL" do
        strategy_should_work(
          "https://galleria-img.emotionflow.com/user_img9/38279/i679579_387.jpeg_360.jpg?0716161312",
          image_urls: %w[https://galleria-img.emotionflow.com/user_img9/38279/i679579_387.jpeg],
          media_files: [{ file_size: 290_444 }],
          page_url: "https://galleria.emotionflow.com/38279/679579.html",
          profile_url: "https://galleria.emotionflow.com/38279/",
          artist_name: "めおどら",
          tags: [
            ["ホロライブ", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=ホロライブ"],
            ["クレイジー・オリー", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=クレイジー・オリー"],
            ["hololive", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=hololive"],
            ["hololiveID", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=hololiveID"],
            ["ゾンビ", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=ゾンビ"],
          ],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A Galleria full image URL" do
        strategy_should_work(
          "https://galleria-img.emotionflow.com/user_img9/38279/i679579_387.jpeg",
          image_urls: %w[https://galleria-img.emotionflow.com/user_img9/38279/i679579_387.jpeg],
          media_files: [{ file_size: 290_444 }],
          page_url: "https://galleria.emotionflow.com/38279/679579.html",
          profile_url: "https://galleria.emotionflow.com/38279/",
          artist_name: "めおどら",
          tags: [
            ["ホロライブ", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=ホロライブ"],
            ["クレイジー・オリー", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=クレイジー・オリー"],
            ["hololive", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=hololive"],
            ["hololiveID", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=hololiveID"],
            ["ゾンビ", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=ゾンビ"],
          ],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A Galleria image URL without a post ID" do
        strategy_should_work(
          "https://galleria-img.emotionflow.com/user_img9/75596/i1549553512126_164.jpeg",
          image_urls: %w[https://galleria-img.emotionflow.com/user_img9/75596/i1549553512126_164.jpeg],
          media_files: [{ file_size: 281_662 }],
          page_url: "https://galleria.emotionflow.com/75596/1549553.html",
          profile_url: "https://galleria.emotionflow.com/75596/",
          artist_name: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A Galleria post with a single image" do
        strategy_should_work(
          "https://galleria.emotionflow.com/40775/660870.html",
          image_urls: %w[https://galleria-img.emotionflow.com/user_img9/40775/i660870_869.jpeg],
          media_files: [{ file_size: 1_187_582 }],
          page_url: "https://galleria.emotionflow.com/40775/660870.html",
          profile_url: "https://galleria.emotionflow.com/40775/",
          artist_name: "Mito-Amatsu",
          tags: [
            ["イラスト", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=イラスト"],
            ["illustration", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=illustration"],
            ["Mito", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=Mito"],
            ["オリジナル", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=オリジナル"],
            ["オリキャラ", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=オリキャラ"],
            ["創作", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=創作"],
            ["創作", "https://galleria.emotionflow.com/40775/創作"],
            ["女の子", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=女の子"],
            ["illustrator", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=illustrator"],
            ["original", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=original"],
            ["ポニーテール", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=ポニーテール"],
            ["黒髪", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=黒髪"],
            ["長髪", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=長髪"],
            ["ロングヘアー", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=ロングヘアー"],
            ["originalillustration", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=originalillustration"],
            ["originalcharacter", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=originalcharacter"],
            ["girlillustration", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=girlillustration"],
            ["girl", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=girl"],
            ["着物", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=着物"],
            ["和服", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=和服"],
            ["kimono", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=kimono"],
            ["女性", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=女性"],
            ["リボン", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=リボン"],
            ["ハーフアップ", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=ハーフアップ"],
            ["帯", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=帯"],
            ["帯締め", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=帯締め"],
            ["和", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=和"],
            ["和風", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=和風"],
          ],
          dtext_artist_commentary_title: "【和服の少女】",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A Galleria post with multiple images" do
        strategy_should_work(
          "https://galleria.emotionflow.com/75596/483362.html",
          image_urls: %w[
            https://galleria-img.emotionflow.com/user_img9/75596/i1661081253247_941.jpeg
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_573.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_727.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_647.jpeg
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_56.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_987.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_176.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_441.jpeg
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_756.jpeg
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_600.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_544.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_721.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_843.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_650.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_822.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_713.jpeg
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_37.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_484.jpeg
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_48.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_263.jpeg
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_596.jpeg
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_438.jpeg
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_512.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_256.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_245.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_863.jpeg
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_803.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_154.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_943.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_182.jpeg
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_838.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_519.png
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_11.jpeg
            https://galleria-img.emotionflow.com/user_img9/75596/c483362_735.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553512126_164.jpeg
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553493813_865.jpeg
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553524311_664.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553550783_267.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553575501_51.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553584282_356.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1661007423319_687.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553597795_332.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553619267_415.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553610821_825.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553630457_589.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553638785_837.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553649515_960.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553682426_294.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553701363_843.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553721914_718.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553739757_272.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553750750_205.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553773549_56.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553782201_916.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553798378_334.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553833199_318.jpeg
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553847169_957.jpeg
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553862522_112.jpeg
            https://galleria-img.emotionflow.com/user_img9/75596/i1549553876254_74.jpeg
            https://galleria-img.emotionflow.com/user_img9/75596/i1555815522114_797.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1559307861330_517.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1562558326490_829.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1567915023340_216.png
            https://galleria-img.emotionflow.com/user_img9/75596/i1602000246056_673.png
          ],
          media_files: [
            { file_size: 97_629 },
            { file_size: 972_617 },
            { file_size: 372_021 },
            { file_size: 1_183_345 },
            { file_size: 489_725 },
            { file_size: 683_563 },
            { file_size: 387_928 },
            { file_size: 609_677 },
            { file_size: 254_293 },
            { file_size: 414_254 },
            { file_size: 575_827 },
            { file_size: 811_737 },
            { file_size: 377_509 },
            { file_size: 329_087 },
            { file_size: 752_116 },
            { file_size: 380_388 },
            { file_size: 417_108 },
            { file_size: 274_871 },
            { file_size: 751_657 },
            { file_size: 211_432 },
            { file_size: 254_668 },
            { file_size: 239_879 },
            { file_size: 484_145 },
            { file_size: 705_565 },
            { file_size: 585_501 },
            { file_size: 456_199 },
            { file_size: 676_000 },
            { file_size: 491_620 },
            { file_size: 1_648_671 },
            { file_size: 464_736 },
            { file_size: 594_091 },
            { file_size: 667_815 },
            { file_size: 255_173 },
            { file_size: 375_683 },
            { file_size: 281_662 },
            { file_size: 271_754 },
            { file_size: 714_115 },
            { file_size: 423_253 },
            { file_size: 699_629 },
            { file_size: 682_473 },
            { file_size: 745_603 },
            { file_size: 644_233 },
            { file_size: 542_663 },
            { file_size: 257_691 },
            { file_size: 463_760 },
            { file_size: 335_636 },
            { file_size: 637_374 },
            { file_size: 646_598 },
            { file_size: 860_030 },
            { file_size: 643_549 },
            { file_size: 392_871 },
            { file_size: 337_534 },
            { file_size: 491_105 },
            { file_size: 646_173 },
            { file_size: 744_134 },
            { file_size: 359_006 },
            { file_size: 197_039 },
            { file_size: 147_268 },
            { file_size: 226_059 },
            { file_size: 386_017 },
            { file_size: 741_306 },
            { file_size: 303_448 },
            { file_size: 658_064 },
            { file_size: 223_063 },
          ],
          page_url: "https://galleria.emotionflow.com/75596/483362.html",
          profile_url: "https://galleria.emotionflow.com/75596/",
          artist_name: "鴬瀬",
          tags: [
            ["undertale", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=undertale"],
          ],
          dtext_artist_commentary_title: "UT",
          dtext_artist_commentary_desc: <<~EOS.chomp
            2018～随時更新
            アンダイン多め/全ルートネタバレ/デルタも少し
          EOS
        )
      end

      context "A R18 Galleria post" do
        strategy_should_work(
          "https://galleria.emotionflow.com/92495/555463.html",
          image_urls: %w[https://galleria-img.emotionflow.com/user_img9/92495/i555463_68.jpeg],
          media_files: [{ file_size: 302_958 }],
          page_url: "https://galleria.emotionflow.com/92495/555463.html",
          profile_url: "https://galleria.emotionflow.com/92495/",
          artist_name: "タマネギーニョ",
          tags: [
            ["幻夢戦記レダ", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=幻夢戦記レダ"],
            ["朝霧陽子", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=朝霧陽子"],
            ["ビキニアーマー", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=ビキニアーマー"],
            ["女の子", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=女の子"],
            ["二次創作", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=二次創作"],
          ],
          dtext_artist_commentary_title: "幻夢戦記レダ 朝霧陽子",
          dtext_artist_commentary_desc: <<~EOS.chomp
            ■幻夢戦記レダより、レダの戦士こと朝霧陽子さん。
            ■エロいんだけどあまりエロくない少しエロいエロ絵。
          EOS
        )
      end

      context "A text-only Galleria post" do
        strategy_should_work(
          "https://galleria.emotionflow.com/115238/679571.html",
          image_urls: [],
          page_url: "https://galleria.emotionflow.com/115238/679571.html",
          profile_url: "https://galleria.emotionflow.com/115238/",
          artist_name: "茶屋",
          tags: [
            ["刀剣乱腐", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=刀剣乱腐"],
            ["刀剣乱舞", "https://galleria.emotionflow.com/115238/刀剣乱舞"],
            ["へし燭", "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=へし燭"],
            ["へし燭", "https://galleria.emotionflow.com/115238/へし燭"],
          ],
          dtext_artist_commentary_title: "[へし燭]お題【水着】",
          dtext_artist_commentary_desc: <<~EOS.chomp
            今日はへし燭の日！！とへし燭Webオンリー『宵の光景』のコラボお題企画にて書かせていただきました！
          EOS
        )
      end

      context "A deleted or nonexistent Galleria post" do
        strategy_should_work(
          "https://galleria.emotionflow.com/999999999/999999999.html",
          image_urls: [],
          page_url: "https://galleria.emotionflow.com/999999999/999999999.html",
          profile_url: "https://galleria.emotionflow.com/999999999/",
          artist_name: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "parse Galleria URLs correctly" do
        assert(Source::URL.image_url?("https://galleria-img.emotionflow.com/user_img9/40775/i660870_869.jpeg"))
        assert(Source::URL.image_url?("http://img01.emotionflow.com/galleria/user_img6/14169/141693874499122908405.png"))
        assert(Source::URL.image_url?("http://galleria.emotionflow.com/user_img6/12915/1291531674451216.png_480.jpg"))

        assert(Source::URL.page_url?("https://galleria.emotionflow.com/40775/660870.html"))
        assert(Source::URL.page_url?("https://galleria.emotionflow.com/s/40775/660870.html"))
        assert(Source::URL.page_url?("https://galleria.emotionflow.com/IllustDetailV.jsp?ID=136703&TD=701021"))
        assert(Source::URL.page_url?("https://galleria.emotionflow.com/s/IllustDetailV.jsp?ID=136703&TD=701021"))

        assert(Source::URL.profile_url?("http://galleria.emotionflow.com/GalleryListGridV.jsp?ID=15878"))
        assert(Source::URL.profile_url?("http://galleria.emotionflow.com/s/GalleryListGridV.jsp?ID=15878"))
        assert(Source::URL.profile_url?("http://galleria.emotionflow.com/MyGalleryListV.jsp?ID=40948"))
        assert(Source::URL.profile_url?("https://galleria.emotionflow.com/40775/gallery.html"))
        assert(Source::URL.profile_url?("https://galleria.emotionflow.com/s/40775/gallery.html"))
        assert(Source::URL.profile_url?("https://galleria.emotionflow.com/40775/創作/"))
        assert(Source::URL.profile_url?("http://temp.emotionflow.com/7289/"))
      end
    end
  end
end
