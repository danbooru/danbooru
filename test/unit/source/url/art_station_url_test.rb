require "test_helper"

module Source::Tests::URL
  class ArtStationUrlTest < ActiveSupport::TestCase
    context "ArtStation URLs" do
      should be_image_url(
        "http://cdna.artstation.com/p/assets/images/images/005/804/224/large/titapa-khemakavat-sa-dui-srevere.jpg?1493887236",
        "https://cdn-animation.artstation.com/p/video_sources/000/466/622/workout.mp4",
        "https://cdna.artstation.com/p/assets/covers/images/007/262/828/small/monica-kyrie-1.jpg?1504865060",
      )

      should be_profile_url(
        "https://www.artstation.com/sa-dui",
        "https://artstation.com/artist/sa-dui",
        "https://anubis1982918.artstation.com",
        "https://heyjay.artstation.com/store/art_posters",
        "https://www.artstation.com/artist/chicle/albums/all/",
        "http://www.artstation.com/envie_dai/prints",
      )

      should be_page_url(
        "https://www.artstation.com/artwork/ghost-in-the-shell-fandom",
        "https://artstation.com/artwork/04XA4",
        "https://sa-dui.artstation.com/projects/DVERn",
      )

      should parse_url("https://dudeunderscore.artstation.com/projects/NoNmD?album_id=23041").into(
        page_url: "https://www.artstation.com/artwork/NoNmD",
        username: "dudeunderscore",
      )

      should parse_url("https://anubis1982918.artstation.com/projects/qPVGP/").into(
        page_url: "https://www.artstation.com/artwork/qPVGP",
        username: "anubis1982918",
      )

      should parse_url("https://www.artstation.com/artwork/ghost-in-the-shell-fandom").into(
        page_url: "https://www.artstation.com/artwork/ghost-in-the-shell-fandom",
        username: nil,
      )

      should parse_url("https://cdna.artstation.com/p/assets/images/images/005/804/224/large/titapa-khemakavat-sa-dui-srevere.jpg?1493887236").into(
        full_image_url: "https://cdn.artstation.com/p/assets/images/images/005/804/224/original/titapa-khemakavat-sa-dui-srevere.jpg?1493887236",
      )

      should parse_url("https://cdnb.artstation.com/p/assets/images/images/014/410/217/smaller_square/bart-osz-bartosz1812041.jpg").into(
        full_image_url: "https://cdn.artstation.com/p/assets/images/images/014/410/217/original/bart-osz-bartosz1812041.jpg",
      )

      should parse_url("https://cdn-animation.artstation.com/p/video_sources/000/466/622/workout.mp4").into(
        full_image_url: "https://cdn-animation.artstation.com/p/video_sources/000/466/622/workout.mp4",
      )

      should parse_url("https://artstation.com/artist/sa-dui").into(
        profile_url: "https://www.artstation.com/sa-dui",
      )
    end
  end
end
