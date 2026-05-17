require "test_helper"

module Source::Tests::URL
  class CarrdUrlTest < ActiveSupport::TestCase
    context "Carrd URLs" do
      should be_image_url(
        "https://rosymiz.carrd.co/assets/images/gallery01/1a19b400.jpg?v=c6f079b5",
        "https://popuru.crd.co/assets/images/gallery01/0a55b9f2_original.jpg?v=ea05d439",
      )

      should be_page_url(
        "https://caminukai-art.carrd.co/#fanart-shadowheartguidance",
        "https://caminukai-art.carrd.co/#home",
        "https://otonokj.crd.co/#info",
      )

      should be_profile_url(
        "https://caminukai-art.carrd.co",
        "https://caminukai-art.carrd.co#",
        "https://otonokj.crd.co",
      )
    end

    should parse_url("https://rosymiz.carrd.co/assets/images/gallery01/1a19b400.jpg?v=c6f079b5").into(site_name: "Carrd")
  end
end
