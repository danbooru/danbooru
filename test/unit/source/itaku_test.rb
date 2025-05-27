# frozen_string_literal: true

require "test_helper"

module Sources
  class ItakuTest < ActiveSupport::TestCase
    context "Itaku:" do
      context "A Itaku sample image URL" do
        strategy_should_work(
          "https://itaku.ee/api/media/gallery_imgs/IMG_2679_3GtFUgB/xl.jpg",
          image_urls: %w[https://itaku.ee/api/media/gallery_imgs/IMG_2679_3GtFUgB.png],
          media_files: [{ file_size: 50_948 }],
          page_url: nil,
          profile_url: nil,
          display_name: nil,
          username: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A Itaku full image URL" do
        strategy_should_work(
          "https://itaku.ee/api/media/gallery_imgs/IMG_2679_3GtFUgB.png",
          image_urls: %w[https://itaku.ee/api/media/gallery_imgs/IMG_2679_3GtFUgB.png],
          media_files: [{ file_size: 50_948 }],
          page_url: nil,
          profile_url: nil,
          display_name: nil,
          username: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A Itaku /images/:id post" do
        strategy_should_work(
          "https://itaku.ee/images/812661",
          image_urls: %w[https://itaku.ee/api/media_2/gallery_imgs/1869351-1.output_1VWokMA.png],
          media_files: [{ file_size: 8_140_744 },],
          page_url: "https://itaku.ee/images/812661",
          profile_url: "https://itaku.ee/velox",
          profile_urls: %w[https://itaku.ee/velox],
          display_name: "Velox",
          username: "velox",
          other_names: ["Velox"],
          tags: [
            ["cream_fur", "https://itaku.ee/home/images?tags=cream_fur"],
            ["white_hair", "https://itaku.ee/home/images?tags=white_hair"],
            ["casual_clothes", "https://itaku.ee/home/images?tags=casual_clothes"],
            ["eeveelution", "https://itaku.ee/home/images?tags=eeveelution"],
            ["whiskers", "https://itaku.ee/home/images?tags=whiskers"],
            ["eyes", "https://itaku.ee/home/images?tags=eyes"],
            ["heterochromia", "https://itaku.ee/home/images?tags=heterochromia"],
            ["hair", "https://itaku.ee/home/images?tags=hair"],
            ["fur", "https://itaku.ee/home/images?tags=fur"],
            ["blue_eyes", "https://itaku.ee/home/images?tags=blue_eyes"],
            ["furry", "https://itaku.ee/home/images?tags=furry"],
            ["fluffy_tail", "https://itaku.ee/home/images?tags=fluffy_tail"],
            ["video_game", "https://itaku.ee/home/images?tags=video_game"],
            ["game", "https://itaku.ee/home/images?tags=game"],
            ["hoodie", "https://itaku.ee/home/images?tags=hoodie"],
            ["velox_(character)", "https://itaku.ee/home/images?tags=velox_(character)"],
            ["pokemon_(species)", "https://itaku.ee/home/images?tags=pokemon_(species)"],
            ["pokemon", "https://itaku.ee/home/images?tags=pokemon"],
            ["collar", "https://itaku.ee/home/images?tags=collar"],
            ["gen_1_pokemon", "https://itaku.ee/home/images?tags=gen_1_pokemon"],
            ["hat", "https://itaku.ee/home/images?tags=hat"],
            ["pink_eyes", "https://itaku.ee/home/images?tags=pink_eyes"],
            ["jolteon", "https://itaku.ee/home/images?tags=jolteon"],
            ["nintendo", "https://itaku.ee/home/images?tags=nintendo"],
          ],
          dtext_artist_commentary_title: "Cool vibes",
          dtext_artist_commentary_desc: <<~EOS.chomp
            Commission by @/yorozu1217 on Twitter
          EOS
        )
      end

      context "A Itaku /images/:id video post" do
        strategy_should_work(
          "https://itaku.ee/images/525359",
          image_urls: %w[https://itaku.ee/api/media/gallery_vids/Final_16-9_ckftagX.mp4],
          media_files: [{ file_size: 9_065_057 }],
          page_url: "https://itaku.ee/images/525359",
          profile_url: "https://itaku.ee/advosart",
          profile_urls: %w[https://itaku.ee/advosart],
          display_name: "Advos",
          username: "advosart",
          other_names: ["Advos", "advosart"],
          tags: [
            ["breakdance", "https://itaku.ee/home/images?tags=breakdance"],
            ["animation", "https://itaku.ee/home/images?tags=animation"],
            ["video", "https://itaku.ee/home/images?tags=video"],
            ["ratchet_and_clank", "https://itaku.ee/home/images?tags=ratchet_and_clank"],
            ["art", "https://itaku.ee/home/images?tags=art"],
          ],
          dtext_artist_commentary_title: "Ratchet's Breakdancing Skills",
          dtext_artist_commentary_desc: <<~EOS.chomp
            https://youtu.be/BwfZ_h22d3U
          EOS
        )
      end

      # XXX Not implemented
      context "A Itaku /posts/:id post" do
        strategy_should_work(
          "https://itaku.ee/posts/130073",
          image_urls: %w[],
          media_files: [],
          page_url: "https://itaku.ee/posts/130073",
          profile_url: nil,
          display_name: nil,
          username: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A deleted or nonexistent Itaku image" do
        strategy_should_work(
          "https://itaku.ee/images/999999999",
          image_urls: [],
          page_url: "https://itaku.ee/images/999999999",
          profile_url: nil,
          profile_urls: %w[],
          display_name: nil,
          username: nil,
          other_names: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "parse Itaku URLs correctly" do
        assert(Source::URL.image_url?("https://itaku.ee/api/media_2/profile_pics/profile_pics/pfp9_kI67Jq5_oyZ4mO8/sm.jpg"))
        assert(Source::URL.image_url?("https://itaku.ee/api/media_2/cover_pics/Banner3_plain_5T9aMBP.png"))
        assert(Source::URL.image_url?("https://itaku.ee/api/media_2/gallery_imgs/1869351-1.output_1VWokMA/xl.jpg"))
        assert(Source::URL.image_url?("https://itaku.ee/api/media_2/gallery_imgs/1869351-1.output_1VWokMA.png"))
        assert(Source::URL.image_url?("https://itaku.ee/api/media/gallery_imgs/IMG_2679_3GtFUgB.png"))
        assert(Source::URL.image_url?("https://itaku.ee/api/media/gallery_vids/Final_16-9_ckftagX.mp4"))

        assert(Source::URL.page_url?("https://itaku.ee/images/812661"))
        assert(Source::URL.page_url?("https://itaku.ee/posts/130073"))
        assert(Source::URL.page_url?("https://itaku.ee/api/galleries/images/812661/comments/"))
        assert(Source::URL.page_url?("https://itaku.ee/api/posts/130073/comments/"))

        assert(Source::URL.profile_url?("https://itaku.ee/profile/advosart"))
        assert(Source::URL.profile_url?("https://itaku.ee/profile/advosart/gallery"))
      end
    end
  end
end
