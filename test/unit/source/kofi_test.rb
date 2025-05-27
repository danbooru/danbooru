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

      context "A gallery item with multiple images" do
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

      context "A gallery item with a downloadable highres image" do
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

      context "A supporters-only gallery item" do
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

      context "A commission page" do
        strategy_should_work(
          "https://ko-fi.com/c/780f9a88f9",
          image_urls: %w[
            https://storage.ko-fi.com/cdn/useruploads/display/d49a3d18-2777-42b4-abc1-8fc6cec88771_47acfea4-fbd9-40f3-8f2b-4e754cacb4ed.png
            https://storage.ko-fi.com/cdn/useruploads/display/PNG_4d7caae0-af23-40cd-b1f7-75deda8027dd.PNG
            https://storage.ko-fi.com/cdn/useruploads/display/PNG_4de0b1a0-a3a0-42c3-a6c6-ba9152791bec.PNG
          ],
          media_files: [
            { file_size: 279_930 },
            { file_size: 465_339 },
            { file_size: 606_571 },
          ],
          page_url: "https://ko-fi.com/c/780f9a88f9",
          profile_urls: %w[https://ko-fi.com/thom_sketching https://ko-fi.com/B0B7BOXI6],
          display_name: "THOM",
          username: "thom_sketching",
          tags: [],
          dtext_artist_commentary_title: "Bust sketch",
          dtext_artist_commentary_desc: <<~EOS.chomp
            Description: Character portrait sketch from waist or shoulders up.

            Refinement: Fairly clean but sketch lines are visible
            Colour: No
            Revisions: No

            Disclaimer: I mostly work on weekends, so depending on which day you place your commission (and how many commissions I have going), it might take a few days before I finish it.
          EOS
        )
      end

      context "A shop item" do
        strategy_should_work(
          "https://ko-fi.com/s/f0260080b5",
          image_urls: %w[
            https://storage.ko-fi.com/cdn/useruploads/display/cc189e63-5e80-4fd9-9f4a-478349d74446_valeriekschiscarameowpromo1.jpg
            https://storage.ko-fi.com/cdn/useruploads/display/9552b8d0-35f0-4425-a517-bf6f57b03023_valeriekschiscarameowpromo2.jpg
            https://storage.ko-fi.com/cdn/useruploads/display/f972f299-0084-49c1-b9c1-575f47bec247_valeriekschiscarameowpromo3.jpg
          ],
          media_files: [
            { file_size: 243_436 },
            { file_size: 205_088 },
            { file_size: 208_842 },
          ],
          page_url: "https://ko-fi.com/s/f0260080b5",
          profile_urls: %w[https://ko-fi.com/valerieks https://ko-fi.com/B0B219LZL],
          display_name: "valerieks",
          username: "valerieks",
          tags: [],
          dtext_artist_commentary_title: "Chiscarameow Discord Emoji",
          dtext_artist_commentary_desc: <<~EOS.chomp
            Discord emoji pack for your server!

            Characters belong to HoYoverse.

            For personal use only, not for commercial use.

            Do not use for purposes other than discord emoji.

            Do not print, copy, reproduce, distribute, publish, modify, or in any way exploit the content.
          EOS
        )
      end

      context "A post page" do
        strategy_should_work(
          "https://ko-fi.com/post/Hooligans-Update-3-May-30th-2024-S6S0YPT5K",
          image_urls: %w[
            https://storage.ko-fi.com/cdn/useruploads/display/08a2aca4-b762-41be-906b-52f296ce486d_hooligans_covercopy.png
            https://storage.ko-fi.com/cdn/useruploads/display/25f82109-b36d-47e6-ab64-8688b9ab768f_hooligans_cover.png
          ],
          media_files: [
            { file_size: 345_395 },
            { file_size: 959_746 },
          ],
          page_url: "https://ko-fi.com/post/Hooligans-Update-3-May-30th-2024-S6S0YPT5K",
          profile_urls: %w[https://ko-fi.com/yonsoncb https://ko-fi.com/C0C33HKRP],
          display_name: "Yonson Carbonell",
          username: "yonsoncb",
          tags: [],
          dtext_artist_commentary_title: "Hooligans Update #3, May 30th 2024",
          dtext_artist_commentary_desc: <<~EOS.chomp
            Hey everyone!!

            This update has good news and bad news, will do the good ones first hahaha.

            So, I'm glad to inform that we have a cover for the comic and I know I've been saying this is going to be free to read online like webtoons or something like that but I've been making it like if it was a traditional comic because you never know if it could get printed and I wanted to leave that window open.

            Here is the cover itself

            "[image]":[https://storage.ko-fi.com/cdn/useruploads/display/25f82109-b36d-47e6-ab64-8688b9ab768f_hooligans_cover.png]

            as you can see it features Clodagh as the main thing and I know some of you probably thought the main character in the story was Cillian and technically in a way he is because everything related to this project started with him but this story itself centers more around his mum and how they both had their first adventure together (him being stolen as baby and her on quest to get him back).

            Page wise I'm at page 21 and now this links to the bad news so up till this point I've been working on this comic on my iPad instead of my computer but 2 weeks ago my iPad out of nowhere died on me and right now I'm waiting for an update from the tech guy to see if it will fixable or not, luckily I did backed up all the hooligans files before all this happened so you don't have to worry about the comic being lost forever or something like that but without the iPad the progress will be be slower than it already was because there are days of the week im not home at all so with the iPad I could work on the go but now I can't so, I'm restricted to work only when I'm at home.

            but I'll keep at it, my goal before this incident was to get to page 30 before June so hopefully by the next update I'll have more than that hahaha.

            anyways... that's all for now, please let me know what you think about the cover.

            see you in the next update :D
          EOS
        )
      end

      context "A deleted or nonexistent gallery item" do
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

      context "A deleted or nonexistent commissions page" do
        strategy_should_work(
          "https://ko-fi.com/c/bad",
          image_urls: [],
          page_url: "https://ko-fi.com/c/bad",
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A deleted or nonexistent post page" do
        strategy_should_work(
          "https://ko-fi.com/post/bad-bad",
          image_urls: [],
          page_url: "https://ko-fi.com/post/bad-bad",
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
