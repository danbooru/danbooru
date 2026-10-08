require "test_helper"

module Source::Tests::URL
  class LitlinkUrlTest < ActiveSupport::TestCase
    context "Lit.link URLs" do
      should be_image_url(
        "https://prd.resource-api.lit.link/images/creators/f2075330-b16d-438f-aac6-8ec41a7278f2/icons/2cd35cc5-9353-4146-ae90-f30bb3c53388.jpeg",
      )

      should be_profile_url(
        "https://lit.link/upn2o",
        "https://lit.link/en/upn2o",
      )

      should_not be_profile_url("https://lit.link/foo/upn2o")
      should_not be_profile_url("https://prd.resource-api.lit.link/upn2o")

      should parse_url("https://lit.link/upn2o").into(
        site_name: "Lit.link",
        username: "upn2o",
        profile_url: "https://lit.link/upn2o",
      )

      should parse_url("https://lit.link/en/upn2o").into(
        site_name: "Lit.link",
        username: "upn2o",
        profile_url: "https://lit.link/upn2o",
      )

      should parse_url("https://prd.resource-api.lit.link/images/creators/f2075330-b16d-438f-aac6-8ec41a7278f2/icons/2cd35cc5-9353-4146-ae90-f30bb3c53388.jpeg").into(
        site_name: "Lit.link",
        username: nil,
        profile_url: nil,
      )
    end
  end
end
