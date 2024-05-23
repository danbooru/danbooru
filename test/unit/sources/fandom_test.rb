require 'test_helper'

module Sources
  class FandomTest < ActiveSupport::TestCase
    context "Fandom: " do
      context "A sample image URL" do
        strategy_should_work(
          "https://static.wikia.nocookie.net/typemoon/images/9/96/Caster_Extra_Takeuchi_design_1.png/revision/latest/scale-to-width-down/1000?cb=20130523100711",
          image_urls: %w[https://static.wikia.nocookie.net/typemoon/images/9/96/Caster_Extra_Takeuchi_design_1.png?format=original],
          media_files: [{ file_size: 6_085_628 }],
          page_url: "https://typemoon.fandom.com/wiki/File:Caster_Extra_Takeuchi_design_1.png",
          profile_urls: %w[https://typemoon.fandom.com/wiki/User:Nikonu],
          display_name: nil,
          username: "Nikonu",
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A UUID image URL" do
        strategy_should_work(
          "https://static.wikia.nocookie.net/74a9f058-f816-4856-8aad-c398aa8a4c81/thumbnail/width/400/height/400",
          image_urls: %w[https://static.wikia.nocookie.net/74a9f058-f816-4856-8aad-c398aa8a4c81?format=original],
          media_files: [{ file_size: 1_021_278 }],
          page_url: nil,
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A wiki.fandom.com/wiki/:page?file=:file URL" do
        strategy_should_work(
          "https://kancolle.fandom.com/Mutsuki?file=Mutsuki_Full.png",
          image_urls: %w[https://static.wikia.nocookie.net/kancolle/images/3/3b/Mutsuki_Full.png?format=original],
          media_files: [{ file_size: 135_822 }],
          page_url: "https://kancolle.fandom.com/wiki/Mutsuki?file=Mutsuki_Full.png",
          profile_urls: %w[https://kancolle.fandom.com/wiki/User:Botkaze],
          display_name: nil,
          username: "Botkaze",
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            id = 1
            name = 睦月
            type = full
            size = 135822
            last-modified = 1534498093000
            sha1 = f12aefe0159aabc91c18f906864ff0f7e6787d23
            url = <http://203.104.209.55/kcs2/resources/ship/full/0001_5865.png>
          EOS
        )
      end

      context "A wiki.fandom.com/wiki/:page?file=:file URL that is a Youtube video" do
        strategy_should_work(
          "https://typemoon.fandom.com/wiki/Kara_no_Kyoukai_-_The_Garden_of_sinners_Movie_4:_The_Hollow_Shrine?file=The_Garden_of_sinners_Chapter_4_Preview",
          image_urls: [],
          page_url: "https://typemoon.fandom.com/wiki/Kara_no_Kyoukai_-_The_Garden_of_sinners_Movie_4:_The_Hollow_Shrine?file=The_Garden_of_sinners_Chapter_4_Preview",
          profile_urls: %w[https://typemoon.fandom.com/wiki/User:Nikonu],
          display_name: nil,
          username: "Nikonu",
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            h2. Description

            Category: Film
          EOS
        )
      end

      context "A wiki.fandom.com/wiki/File:name URL" do
        strategy_should_work(
          "https://typemoon.fandom.com/wiki/File:Memories_of_Trifas.png",
          image_urls: %w[https://static.wikia.nocookie.net/typemoon/images/2/2f/Memories_of_Trifas.png?format=original],
          media_files: [{ file_size: 450_447 }],
          page_url: "https://typemoon.fandom.com/wiki/File:Memories_of_Trifas.png",
          profile_urls: %w[https://typemoon.fandom.com/wiki/User:Lemostr00],
          display_name: nil,
          username: "Lemostr00",
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: "File uploaded with MsUpload"
        )
      end

      context "A wiki page" do
        strategy_should_work(
          "https://typemoon.fandom.com/wiki/Tamamo-no-Mae",
          image_urls: [],
          media_files: [],
          page_url: "https://typemoon.fandom.com/wiki/Tamamo-no-Mae",
          profile_urls: %w[https://typemoon.fandom.com],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A deleted or nonexistent wiki file" do
        strategy_should_work(
          "https://kancolle.fandom.com/wiki/File:bad.png",
          image_urls: [],
          page_url: "https://kancolle.fandom.com/wiki/File:bad.png",
          profile_urls: %w[https://kancolle.fandom.com],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "convert fandom image urls to page urls" do
        assert_equal("https://valkyriecrusade.fandom.com/wiki/File:Crimson_Hatsune_H.png", Source::URL.page_url("https://vignette.wikia.nocookie.net/valkyriecrusade/images/c/c5/Crimson_Hatsune_H.png/revision/latest?cb=20180702031954"))
        assert_equal("https://ishtaria.fandom.com/wiki/File:Union-List.png", Source::URL.page_url("https://static.wikia.nocookie.net/age-of-ishtaria/images/f/f9/Union-List.png/revision/latest/scale-to-width-down/670?cb=20141219153314"))
        assert_equal("https://atelier.fandom.com/wiki/File:Marie_(Front_Page_Art).jpg", Source::URL.page_url("https://static.wikia.nocookie.net/atelierseries/images/2/22/Marie_%28Front_Page_Art%29.jpg/revision/latest/scale-to-width-down/670?cb=20130129113100"))
        assert_equal("https://senrankagura.fandom.com/wiki/File:Kagurapedia_Header.png", Source::URL.page_url("https://static.wikia.nocookie.net/kagura/images/9/9f/Kagurapedia_Header.png/revision/latest/scale-to-width-down/650?cb=20171016220119"))
        assert_equal("https://genshin-impact.fandom.com/wiki/File:Character_Kamisato_Ayato_Card.png", Source::URL.page_url("https://static.wikia.nocookie.net/gensin-impact/images/2/22/Character_Kamisato_Ayato_Card.png/revision/latest/scale-to-width-down/281?cb=20220204094446"))
        assert_equal("https://neptunia.fandom.com/wiki/File:Plutia_B%2BNvZ.png", Source::URL.page_url("http://vignette3.wikia.nocookie.net/neptunia/images/2/28/Plutia_B%2BNvZ.png/revision/latest?cb=20160420084622"))
        assert_equal("https://typemoon.fandom.com/wiki/File:Caster_Extra_Takeuchi_design_1.png", Source::URL.page_url("http://img3.wikia.nocookie.net/__cb20130523100711/typemoon/images/9/96/Caster_Extra_Takeuchi_design_1.png"))
        assert_equal("https://virtualyoutuber.fandom.com/vi/wiki/File:Alicia_Cotton_2nd_Outfit_2.png", Source::URL.page_url("https://static.wikia.nocookie.net/virtualyoutuber/images/c/c4/Alicia_Cotton_2nd_Outfit_2.png/revision/latest?cb=20211107035307&path-prefix=vi"))
        assert_equal("https://typemoon.fandom.com/fr/wiki/File:Aozaki_Aoko_Blue.png", Source::URL.page_url("http://img3.wikia.nocookie.net/__cb20140404214519/typemoon/fr/images/f/fd/Aozaki_Aoko_Blue.png"))
        assert_equal("https://typemoon.fandom.com/fr/wiki/File:Aozaki_Aoko_Blue.png", Source::URL.page_url("http://img3.wikia.nocookie.net/__cb20140404214519/typemoon/images/f/fd/Aozaki_Aoko_Blue.png/revision/latest?path-prefix=fr"))
        assert_equal("https://typemoon.fandom.com/fr/wiki/File:Aozaki_Aoko_Blue.png", Source::URL.page_url("http://img3.wikia.nocookie.net/__cb20140404214519/typemoon/fr/images/thumb/f/fd/Aozaki_Aoko_Blue.png/500px-Aozaki_Aoko_Blue.png"))
        assert_equal("https://allanimefanon.fandom.com/wiki/File:2560-1600-104761.jpg", Source::URL.page_url("http://img3.wikia.nocookie.net/__cb20130520180921/allanimefanon/images/thumb/8/82/2560-1600-104761.jpg/2000px-2560-1600-104761.jpg"))
        assert_equal("https://hero.fandom.com/wiki/File:Yukiko_Amagi_(BlazBlue_Cross_Tag_Battle,_Character_Select_Artwork).png", Source::URL.page_url("https://static.wikia.nocookie.net/p__/protagonist/images/3/3f/Yukiko_Amagi_(BlazBlue_Cross_Tag_Battle%2C_Character_Select_Artwork).png"))
      end

      should "parse URLs correctly" do
        assert(Source::URL.image_url?("https://vignette.wikia.nocookie.net/valkyriecrusade/images/c/c5/Crimson_Hatsune_H.png/revision/latest?cb=20180702031954"))
        assert(Source::URL.image_url?("https://static.wikia.nocookie.net/74a9f058-f816-4856-8aad-c398aa8a4c81/thumbnail/width/400/height/400"))
        assert(Source::URL.image_url?("https://static.wikia.nocookie.net/74a9f058-f816-4856-8aad-c398aa8a4c81"))

        assert(Source::URL.page_url?("https://typemoon.fandom.com/wiki/Gallery?file=Caster_Extra_Takeuchi_design_1.png"))
        assert(Source::URL.page_url?("https://typemoon.fandom.com/wiki/Tamamo-no-Mae?file=Caster_Extra_Takeuchi_design_1.png"))
        assert(Source::URL.page_url?("https://typemoon.fandom.com/wiki/User:Lemostr00"))
        assert(Source::URL.page_url?("https://typemoon.fandom.com/wiki/File:Memories_of_Trifas.png"))
        assert(Source::URL.page_url?("https://typemoon.fandom.com/Gallery?file=Caster_Extra_Takeuchi_design_1.png"))
        assert(Source::URL.page_url?("https://typemoon.fandom.com/User:Lemostr00"))
        assert(Source::URL.page_url?("https://typemoon.fandom.com/File:Memories_of_Trifas.png"))

        assert(Source::URL.page_url?("https://genshin-impact.fandom.com/wiki/Ningguang/Gallery"))
        assert(Source::URL.page_url?("https://genshin-impact.fandom.com/Ningguang/Gallery"))
        assert(Source::URL.page_url?("https://genshin-impact.fandom.com/ja/wiki/凝光/ギャラリー"))
        assert(Source::URL.page_url?("https://genshin-impact.fandom.com/ja/凝光/ギャラリー"))

        assert_not(Source::URL.page_url?("https://typemoon.fandom.com/f/p/4400000000000077950"))
        assert_not(Source::URL.page_url?("https://genshin-impact.fandom.com/pt-br/f"))

        assert(Source::URL.profile_url?("https://typemoon.fandom.com"))
        assert(Source::URL.profile_url?("https://genshin-impact.fandom.com/pt-br"))
      end

      should "identify bad sources correctly" do
        assert_not(Source::URL.parse("https://vignette.wikia.nocookie.net/valkyriecrusade/images/c/c5/Crimson_Hatsune_H.png/revision/latest?cb=20180702031954").bad_source?)
        assert_not(Source::URL.parse("https://typemoon.fandom.com/wiki/Tamamo-no-Mae?file=Caster_Extra_Takeuchi_design_1.png").bad_source?)
        assert_not(Source::URL.parse("https://typemoon.fandom.com/wiki/File:Memories_of_Trifas.png").bad_source?)

        assert(Source::URL.parse("https://typemoon.fandom.com").bad_source?)
        assert(Source::URL.parse("https://typemoon.fandom.com/wiki/User:Lemostr00").bad_source?)
        assert(Source::URL.parse("https://typemoon.fandom.com/f/p/4400000000000077950").bad_source?)
        assert(Source::URL.parse("https://genshin-impact.fandom.com/wiki/Ningguang/Gallery").bad_source?)
      end
    end
  end
end
