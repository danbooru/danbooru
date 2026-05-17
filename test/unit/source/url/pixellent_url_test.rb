require "test_helper"

module Source::Tests::URL
  class PixellentUrlTest < ActiveSupport::TestCase
    context "Pixellent URLs" do
      should be_image_url(
        "https://firebasestorage.googleapis.com/v0/b/pixellent.appspot.com/o/users%2FUbwtLvQnfEcV4d4IhAFztXXghR03%2Fposts%2Fs89Uq4Zwq8CVHQhpQ26B%2Fimages%2Fthumbnail-full.jpg?alt=media",
      )

      should be_page_url(
        "https://pixellent.me/p/s89Uq4Zwq8CVHQhpQ26B",
      )

      should be_profile_url(
        "https://pixellent.me/@u-UbwtLvQnfEcV4d4IhAFztXXghR03",
        "https://pixellent.me/@shina",
      )
    end

    should parse_url("https://firebasestorage.googleapis.com/v0/b/pixellent.appspot.com/o/users%2FUbwtLvQnfEcV4d4IhAFztXXghR03%2Fposts%2Fs89Uq4Zwq8CVHQhpQ26B%2Fimages%2Fthumbnail-full.jpg?alt=media").into(site_name: "Pixellent")
  end
end
