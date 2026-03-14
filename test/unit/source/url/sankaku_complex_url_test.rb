require "test_helper"

module Source::Tests::URL
  class SankakuComplexUrlTest < ActiveSupport::TestCase
    context "Sankaku Complex URLs" do
      should parse_url("http://cs.sankakucomplex.com/data/sample/c2/d7/sample-c2d7270b84ac81326384d4eadd4d4746.jpg?2738848").into(
        page_url: "https://chan.sankakucomplex.com/post/show?md5=c2d7270b84ac81326384d4eadd4d4746",
      )
    end
  end
end
