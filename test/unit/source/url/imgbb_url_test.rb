require "test_helper"

module Source::Tests::URL
  class ImgbbUrlTest < ActiveSupport::TestCase
    context "when extracting attributes" do
      url_parser_should_work(
        "https://meliach.imgbb.com",
        profile_url: "https://meliach.imgbb.com",
      )

      url_parser_should_work(
        "https://meliach.imgbb.com/albums",
        profile_url: "https://meliach.imgbb.com",
      )
    end
  end
end
