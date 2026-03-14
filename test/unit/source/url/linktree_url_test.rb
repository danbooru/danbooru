require "test_helper"

module Source::Tests::URL
  class LinktreeUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        profile_urls: [
          "https://linktr.ee/cxlinray",
          "https://linktr.ee/seamonkey_op?utm_source=linktree_admin_share",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work(
        "https://linktr.ee/cxlinray",
        profile_url: "https://linktr.ee/cxlinray",
      )
    end
  end
end
