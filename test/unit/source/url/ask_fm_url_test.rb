require "test_helper"

module Source::Tests::URL
  class AskFmUrlTest < ActiveSupport::TestCase
    context "AskFm URLs" do
      should be_profile_url(
        "https://ask.fm/kiminaho",
        "https://m.ask.fm/kiminaho",
        "http://ask.fm/cyoooooon/best",
      )
    end

    should parse_url("https://ask.fm/kiminaho").into(site_name: "Ask.fm")
  end
end
