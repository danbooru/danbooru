require "test_helper"

module Source::Tests::URL
  class KofiUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://storage.ko-fi.com/cdn/useruploads/post/6132206b-945b-42e9-8326-b4de510bb1da_ilustraci%C3%B3n9_2.png",
          "https://storage.ko-fi.com/cdn/useruploads/display/6132206b-945b-42e9-8326-b4de510bb1da_ilustraci%C3%B3n9_2.png",
          "https://storage.ko-fi.com/cdn/useruploads/png_bec82915-ce70-4fea-a386-608a6afb1b33cover.jpg?v=f2fcf155-8d71-4a7d-a91a-0fbdec814684",
          "https://cdn.ko-fi.com/cdn/useruploads/e53090ad-734d-4c1c-ab15-73215be79804_tiny.png",
          "https://az743702.vo.msecnd.net/cdn/useruploads/tiny_dfc72789-50bf-486f-9a87-81d05ee09437.jpg",
        ],
        page_urls: [
          "https://ko-fi.com/i/IU7U5SS0YZ",
          "https://ko-fi.com/s/5fc8f89b6e",
          "https://ko-fi.com/c/780f9a88f9",
          "https://ko-fi.com/post/Hooligans-Update-3-May-30th-2024-S6S0YPT5K",
          "https://ko-fi.com/album/Original-Artworks-Q5Q2JPOWH",
          "https://ko-fi.com/E1E7FH8ZY?viewimage=IU7U5SS0YZ",
          "https://ko-fi.com/thom_sketching/gallery?viewimage=IO5O1BOYV6#galleryItemView",
          "https://ko-fi.com/Gallery/LockedGalleryItem?id=IV7V6XDSRU#checkoutModal",
        ],
        profile_urls: [
          "https://ko-fi.com/johndaivid",
          "https://ko-fi.com/T6T41FDFF/gallery/?action=gallery",
        ],
      )
    end
  end
end
