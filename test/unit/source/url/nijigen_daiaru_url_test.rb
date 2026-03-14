require "test_helper"

module Source::Tests::URL
  class NijigenDaiaruUrlTest < ActiveSupport::TestCase
    context "Nijigen Daiaru URLs" do
      should parse_url("http://jpg.nijigen-daiaru.com/19909/029.jpg").into(
        page_url: "http://nijigen-daiaru.com/book.php?idb=19909",
      )
    end
  end
end
