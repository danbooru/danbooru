require "test_helper"

module Source::Tests::URL
  class AmebaUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        profile_urls: [
          "http://marilyn77.ameblo.jp/",
          "https://ameblo.jp/g8set55679",
          "http://ameblo.jp/hanauta-os/entry-11860045489.html",
          "http://stat.ameba.jp/user_images/20130802/21/moment1849/38/bd/p",
          "https://profile.ameba.jp/ameba/kbnr32rbfs",
        ],
      )
    end
  end
end
