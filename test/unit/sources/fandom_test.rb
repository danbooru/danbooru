require 'test_helper'

module Sources
  class FandomTest < ActiveSupport::TestCase
    context "Fandom" do
      should "convert fandom image urls to page urls" do
        assert_equal("https://valkyriecrusade.fandom.com/wiki/Gallery?file=Crimson_Hatsune_H.png", Source::URL.page_url("https://vignette.wikia.nocookie.net/valkyriecrusade/images/c/c5/Crimson_Hatsune_H.png/revision/latest?cb=20180702031954"))
        assert_equal("https://ishtaria.fandom.com/wiki/Gallery?file=Union-List.png", Source::URL.page_url("https://static.wikia.nocookie.net/age-of-ishtaria/images/f/f9/Union-List.png/revision/latest/scale-to-width-down/670?cb=20141219153314"))
        assert_equal("https://atelier.fandom.com/wiki/Gallery?file=Marie_(Front_Page_Art).jpg", Source::URL.page_url("https://static.wikia.nocookie.net/atelierseries/images/2/22/Marie_%28Front_Page_Art%29.jpg/revision/latest/scale-to-width-down/670?cb=20130129113100"))
        assert_equal("https://senrankagura.fandom.com/wiki/Gallery?file=Kagurapedia_Header.png", Source::URL.page_url("https://static.wikia.nocookie.net/kagura/images/9/9f/Kagurapedia_Header.png/revision/latest/scale-to-width-down/650?cb=20171016220119"))
        assert_equal("https://genshin-impact.fandom.com/wiki/Gallery?file=Character_Kamisato_Ayato_Card.png", Source::URL.page_url("https://static.wikia.nocookie.net/gensin-impact/images/2/22/Character_Kamisato_Ayato_Card.png/revision/latest/scale-to-width-down/281?cb=20220204094446"))
        assert_equal("https://neptunia.fandom.com/wiki/Gallery?file=Plutia_B%2BNvZ.png", Source::URL.page_url("http://vignette3.wikia.nocookie.net/neptunia/images/2/28/Plutia_B%2BNvZ.png/revision/latest?cb=20160420084622"))
        assert_equal("https://typemoon.fandom.com/wiki/Gallery?file=Caster_Extra_Takeuchi_design_1.png", Source::URL.page_url("http://img3.wikia.nocookie.net/__cb20130523100711/typemoon/images/9/96/Caster_Extra_Takeuchi_design_1.png"))
        assert_equal("https://virtualyoutuber.fandom.com/vi/wiki/Gallery?file=Alicia_Cotton_2nd_Outfit_2.png", Source::URL.page_url("https://static.wikia.nocookie.net/virtualyoutuber/images/c/c4/Alicia_Cotton_2nd_Outfit_2.png/revision/latest?cb=20211107035307&path-prefix=vi"))
        assert_equal("https://typemoon.fandom.com/fr/wiki/Gallery?file=Aozaki_Aoko_Blue.png", Source::URL.page_url("http://img3.wikia.nocookie.net/__cb20140404214519/typemoon/fr/images/f/fd/Aozaki_Aoko_Blue.png"))
        assert_equal("https://typemoon.fandom.com/fr/wiki/Gallery?file=Aozaki_Aoko_Blue.png", Source::URL.page_url("http://img3.wikia.nocookie.net/__cb20140404214519/typemoon/images/f/fd/Aozaki_Aoko_Blue.png/revision/latest?path-prefix=fr"))
        assert_equal("https://typemoon.fandom.com/fr/wiki/Gallery?file=Aozaki_Aoko_Blue.png", Source::URL.page_url("http://img3.wikia.nocookie.net/__cb20140404214519/typemoon/fr/images/thumb/f/fd/Aozaki_Aoko_Blue.png/500px-Aozaki_Aoko_Blue.png"))
        assert_equal("https://allanimefanon.fandom.com/wiki/Gallery?file=2560-1600-104761.jpg", Source::URL.page_url("http://img3.wikia.nocookie.net/__cb20130520180921/allanimefanon/images/thumb/8/82/2560-1600-104761.jpg/2000px-2560-1600-104761.jpg"))
      end

      should "parse URLs correctly" do
        assert(Source::URL.image_url?("https://vignette.wikia.nocookie.net/valkyriecrusade/images/c/c5/Crimson_Hatsune_H.png/revision/latest?cb=20180702031954"))
        assert(Source::URL.image_url?("https://static.wikia.nocookie.net/74a9f058-f816-4856-8aad-c398aa8a4c81/thumbnail/width/400/height/400"))
        assert(Source::URL.image_url?("https://static.wikia.nocookie.net/74a9f058-f816-4856-8aad-c398aa8a4c81"))
      end
    end
  end
end
