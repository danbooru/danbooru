require "test_helper"

module Source::Tests::URL
  class ArtStationUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "http://cdna.artstation.com/p/assets/images/images/005/804/224/large/titapa-khemakavat-sa-dui-srevere.jpg?1493887236",
          "https://cdn-animation.artstation.com/p/video_sources/000/466/622/workout.mp4",
        ],
        profile_urls: [
          "https://www.artstation.com/sa-dui",
          "https://artstation.com/artist/sa-dui",
          "https://anubis1982918.artstation.com",
        ],
        page_urls: [
          "https://www.artstation.com/artwork/ghost-in-the-shell-fandom",
          "https://artstation.com/artwork/04XA4",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://dudeunderscore.artstation.com/projects/NoNmD?album_id=23041", page_url: "https://www.artstation.com/artwork/NoNmD", username: "dudeunderscore")
      url_parser_should_work("https://anubis1982918.artstation.com/projects/qPVGP/", page_url: "https://www.artstation.com/artwork/qPVGP", username: "anubis1982918")
      url_parser_should_work("https://www.artstation.com/artwork/ghost-in-the-shell-fandom", page_url: "https://www.artstation.com/artwork/ghost-in-the-shell-fandom", username: nil)
    end
  end
end
