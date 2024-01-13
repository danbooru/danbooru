require 'test_helper'

module Sources
  class InkbunnyTest < ActiveSupport::TestCase
    context "A submission url" do
      strategy_should_work(
        "https://inkbunny.net/s/2973731-p2-#pictop",
        page_url: "https://inkbunny.net/s/2973731",
        image_urls: %w[
          https://nl.ib.metapix.net/files/full/4441/4441953_Yupa_25-1.jpg
          https://nl.ib.metapix.net/files/full/4441/4441954_Yupa_25-2.jpg
          https://nl.ib.metapix.net/files/full/4441/4441955_Yupa_25-3.jpg
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
        dtext_artist_commentary_desc: "commission work for \n\t\t\t\t\t\"Okamii\":[https://inkbunny.net/Okamii]\n\nThank you!"
      )
    end

    context "A direct image url" do
      strategy_should_work(
        "https://nl.ib.metapix.net/files/full/4441/4441954_Yupa_25-2.jpg",
        image_urls: %w[
          https://nl.ib.metapix.net/files/full/4441/4441954_Yupa_25-2.jpg
        ],
        media_files: [{ file_size: 506_992 }],
        profile_url: nil
      )
    end

    should "Parse Inkbunny URLs correctly" do
      assert(Source::URL.image_url?("https://nl.ib.metapix.net/files/preview/4816/4816665_DAGASI_1890.12.jpg"))
      assert(Source::URL.image_url?("https://nl.ib.metapix.net/files/full/4816/4816665_DAGASI_1890.12.png"))

      assert(Source::URL.page_url?("https://inkbunny.net/s/3200751"))
      assert_equal("https://inkbunny.net/s/3200751", Source::URL.page_url("https://inkbunny.net/s/3200751"))
      assert_equal("https://inkbunny.net/s/3200751", Source::URL.page_url("https://inkbunny.net/s/3200751-p1-"))
      assert_equal("https://inkbunny.net/s/3200751", Source::URL.page_url("https://inkbunny.net/submissionview.php?id=3200751"))

      assert(Source::URL.profile_url?("https://inkbunny.net/DAGASI"))
      assert(Source::URL.profile_url?("https://inkbunny.net/user.php?user_id=152800"))

      assert_not(Source::URL.profile_url?("https://inkbunny.net/index.php"))
      assert_not(Source::URL.profile_url?("https://inkbunny.net/user.php"))
      assert_not(Source::URL.profile_url?("https://inkbunny.net/profile.php"))

      assert_nil(Source::URL.parse("https://inkbunny.net/DAGASI").user_id)
      assert_equal("DAGASI", Source::URL.parse("https://inkbunny.net/DAGASI").username)

      assert_equal(152800, Source::URL.parse("https://inkbunny.net/user.php?user_id=152800").user_id)
      assert_nil(Source::URL.parse("https://inkbunny.net/user.php?user_id=152800").username)
    end
  end
end
