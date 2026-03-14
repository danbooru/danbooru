require "test_helper"

module Source::Tests::URL
  class AskFmUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        profile_urls: [
          "https://ask.fm/kiminaho",
          "https://m.ask.fm/kiminaho",
          "http://ask.fm/cyoooooon/best",
        ],
      )
    end
  end
end
