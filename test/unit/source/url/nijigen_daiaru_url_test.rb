require "test_helper"

module Source::Tests::URL
  class NijigenDaiaruUrlTest < ActiveSupport::TestCase
    context "when extracting attributes" do
      url_parser_should_work(
        "http://jpg.nijigen-daiaru.com/19909/029.jpg",
        page_url: "http://nijigen-daiaru.com/book.php?idb=19909",
      )
    end
  end
end
