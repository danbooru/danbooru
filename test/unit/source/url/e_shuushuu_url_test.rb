require "test_helper"

module Source::Tests::URL
  class EShuushuuUrlTest < ActiveSupport::TestCase
    context "when extracting attributes" do
      url_parser_should_work(
        "http://e-shuushuu.net/images/2014-07-22-662472.png",
        page_url: "https://e-shuushuu.net/image/662472",
      )
    end
  end
end
