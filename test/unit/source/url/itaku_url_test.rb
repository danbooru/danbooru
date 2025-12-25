require "test_helper"

module Source::Tests::URL
  class ItakuUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://itaku.ee/api/media_2/profile_pics/profile_pics/pfp9_kI67Jq5_oyZ4mO8/sm.jpg",
          "https://itaku.ee/api/media_2/cover_pics/Banner3_plain_5T9aMBP.png",
          "https://itaku.ee/api/media_2/gallery_imgs/1869351-1.output_1VWokMA/xl.jpg",
          "https://itaku.ee/api/media_2/gallery_imgs/1869351-1.output_1VWokMA.png",
          "https://itaku.ee/api/media/gallery_imgs/IMG_2679_3GtFUgB.png",
          "https://itaku.ee/api/media/gallery_vids/Final_16-9_ckftagX.mp4",
        ],
        page_urls: [
          "https://itaku.ee/images/812661",
          "https://itaku.ee/posts/130073",
          "https://itaku.ee/api/galleries/images/812661/comments/",
          "https://itaku.ee/api/posts/130073/comments/",
        ],
        profile_urls: [
          "https://itaku.ee/profile/advosart",
          "https://itaku.ee/profile/advosart/gallery",
        ],
      )
    end
  end
end
