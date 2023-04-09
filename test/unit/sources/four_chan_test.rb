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
          media_files: [{ file_size: 145_602 }],
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
          media_files: [{ file_size: 145_602 }],
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
          media_files: [{ file_size: 7430 }],
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
          media_files: [{ file_size: 145_602 }],
        )
      end

      context "A 4chan thread url" do
        strategy_should_work(
          "https://boards.4channel.org/vt/thread/1",
          image_urls: ["https://i.4cdn.org/vt/1611919211191.jpg"],
          page_url: "https://boards.4channel.org/vt/thread/1",
          media_files: [{ file_size: 145_602 }],
        )
      end
    end

    should "Parse 4chan URLs correctly" do
      assert(Source::URL.image_url?("https://i.4cdn.org/vt/1668729957824814.webm"))
      assert(Source::URL.image_url?("https://i.4cdn.org/vt/1668729957824814s.jpg"))
      assert(Source::URL.image_url?("https://is2.4chan.org/vg/1663135782567622.jpg"))
      assert(Source::URL.image_url?("http://is.4chan.org/vp/1483914199051.jpg"))
      assert(Source::URL.image_url?("http://images.4chan.org/vg/src/1378607754334.jpg"))
      assert(Source::URL.image_url?("http://orz.4chan.org/e/src/1202811803217.png"))
      assert(Source::URL.image_url?("http://zip.4chan.org/a/src/1201922408724.jpg"))
      assert(Source::URL.image_url?("http://cgi.4chan.org/r/src/1210870653551.jpg"))
      assert(Source::URL.image_url?("http://img.4chan.org/b/src/1226194386317.jpg"))
      assert(Source::URL.image_url?("http://cgi.4chan.org/f/src/Zone_Peach.swf"))
      assert(Source::URL.image_url?("https://s.4cdn.org/image/contests/4chan_vtuber_winner_2018.jpg"))

      assert(Source::URL.page_url?("https://boards.4channel.org/vt/thread/37293562#p37294005"))
      assert(Source::URL.page_url?("http://boards.4chan.org/a/res/41938201"))
      assert(Source::URL.page_url?("http://zip.4chan.org/jp/res/3598845.html"))
    end
  end
end
