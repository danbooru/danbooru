require "test_helper"

module Source::Tests::URL
  class DoujinantenaUrlTest < ActiveSupport::TestCase
    context "Doujinantena URLs" do
      should parse_url("http://sozai.doujinantena.com/contents_jpg/d6c39f09d435e32c221e4ef866eceba4/015.jpg").into(
        page_url: "http://doujinantena.com/page.php?id=d6c39f09d435e32c221e4ef866eceba4",
      )
    end
  end
end
