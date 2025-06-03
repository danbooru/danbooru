require "test_helper"

module Source::Tests::URL
  class CohostUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://staging.cohostcdn.org/attachment/e70670fc-591b-4f66-b4e9-75938adaa1dd/245_evil_nigiri.png?width=675&auto=webp&dpr=1",
          "https://staging.cohostcdn.org/header/42892-7cd2e652-82fd-464d-b544-4bdd4bea429a-profile.jpeg",
          "https://staging.cohostcdn.org/avatar/42892-471e51cc-d0d5-4e86-a52c-eec635fc4a2c-profile.gif?dpr=2&width=80&height=80&fit=cover&auto=webp",
          "https://cohost.org/rc/default-avatar/246987.png?dpr=2&width=80&height=80&fit=cover&auto=webp",
        ],
        page_urls: [
          "https://cohost.org/Karuu/post/2605252-nigiri-evil",
        ],
        profile_urls: [
          "https://cohost.org/Karuu",
        ],
      )
    end
    context "when extracting attributes" do
      url_parser_should_work("https://cohost.org/Karuu/post/2605252-nigiri-evil", profile_url: "https://cohost.org/Karuu")
    end
  end
end
