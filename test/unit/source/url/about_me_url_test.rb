require "test_helper"

class Source::URL::AboutMeTest < ActiveSupport::TestCase
  context "About.me URLs" do
    should be_image_url(
      "https://about.me/cdn-cgi/image/q=40,dpr=2,f=auto,fit=cover,w=120,h=120,gravity=auto/https://assets.about.me/background/users/s/g/r/sgr_sk_1369590004_43.jpg",
      "https://about.me/cdn-cgi/image/q=40,dpr=2,f=auto,fit=contain,w=1200,h=1799.9100044997751/https://assets.about.me/background/users/u/dot/n/u.no_1471830904_68.jpg",
      "https://assets.about.me/background/users/w/o/k/wokada156_1411467603_49.jpg",
    )

    should be_profile_url(
      "https://about.me/u.no",
      "https://about.me/sgr_sk",
    )

    should parse_url("https://about.me/cdn-cgi/image/q=40,dpr=2,f=auto,fit=cover,w=120,h=120,gravity=auto/https://assets.about.me/background/users/s/g/r/sgr_sk_1369590004_43.jpg").into(
      profile_url: "https://about.me/sgr_sk",
    )

    should parse_url("https://about.me/cdn-cgi/image/q=40,dpr=2,f=auto,fit=contain,w=1200,h=1799.9100044997751/https://assets.about.me/background/users/u/dot/n/u.no_1471830904_68.jpg").into(
      profile_url: "https://about.me/u.no",
    )

    should parse_url("https://about.me/cdn-cgi/image/q=40").into(site_name: "About.me")
  end
end
