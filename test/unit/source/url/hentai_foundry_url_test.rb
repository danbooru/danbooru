require "test_helper"

module Source::Tests::URL
  class HentaiFoundryUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://pictures.hentai-foundry.com/a/Afrobull/795025/Afrobull-795025-kuroeda.png",
          "http://pictures.hentai-foundry.com//s/soranamae/363663.jpg",
          "http://www.hentai-foundry.com/piccies/d/dmitrys/1183.jpg",
          "http://hentai-foundry.com/piccies/d/dmitrys/1183.jpg",
          "https://thumbs.hentai-foundry.com/thumb.php?pid=795025&size=350",
        ],
        page_urls: [
          "https://www.hentai-foundry.com/pictures/user/Afrobull/795025",
          "http://www.hentai-foundry.com/pic-795025",
          "https://hentai-foundry.com/pictures/user/Afrobull/795025",
          "http://hentai-foundry.com/pic-795025",
        ],
        profile_urls: [
          "https://www.hentai-foundry.com/user/kajinman",
          "https://www.hentai-foundry.com/pictures/user/kajinman",
          "http://www.hentai-foundry.com/profile-sawao.php",
          "https://hentai-foundry.com/user/kajinman",
          "https://hentai-foundry.com/pictures/user/kajinman",
          "http://hentai-foundry.com/profile-sawao.php",
        ],
      )
    end
  end
end
