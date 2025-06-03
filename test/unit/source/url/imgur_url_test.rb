require "test_helper"

module Source::Tests::URL
  class ImgurUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://i.imgur.com/c7EXjJu.jpeg",
          "https://i.imgur.io/c7EXjJu.jpeg",
          "https://imgur.com/c7EXjJu.jpeg",
          "https://imgur.com/download/c7EXjJu/",
        ],
        page_urls: [
          "https://imgur.com/c7EXjJu",
          "https://imgur.io/c7EXjJu",
          "https://imgur.com/arknights-tv-animation-prelude-to-dawn-new-character-visuals-tallulah-w-5Os4IW2",
          "https://imgur.com/gallery/0BDNq",
          "https://imgur.com/gallery/i-would-be-villain-jessie-from-pok-mon-i-would-be-villain-jessie-from-pok-mon-g0ua0kg#/t/anime",
          "https://imgur.com/a/0BDNq",
          "https://imgur.com/t/anime/g0ua0kg",
        ],
        profile_urls: [
          "https://imgur.com/user/naugrim2875",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://i.imgur.com/c7EXjJu.jpeg", image_id: "c7EXjJu")
      url_parser_should_work("https://i.imgur.com/c7EXjJum.jpeg", image_id: "c7EXjJu")
      url_parser_should_work("https://i.imgur.com/c7EXjJu_d.jpeg", image_id: "c7EXjJu")
      url_parser_should_work("https://imgur.com/c7EXjJu.jpeg", image_id: "c7EXjJu")
      url_parser_should_work("https://i.imgur.com/kJ2FL.jpeg", image_id: "kJ2FL")
      url_parser_should_work("https://i.imgur.com/kJ2FLm.jpeg", image_id: "kJ2FL")
      url_parser_should_work("https://i.imgur.com/kJ2FL_d.jpeg", image_id: "kJ2FL")
    end
  end
end
