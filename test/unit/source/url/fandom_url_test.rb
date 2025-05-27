require "test_helper"

module Source::Tests::URL
  class FandomUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://vignette.wikia.nocookie.net/valkyriecrusade/images/c/c5/Crimson_Hatsune_H.png/revision/latest?cb=20180702031954",
          "https://static.wikia.nocookie.net/74a9f058-f816-4856-8aad-c398aa8a4c81/thumbnail/width/400/height/400",
          "https://static.wikia.nocookie.net/74a9f058-f816-4856-8aad-c398aa8a4c81",
        ],
        page_urls: [
          "https://typemoon.fandom.com/wiki/Gallery?file=Caster_Extra_Takeuchi_design_1.png",
          "https://typemoon.fandom.com/wiki/Tamamo-no-Mae?file=Caster_Extra_Takeuchi_design_1.png",
          "https://typemoon.fandom.com/wiki/User:Lemostr00",
          "https://typemoon.fandom.com/wiki/File:Memories_of_Trifas.png",
          "https://typemoon.fandom.com/Gallery?file=Caster_Extra_Takeuchi_design_1.png",
          "https://typemoon.fandom.com/User:Lemostr00",
          "https://typemoon.fandom.com/File:Memories_of_Trifas.png",
          "https://genshin-impact.fandom.com/wiki/Ningguang/Gallery",
          "https://genshin-impact.fandom.com/Ningguang/Gallery",
          "https://genshin-impact.fandom.com/ja/wiki/凝光/ギャラリー",
          "https://genshin-impact.fandom.com/ja/凝光/ギャラリー",
        ],
        profile_urls: [
          "https://typemoon.fandom.com",
          "https://genshin-impact.fandom.com/pt-br",
        ],
        bad_sources: [
          "https://typemoon.fandom.com",
          "https://typemoon.fandom.com/wiki/User:Lemostr00",
          "https://typemoon.fandom.com/f/p/4400000000000077950",
          "https://genshin-impact.fandom.com/wiki/Ningguang/Gallery",
        ],
      )

      should_not_find_false_positives(
        page_urls: [
          "https://typemoon.fandom.com/f/p/4400000000000077950",
          "https://genshin-impact.fandom.com/pt-br/f",
        ],
        bad_sources: [
          "https://vignette.wikia.nocookie.net/valkyriecrusade/images/c/c5/Crimson_Hatsune_H.png/revision/latest?cb=20180702031954",
          "https://typemoon.fandom.com/wiki/Tamamo-no-Mae?file=Caster_Extra_Takeuchi_design_1.png",
          "https://typemoon.fandom.com/wiki/File:Memories_of_Trifas.png",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://vignette.wikia.nocookie.net/valkyriecrusade/images/c/c5/Crimson_Hatsune_H.png/revision/latest?cb=20180702031954",
                             page_url: "https://valkyriecrusade.fandom.com/wiki/File:Crimson_Hatsune_H.png",)

      url_parser_should_work("https://static.wikia.nocookie.net/age-of-ishtaria/images/f/f9/Union-List.png/revision/latest/scale-to-width-down/670?cb=20141219153314",
                             page_url: "https://ishtaria.fandom.com/wiki/File:Union-List.png",)

      url_parser_should_work("https://static.wikia.nocookie.net/atelierseries/images/2/22/Marie_%28Front_Page_Art%29.jpg/revision/latest/scale-to-width-down/670?cb=20130129113100",
                             page_url: "https://atelier.fandom.com/wiki/File:Marie_(Front_Page_Art).jpg",)

      url_parser_should_work("https://static.wikia.nocookie.net/kagura/images/9/9f/Kagurapedia_Header.png/revision/latest/scale-to-width-down/650?cb=20171016220119",
                             page_url: "https://senrankagura.fandom.com/wiki/File:Kagurapedia_Header.png",)

      url_parser_should_work("https://static.wikia.nocookie.net/gensin-impact/images/2/22/Character_Kamisato_Ayato_Card.png/revision/latest/scale-to-width-down/281?cb=20220204094446",
                             page_url: "https://genshin-impact.fandom.com/wiki/File:Character_Kamisato_Ayato_Card.png",)

      url_parser_should_work("http://vignette3.wikia.nocookie.net/neptunia/images/2/28/Plutia_B%2BNvZ.png/revision/latest?cb=20160420084622",
                             page_url: "https://neptunia.fandom.com/wiki/File:Plutia_B%2BNvZ.png",)

      url_parser_should_work("http://img3.wikia.nocookie.net/__cb20130523100711/typemoon/images/9/96/Caster_Extra_Takeuchi_design_1.png",
                             page_url: "https://typemoon.fandom.com/wiki/File:Caster_Extra_Takeuchi_design_1.png",)

      url_parser_should_work("https://static.wikia.nocookie.net/virtualyoutuber/images/c/c4/Alicia_Cotton_2nd_Outfit_2.png/revision/latest?cb=20211107035307&path-prefix=vi",
                             page_url: "https://virtualyoutuber.fandom.com/vi/wiki/File:Alicia_Cotton_2nd_Outfit_2.png",)

      url_parser_should_work("http://img3.wikia.nocookie.net/__cb20140404214519/typemoon/fr/images/f/fd/Aozaki_Aoko_Blue.png",
                             page_url: "https://typemoon.fandom.com/fr/wiki/File:Aozaki_Aoko_Blue.png",)

      url_parser_should_work("http://img3.wikia.nocookie.net/__cb20140404214519/typemoon/images/f/fd/Aozaki_Aoko_Blue.png/revision/latest?path-prefix=fr",
                             page_url: "https://typemoon.fandom.com/fr/wiki/File:Aozaki_Aoko_Blue.png",)

      url_parser_should_work("http://img3.wikia.nocookie.net/__cb20140404214519/typemoon/fr/images/thumb/f/fd/Aozaki_Aoko_Blue.png/500px-Aozaki_Aoko_Blue.png",
                             page_url: "https://typemoon.fandom.com/fr/wiki/File:Aozaki_Aoko_Blue.png",)

      url_parser_should_work("http://img3.wikia.nocookie.net/__cb20130520180921/allanimefanon/images/thumb/8/82/2560-1600-104761.jpg/2000px-2560-1600-104761.jpg",
                             page_url: "https://allanimefanon.fandom.com/wiki/File:2560-1600-104761.jpg",)

      url_parser_should_work("https://static.wikia.nocookie.net/p__/protagonist/images/3/3f/Yukiko_Amagi_(BlazBlue_Cross_Tag_Battle%2C_Character_Select_Artwork).png",
                             page_url: "https://hero.fandom.com/wiki/File:Yukiko_Amagi_(BlazBlue_Cross_Tag_Battle,_Character_Select_Artwork).png",)
    end
  end
end
