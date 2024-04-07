require 'test_helper'

module Sources
  class MisskeyTest < ActiveSupport::TestCase
    context "A https://misskey.io/notes/:note_id url" do
      strategy_should_work(
        "https://misskey.io/notes/9bxaf592x6",
        page_url: "https://misskey.io/notes/9bxaf592x6",
        image_urls: [
          "https://media.misskeyusercontent.jp/misskey/7d2adf4a-b2dd-40b4-ba27-916e44f7bd48.png",
        ],
        media_files: [
          { file_size: 197_151 },
        ],
        profile_url: "https://misskey.io/@ixy194",
        profile_urls: [
          "https://misskey.io/@ixy194",
          "https://misskey.io/users/9bpemdns40",
        ],
        artist_name: "Ｉｘｙ（いくしー）",
        tag_name: "ixy194",
        tags: ["村上さん"],
        dtext_artist_commentary_desc: <<~EOS.chomp
          村上さん "#村上さん":[https://misskey.io/tags/村上さん] 村上アート
        EOS
      )
    end

    context "A note with multiple files" do
      strategy_should_work(
        "https://misskey.io/notes/9e5pggsolw",
        image_urls: [
          "https://media.misskeyusercontent.jp/misskey/c6909d66-9f53-4050-b46d-643d266995c7.jpg",
          "https://media.misskeyusercontent.jp/misskey/08e1b86c-0d5e-4391-9b02-125a5f7f4794.jpg",
        ],
        media_files: [
          { file_size: 81_793 },
          { file_size: 80_996 },
        ],
      )
    end

    context "A note without any files" do
      strategy_should_work(
        "https://misskey.io/notes/9ef8xtot2m",
        image_urls: [],
      )
    end

    context "A note with content warning" do
      strategy_should_work(
        "https://misskey.io/notes/9eh2m7ir57",
        dtext_artist_commentary_desc: <<~EOS.chomp
          RNしてくれたフォロワーさんの第一印象を答えます！
          (知らねぇやつばっかだからプロフィールとアイコンと直近のノートを参照しよう…。)
        EOS
      )
    end

    context "A s3.arkjp.net direct image url" do
      strategy_should_work(
        "https://s3.arkjp.net/misskey/99ae6116-2896-4cf3-9abc-e9746cd2408e.jpg",
        image_urls: ["https://s3.arkjp.net/misskey/99ae6116-2896-4cf3-9abc-e9746cd2408e.jpg"],
        media_files: [{ file_size: 100_766 }],
        profile_url: nil
      )
    end

    context "A media.misskeyusercontent.jp direct image url" do
      strategy_should_work(
        "https://media.misskeyusercontent.jp/io/webpublic-806fd8e2-3425-486f-975e-2fb57d8e651a.png",
        image_urls: ["https://media.misskeyusercontent.jp/io/webpublic-806fd8e2-3425-486f-975e-2fb57d8e651a.png"],
        media_files: [{ file_size: 386_451 }]
      )
    end

    context "A files.misskey.art direct image url" do
      strategy_should_work(
        "https://files.misskey.art//webpublic-94d9354f-ddba-406b-b878-4ce02ccfa505.webp",
        image_urls: ["https://files.misskey.art//webpublic-94d9354f-ddba-406b-b878-4ce02ccfa505.webp"],
        media_files: [{ file_size: 35_338 }]
      )
    end

    context "A file.misskey.design direct image url" do
      strategy_should_work(
        "https://file.misskey.design/post/webpublic-ac7072e9-812f-460b-ad24-1f303a62f0b4.webp",
        image_urls: ["https://file.misskey.design/post/webpublic-ac7072e9-812f-460b-ad24-1f303a62f0b4.webp"],
        media_files: [{ file_size: 188_294 }]
      )
    end

    should "Parse Misskey URLs correctly" do
      assert(Source::URL.image_url?("https://s3.arkjp.net/misskey/thumbnail-10c4379a-b999-4148-9d32-7bb6f22453bf.webp"))
      assert(Source::URL.image_url?("https://s3.arkjp.net/misskey/7d2adf4a-b2dd-40b4-ba27-916e44f7bd48.png"))
      assert(Source::URL.image_url?("https://media.misskeyusercontent.jp/io/dfca7bd4-c073-4ea0-991f-313ab3a77847.png"))
      assert(Source::URL.image_url?("https://media.misskeyusercontent.com/io/thumbnail-e9f307e4-3fad-435f-91b6-3768d688491d.webp"))
      assert(Source::URL.image_url?("https://media.misskeyusercontent.com/io/webpublic-a2cdd9c7-0449-4a61-b453-b5c7b2134677.png"))
      assert(Source::URL.image_url?("https://proxy.misskeyusercontent.com/image.webp?url=https%3A%2F%2Fimg.pawoo.net%2Fmedia_attachments%2Ffiles%2F111%2F232%2F575%2F490%2F284%2F147%2Foriginal%2F9aaf0c71a41b5647.jpeg"))
      assert(Source::URL.image_url?("https://media.misskeyusercontent.com/misskey/7d2adf4a-b2dd-40b4-ba27-916e44f7bd48.png"))
      assert(Source::URL.image_url?("https://nos3.arkjp.net/image.webp?url=https%3A%2F%2Fimg.pawoo.net%2Fmedia_attachments%2Ffiles%2F110%2F314%2F466%2F230%2F358%2F806%2Foriginal%2F6fbcc38659d3cb97.jpeg"))
      assert(Source::URL.image_url?("https://s3.arkjp.net/misskey/930fe4fb-c07b-4439-804e-06fb472d698f.gif"))
      assert(Source::URL.image_url?("https://files.misskey.art//webpublic-94d9354f-ddba-406b-b878-4ce02ccfa505.webp"))
      assert(Source::URL.image_url?("https://file.misskey.design/post/webpublic-ac7072e9-812f-460b-ad24-1f303a62f0b4.webp"))

      assert(Source::URL.page_url?("https://misskey.io/notes/9bxaf592x6"))
      assert_equal("https://misskey.io/notes/9bxaf592x6", Source::URL.page_url("https://misskey.io/notes/9bxaf592x6#pswp"))

      assert(Source::URL.profile_url?("https://misskey.io/@ixy194"))
      assert(Source::URL.profile_url?("https://misskey.io/users/9bpemdns40"))
      assert_equal("https://misskey.io/users/9bpemdns40", Source::URL.profile_url("https://misskey.io/user-info/9bpemdns40"))

      assert_not(Source::URL.profile_url?("https://misskey.io/@"))
      assert_not(Source::URL.profile_url?("https://misskey.io/users/"))
      assert_not(Source::URL.profile_url?("https://misskey.io/user-info/"))

      assert_nil(Source::URL.parse("https://misskey.io/@ixy194").user_id)
      assert_equal("ixy194", Source::URL.parse("https://misskey.io/@ixy194").username)

      assert_equal("9bpemdns40", Source::URL.parse("https://misskey.io/users/9bpemdns40").user_id)
      assert_nil(Source::URL.parse("https://misskey.io/users/9bpemdns40").username)
    end
  end
end
