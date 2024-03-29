require "test_helper"

module Sources
  class DanbooruTest < ActiveSupport::TestCase
    context "Danbooru:" do
      context "a post" do
        strategy_should_work(
          "https://danbooru.donmai.us/posts/7000000",
          image_urls: ["https://cdn.donmai.us/original/8d/81/8d819da4871c3ca39f428999df8220ce.jpg"],
          media_files: [{ file_size: 2_433_964 }],
          tags: %w[beishang_yutou reverse:1999 sonetto_(reverse:1999) absurdres chinese_commentary commentary highres 4girls aged_down arch armor bow bowtie braid closed_mouth dress green_eyes hair_intakes hair_ornament hairband indoors long_hair looking_ahead looking_at_viewer multiple_girls no_ai_logo orange_hair portrait profile sidelighting single_braid solo_focus statue upper_body white_dress white_hairband window],
          page_url: "https://danbooru.donmai.us/posts/7000000",
          profile_url: "https://www.pixiv.net/users/80781332",
          artist_name: "悲伤鱼头",
          artist_commentary_title: "注视"
        )
      end

      context "an original image URL" do
        strategy_should_work(
          "https://cdn.donmai.us/original/8d/81/8d819da4871c3ca39f428999df8220ce.jpg",
          image_urls: ["https://cdn.donmai.us/original/8d/81/8d819da4871c3ca39f428999df8220ce.jpg"],
          media_files: [{ file_size: 2_433_964 }],
          tags: %w[beishang_yutou reverse:1999 sonetto_(reverse:1999) absurdres chinese_commentary commentary highres 4girls aged_down arch armor bow bowtie braid closed_mouth dress green_eyes hair_intakes hair_ornament hairband indoors long_hair looking_ahead looking_at_viewer multiple_girls no_ai_logo orange_hair portrait profile sidelighting single_braid solo_focus statue upper_body white_dress white_hairband window],
          page_url: "https://danbooru.donmai.us/posts/7000000",
          profile_url: "https://www.pixiv.net/users/80781332",
          artist_name: "悲伤鱼头",
          artist_commentary_title: "注视"
        )
      end

      context "a sample image URL" do
        strategy_should_work(
          "https://cdn.donmai.us/sample/8d/81/__sonetto_reverse_1999_drawn_by_beishang_yutou__sample-8d819da4871c3ca39f428999df8220ce.jpg",
          image_urls: ["https://cdn.donmai.us/original/8d/81/8d819da4871c3ca39f428999df8220ce.jpg"],
          media_files: [{ file_size: 2_433_964 }],
          tags: %w[beishang_yutou reverse:1999 sonetto_(reverse:1999) absurdres chinese_commentary commentary highres 4girls aged_down arch armor bow bowtie braid closed_mouth dress green_eyes hair_intakes hair_ornament hairband indoors long_hair looking_ahead looking_at_viewer multiple_girls no_ai_logo orange_hair portrait profile sidelighting single_braid solo_focus statue upper_body white_dress white_hairband window],
          page_url: "https://danbooru.donmai.us/posts/7000000",
          profile_url: "https://www.pixiv.net/users/80781332",
          artist_name: "悲伤鱼头",
          artist_commentary_title: "注视"
        )
      end

      context "a nonexistent post" do
        strategy_should_work(
          "https://danbooru.donmai.us/posts/0",
          image_urls: [],
          tags: [],
          page_url: "https://danbooru.donmai.us/posts/0",
          profile_url: nil,
          artist_name: nil,
          artist_commentary_title: nil
        )
      end
    end

    should "Parse URLs correctly" do
      assert(Source::URL.image_url?("https://cdn.donmai.us/sample/8d/81/__sonetto_reverse_1999_drawn_by_beishang_yutou__sample-8d819da4871c3ca39f428999df8220ce.jpg"))
      assert(Source::URL.image_url?("https://cdn.donmai.us/original/8d/81/8d819da4871c3ca39f428999df8220ce.jpg"))
      assert(Source::URL.image_url?("https://cdn.donmai.us/8d/81/8d819da4871c3ca39f428999df8220ce.jpg"))
      assert(Source::URL.image_url?("https://danbooru.donmai.us/data/8d/81/8d819da4871c3ca39f428999df8220ce.jpg"))

      assert(Source::URL.page_url?("https://danbooru.donmai.us/posts/1"))
      assert(Source::URL.page_url?("https://danbooru.donmai.us/posts/1.json"))
      assert(Source::URL.page_url?("https://danbooru.donmai.us/posts?md5=8d819da4871c3ca39f428999df8220ce"))

      assert(Source::URL.profile_url?("https://danbooru.donmai.us/users/1"))
      assert(Source::URL.profile_url?("https://danbooru.donmai.us/users/1.json"))
    end
  end
end
