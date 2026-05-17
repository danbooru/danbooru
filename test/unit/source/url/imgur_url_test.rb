require "test_helper"

module Source::Tests::URL
  class ImgurUrlTest < ActiveSupport::TestCase
    context "Imgur URLs" do
      should be_image_url(
        "https://i.imgur.com/c7EXjJu.jpeg",
        "https://i.imgur.io/c7EXjJu.jpeg",
        "https://imgur.com/c7EXjJu.jpeg",
        "https://imgur.com/download/c7EXjJu/",
      )

      should be_page_url(
        "https://imgur.com/c7EXjJu",
        "https://imgur.io/c7EXjJu",
        "https://imgur.com/arknights-tv-animation-prelude-to-dawn-new-character-visuals-tallulah-w-5Os4IW2",
        "https://imgur.com/gallery/0BDNq",
        "https://imgur.com/gallery/i-would-be-villain-jessie-from-pok-mon-i-would-be-villain-jessie-from-pok-mon-g0ua0kg#/t/anime",
        "https://imgur.com/a/0BDNq",
        "https://imgur.com/t/anime/g0ua0kg",
      )

      should be_profile_url(
        "https://imgur.com/user/naugrim2875",
      )

      should parse_url("https://i.imgur.com/c7EXjJu.jpeg").into(image_id: "c7EXjJu")
      should parse_url("https://i.imgur.com/c7EXjJum.jpeg").into(image_id: "c7EXjJu")
      should parse_url("https://i.imgur.com/c7EXjJu_d.jpeg").into(image_id: "c7EXjJu")
      should parse_url("https://imgur.com/c7EXjJu.jpeg").into(image_id: "c7EXjJu")
      should parse_url("https://i.imgur.com/kJ2FL.jpeg").into(image_id: "kJ2FL")
      should parse_url("https://i.imgur.com/kJ2FLm.jpeg").into(image_id: "kJ2FL")
      should parse_url("https://i.imgur.com/kJ2FL_d.jpeg").into(image_id: "kJ2FL")
    end

    should parse_url("https://i.imgur.com/c7EXjJu.jpeg").into(site_name: "Imgur")
  end
end
