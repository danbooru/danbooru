require "test_helper"

module Source::URL::Tests
  class AniftyParserTest < ActiveSupport::TestCase
    context "for image urls" do
      should_recognize_image_urls(
        "https://anifty.imgix.net/creation/0x961d09077b4a9f7a27f6b7ee78cb4c26f0e72c18/20d5ce5b5163a71258e1d0ee152a0347bf40c7da.png?w=660&h=660&fit=crop&crop=focalpoint&fp-x=0.76&fp-y=0.5&fp-z=1&auto=compress",
        "https://storage.googleapis.com/anifty-media/creation/0x961d09077b4a9f7a27f6b7ee78cb4c26f0e72c18/20d5ce5b5163a71258e1d0ee152a0347bf40c7da.png",
      )
    end

    context "for page urls" do
      should_recognize_page_urls(
        "https://anifty.jp/creations/373",
      )
    end

    context "for profile urls" do
      should_recognize_profile_urls(
        "https://anifty.jp/@hightree",
      )
    end
  end
end
