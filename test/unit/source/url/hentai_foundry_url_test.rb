require "test_helper"

module Source::Tests::URL
  class HentaiFoundryUrlTest < ActiveSupport::TestCase
    context "HentaiFoundry URLs" do
      should be_image_url(
        "https://pictures.hentai-foundry.com/a/Afrobull/795025/Afrobull-795025-kuroeda.png",
        "http://pictures.hentai-foundry.com//s/soranamae/363663.jpg",
        "http://www.hentai-foundry.com/piccies/d/dmitrys/1183.jpg",
        "http://hentai-foundry.com/piccies/d/dmitrys/1183.jpg",
        "https://thumbs.hentai-foundry.com/thumb.php?pid=795025&size=350",
      )

      should be_page_url(
        "https://www.hentai-foundry.com/pictures/user/Afrobull/795025",
        "http://www.hentai-foundry.com/pic-795025",
        "https://hentai-foundry.com/pictures/user/Afrobull/795025",
        "http://hentai-foundry.com/pic-795025",
      )

      should be_profile_url(
        "https://www.hentai-foundry.com/user/kajinman",
        "https://www.hentai-foundry.com/pictures/user/kajinman",
        "http://www.hentai-foundry.com/profile-sawao.php",
        "https://hentai-foundry.com/user/kajinman",
        "https://hentai-foundry.com/pictures/user/kajinman",
        "http://hentai-foundry.com/profile-sawao.php",
      )
    end

    should parse_url("https://pictures.hentai-foundry.com/a/Afrobull/795025/Afrobull-795025-kuroeda.png").into(site_name: "Hentai Foundry")
  end
end
