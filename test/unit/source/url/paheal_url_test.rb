require "test_helper"

module Source::Tests::URL
  class PahealUrlTest < ActiveSupport::TestCase
    context "when extracting attributes" do
      url_parser_should_work(
        "http://rule34-data-010.paheal.net/_images/854806addcd3b1246424e7cea49afe31/852405%20-%20Darkstalkers%20Felicia.jpg",
        page_url: "https://rule34.paheal.net/post/view/852405",
      )
    end
  end
end
