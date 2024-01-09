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
      end
    end
  end
end
