require "test_helper"

module Source::Tests::Extractor
  class InkbunnyExtractorTest < ActiveSupport::TestCase
    context "A submission url" do
      strategy_should_work(
        "https://inkbunny.net/s/2973731-p2-#pictop",
        page_url: "https://inkbunny.net/s/2973731",
        image_urls: [
          %r{https://\w+.ib.metapix.net/files/full/4441/4441953_Yupa_25-1.jpg},
          %r{https://\w+.ib.metapix.net/files/full/4441/4441954_Yupa_25-2.jpg},
          %r{https://\w+.ib.metapix.net/files/full/4441/4441955_Yupa_25-3.jpg},
        ],
        media_files: [
          { file_size: 500_463 },
          { file_size: 506_992 },
          { file_size: 509_096 },
        ],
        profile_url: "https://inkbunny.net/Yupa",
        profile_urls: [
          "https://inkbunny.net/Yupa",
          "https://inkbunny.net/user.php?user_id=483689",
        ],
        artist_name: "Yupa",
        tag_name: "yupa",
        tags: ["cub", "cum", "cum in pussy", "cum inside", "cumming", "female", "fox", "furry", "girl", "nude", "pussy", "underwear"],
        dtext_artist_commentary_desc: <<~EOS.chomp,
          commission work for "Okamii":[https://inkbunny.net/Okamii]

          Thank you!
        EOS
      )
    end

    context "A direct image url" do
      strategy_should_work(
        "https://tx.ib.metapix.net/files/full/4441/4441954_Yupa_25-2.jpg",
        image_urls: %w[https://tx.ib.metapix.net/files/full/4441/4441954_Yupa_25-2.jpg],
        media_files: [{ file_size: 506_992 }],
        page_url: nil,
      )
    end

    context "A stale session ID should automatically refresh the session ID" do
      setup do
        Cache.put("inkbunny-session-id", "invalid")
      end

      strategy_should_work(
        "https://inkbunny.net/s/2973731-p2-#pictop",
        page_url: "https://inkbunny.net/s/2973731",
        image_urls: [
          %r{https://\w+.ib.metapix.net/files/full/4441/4441953_Yupa_25-1.jpg},
          %r{https://\w+.ib.metapix.net/files/full/4441/4441954_Yupa_25-2.jpg},
          %r{https://\w+.ib.metapix.net/files/full/4441/4441955_Yupa_25-3.jpg},
        ],
        profile_url: "https://inkbunny.net/Yupa",
        artist_name: "Yupa",
      )
    end
  end
end
