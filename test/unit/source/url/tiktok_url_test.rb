require "test_helper"

module Source::Tests::URL
  class TiktokUrlTest < ActiveSupport::TestCase
    context "when extracting attributes" do
      url_parser_should_work(
        "https://www.tiktok.com/@ajmarekart?_t=ZM-8wmxRtoZXjq&_r=1",
        profile_url: "https://www.tiktok.com/@ajmarekart",
      )

      url_parser_should_work(
        "https://www.tiktok.com/@lenn0n__?",
        profile_url: "https://www.tiktok.com/@lenn0n__",
      )

      url_parser_should_work(
        "https://www.tiktok.com/@h.panda_12",
        profile_url: "https://www.tiktok.com/@h.panda_12",
      )
    end
  end
end
