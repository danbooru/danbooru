require "test_helper"

module Source::Tests::URL
  class PixellentUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://firebasestorage.googleapis.com/v0/b/pixellent.appspot.com/o/users%2FUbwtLvQnfEcV4d4IhAFztXXghR03%2Fposts%2Fs89Uq4Zwq8CVHQhpQ26B%2Fimages%2Fthumbnail-full.jpg?alt=media",
        ],
        page_urls: [
          "https://pixellent.me/p/s89Uq4Zwq8CVHQhpQ26B",
        ],
        profile_urls: [
          "https://pixellent.me/@u-UbwtLvQnfEcV4d4IhAFztXXghR03",
          "https://pixellent.me/@shina",
        ],
      )
    end
  end
end
