require "test_helper"

module Source::Tests::URL
  class SklandUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://bbs.hycdn.cn/image/2024/04/29/576904/1dc98f0a6780ddcbc107d77bfdba673f.webp",
          "https://skland-vod.hycdn.cn/302baa34192071efbfae5017f0e90102/ceae138088e6ffb74cde2f255256f43d-sd-00004.ts?auth_key=1716481288-d3ee979fabcb40ba81081ceb020d6c61-0-3fe9870a677988387d250723b318776b",
          "https://skland-vod.hycdn.cn/302baa34192071efbfae5017f0e90102/507915004148ecaf55d6244e88e976f5-ld.m3u8?auth_key=1716481288-b59e656f4e32461d97c85ab666158512-0-9083e6744ad7e3e28c7231767731f2ea",
          "https://web.hycdn.cn/skland/site/assets/img/homeMainFirst.472886.png",
        ],
        page_urls: [
          "https://www.skland.com/article?id=1827735",
          "https://www.skland.com/h/detail?id=1827735",
          "https://m.skland.com/article?id=1827735",
        ],
        profile_urls: [
          "https://www.skland.com/profile?id=4040407836824",
        ],
      )
    end
  end
end
