require "test_helper"

module Source::Tests::URL
  class XiaohongshuUrlTest < ActiveSupport::TestCase
    context "Xiaohongshu URLs" do
      should be_image_url(
        "http://sns-webpic-qc.xhscdn.com/202405050857/60985d4963cfb500a9b0838667eb3adc/1000g00828idf6nofk05g5ohki5uk137o8beqcv8!nd_dft_wgth_webp_3",
        "https://sns-web-i10.rednotecdn.com/202605022153/beebca051fa7f146cac83b58b49f020e/notes_pre_post/1040g3k831ugifr7iip205o4ptfh0814d1eq53fo!nd_dft_wlteh_webp_3?src=A",
        "https://ci.xiaohongshu.com/1000g00828idf6nofk05g5ohki5uk137o8beqcv8",
        "https://sns-avatar-qc.xhscdn.com/avatar/1040g2jo30s5tg4ugig605ohki5uk137o34ug2fo",
      )

      should be_page_url(
        "https://www.xiaohongshu.com/explore/6421b331000000002702901f",
        "https://www.rednote.com/explore/6421b331000000002702901f",
        "https://www.xiaohongshu.com/user/profile/6234917d0000000010008cf8/6421b331000000002702901f",
        "https://www.rednote.com/user/profile/6234917d0000000010008cf8/6421b331000000002702901f",
        "https://www.xiaohongshu.com/discovery/item/65880524000000000700a643",
        "https://www.rednote.com/discovery/item/65880524000000000700a643",
      )

      should be_profile_url(
        "https://www.xiaohongshu.com/user/profile/6234917d0000000010008cf8",
        "https://www.rednote.com/user/profile/6234917d0000000010008cf8",
      )

      should be_bad_source(
        "https://xhslink.com/WNd9gI",
        "https://xhslink.com/o/3y3uwYYeyHn",
      )
    end

    should parse_url("http://sns-webpic-qc.xhscdn.com/202405050857/60985d4963cfb500a9b0838667eb3adc/1000g00828idf6nofk05g5ohki5uk137o8beqcv8!nd_dft_wgth_webp_3").into(site_name: "Xiaohongshu")
  end
end
