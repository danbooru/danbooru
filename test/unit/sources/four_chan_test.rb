require "test_helper"

module Sources
  class FourChanTest < ActiveSupport::TestCase
    context "A 4chan source extractor" do
      context "A 4chan direct image url without a referer" do
        strategy_should_work(
          "https://i.4cdn.org/vt/1611919211191.jpg",
          image_urls: ["https://i.4cdn.org/vt/1611919211191.jpg"],
          page_url: nil,
          artist_commentary_title: nil,
          artist_commentary_desc: nil,
          dtext_artist_commentary_desc: "",
          download_size: 145_602,
        )
      end

      context "A 4chan direct image url with a referer" do
        strategy_should_work(
          "https://i.4cdn.org/vt/1611919211191.jpg",
          referer: "https://boards.4channel.org/vt/thread/1",
          image_urls: ["https://i.4cdn.org/vt/1611919211191.jpg"],
          page_url: "https://boards.4channel.org/vt/thread/1#p1",
          artist_commentary_title: "Anonymous 01/29/21(Fri)06:20:11 No.1",
          dtext_artist_commentary_desc: <<~EOS.chomp,
            "vt.jpg":[https://i.4cdn.org/vt/1611919211191.jpg] (142 KB, 767x677)
            This board is for the discussion of Virtual YouTubers ("VTubers"), including those streaming in Japanese, English, and other languages. VTubers don't necessarily need to be on Youtube of course, they can be on Twitch, Niconico, Bilibili, or any other platform.

            Please note that discussion should pertain to a VTuber's streams and content, and should not pertain to their real lives, relationships, or appearances ("IRL").
          EOS
          download_size: 145_602,
        )
      end

      context "A 4chan thumbnail image url without a referer" do
        strategy_should_work(
          "https://i.4cdn.org/vt/1611919211191s.jpg",
          image_urls: ["https://i.4cdn.org/vt/1611919211191s.jpg"],
          page_url: nil,
          artist_commentary_title: nil,
          artist_commentary_desc: nil,
          dtext_artist_commentary_desc: "",
          download_size: 7430,
        )
      end

      context "A 4chan post url" do
        strategy_should_work(
          "https://boards.4channel.org/vt/thread/1#p1",
          image_urls: ["https://i.4cdn.org/vt/1611919211191.jpg"],
          page_url: "https://boards.4channel.org/vt/thread/1#p1",
          artist_commentary_title: "Anonymous 01/29/21(Fri)06:20:11 No.1",
          dtext_artist_commentary_desc: <<~EOS.chomp,
            "vt.jpg":[https://i.4cdn.org/vt/1611919211191.jpg] (142 KB, 767x677)
            This board is for the discussion of Virtual YouTubers ("VTubers"), including those streaming in Japanese, English, and other languages. VTubers don't necessarily need to be on Youtube of course, they can be on Twitch, Niconico, Bilibili, or any other platform.

            Please note that discussion should pertain to a VTuber's streams and content, and should not pertain to their real lives, relationships, or appearances ("IRL").
          EOS
          download_size: 145_602,
        )
      end

      context "A 4chan thread url" do
        strategy_should_work(
          "https://boards.4channel.org/vt/thread/1",
          image_urls: ["https://i.4cdn.org/vt/1611919211191.jpg"],
          page_url: "https://boards.4channel.org/vt/thread/1",
          download_size: 145_602,
        )
      end
    end
  end
end
