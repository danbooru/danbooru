require "test_helper"

module Source::Tests::URL
  class MinusUrlTest < ActiveSupport::TestCase
    context "when extracting attributes" do
      url_parser_should_work(
        "http://i1.minus.com/ibb0DuE2Ds0yE6.jpg",
        page_url: "http://minus.com/i/bb0DuE2Ds0yE6",
      )
    end
  end
end
