require "test_helper"

module Sources
  class DanbooruTest < ActiveSupport::TestCase
    context "Danbooru:" do
      context "a post" do
        strategy_should_work(
          "https://danbooru.donmai.us/posts/7000000",
          image_urls: ["https://cdn.donmai.us/original/8d/81/8d819da4871c3ca39f428999df8220ce.jpg"],
          media_files: [{ file_size: 2_433_964 }],
          tags: %w[beishang_yutou reverse:1999 sonetto_(reverse:1999) absurdres chinese_commentary commentary highres 4girls aged_down arch armor bow bowtie braid closed_mouth dress green_eyes hair_intakes hair_ornament hairband indoors long_hair looking_ahead looking_at_viewer multiple_girls no_ai_logo orange_hair portrait profile sidelighting single_braid statue upper_body white_dress white_hairband window],
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
          tags: %w[beishang_yutou reverse:1999 sonetto_(reverse:1999) absurdres chinese_commentary commentary highres 4girls aged_down arch armor bow bowtie braid closed_mouth dress green_eyes hair_intakes hair_ornament hairband indoors long_hair looking_ahead looking_at_viewer multiple_girls no_ai_logo orange_hair portrait profile sidelighting single_braid statue upper_body white_dress white_hairband window],
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
          tags: %w[beishang_yutou reverse:1999 sonetto_(reverse:1999) absurdres chinese_commentary commentary highres 4girls aged_down arch armor bow bowtie braid closed_mouth dress green_eyes hair_intakes hair_ornament hairband indoors long_hair looking_ahead looking_at_viewer multiple_girls no_ai_logo orange_hair portrait profile sidelighting single_braid statue upper_body white_dress white_hairband window],
          page_url: "https://danbooru.donmai.us/posts/7000000",
          profile_url: "https://www.pixiv.net/users/80781332",
          artist_name: "悲伤鱼头",
          artist_commentary_title: "注视"
        )
      end

      context "a sample image URL for a PNG original" do
        strategy_should_work(
          "https://cdn.donmai.us/sample/fa/dd/__dokibird_indie_virtual_youtuber_drawn_by_aocoa__sample-fadda8ec550a7293bedb7100e54df68c.jpg",
          image_urls: ["https://cdn.donmai.us/original/fa/dd/fadda8ec550a7293bedb7100e54df68c.png"],
          media_files: [{ file_size: 41_634 }],
          tags: %w[aocoa indie_virtual_youtuber dokibird_(vtuber) dokibird_(vtuber)_(retro_doki) highres 1girl :3 blonde_hair blue_hat crooked_smile earrings green_eyes hair_between_eyes hair_ribbon hat jewelry long_hair portrait ribbon simple_background single_earring smile solo transparent_background twintails virtual_youtuber],
          page_url: "https://danbooru.donmai.us/posts/7392739",
          profile_url: "https://twitter.com/AoCoa",
          artist_name: "AoCoa"
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

      context "an ugoira" do
        strategy_should_work(
          "https://cdn.donmai.us/original/22/30/2230a9de4ceecec50228cbb6e37630bd.zip",
          image_urls: %w[https://cdn.donmai.us/original/22/30/2230a9de4ceecec50228cbb6e37630bd.zip],
          media_files: [{ file_size: 3_433_318, frame_delays: [100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100] }],
          page_url: "https://danbooru.donmai.us/posts/7271978",
        )
      end

      context "A post with a source pointing to itself" do
        strategy_should_work(
          "https://danbooru.donmai.us/posts/4542652",
          image_urls: ["https://cdn.donmai.us/original/b4/44/b44417c286c090059150a5148c36e034.jpg"],
          page_url: "https://danbooru.donmai.us/posts/4542652",
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
