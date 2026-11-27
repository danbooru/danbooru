require "test_helper"

module Source::Tests::URL
  class SkimaUrlTest < ActiveSupport::TestCase
    context "Skima URLs" do
      should be_image_url(
        "https://cdn-gallery.skima.jp/gallery/017/284/17284/d1905510dbb435ce81cc4056c32055d8-20171226132800.jpeg",
        "https://cdn-gallery.skima.jp/gallery/017/284/17284/detail-e2ff46808671c188aba936b55038db1b-20171226132800.jpeg",
        "https://cdn-gallery.skima.jp/gallery/055/208/55208/tip-f0081762dcb72ab22241526cbc00c814-20190215093719.jpeg",
        "https://cdn-common.skima.jp/item/472/833/1472833/9006bf8a7e0026066bfba843d2e12364-20240403213428.jpeg",
        "https://cdn-common.skima.jp/item/472/833/1472833/showcase-9006bf8a7e0026066bfba843d2e12364-20240403213428.jpeg",
        "https://cdn-common.skima.jp/item/181/491/1181491/thumbnail-decd257745cc6e1a06af3df899c019f2-20230112232332.jpeg",
        "https://cdn-common.skima.jp/item/875/376/1875376/timeline-6218f03c65fb9113b5e4d876ef332521-20260607185215.jpeg",
        "https://cdn-common.skima.jp/dlsample/294/329/2294329/41c5e0f2f64bd224785f5bb352f4f420-20240601221013.png",
        "https://cdn-common.skima.jp/dlsample/294/329/2294329/thumbnail-41c5e0f2f64bd224785f5bb352f4f420-20240601221013.jpeg",
        "https://cdn-common.skima.jp/profile/067/007/67007/61a8a2b43e63f24bb9cfe989d8d0d942-20191204225002.png",
        "https://cdn-common.skima.jp/profile/067/007/67007/large-61a8a2b43e63f24bb9cfe989d8d0d942-20191204225002.jpeg",
        "https://cdn-common.skima.jp/profcover/074/536/74536/70135caaca056b9506f4a22457f05b03-20240609020637.jpeg",
      )

      should be_image_sample(
        "https://cdn-gallery.skima.jp/gallery/017/284/17284/detail-e2ff46808671c188aba936b55038db1b-20171226132800.jpeg",
        "https://cdn-gallery.skima.jp/gallery/055/208/55208/tip-f0081762dcb72ab22241526cbc00c814-20190215093719.jpeg",
        "https://cdn-common.skima.jp/item/472/833/1472833/showcase-9006bf8a7e0026066bfba843d2e12364-20240403213428.jpeg",
        "https://cdn-common.skima.jp/dlsample/294/329/2294329/thumbnail-41c5e0f2f64bd224785f5bb352f4f420-20240601221013.jpeg",
        "https://cdn-common.skima.jp/profile/067/007/67007/large-61a8a2b43e63f24bb9cfe989d8d0d942-20191204225002.jpeg",
      )

      should_not be_image_sample(
        "https://cdn-gallery.skima.jp/gallery/017/284/17284/d1905510dbb435ce81cc4056c32055d8-20171226132800.jpeg",
        "https://cdn-common.skima.jp/item/472/833/1472833/9006bf8a7e0026066bfba843d2e12364-20240403213428.jpeg",
        "https://cdn-common.skima.jp/dlsample/294/329/2294329/41c5e0f2f64bd224785f5bb352f4f420-20240601221013.png",
      )

      should be_page_url(
        "https://skima.jp/gallery?id=6428",
        "https://skima.jp/item/detail?item_id=169712",
        "https://skima.jp/dl/detail?id=260834",
        "https://commission.skima.jp/en/commission/detail/307121",
        "https://commission.skima.jp/commission/detail/307121",
        "https://commission.skima.jp/en/pre-made-illustration/detail/256160",
        "https://commission.skima.jp/zh-Hant/pre-made-illustration/detail/256160",
        "https://commission.skima.jp/en/items/256160",
        "https://wskima.com/items/256160",
      )

      should be_profile_url(
        "https://skima.jp/profile?id=1927",
        "https://skima.jp/profile/galleries?id=1927",
        "https://skima.jp/profile/commissions?id=1927",
        "https://skima.jp/profile/dl_products?id=1927",
        "https://skima.jp/profile/reviews?id=1927",
        "http://skima.jp/u/id21469/",
        "https://commission.skima.jp/en/creator/294451",
        "https://commission.skima.jp/ko/profile/294451",
        "https://wskima.com/creator/294451",
      )

      should_not be_page_url(
        "https://skima.jp/gallery?id=abc",
        "https://skima.jp/gallery?id[]=1",
        "https://skima.jp/item/detail",
        "https://skima.jp/dl",
        "https://commission.skima.jp/en",
      )

      should_not be_profile_url(
        "https://skima.jp/profile?id=abc",
        "https://skima.jp/profile",
        "https://skima.jp/creator/294451",
        "https://skima.jp/u/abc",
      )

      should parse_url("https://cdn-common.skima.jp/item/472/833/1472833/showcase-9006bf8a7e0026066bfba843d2e12364-20240403213428.jpeg").into(
        site_name: "Skima",
        image_id: "1472833",
        candidate_full_image_urls: %w[
          https://cdn-common.skima.jp/item/472/833/1472833/9006bf8a7e0026066bfba843d2e12364-20240403213428.jpeg
          https://cdn-common.skima.jp/item/472/833/1472833/9006bf8a7e0026066bfba843d2e12364-20240403213428.png
          https://cdn-common.skima.jp/item/472/833/1472833/9006bf8a7e0026066bfba843d2e12364-20240403213428.gif
        ],
      )

      should parse_url("https://cdn-common.skima.jp/dlsample/294/329/2294329/thumbnail-41c5e0f2f64bd224785f5bb352f4f420-20240601221013.jpeg").into(
        candidate_full_image_urls: %w[
          https://cdn-common.skima.jp/dlsample/294/329/2294329/41c5e0f2f64bd224785f5bb352f4f420-20240601221013.png
          https://cdn-common.skima.jp/dlsample/294/329/2294329/41c5e0f2f64bd224785f5bb352f4f420-20240601221013.jpg
          https://cdn-common.skima.jp/dlsample/294/329/2294329/41c5e0f2f64bd224785f5bb352f4f420-20240601221013.jpeg
          https://cdn-common.skima.jp/dlsample/294/329/2294329/41c5e0f2f64bd224785f5bb352f4f420-20240601221013.PNG
        ],
      )

      should parse_url("https://cdn-gallery.skima.jp/gallery/017/284/17284/detail-e2ff46808671c188aba936b55038db1b-20171226132800.jpeg").into(
        image_id: "17284",
        full_image_url: nil,
        candidate_full_image_urls: nil,
      )

      should parse_url("https://skima.jp/gallery?id=6428").into(
        site_name: "Skima",
        gallery_id: "6428",
        page_url: "https://skima.jp/gallery?id=6428",
        profile_url: nil,
      )

      should parse_url("https://skima.jp/item/detail?item_id=169712").into(
        item_id: "169712",
        page_url: "https://skima.jp/item/detail?item_id=169712",
      )

      should parse_url("https://skima.jp/dl/detail?id=260834").into(
        dl_product_id: "260834",
        page_url: "https://skima.jp/dl/detail?id=260834",
      )

      should parse_url("https://commission.skima.jp/en/commission/detail/307121").into(
        item_id: "307121",
        page_url: "https://commission.skima.jp/commission/detail/307121",
      )

      should parse_url("https://wskima.com/items/256160").into(
        dl_product_id: "256160",
        page_url: "https://commission.skima.jp/pre-made-illustration/detail/256160",
      )

      should parse_url("https://skima.jp/profile/galleries?id=1927").into(
        user_id: "1927",
        profile_url: "https://skima.jp/profile?id=1927",
      )

      should parse_url("http://skima.jp/u/id21469/").into(
        user_id: "21469",
        profile_url: "https://skima.jp/profile?id=21469",
      )

      should parse_url("https://wskima.com/creator/294451").into(
        user_id: "294451",
        profile_url: "https://skima.jp/profile?id=294451",
      )
    end
  end
end
