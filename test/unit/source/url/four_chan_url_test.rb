require "test_helper"

module Source::Tests::URL
  class FourChanUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://i.4cdn.org/vt/1668729957824814.webm",
          "https://i.4cdn.org/vt/1668729957824814s.jpg",
          "https://is2.4chan.org/vg/1663135782567622.jpg",
          "http://is.4chan.org/vp/1483914199051.jpg",
          "http://images.4chan.org/vg/src/1378607754334.jpg",
          "http://orz.4chan.org/e/src/1202811803217.png",
          "http://zip.4chan.org/a/src/1201922408724.jpg",
          "http://cgi.4chan.org/r/src/1210870653551.jpg",
          "http://img.4chan.org/b/src/1226194386317.jpg",
          "http://cgi.4chan.org/f/src/Zone_Peach.swf",
          "https://s.4cdn.org/image/contests/4chan_vtuber_winner_2018.jpg",
        ],
        page_urls: [
          "https://boards.4channel.org/vt/thread/37293562#p37294005",
          "http://boards.4chan.org/a/res/41938201",
          "http://zip.4chan.org/jp/res/3598845.html",
        ],
      )
    end
  end
end
