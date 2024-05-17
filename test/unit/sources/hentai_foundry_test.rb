require 'test_helper'

module Sources
  class HentaiFoundryTest < ActiveSupport::TestCase
    context "A hentai-foundry post" do
      strategy_should_work(
        "https://www.hentai-foundry.com/pictures/user/Afrobull/795025/kuroeda",
        image_urls: ["https://pictures.hentai-foundry.com/a/Afrobull/795025/Afrobull-795025-kuroeda.png"],
        username: "Afrobull",
        artist_commentary_title: "kuroeda",
        profile_url: "https://www.hentai-foundry.com/user/Afrobull",
        media_files: [{ file_size: 1_349_887 }],
        tags: [["elf", "https://www.hentai-foundry.com/pictures/tagged/elf"]]
      )
    end

    context "A hentai-foundry picture" do
      strategy_should_work(
        "https://www.hentai-foundry.com/pictures/user/Afrobull/795025/kuroeda",
        image_urls: ["https://pictures.hentai-foundry.com/a/Afrobull/795025/Afrobull-795025-kuroeda.png"],
        username: "Afrobull",
        artist_commentary_title: "kuroeda",
        profile_url: "https://www.hentai-foundry.com/user/Afrobull",
        media_files: [{ file_size: 1_349_887 }],
        tags: [["elf", "https://www.hentai-foundry.com/pictures/tagged/elf"]]
      )
    end

    context "A deleted picture" do
      strategy_should_work(
        "https://www.hentai-foundry.com/pictures/user/faustsketcher/279498",
        image_urls: [],
        username: "faustsketcher",
        profile_url: "https://www.hentai-foundry.com/user/faustsketcher",
        deleted: true
      )
    end

    context "An old image url" do
      strategy_should_work(
        "http://pictures.hentai-foundry.com//a/AnimeFlux/219123.jpg",
        image_urls: ["https://pictures.hentai-foundry.com/a/AnimeFlux/219123/AnimeFlux-219123-Mobile_Suit_Equestria_rainbow_run.jpg"],
        page_url: "https://www.hentai-foundry.com/pictures/user/AnimeFlux/219123",
        profile_url: "https://www.hentai-foundry.com/user/AnimeFlux"
      )
    end

    context "An image url without the extension" do
      strategy_should_work(
        "http://www.hentai-foundry.com/pictures/user/Ganassa/457176/LOL-Swimsuit---Caitlyn-reworked-nude-ver.",
        image_urls: ["https://pictures.hentai-foundry.com/g/Ganassa/457176/Ganassa-457176-LOL_Swimsuit_-_Caitlyn_reworked_nude_ver..jpg"],
        page_url: "https://www.hentai-foundry.com/pictures/user/Ganassa/457176",
        profile_url: "https://www.hentai-foundry.com/user/Ganassa"
      )
    end

    context "A post with deeply nested commentary" do
      strategy_should_work(
        "https://www.hentai-foundry.com/pictures/user/LumiNyu/867562/Mona-patreon-winner",
        dtext_artist_commentary_desc: <<~EOS.chomp
          [b]If you like this picture don't forget to thumbs up and favorite
          [/b][b]"Also you can support my art on ":[https://picarto.tv/LumiNyu][/b][b]"Patreon":[https://www.patreon.com/LumiNyu] and gain instant access to exclusive "patreon":[https://www.patreon.com/LumiNyu] content and also be able to vote for the future set of girls I should draw.[/b]
        EOS
      )
    end

    context "A post with commentary containing quote marks inside the links" do
      strategy_should_work(
        "https://www.hentai-foundry.com/pictures/user/QueenComplex/1079933/Fucc",
        dtext_artist_commentary_desc: <<~EOS.chomp
          It's a 4th piece in a set of 6
          Previous ones being - This is a sequel to my drawings "[b]&quot;Butts&quot;[/b]":[https://www.newgrounds.com/art/view/queencomplex/butts], "[b]&quot;Bubbs&quot;[/b]":[https://www.newgrounds.com/art/view/queencomplex/bubbs] and "[b]&quot;Diccs&quot;[/b]":[https://www.newgrounds.com/art/view/queencomplex/diccs]
          "[b]QUEENCOMPLEX.NET[/b]":[https://queencomplex.net/]
          The place to see my newest drawings
          and the place to support my work.
          "[b]@Queen_Complexxx[/b]":[https://twitter.com/Queen_Complexxx] - My Twitter
          "[b]mail@queencomplex.net[/b]":[mailto:<span style=]"&quot;>":[mailto:<span style=][b]<mailto:mail@queencomplex.net>[/b] - My main Email
        EOS
      )
    end

    should "Parse HentaiFoundry URLs correctly" do
      assert(Source::URL.image_url?("https://pictures.hentai-foundry.com/a/Afrobull/795025/Afrobull-795025-kuroeda.png"))
      assert(Source::URL.image_url?("http://pictures.hentai-foundry.com//s/soranamae/363663.jpg"))
      assert(Source::URL.image_url?("http://www.hentai-foundry.com/piccies/d/dmitrys/1183.jpg"))
      assert(Source::URL.image_url?("http://hentai-foundry.com/piccies/d/dmitrys/1183.jpg"))
      assert(Source::URL.image_url?("https://thumbs.hentai-foundry.com/thumb.php?pid=795025&size=350"))

      assert(Source::URL.page_url?("https://www.hentai-foundry.com/pictures/user/Afrobull/795025"))
      assert(Source::URL.page_url?("http://www.hentai-foundry.com/pic-795025"))
      assert(Source::URL.page_url?("https://hentai-foundry.com/pictures/user/Afrobull/795025"))
      assert(Source::URL.page_url?("http://hentai-foundry.com/pic-795025"))

      assert(Source::URL.profile_url?("https://www.hentai-foundry.com/user/kajinman"))
      assert(Source::URL.profile_url?("https://www.hentai-foundry.com/pictures/user/kajinman"))
      assert(Source::URL.profile_url?("http://www.hentai-foundry.com/profile-sawao.php"))
      assert(Source::URL.profile_url?("https://hentai-foundry.com/user/kajinman"))
      assert(Source::URL.profile_url?("https://hentai-foundry.com/pictures/user/kajinman"))
      assert(Source::URL.profile_url?("http://hentai-foundry.com/profile-sawao.php"))
    end
  end
end
