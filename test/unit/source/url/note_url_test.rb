require "test_helper"

module Source::Tests::URL
  class NoteUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://assets.st-note.com/img/1623726537463-B8LOZ1JZUS.png?width=2000&height=2000&fit=bounds&format=jpg&quality=85",
          "https://assets.st-note.com/production/uploads/images/14533920/profile_812af2baf1a6eb05c62182d43b0cbdbe.png?width=60",
        ],
        page_urls: [
          "https://note.com/koma_labo/n/n32fb90fac512",
          "https://note.mu/koma_labo/n/n32fb90fac512",
        ],
        profile_urls: [
          "https://note.com/koma_labo",
          "https://note.mu/koma_labo",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://assets.st-note.com/img/1623726537463-B8LOZ1JZUS.png?width=2000&height=2000&fit=bounds&format=jpg&quality=85",
                             full_image_url: "https://d2l930y2yx77uc.cloudfront.net/img/1623726537463-B8LOZ1JZUS.png",)

      url_parser_should_work("https://assets.st-note.com/img/1623726537463-B8LOZ1JZUS.png",
                             full_image_url: "https://d2l930y2yx77uc.cloudfront.net/img/1623726537463-B8LOZ1JZUS.png",)

      url_parser_should_work("https://note-cakes-web-dev.s3.amazonaws.com/img/1623726537463-B8LOZ1JZUS.png",
                             full_image_url: "https://d2l930y2yx77uc.cloudfront.net/img/1623726537463-B8LOZ1JZUS.png",)

      url_parser_should_work("https://assets.st-note.com/production/uploads/images/17105324/c647f6629bcfe2638e23924d96a7aae4.jpeg",
                             full_image_url: "https://d2l930y2yx77uc.cloudfront.net/production/uploads/images/17105324/c647f6629bcfe2638e23924d96a7aae4.jpeg",)

      url_parser_should_work("https://d2l930y2yx77uc.cloudfront.net/production/uploads/images/17105324/c647f6629bcfe2638e23924d96a7aae4.jpeg",
                             full_image_url: "https://d2l930y2yx77uc.cloudfront.net/production/uploads/images/17105324/c647f6629bcfe2638e23924d96a7aae4.jpeg",)

      url_parser_should_work("https://note-cakes-web-dev.s3.amazonaws.com/production/uploads/images/17105324/c647f6629bcfe2638e23924d96a7aae4.jpeg",
                             full_image_url: "https://d2l930y2yx77uc.cloudfront.net/production/uploads/images/17105324/c647f6629bcfe2638e23924d96a7aae4.jpeg",)
    end
  end
end
