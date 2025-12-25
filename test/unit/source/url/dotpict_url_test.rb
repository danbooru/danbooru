require "test_helper"

module Source::Tests::URL
  class DotpictUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://img.dotpicko.net/thumbnail_work/2023/06/09/20/57/thumb_e45a20d18dbca13bb52ae7f01eaf2de4db1054886d358bea0f36acfb7c1ce667.png",
          "https://img.dotpicko.net/work/2023/06/09/20/57/e45a20d18dbca13bb52ae7f01eaf2de4db1054886d358bea0f36acfb7c1ce667.gif",
          "https://img.dotpicko.net/0a50367ceece3eb2dda17e2e9643486f4b4950e1677bfc061ecce3c7a71c5f20.png",
          "https://img.dotpicko.net/header_3bd62384fba07600a7247cb6093ad1ecd271adca72b8c15a5eb4263ca26c5ae2.png",
        ],
        page_urls: [
          "https://dotpict.net/works/4814277",
          "https://jumpanaatta.dotpict.net/works/5356301",
        ],
        profile_urls: [
          "https://dotpict.net/users/2011866",
          "https://dotpict.net/@your_moms_house",
          "https://jumpanaatta.dotpict.net",
          "https://www.dotpict.net",
        ],
      )
    end
  end
end
