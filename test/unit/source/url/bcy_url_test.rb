require "test_helper"

module Source::Tests::URL
  class BcyUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://img5.bcyimg.com/drawer/103785/post/178q3/88fdb790392d11e7b58d17da09c22716.jpg/w650",
          "https://img9.bcyimg.com/drawer/32360/post/178vu/46229ec06e8111e79558c1b725ebc9e6.jpg",
          "https://p3-bcy.bcyimg.com/banciyuan/4aad9c6849ca46da86532cdef8b12e42~tplv-banciyuan-obj.image",
        ],
        page_urls: [
          "https://bcy.net/illust/detail/1918/754976",
          "https://bcy.net/item/detail/6945012959928130597",
        ],
        profile_urls: [
          "https://bcy.net/u/1617969s",
        ],
      )
    end
  end
end
