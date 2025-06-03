require "test_helper"

module Source::Tests::URL
  class XiaohongshuUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "http://sns-webpic-qc.xhscdn.com/202405050857/60985d4963cfb500a9b0838667eb3adc/1000g00828idf6nofk05g5ohki5uk137o8beqcv8!nd_dft_wgth_webp_3",
          "https://ci.xiaohongshu.com/1000g00828idf6nofk05g5ohki5uk137o8beqcv8",
          "https://sns-avatar-qc.xhscdn.com/avatar/1040g2jo30s5tg4ugig605ohki5uk137o34ug2fo",
        ],
        page_urls: [
          "https://www.xiaohongshu.com/explore/6421b331000000002702901f",
          "https://www.xiaohongshu.com/user/profile/6234917d0000000010008cf8/6421b331000000002702901f",
          "https://www.xiaohongshu.com/discovery/item/65880524000000000700a643",
        ],
        profile_urls: [
          "https://www.xiaohongshu.com/user/profile/6234917d0000000010008cf8",
        ],
      )
    end
  end
end
