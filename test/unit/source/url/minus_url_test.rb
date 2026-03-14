require "test_helper"

module Source::Tests::URL
  class MinusUrlTest < ActiveSupport::TestCase
    context "Minus URLs" do
      should parse_url("http://i1.minus.com/ibb0DuE2Ds0yE6.jpg").into(
        page_url: "http://minus.com/i/bb0DuE2Ds0yE6",
      )
    end
  end
end
