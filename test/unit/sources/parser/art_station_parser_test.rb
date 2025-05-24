require "test_helper"

module Source::URL::Tests
  class ArtStationParserTest < ActiveSupport::TestCase
    context "for image urls" do
      should_recognize_image_urls(
        "http://cdna.artstation.com/p/assets/images/images/005/804/224/large/titapa-khemakavat-sa-dui-srevere.jpg?1493887236",
        "https://cdn-animation.artstation.com/p/video_sources/000/466/622/workout.mp4",
      )
    end

    context "for page urls" do
      should_recognize_page_urls(
        "https://www.artstation.com/artwork/ghost-in-the-shell-fandom",
        "https://artstation.com/artwork/04XA4",
      )
    end

    context "for profile urls" do
      should_recognize_profile_urls(
        "https://www.artstation.com/sa-dui",
        "https://artstation.com/artist/sa-dui",
        "https://anubis1982918.artstation.com",
      )
    end

    context "when parsing" do
      url_parser_should_work("https://dudeunderscore.artstation.com/projects/NoNmD?album_id=23041", page_url: "https://www.artstation.com/artwork/NoNmD", username: "dudeunderscore")
      url_parser_should_work("https://anubis1982918.artstation.com/projects/qPVGP/", page_url: "https://www.artstation.com/artwork/qPVGP", username: "anubis1982918")
      url_parser_should_work("https://www.artstation.com/artwork/ghost-in-the-shell-fandom", page_url: "https://www.artstation.com/artwork/ghost-in-the-shell-fandom", username: nil)
    end
  end
end
