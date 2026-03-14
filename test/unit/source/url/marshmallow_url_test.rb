require "test_helper"

module Source::Tests::URL
  class MarshmallowUrlTest < ActiveSupport::TestCase
    context "Marshmallow URLs" do
      should be_profile_url(
        "https://marshmallow-qa.com/horyu999",
        "https://marshmallow-qa.com/horyu999#new_message",
        "https://marshmallow-qa.com/horyu999?__cf_chl_tk=t4HJ3WYtKYRPgaj9I_byIFndn.5yeDMykvz4333hj6I-1751918588-1.0.1.1-Y43O5_VrRFTno5n527UGp2VYR6kpNgqmITsiuy6Khe0",
      )

      should_not be_profile_url(
        "https://marshmallow-qa.com/messages",
      )

      should parse_url("https://marshmallow-qa.com/horyu999?__cf_chl_tk=t4HJ3WYtKYRPgaj9I_byIFndn.5yeDMykvz4333hj6I-1751918588-1.0.1.1-Y43O5_VrRFTno5n527UGp2VYR6kpNgqmITsiuy6Khe0").into(
        profile_url: "https://marshmallow-qa.com/horyu999",
      )
    end
  end
end
