require "test_helper"

module Source::Tests::URL
  class MarshamllowUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        profile_urls: %w[
          https://marshmallow-qa.com/horyu999
          https://marshmallow-qa.com/horyu999#new_message
          https://marshmallow-qa.com/horyu999?__cf_chl_tk=t4HJ3WYtKYRPgaj9I_byIFndn.5yeDMykvz4333hj6I-1751918588-1.0.1.1-Y43O5_VrRFTno5n527UGp2VYR6kpNgqmITsiuy6Khe0
        ],
      )

      should_not_find_false_positives(
        profile_urls: %w[
          https://marshmallow-qa.com/messages
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work(
        "https://marshmallow-qa.com/horyu999?__cf_chl_tk=t4HJ3WYtKYRPgaj9I_byIFndn.5yeDMykvz4333hj6I-1751918588-1.0.1.1-Y43O5_VrRFTno5n527UGp2VYR6kpNgqmITsiuy6Khe0",
        profile_url: "https://marshmallow-qa.com/horyu999",
      )
    end
  end
end
