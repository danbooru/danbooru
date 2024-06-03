# frozen_string_literal: true

require "test_helper"

module Sources
  class KofiTest < ActiveSupport::TestCase
    context "Kofi:" do
      context "A sample image URL" do
        strategy_should_work(
          "https://storage.ko-fi.com/cdn/useruploads/post/2c42fc4c-6ebb-4b09-9da0-d14b19a105b1_d69ed1ef-bb4c-4c9f-96ed-4cac35ab8c0d.png",
          image_urls: %w[https://storage.ko-fi.com/cdn/useruploads/display/2c42fc4c-6ebb-4b09-9da0-d14b19a105b1_d69ed1ef-bb4c-4c9f-96ed-4cac35ab8c0d.png],
          media_files: [{ file_size: 607_634 }],
          page_url: nil,
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A full image URL" do
        strategy_should_work(
          "https://storage.ko-fi.com/cdn/useruploads/display/2c42fc4c-6ebb-4b09-9da0-d14b19a105b1_d69ed1ef-bb4c-4c9f-96ed-4cac35ab8c0d.png",
          image_urls: %w[https://storage.ko-fi.com/cdn/useruploads/display/2c42fc4c-6ebb-4b09-9da0-d14b19a105b1_d69ed1ef-bb4c-4c9f-96ed-4cac35ab8c0d.png],
          media_files: [{ file_size: 607_634 }],
          page_url: nil,
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A post with multiple images" do
        strategy_should_work(
          "https://ko-fi.com/i/IS6S8U4PAZ",
          image_urls: %w[
            https://storage.ko-fi.com/cdn/useruploads/display/f744b057-c605-49ae-98ea-c3bcd9da75f7_frieren10.jpg
            https://storage.ko-fi.com/cdn/useruploads/display/7fbad9e7-5977-4eb2-b4d1-9b25e80e2729_frieren11.jpg
            https://storage.ko-fi.com/cdn/useruploads/display/6eb3caed-688d-4dfb-adfc-ee80a6b6aae9_frieren12.jpg
            https://storage.ko-fi.com/cdn/useruploads/display/1457e396-f401-4a77-9c3e-e41b7f612ee2_frieren13.jpg
            https://storage.ko-fi.com/cdn/useruploads/display/f3e7e80f-7582-4f88-8d36-e719cd224b49_frieren14.jpg
            https://storage.ko-fi.com/cdn/useruploads/display/63980fa6-c058-4378-9618-34355252e83c_frieren15.jpg
          ],
          media_files: [
            { file_size: 85_702 },
            { file_size: 166_904 },
            { file_size: 140_965 },
            { file_size: 136_404 },
            { file_size: 143_317 },
            { file_size: 153_648 },
          ],
          page_url: "https://ko-fi.com/i/IS6S8U4PAZ",
          profile_urls: %w[https://ko-fi.com/nestvirgo https://ko-fi.com/Z8Z05UNZE],
          display_name: "nestvirgo",
          username: "nestvirgo",
          tags: [],
          dtext_artist_commentary_title: "Frieren Drawing Process",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A post with a downloadable highres image" do
        strategy_should_work(
          "https://ko-fi.com/empresstwilight?viewimage=IT6T0N4D36#galleryItemView",
          image_urls: %w[https://storage.ko-fi.com/cdn/useruploads/93b977cb-22ed-45c1-86ad-2655e0b7d068_ilustración9_2.png],
          media_files: [{ file_size: 10_629_195 }],
          page_url: "https://ko-fi.com/empresstwilight?viewimage=IT6T0N4D36",
          profile_urls: %w[https://ko-fi.com/empresstwilight https://ko-fi.com/Q5Q3L7K01],
          display_name: "Twilight Sparkle",
          username: "empresstwilight",
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            "www.deviantart.com/empress-twilight":[https://www.deviantart.com/empress-twilight]
            "ych.art/user/empress-twilight":[https://ych.art/user/empress-twilight]
          EOS
        )
      end

      context "A supporters-only post" do
        strategy_should_work(
          "https://ko-fi.com/Gallery/LockedGalleryItem?id=IF1F6YVVVE#checkoutModal",
          image_urls: [],
          page_url: "https://ko-fi.com/i/IF1F6YVVVE",
          profile_urls: %w[https://ko-fi.com/sitraxis https://ko-fi.com/X8X668RY],
          display_name: "Tris",
          username: "sitraxis",
          tags: [],
          dtext_artist_commentary_title: "Shiki Animatic Frame Preview #15",
          dtext_artist_commentary_desc: "Available to monthly supporters"
        )
      end

      context "A deleted or nonexistent post" do
        strategy_should_work(
          "https://ko-fi.com/i/99999",
          image_urls: [],
          page_url: "https://ko-fi.com/i/99999",
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "Parse URLs correctly" do
        assert(Source::URL.image_url?("https://storage.ko-fi.com/cdn/useruploads/post/6132206b-945b-42e9-8326-b4de510bb1da_ilustraci%C3%B3n9_2.png"))
        assert(Source::URL.image_url?("https://storage.ko-fi.com/cdn/useruploads/display/6132206b-945b-42e9-8326-b4de510bb1da_ilustraci%C3%B3n9_2.png"))
        assert(Source::URL.image_url?("https://storage.ko-fi.com/cdn/useruploads/png_bec82915-ce70-4fea-a386-608a6afb1b33cover.jpg?v=f2fcf155-8d71-4a7d-a91a-0fbdec814684"))
        assert(Source::URL.image_url?("https://cdn.ko-fi.com/cdn/useruploads/e53090ad-734d-4c1c-ab15-73215be79804_tiny.png"))
        assert(Source::URL.image_url?("https://az743702.vo.msecnd.net/cdn/useruploads/tiny_dfc72789-50bf-486f-9a87-81d05ee09437.jpg"))

        assert(Source::URL.page_url?("https://ko-fi.com/i/IU7U5SS0YZ"))
        assert(Source::URL.page_url?("https://ko-fi.com/s/5fc8f89b6e"))
        assert(Source::URL.page_url?("https://ko-fi.com/c/780f9a88f9"))
        assert(Source::URL.page_url?("https://ko-fi.com/post/Hooligans-Update-3-May-30th-2024-S6S0YPT5K"))
        assert(Source::URL.page_url?("https://ko-fi.com/album/Original-Artworks-Q5Q2JPOWH"))
        assert(Source::URL.page_url?("https://ko-fi.com/E1E7FH8ZY?viewimage=IU7U5SS0YZ"))
        assert(Source::URL.page_url?("https://ko-fi.com/thom_sketching/gallery?viewimage=IO5O1BOYV6#galleryItemView"))
        assert(Source::URL.page_url?("https://ko-fi.com/Gallery/LockedGalleryItem?id=IV7V6XDSRU#checkoutModal"))

        assert(Source::URL.profile_url?("https://ko-fi.com/johndaivid"))
        assert(Source::URL.profile_url?("https://ko-fi.com/T6T41FDFF/gallery/?action=gallery"))
      end
    end
  end
end
