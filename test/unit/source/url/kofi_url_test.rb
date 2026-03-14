require "test_helper"

module Source::Tests::URL
  class KofiUrlTest < ActiveSupport::TestCase
    context "Kofi URLs" do
      should be_image_url(
        "https://storage.ko-fi.com/cdn/useruploads/post/6132206b-945b-42e9-8326-b4de510bb1da_ilustraci%C3%B3n9_2.png",
      )
      should be_image_url(
        "https://storage.ko-fi.com/cdn/useruploads/display/6132206b-945b-42e9-8326-b4de510bb1da_ilustraci%C3%B3n9_2.png",
      )
      should be_image_url(
        "https://storage.ko-fi.com/cdn/useruploads/png_bec82915-ce70-4fea-a386-608a6afb1b33cover.jpg?v=f2fcf155-8d71-4a7d-a91a-0fbdec814684",
      )
      should be_image_url(
        "https://cdn.ko-fi.com/cdn/useruploads/e53090ad-734d-4c1c-ab15-73215be79804_tiny.png",
      )
      should be_image_url(
        "https://az743702.vo.msecnd.net/cdn/useruploads/tiny_dfc72789-50bf-486f-9a87-81d05ee09437.jpg",
      )
      should be_page_url(
        "https://ko-fi.com/i/IU7U5SS0YZ",
        "https://ko-fi.com/s/5fc8f89b6e",
        "https://ko-fi.com/c/780f9a88f9",
        "https://ko-fi.com/post/Hooligans-Update-3-May-30th-2024-S6S0YPT5K",
        "https://ko-fi.com/album/Original-Artworks-Q5Q2JPOWH",
        "https://ko-fi.com/E1E7FH8ZY?viewimage=IU7U5SS0YZ",
        "https://ko-fi.com/thom_sketching/gallery?viewimage=IO5O1BOYV6#galleryItemView",
        "https://ko-fi.com/Gallery/LockedGalleryItem?id=IV7V6XDSRU#checkoutModal",
        "https://ko-fi-live.azurewebsites.net/D1D5VUW3P?viewimage=IV7V6X5X5F",
      )
      should be_profile_url(
        "https://ko-fi.com/johndaivid",
        "https://ko-fi.com/T6T41FDFF/gallery/?action=gallery",
        "https://ko-fi-live.azurewebsites.net/gyngerwombatart",
      )

      should parse_url("https://storage.ko-fi.com/cdn/useruploads/post/6132206b-945b-42e9-8326-b4de510bb1da_ilustraci%C3%B3n9_2.png").into(
        full_image_url: "https://storage.ko-fi.com/cdn/useruploads/display/6132206b-945b-42e9-8326-b4de510bb1da_ilustración9_2.png",
      )

      should parse_url("https://ko-fi.com/post/Hooligans-Update-3-May-30th-2024-S6S0YPT5K").into(
        page_url: "https://ko-fi.com/post/Hooligans-Update-3-May-30th-2024-S6S0YPT5K",
      )

      should parse_url("https://ko-fi.com/album/Original-Artworks-Q5Q2JPOWH").into(
        page_url: "https://ko-fi.com/album/Original-Artworks-Q5Q2JPOWH",
      )

      should parse_url("https://ko-fi.com/Gallery/LockedGalleryItem?id=IV7V6XDSRU#checkoutModal").into(
        page_url: "https://ko-fi.com/i/IV7V6XDSRU",
      )

      should parse_url("https://ko-fi.com/thom_sketching/commissions?commissionAlias=780f9a88f9&openCommissionsMenu=True#buyShopCommissionModal").into(
        page_url: "https://ko-fi.com/c/780f9a88f9",
      )

      should parse_url("https://ko-fi.com/T6T41FDFF/gallery/?action=gallery").into(
        profile_url: "https://ko-fi.com/T6T41FDFF",
      )
    end
  end
end
