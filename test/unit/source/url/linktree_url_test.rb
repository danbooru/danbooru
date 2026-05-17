require "test_helper"

module Source::Tests::URL
  class LinktreeUrlTest < ActiveSupport::TestCase
    context "Linktree URLs" do
      should be_profile_url(
        "https://linktr.ee/cxlinray",
        "https://linktr.ee/seamonkey_op?utm_source=linktree_admin_share",
      )

      should parse_url("https://linktr.ee/cxlinray").into(
        profile_url: "https://linktr.ee/cxlinray",
      )
    end

    should parse_url("https://linktr.ee/cxlinray").into(site_name: "Linktree")
  end
end
