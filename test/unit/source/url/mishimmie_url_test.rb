require "test_helper"

module Source::Tests::URL
  class MishimmieUrlTest < ActiveSupport::TestCase
    context "when extracting attributes" do
      url_parser_should_work(
        "http://shimmie.katawa-shoujo.com/image/2740.png",
        page_url: "https://shimmie.katawa-shoujo.com/post/view/2740",
      )
    end
  end
end
