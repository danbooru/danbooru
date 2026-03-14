require "test_helper"

module Source::Tests::URL
  class SankakuComplexUrlTest < ActiveSupport::TestCase
    context "when extracting attributes" do
      url_parser_should_work(
        "http://cs.sankakucomplex.com/data/sample/c2/d7/sample-c2d7270b84ac81326384d4eadd4d4746.jpg?2738848",
        page_url: "https://chan.sankakucomplex.com/post/show?md5=c2d7270b84ac81326384d4eadd4d4746",
      )
    end
  end
end
