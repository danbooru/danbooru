require 'test_helper'

module Sources
  class MisskeyTest < ActiveSupport::TestCase
    context "A https://misskey.io/notes/:note_id url" do
      strategy_should_work(
        "https://misskey.io/notes/9bxaf592x6",
        page_url: "https://misskey.io/notes/9bxaf592x6",
        image_urls: [
          "https://s3.arkjp.net/misskey/7d2adf4a-b2dd-40b4-ba27-916e44f7bd48.png",
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
          村上さん #村上さん　村上アート
        EOS
      )
    end

    context "A note with multiple files" do
      strategy_should_work(
        "https://misskey.io/notes/9e5pggsolw",
        image_urls: [
          "https://s3.arkjp.net/misskey/c6909d66-9f53-4050-b46d-643d266995c7.jpg",
          "https://s3.arkjp.net/misskey/08e1b86c-0d5e-4391-9b02-125a5f7f4794.jpg",
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

    context "A direct image url" do
      strategy_should_work(
        "https://s3.arkjp.net/misskey/99ae6116-2896-4cf3-9abc-e9746cd2408e.jpg",
        image_urls: ["https://s3.arkjp.net/misskey/99ae6116-2896-4cf3-9abc-e9746cd2408e.jpg"],
        media_files: [{ file_size: 100_766 }],
        profile_url: nil
      )
    end

    should "Parse Misskey URLs correctly" do
      assert(Source::URL.image_url?("https://s3.arkjp.net/misskey/thumbnail-10c4379a-b999-4148-9d32-7bb6f22453bf.webp"))
      assert(Source::URL.image_url?("https://s3.arkjp.net/misskey/7d2adf4a-b2dd-40b4-ba27-916e44f7bd48.png"))

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
