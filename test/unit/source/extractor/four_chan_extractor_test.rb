require "test_helper"

module Source::Tests::Extractor
  class FourChanExtractorTest < ActiveSupport::ExtractorTestCase
    context "A 4chan direct image url without a referer" do
      strategy_should_work(
        "https://i.4cdn.org/vt/1745613423284732.jpg",
        image_urls: %w[https://i.4cdn.org/vt/1745613423284732.jpg],
        media_files: [{ file_size: 145_602 }],
        page_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A 4chan direct image url with a referer" do
      strategy_should_work(
        "https://i.4cdn.org/vt/1745613423284732.jpg",
        referer: "https://boards.4chan.org/vt/thread/99394683",
        image_urls: ["https://i.4cdn.org/vt/1745613423284732.jpg"],
        media_files: [{ file_size: 145_602 }],
        page_url: "https://boards.4chan.org/vt/thread/99394683#p99394683",
        profile_urls: [],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "Anonymous 04/25/25(Fri)16:37:03 No.99394683",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "vt.jpg":[https://i.4cdn.org/vt/1745613423284732.jpg] (142 KB, 767x677)
          This board is for the discussion of Virtual YouTubers ("VTubers"), including those streaming in Japanese, English, and other languages. VTubers don't necessarily need to be on Youtube of course, they can be on Twitch, Niconico, Bilibili, or any other platform.

          Please note that discussion should pertain to a VTuber's streams and content, and should not pertain to their real lives, relationships, or appearances ("IRL").
        EOS
      )
    end

    context "A 4chan thumbnail image url without a referer" do
      strategy_should_work(
        "https://i.4cdn.org/vt/1745613423284732s.jpg",
        image_urls: %w[https://i.4cdn.org/vt/1745613423284732s.jpg],
        media_files: [{ file_size: 7_421 }],
        page_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A 4chan post url" do
      strategy_should_work(
        "https://boards.4chan.org/vt/thread/99394683#p99394683",
        image_urls: %w[https://i.4cdn.org/vt/1745613423284732.jpg],
        media_files: [{ file_size: 145_602 }],
        page_url: "https://boards.4chan.org/vt/thread/99394683#p99394683",
        profile_urls: [],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "Anonymous 04/25/25(Fri)16:37:03 No.99394683",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "vt.jpg":[https://i.4cdn.org/vt/1745613423284732.jpg] (142 KB, 767x677)
          This board is for the discussion of Virtual YouTubers ("VTubers"), including those streaming in Japanese, English, and other languages. VTubers don't necessarily need to be on Youtube of course, they can be on Twitch, Niconico, Bilibili, or any other platform.

          Please note that discussion should pertain to a VTuber's streams and content, and should not pertain to their real lives, relationships, or appearances ("IRL").
        EOS
      )
    end

    context "A 4chan thread url" do
      strategy_should_work(
        "https://boards.4chan.org/vt/thread/99394683",
        image_urls: %w[https://i.4cdn.org/vt/1745613423284732.jpg],
        media_files: [{ file_size: 145_602 }],
        page_url: "https://boards.4chan.org/vt/thread/99394683",
        profile_urls: [],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end
  end
end
