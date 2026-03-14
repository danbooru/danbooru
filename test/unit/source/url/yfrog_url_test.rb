require "test_helper"

module Source::Tests::URL
  class YfrogUrlTest < ActiveSupport::TestCase
    context "when extracting attributes" do
      url_parser_should_work(
        "http://yfrog.com/gyi1smoj",
        page_url: "http://yfrog.com/gyi1smoj",
      )

      url_parser_should_work(
        "http://twitter.yfrog.com/z/oe3umiifj",
        page_url: "http://yfrog.com/oe3umiifj",
      )

      url_parser_should_work(
        "http://yfrog.com/user/0128sinonome/photos",
        profile_url: "http://yfrog.com/user/0128sinonome/photos",
      )
    end
  end
end
