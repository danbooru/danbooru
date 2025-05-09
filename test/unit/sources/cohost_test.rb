# frozen_string_literal: true

require "test_helper"

module Sources
  class CohostTest < ActiveSupport::TestCase
    context "Cohost:" do
      should "parse URLs correctly" do
        assert(Source::URL.image_url?("https://staging.cohostcdn.org/attachment/e70670fc-591b-4f66-b4e9-75938adaa1dd/245_evil_nigiri.png?width=675&auto=webp&dpr=1"))
        assert(Source::URL.image_url?("https://staging.cohostcdn.org/header/42892-7cd2e652-82fd-464d-b544-4bdd4bea429a-profile.jpeg"))
        assert(Source::URL.image_url?("https://staging.cohostcdn.org/avatar/42892-471e51cc-d0d5-4e86-a52c-eec635fc4a2c-profile.gif?dpr=2&width=80&height=80&fit=cover&auto=webp"))

        assert(Source::URL.page_url?("https://cohost.org/Karuu/post/2605252-nigiri-evil"))

        assert(Source::URL.profile_url?("https://cohost.org/Karuu"))

        assert_equal("https://cohost.org/Karuu", Source::URL.profile_url("https://cohost.org/Karuu/post/2605252-nigiri-evil"))
      end
    end
  end
end
