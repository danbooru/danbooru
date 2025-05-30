require "test_helper"

module Source::Tests::URL
  class CarrdUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://rosymiz.carrd.co/assets/images/gallery01/1a19b400.jpg?v=c6f079b5",
          "https://popuru.crd.co/assets/images/gallery01/0a55b9f2_original.jpg?v=ea05d439",
        ],
        page_urls: [
          "https://caminukai-art.carrd.co/#fanart-shadowheartguidance",
          "https://caminukai-art.carrd.co/#home",
          "https://otonokj.crd.co/#info",
        ],
        profile_urls: [
          "https://caminukai-art.carrd.co",
          "https://caminukai-art.carrd.co#",
          "https://otonokj.crd.co",
        ],
      )
    end
  end
end
