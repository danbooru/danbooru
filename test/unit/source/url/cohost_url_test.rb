require "test_helper"

module Source::Tests::URL
  class CohostUrlTest < ActiveSupport::TestCase
    context "Cohost URLs" do
      should be_image_url(
        "https://staging.cohostcdn.org/attachment/e70670fc-591b-4f66-b4e9-75938adaa1dd/245_evil_nigiri.png?width=675&auto=webp&dpr=1",
        "https://staging.cohostcdn.org/header/42892-7cd2e652-82fd-464d-b544-4bdd4bea429a-profile.jpeg",
        "https://staging.cohostcdn.org/avatar/42892-471e51cc-d0d5-4e86-a52c-eec635fc4a2c-profile.gif?dpr=2&width=80&height=80&fit=cover&auto=webp",
        "https://cohost.org/rc/default-avatar/246987.png?dpr=2&width=80&height=80&fit=cover&auto=webp",
      )

      should be_page_url(
        "https://cohost.org/Karuu/post/2605252-nigiri-evil",
      )

      should be_profile_url(
        "https://cohost.org/Karuu",
      )

      should parse_url("https://cohost.org/Karuu/post/2605252-nigiri-evil").into(
        profile_url: "https://cohost.org/Karuu",
      )
    end
  end
end
