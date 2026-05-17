require "test_helper"

module Source::Tests::URL
  class InkbunnyUrlTest < ActiveSupport::TestCase
    context "Inkbunny URLs" do
      should be_image_url(
        "https://nl.ib.metapix.net/files/preview/4816/4816665_DAGASI_1890.12.jpg",
        "https://nl.ib.metapix.net/files/full/4816/4816665_DAGASI_1890.12.png",
      )

      should be_page_url(
        "https://inkbunny.net/s/3200751",
      )

      should be_profile_url(
        "https://inkbunny.net/DAGASI",
        "https://inkbunny.net/user.php?user_id=152800",
      )

      should be_secondary_url(
        "https://inkbunny.net/user.php?user_id=152800",
      )

      should_not be_secondary_url(
        "https://inkbunny.net/DAGASI",
      )

      should_not be_profile_url(
        "https://inkbunny.net/index.php",
        "https://inkbunny.net/user.php",
        "https://inkbunny.net/profile.php",
      )

      should parse_url("https://inkbunny.net/s/3200751").into(page_url: "https://inkbunny.net/s/3200751")
      should parse_url("https://inkbunny.net/s/3200751-p1-").into(page_url: "https://inkbunny.net/s/3200751")
      should parse_url("https://inkbunny.net/submissionview.php?id=3200751").into(page_url: "https://inkbunny.net/s/3200751")

      should parse_url("https://inkbunny.net/DAGASI").into(username: "DAGASI", user_id: nil)
      should parse_url("https://inkbunny.net/user.php?user_id=152800").into(username: nil, user_id: 152_800)
    end

    should parse_url("https://nl.ib.metapix.net/files/preview/4816/4816665_DAGASI_1890.12.jpg").into(site_name: "Inkbunny")
  end
end
