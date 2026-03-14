require "test_helper"

module Source::Tests::URL
  class AllmylinksUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        profile_urls: [
          "https://allmylinks.com/hieumayart",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work(
        "https://allmylinks.com/hieumayart",
        profile_url: "https://allmylinks.com/hieumayart",
      )
    end
  end
end
