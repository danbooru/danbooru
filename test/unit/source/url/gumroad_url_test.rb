require "test_helper"

module Source::Tests::URL
  class GumroadUrlTest < ActiveSupport::TestCase
    context "Gumroad URLs" do
      should be_image_url(
        "https://public-files.gumroad.com/zc2289rdv8fx905pgaikh40fsle2",
        "https://public-files.gumroad.com/variants/nsqiekm8gnl5nfrw3mtthminn2ig/e82ce07851bf15f5ab0ebde47958bb042197dbcdcae02aa122ef3f5b41e97c02",
      )

      should be_page_url(
        "https://aiki.gumroad.com/l/HelmV2T3?layout=profile",
        "https://gumroad.com/l/HelmV2T3?layout=profile",
        "https://www.gumroad.com/l/HelmV2T3?layout=profile",
      )

      should be_profile_url(
        "https://gumroad.com/aiki",
        "https://www.gumroad.com/aiki",
        "https://aiki.gumroad.com",
      )
    end
  end
end
