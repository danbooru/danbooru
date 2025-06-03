require "test_helper"

module Source::Tests::URL
  class MisskeyUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://s3.arkjp.net/misskey/thumbnail-10c4379a-b999-4148-9d32-7bb6f22453bf.webp",
          "https://s3.arkjp.net/misskey/7d2adf4a-b2dd-40b4-ba27-916e44f7bd48.png",
          "https://media.misskeyusercontent.jp/io/dfca7bd4-c073-4ea0-991f-313ab3a77847.png",
          "https://media.misskeyusercontent.com/io/thumbnail-e9f307e4-3fad-435f-91b6-3768d688491d.webp",
          "https://media.misskeyusercontent.com/io/webpublic-a2cdd9c7-0449-4a61-b453-b5c7b2134677.png",
          "https://proxy.misskeyusercontent.com/image.webp?url=https%3A%2F%2Fimg.pawoo.net%2Fmedia_attachments%2Ffiles%2F111%2F232%2F575%2F490%2F284%2F147%2Foriginal%2F9aaf0c71a41b5647.jpeg",
          "https://media.misskeyusercontent.com/misskey/7d2adf4a-b2dd-40b4-ba27-916e44f7bd48.png",
          "https://nos3.arkjp.net/image.webp?url=https%3A%2F%2Fimg.pawoo.net%2Fmedia_attachments%2Ffiles%2F110%2F314%2F466%2F230%2F358%2F806%2Foriginal%2F6fbcc38659d3cb97.jpeg",
          "https://s3.arkjp.net/misskey/930fe4fb-c07b-4439-804e-06fb472d698f.gif",
          "https://files.misskey.art//webpublic-94d9354f-ddba-406b-b878-4ce02ccfa505.webp",
          "https://file.misskey.design/post/webpublic-ac7072e9-812f-460b-ad24-1f303a62f0b4.webp",
        ],
        page_urls: [
          "https://misskey.io/notes/9bxaf592x6",
        ],
        profile_urls: [
          "https://misskey.io/@ixy194",
          "https://misskey.io/users/9bpemdns40",
        ],
      )

      should_not_find_false_positives(
        image_urls: [
          "https://media.misskeyusercontent.com",
        ],
        profile_urls: [
          "https://misskey.io/@",
          "https://misskey.io/users/",
          "https://misskey.io/user-info/",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://misskey.io/notes/9bxaf592x6#pswp",
                             page_url: "https://misskey.io/notes/9bxaf592x6",)

      url_parser_should_work("https://misskey.io/user-info/9bpemdns40",
                             profile_url: "https://misskey.io/users/9bpemdns40",)

      url_parser_should_work("https://misskey.io/@ixy194", user_id: nil)
      url_parser_should_work("https://misskey.io/@ixy194", username: "ixy194")
      url_parser_should_work("https://misskey.io/users/9bpemdns40", user_id: "9bpemdns40")
      url_parser_should_work("https://misskey.io/users/9bpemdns40", username: nil)
    end
  end
end
