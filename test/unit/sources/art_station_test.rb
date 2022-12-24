require 'test_helper'

module Sources
  class ArtStationTest < ActiveSupport::TestCase
    context "An ArtStation /artwork/:id URL" do
      strategy_should_work(
        "https://www.artstation.com/artwork/04XA4",
        image_urls: ["https://cdn.artstation.com/p/assets/images/images/000/705/368/4k/jey-rain-one1.jpg?1443931773"],
        page_url: "https://jeyrain.artstation.com/projects/04XA4",
        profile_url: "https://www.artstation.com/jeyrain",
        artist_name: "jeyrain",
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
        artist_name: "dantewontdie",
        tags: %w[gantz Reika],
        artist_commentary_title: "Reika ",
        dtext_artist_commentary_desc: "From Gantz.",
        download_size: 210_899
      )
    end

    context "An ArtStation /artwork/$slug page" do
      strategy_should_work(
        "https://www.artstation.com/artwork/cody-from-sf",
        image_urls: ["https://cdn.artstation.com/p/assets/images/images/000/144/922/4k/cassio-yoshiyaki-cody2backup2-yoshiyaki.jpg?1406314198"],
        tags: ["Street Fighter", "Cody", "SF", "NoAI"]
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
        artist_name: "amama"
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
        image_urls: ["https://cdn.artstation.com/p/assets/images/images/006/037/253/4k/astri-lohne-sjursen-eva.jpg?1495573664"]
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
          https://cdn-animation.artstation.com/p/video_sources/000/466/622/workout.mp4
          https://cdn-animation.artstation.com/p/video_sources/000/466/623/workout-clay.mp4
        ]
      )
    end

    context "An ArtStation video url" do
      strategy_should_work(
        "https://cdn-animation.artstation.com/p/video_sources/000/466/622/workout.mp4",
        image_urls: ["https://cdn-animation.artstation.com/p/video_sources/000/466/622/workout.mp4"],
        download_size: 377_969,
      )
    end

    context "A deleted ArtStation url" do
      strategy_should_work(
        "https://fiship.artstation.com/projects/x8n8XT",
        deleted: true,
        image_urls: [],
        artist_name: "fiship",
        profile_url: "https://www.artstation.com/fiship",
        page_url: "https://fiship.artstation.com/projects/x8n8XT"
      )
    end

    context "A /small/ ArtStation image URL" do
      strategy_should_work(
        "https://cdnb3.artstation.com/p/assets/images/images/003/716/071/small/aoi-ogata-hate-city.jpg?1476754974",
        image_urls: ["https://cdn.artstation.com/p/assets/images/images/003/716/071/4k/aoi-ogata-hate-city.jpg?1476754974"],
        download_size: 1_816_628
      )
    end

    context "A /large/ ArtStation image URL (1)" do
      strategy_should_work(
        "https://cdnb.artstation.com/p/assets/images/images/003/716/071/large/aoi-ogata-hate-city.jpg?1476754974",
        image_urls: ["https://cdn.artstation.com/p/assets/images/images/003/716/071/4k/aoi-ogata-hate-city.jpg?1476754974"],
        download_size: 1_816_628
      )
    end

    context "A /large/ ArtStation image URL (2)" do
      strategy_should_work(
        "https://cdna.artstation.com/p/assets/images/images/004/730/278/large/mendel-oh-dragonll.jpg",
        image_urls: ["https://cdn.artstation.com/p/assets/images/images/004/730/278/4k/mendel-oh-dragonll.jpg"],
        download_size: 452_985
      )
    end

    context "An ArtStation url with underscores in the artist name" do
      strategy_should_work(
        "https://hosi_na.artstation.com/projects/3oEk3B",
        artist_name: "hosi_na"
      )
    end

    context "An ArtStation url with dashes in the artist name" do
      strategy_should_work(
        "https://sa-dui.artstation.com/projects/DVERn",
        artist_name: "sa-dui"
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
