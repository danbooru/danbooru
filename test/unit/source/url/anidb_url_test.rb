require "test_helper"

module Source::Tests::URL
  class AnidbUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        profile_urls: [
          "https://anidb.net/creator/65313",
          "https://anidb.net/perl-bin/animedb.pl?show=creator&creatorid=3903",
        ],
      )
    end
  end
end
