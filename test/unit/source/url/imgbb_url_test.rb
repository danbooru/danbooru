require "test_helper"

module Source::Tests::URL
  class ImgbbUrlTest < ActiveSupport::TestCase
    context "ImgBB URLs" do
      should be_profile_url(
        "https://meliach.imgbb.com",
        "https://meliach.imgbb.com/albums",
      )
    end
  end
end
