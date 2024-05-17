require 'test_helper'

module Sources
  class ArtStationTest < ActiveSupport::TestCase
    context "An ArtStation /artwork/:id URL" do
      strategy_should_work(
        "https://www.artstation.com/artwork/04XA4",
        image_urls: ["https://cdn.artstation.com/p/assets/images/images/000/705/368/4k/jey-rain-one1.jpg?1443931773"],
        page_url: "https://jeyrain.artstation.com/projects/04XA4",
        profile_url: "https://www.artstation.com/jeyrain",
        display_name: "Jey Rain",
        username: "jeyrain",
        tags: [],
        artist_commentary_title: "pink",
        dtext_artist_commentary_desc: ""
      )
    end

    context "An ArtStation /projects/ URL" do
      strategy_should_work(
        "https://dantewontdie.artstation.com/projects/YZK5q",
        image_urls: ["https://cdn.artstation.com/p/assets/images/images/006/066/534/4k/yinan-cui-reika.jpg?1495781565"],
        page_url: "https://dantewontdie.artstation.com/projects/YZK5q",
        profile_url: "https://www.artstation.com/dantewontdie",
        display_name: "Yinan Cui",
        username: "dantewontdie",
        tags: %w[gantz Reika],
        artist_commentary_title: "Reika ",
        dtext_artist_commentary_desc: "From Gantz.",
        media_files: [{ file_size: 210_899 }]
      )
    end

    context "An ArtStation /artwork/$slug page" do
      strategy_should_work(
        "https://www.artstation.com/artwork/cody-from-sf",
        image_urls: ["https://cdn.artstation.com/p/assets/images/images/000/144/922/4k/cassio-yoshiyaki-cody2backup2-yoshiyaki.jpg?1406314198"],
        display_name: "Cassio Yoshiyaki",
        username: "yoshiyaki",
        tags: ["Street Fighter", "Cody", "SF", "NoAI"],
        artist_commentary_title: "Cody from SF",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A http://cdn.artstation.com/p/assets/... url" do
      strategy_should_work(
        "https://cdna.artstation.com/p/assets/images/images/006/029/978/large/amama-l-z.jpg",
        image_urls: ["https://cdn.artstation.com/p/assets/images/images/006/029/978/4k/amama-l-z.jpg"],
        page_url: nil,
        profile_url: nil
      )
    end

    context "A http://cdn.artstation.com/p/assets/... url with referrer" do
      strategy_should_work(
        "https://cdna.artstation.com/p/assets/images/images/006/029/978/large/amama-l-z.jpg",
        image_urls: ["https://cdn.artstation.com/p/assets/images/images/006/029/978/4k/amama-l-z.jpg"],
        referer: "https://www.artstation.com/artwork/4BWW2",
        page_url: "https://amama.artstation.com/projects/4BWW2",
        profile_url: "https://www.artstation.com/amama",
        display_name: "Amama L",
        username: "amama",
      )
    end

    context "An ArtStation cover url" do
      strategy_should_work(
        "https://cdna.artstation.com/p/assets/covers/images/007/262/828/large/monica-kyrie-1.jpg?1504865060",
        image_urls: ["https://cdn.artstation.com/p/assets/covers/images/007/262/828/original/monica-kyrie-1.jpg?1504865060"]
      )
    end

    context "An ArtStation post with images and youtube links" do
      strategy_should_work(
        "https://www.artstation.com/artwork/BDxrA",
        image_urls: ["https://cdn.artstation.com/p/assets/images/images/006/037/253/4k/astri-lohne-sjursen-eva.jpg?1495573664"],
        display_name: "Astri Lohne",
        username: "sjursen",
        artist_commentary_title: "Akealor",
        dtext_artist_commentary_desc: "Demon hunter commissionnnn",
      )
    end

    context "An ArtStation post with images and videos" do
      strategy_should_work(
        "https://www.artstation.com/artwork/0nP1e8",
        image_urls: %w[
          https://cdn.artstation.com/p/assets/images/images/040/979/418/original/yusuf-umar-workout-10mb.gif?1630425406
          https://cdn.artstation.com/p/assets/images/images/040/979/435/4k/yusuf-umar-1.jpg?1630425420
          https://cdn.artstation.com/p/assets/images/images/040/979/470/4k/yusuf-umar-2.jpg?1630425483
          https://cdn.artstation.com/p/assets/images/images/040/979/494/4k/yusuf-umar-3.jpg?1630425530
          https://cdn.artstation.com/p/assets/images/images/040/979/503/4k/yusuf-umar-4.jpg?1630425547
          https://cdn.artstation.com/p/assets/images/images/040/979/659/4k/yusuf-umar-5.jpg?1630425795
          https://cdn.artstation.com/p/assets/images/images/040/980/932/4k/yusuf-umar-tpose.jpg?1630427748
          https://cdn.artstation.com/p/video_sources/000/466/622/workout.mp4
          https://cdn.artstation.com/p/video_sources/000/466/623/workout-clay.mp4
        ],
        display_name: "ucupumar",
        username: "ucupumar",
        artist_commentary_title: "Workout",
        dtext_artist_commentary_desc: <<~EOS.chomp
          Workout. Created using Blender 2.93 and rendered using Eevee.
          Blend file is available on:
          <https://www.artstation.com/marketplace/p/v9YrA>
          If you like my artwork, consider supporting me on Patreon: <https://www.patreon.com/ucupumar>
        EOS
      )
    end

    context "An ArtStation video url" do
      strategy_should_work(
        "https://cdn.artstation.com/p/video_sources/000/466/622/workout.mp4",
        image_urls: ["https://cdn.artstation.com/p/video_sources/000/466/622/workout.mp4"],
        media_files: [{ file_size: 377_969 }],
      )
    end

    context "A deleted ArtStation url" do
      strategy_should_work(
        "https://fiship.artstation.com/projects/x8n8XT",
        deleted: true,
        image_urls: [],
        display_name: nil,
        username: "fiship",
        profile_url: "https://www.artstation.com/fiship",
        page_url: "https://fiship.artstation.com/projects/x8n8XT"
      )
    end

    context "A /small/ ArtStation image URL" do
      strategy_should_work(
        "https://cdnb3.artstation.com/p/assets/images/images/003/716/071/small/aoi-ogata-hate-city.jpg?1476754974",
        image_urls: ["https://cdn.artstation.com/p/assets/images/images/003/716/071/4k/aoi-ogata-hate-city.jpg?1476754974"],
        media_files: [{ file_size: 1_816_628 }]
      )
    end

    context "A /large/ ArtStation image URL (1)" do
      strategy_should_work(
        "https://cdnb.artstation.com/p/assets/images/images/003/716/071/large/aoi-ogata-hate-city.jpg?1476754974",
        image_urls: ["https://cdn.artstation.com/p/assets/images/images/003/716/071/4k/aoi-ogata-hate-city.jpg?1476754974"],
        media_files: [{ file_size: 1_816_628 }]
      )
    end

    context "A /large/ ArtStation image URL (2)" do
      strategy_should_work(
        "https://cdna.artstation.com/p/assets/images/images/004/730/278/large/mendel-oh-dragonll.jpg",
        image_urls: ["https://cdn.artstation.com/p/assets/images/images/004/730/278/4k/mendel-oh-dragonll.jpg"],
        media_files: [{ file_size: 452_985 }]
      )
    end

    context "An ArtStation url with underscores in the artist name" do
      strategy_should_work(
        "https://hosi_na.artstation.com/projects/3oEk3B",
        display_name: "somi kim",
        username: "hosi_na",
        artist_commentary_title: "The Queen 여왕",
        dtext_artist_commentary_desc: <<~EOS.chomp
          The keywords of this concept are absolute Power, The Queen, and a cool-headed person.
          컨셉 키워드는 '힘,여왕,냉정함'
        EOS
      )
    end

    context "An ArtStation url with dashes in the artist name" do
      strategy_should_work(
        "https://sa-dui.artstation.com/projects/DVERn",
        display_name: "Titapa Khemakavat (Sa-Dui)",
        username: "sa-dui",
        artist_commentary_title: "Commission : Srevere",
        dtext_artist_commentary_desc: <<~EOS.chomp
          Commission for Srevere.
          Cover image for her Pokemon-based fandom series.
        EOS
      )
    end

    context "An ArtStation post with HTML entities in the commentary" do
      strategy_should_work(
        "https://www.artstation.com/artwork/nq8go",
        page_url: "https://idrawbagman.artstation.com/projects/nq8go",
        image_urls: %w[
          https://cdn.artstation.com/p/assets/images/images/006/809/536/4k/kent-davis-stillben-02.jpg?1501433242
          https://cdn.artstation.com/p/assets/images/images/006/809/540/4k/kent-davis-theemeraldcitadelofsyngorn-03.jpg?1501433246
          https://cdn.artstation.com/p/assets/images/images/006/809/543/4k/kent-davis-theinsatiablesanctuary-02.jpg?1501433252
          https://cdn.artstation.com/p/assets/images/images/006/809/614/4k/kent-davis-wildemountcastle-02.jpg?1501433798
        ],
        display_name: "Kent Davis",
        username: "idrawbagman",
        other_names: ["Kent Davis", "idrawbagman"],
        profile_url: "https://www.artstation.com/idrawbagman",
        tags: [],
        artist_commentary_title: "Landscapes of Tal'dorei Part 1",
        dtext_artist_commentary_desc: <<~EOS.chomp
          "Wildemount Castle"
          "The Insatiable Sanctuary"
          "Stilben"
          "The Emerald Citadel of Syngorn"

          These were featured as part of the art for the "Tal'dorei Campaign Setting" book by Matt Mercer and James Haeck. Based on locations on the continent of Tal'dorei from the D&D web series "Critical Role" by Geek & Sundry.

          Copyright 2017
          Green Ronin Publishing, LLC
        EOS
      )
    end

    should "Parse ArtStation URLs correctly" do
      assert_equal("https://www.artstation.com/artwork/ghost-in-the-shell-fandom", Source::URL.page_url("https://www.artstation.com/artwork/ghost-in-the-shell-fandom"))
      assert_equal("https://www.artstation.com/artwork/qPVGP", Source::URL.page_url("https://anubis1982918.artstation.com/projects/qPVGP/"))
      assert_equal("https://www.artstation.com/artwork/NoNmD", Source::URL.page_url("https://dudeunderscore.artstation.com/projects/NoNmD?album_id=23041"))

      assert(Source::URL.page_url?("https://www.artstation.com/artwork/ghost-in-the-shell-fandom"))
      assert(Source::URL.page_url?("https://artstation.com/artwork/04XA4"))

      assert(Source::URL.image_url?("http://cdna.artstation.com/p/assets/images/images/005/804/224/large/titapa-khemakavat-sa-dui-srevere.jpg?1493887236"))
      assert(Source::URL.image_url?("https://cdn-animation.artstation.com/p/video_sources/000/466/622/workout.mp4"))

      assert(Source::URL.profile_url?("https://www.artstation.com/sa-dui"))
      assert(Source::URL.profile_url?("https://artstation.com/artist/sa-dui"))
      assert(Source::URL.profile_url?("https://anubis1982918.artstation.com"))

      assert_not(Source::URL.profile_url?("https://anubis1982918.artstation.com/projects/qPVGP"))
      assert_not(Source::URL.profile_url?("https://www.artstation.com"))
      assert_not(Source::URL.profile_url?("https://artstation.com"))
    end
  end
end
