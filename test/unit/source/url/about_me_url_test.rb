require "test_helper"

module Source::Tests::URL
  class AboutMeUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://about.me/cdn-cgi/image/q=40,dpr=2,f=auto,fit=cover,w=120,h=120,gravity=auto/https://assets.about.me/background/users/s/g/r/sgr_sk_1369590004_43.jpg",
          "https://about.me/cdn-cgi/image/q=40,dpr=2,f=auto,fit=contain,w=1200,h=1799.9100044997751/https://assets.about.me/background/users/u/dot/n/u.no_1471830904_68.jpg",
          "https://assets.about.me/background/users/w/o/k/wokada156_1411467603_49.jpg",
        ],
        profile_urls: [
          "https://about.me/u.no",
          "https://about.me/sgr_sk",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work(
        "https://about.me/cdn-cgi/image/q=40,dpr=2,f=auto,fit=cover,w=120,h=120,gravity=auto/https://assets.about.me/background/users/s/g/r/sgr_sk_1369590004_43.jpg",
        profile_url: "https://about.me/sgr_sk",
      )

      url_parser_should_work(
        "https://about.me/cdn-cgi/image/q=40,dpr=2,f=auto,fit=contain,w=1200,h=1799.9100044997751/https://assets.about.me/background/users/u/dot/n/u.no_1471830904_68.jpg",
        profile_url: "https://about.me/u.no",
      )
    end
  end
end
