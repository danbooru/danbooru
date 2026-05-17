require "test_helper"

module Source::Tests::URL
  class AnidbUrlTest < ActiveSupport::TestCase
    context "Anidb URLs" do
      should be_profile_url(
        "https://anidb.net/creator/65313",
        "https://anidb.net/perl-bin/animedb.pl?show=creator&creatorid=3903",
      )
    end

    should parse_url("https://anidb.net/creator/65313").into(site_name: "AniDB")
  end
end
