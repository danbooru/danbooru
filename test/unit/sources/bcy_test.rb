# frozen_string_literal: true

require "test_helper"

module Sources
  class BcyTest < ActiveSupport::TestCase
    context "BCY:" do
      context "A sample image URL" do
        strategy_should_work(
          "https://img5.bcyimg.com/drawer/103785/post/178q3/88fdb790392d11e7b58d17da09c22716.jpg/w650",
          image_urls: %w[http://img5.bcyimg.com/drawer/103785/post/178q3/88fdb790392d11e7b58d17da09c22716.jpg],
          media_files: [{ file_size: 651_142 }],
          page_url: nil,
          profile_url: nil,
          profile_urls: %w[],
          artist_name: nil,
          tag_name: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "Parse URLs correctly" do
        assert(Source::URL.image_url?("https://img5.bcyimg.com/drawer/103785/post/178q3/88fdb790392d11e7b58d17da09c22716.jpg/w650"))
        assert(Source::URL.image_url?("https://img9.bcyimg.com/drawer/32360/post/178vu/46229ec06e8111e79558c1b725ebc9e6.jpg"))
        assert(Source::URL.image_url?("https://p3-bcy.bcyimg.com/banciyuan/4aad9c6849ca46da86532cdef8b12e42~tplv-banciyuan-obj.image"))

        assert(Source::URL.page_url?("https://bcy.net/illust/detail/1918/754976"))
        assert(Source::URL.page_url?("https://bcy.net/item/detail/6945012959928130597"))

        assert(Source::URL.profile_url?("https://bcy.net/u/1617969"))
      end
    end
  end
end
