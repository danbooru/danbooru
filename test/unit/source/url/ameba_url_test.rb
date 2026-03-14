require "test_helper"

module Source::Tests::URL
  class AmebaUrlTest < ActiveSupport::TestCase
    context "Ameba URLs" do
      should be_profile_url(
        "http://marilyn77.ameblo.jp/",
        "https://ameblo.jp/g8set55679",
        "https://profile.ameba.jp/ameba/kbnr32rbfs",
      )

      should_eventually be_page_url("http://ameblo.jp/hanauta-os/entry-11860045489.html")
      should_eventually be_image_url("http://stat.ameba.jp/user_images/20130802/21/moment1849/38/bd/p")

      should parse_url("http://marilyn77.ameblo.jp/").into(
        username: "marilyn77",
        profile_url: "https://ameblo.jp/marilyn77",
      )

      should parse_url("https://ameblo.jp/g8set55679").into(
        username: "g8set55679",
        profile_url: "https://ameblo.jp/g8set55679",
      )

      should parse_url("http://ameblo.jp/hanauta-os/entry-11860045489.html").into(
        username: "hanauta-os",
        profile_url: "https://ameblo.jp/hanauta-os",
      )

      should parse_url("http://stat.ameba.jp/user_images/20130802/21/moment1849/38/bd/p").into(
        username: "moment1849",
        profile_url: "https://ameblo.jp/moment1849",
      )

      should parse_url("https://profile.ameba.jp/ameba/kbnr32rbfs").into(
        username: "kbnr32rbfs",
        profile_url: "https://ameblo.jp/kbnr32rbfs",
      )
    end
  end
end
