require "test_helper"

module Source::Tests::URL
  class DoujinantenaUrlTest < ActiveSupport::TestCase
    context "when extracting attributes" do
      url_parser_should_work(
        "http://sozai.doujinantena.com/contents_jpg/d6c39f09d435e32c221e4ef866eceba4/015.jpg",
        page_url: "http://doujinantena.com/page.php?id=d6c39f09d435e32c221e4ef866eceba4",
      )
    end
  end
end
