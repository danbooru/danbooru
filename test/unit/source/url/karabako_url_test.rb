require "test_helper"

module Source::Tests::URL
  class KarabakoUrlTest < ActiveSupport::TestCase
    context "when extracting attributes" do
      url_parser_should_work(
        "http://www.karabako.net/images/karabako_38835.jpg",
        page_url: "http://www.karabako.net/post/view/38835",
      )
    end
  end
end
