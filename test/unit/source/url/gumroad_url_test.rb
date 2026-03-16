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
        "https://movw2000.gumroad.com/p/new-product-b072093e-e628-4a92-9740-e9b4564d9901",
      )

      should be_profile_url(
        "https://gumroad.com/aiki",
        "https://www.gumroad.com/aiki",
        "https://aiki.gumroad.com",
      )

      should parse_url("https://public-files.gumroad.com/zc2289rdv8fx905pgaikh40fsle2").into(
        full_image_url: "https://public-files.gumroad.com/zc2289rdv8fx905pgaikh40fsle2",
      )

      should parse_url("https://public-files.gumroad.com/variants/nsqiekm8gnl5nfrw3mtthminn2ig/e82ce07851bf15f5ab0ebde47958bb042197dbcdcae02aa122ef3f5b41e97c02").into(
        full_image_url: "https://public-files.gumroad.com/nsqiekm8gnl5nfrw3mtthminn2ig",
      )

      should parse_url("https://movw2000.gumroad.com/p/new-product-b072093e-e628-4a92-9740-e9b4564d9901").into(
        page_url: "https://movw2000.gumroad.com/p/new-product-b072093e-e628-4a92-9740-e9b4564d9901",
        profile_url: "https://movw2000.gumroad.com",
      )

      should parse_url("https://gum.co/dkvcip").into(
        page_url: nil,
      )
    end

    should parse_url("https://public-files.gumroad.com/zc2289rdv8fx905pgaikh40fsle2").into(site_name: "Gumroad")
  end
end
