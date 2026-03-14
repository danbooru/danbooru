require "test_helper"

module Source::Tests::URL
  class UrlShortenerUrlTest < ActiveSupport::TestCase
    context "UrlShortener URLs" do
      should be_bad_source(
        "https://bit.ly/4aAVa4y",
        "http://j.mp/cKV0uf",
        "https://t.co/Dxn7CuVErW",
        "https://pic.twitter.com/Dxn7CuVErW",
      )
    end
  end
end
