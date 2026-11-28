require "test_helper"

module Source::Tests::URL
  class PixelJointUrlTest < ActiveSupport::TestCase
    context "Pixel Joint URLs" do
      should be_image_url(
        "https://pixeljoint.com/files/icons/full/cat__r16042437891.png",
        "https://pixeljoint.com/files/icons/cat_icon.png",
        "https://pixeljoint.com/files/icons/icon__r15732437891.png",
      )

      should be_image_sample(
        "https://pixeljoint.com/files/icons/cat_icon.png",
      )

      should_not be_image_sample(
        "https://pixeljoint.com/files/icons/full/cat__r16042437891.png",
      )

      should be_page_url(
        "https://pixeljoint.com/pixelart/165655.htm",
        "http://www.pixeljoint.com/pixelart/165655.htm",
      )

      should be_profile_url(
        "https://pixeljoint.com/p/243789.htm",
        "https://pixeljoint.com/pixels/profile.asp?id=243789",
      )

      should_not be_page_url(
        "https://pixeljoint.com/pixelart/2003/Miscellaneous.htm",
      )

      should_not be_profile_url(
        "https://pixeljoint.com/pixels/profile.asp",
        "https://pixeljoint.com/pixels/profile.asp?id=abc",
      )
    end

    should parse_url("https://pixeljoint.com/files/icons/full/cat__r16042437891.png").into(site_name: "Pixel Joint")
    should parse_url("http://www.pixeljoint.com/pixelart/165655.htm").into(page_url: "https://pixeljoint.com/pixelart/165655.htm")
    should parse_url("https://pixeljoint.com/pixels/profile.asp?id=243789").into(profile_url: "https://pixeljoint.com/p/243789.htm")
  end
end
