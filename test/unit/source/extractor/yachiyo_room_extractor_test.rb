require "test_helper"

module Source::Tests::Extractor
  class YachiyoRoomExtractorTest < ActiveSupport::ExtractorTestCase
    strategy_should_work(
      "https://yachiyo-room.com/oekaki/1059",
      image_urls: %w[https://d3icawwrjcmhat.cloudfront.net/prod/oekaki/1774796101015-w8euiu.png],
      media_files: [{ file_size: 226_810 }],
      page_url: "https://yachiyo-room.com/oekaki/1059",
      profile_url: "https://yachiyo-room.com/gallery?name=んぽょ。",
      profile_urls: %w[https://yachiyo-room.com/gallery?name=んぽょ。],
      display_name: "んぽょ。",
      username: nil,
      published_at: Time.parse("2026-03-29T14:55:01.000000+00:00"),
      updated_at: nil,
      tags: [
        ["ヤチヨ", "https://yachiyo-room//gallery?tag=1"],
      ],
      dtext_artist_commentary_title: "お花見ヤチヨ",
      dtext_artist_commentary_desc: "レイヤー機能実装につき能力解放",
    )

    strategy_should_work(
      "https://yachiyo-room.com/oekaki/5732",
      image_urls: %w[https://d3icawwrjcmhat.cloudfront.net/prod/oekaki/1779626778954-77gac5.png],
      media_files: [{ file_size: 18_151 }],
      page_url: "https://yachiyo-room.com/oekaki/5732",
      profile_url: "https://yachiyo-room.com/gallery?name=やっちょ推し",
      profile_urls: %w[https://yachiyo-room.com/gallery?name=やっちょ推し],
      display_name: "やっちょ推し",
      username: nil,
      published_at: Time.parse("2026-05-24T12:46:18.000000+00:00"),
      updated_at: nil,
      tags: [],
      dtext_artist_commentary_title: "",
      dtext_artist_commentary_desc: "",
    )

    strategy_should_work(
      "https://yachiyo-room.com/gallery?name=んぽょ。",
      image_urls: [],
      page_url: nil,
      profile_url: "https://yachiyo-room.com/gallery?name=んぽょ。",
      profile_urls: %w[https://yachiyo-room.com/gallery?name=んぽょ。],
      display_name: "んぽょ。",
      username: nil,
      published_at: nil,
      updated_at: nil,
      tags: [],
      dtext_artist_commentary_title: "",
      dtext_artist_commentary_desc: "",
    )

    strategy_should_work(
      "https://yachiyo-room.com/gallery?name=んぽょ。&name_mode=exact&from=2026-01-22",
      image_urls: [],
      page_url: nil,
      profile_url: "https://yachiyo-room.com/gallery?name=んぽょ。",
      profile_urls: %w[https://yachiyo-room.com/gallery?name=んぽょ。],
      display_name: "んぽょ。",
      username: nil,
      published_at: nil,
      updated_at: nil,
      tags: [],
      dtext_artist_commentary_title: "",
      dtext_artist_commentary_desc: "",
    )

    strategy_should_work(
      "https://d3icawwrjcmhat.cloudfront.net/prod/oekaki/1774796101015-w8euiu.png",
      image_urls: %w[https://d3icawwrjcmhat.cloudfront.net/prod/oekaki/1774796101015-w8euiu.png],
      media_files: [{ file_size: 226_810 }],
      page_url: nil,
      profile_url: nil,
      profile_urls: [],
      display_name: nil,
      username: nil,
      published_at: Time.parse("2026-03-29T14:55:01.000000+00:00"),
      updated_at: nil,
      tags: [],
      dtext_artist_commentary_title: "",
      dtext_artist_commentary_desc: "",
    )

    strategy_should_work(
      "https://d3icawwrjcmhat.cloudfront.net/prod/oekaki/1775314224027-0ql3na.png",
      image_urls: %w[https://d3icawwrjcmhat.cloudfront.net/prod/oekaki/1775314224027-0ql3na.png],
      media_files: [{ file_size: 55_578 }],
      page_url: nil,
      profile_url: nil,
      profile_urls: [],
      display_name: nil,
      username: nil,
      published_at: Time.parse("2026-04-04T14:50:24.000000+00:00"),
      updated_at: nil,
      tags: [],
      dtext_artist_commentary_title: "",
      dtext_artist_commentary_desc: "",
    )
  end
end
