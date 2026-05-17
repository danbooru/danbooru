require "test_helper"

module Source::Tests::URL
  class AllmylinksUrlTest < ActiveSupport::TestCase
    context "All My Links URLs" do
      should be_profile_url("https://allmylinks.com/hieumayart")

      should parse_url("https://allmylinks.com/hieumayart").into(profile_url: "https://allmylinks.com/hieumayart")
    end

    should parse_url("https://allmylinks.com/hieumayart").into(site_name: "AllMyLinks")
  end
end
