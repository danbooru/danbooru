require "test_helper"

module Source::Tests::URL
  class MishimmieUrlTest < ActiveSupport::TestCase
    context "Mishimmie URLs" do
      should parse_url("http://shimmie.katawa-shoujo.com/image/2740.png").into(
        page_url: "https://shimmie.katawa-shoujo.com/post/view/2740",
      )
    end
  end
end
