require "test_helper"

module Source::Tests::Extractor
  class DanbooruExtractorTest < ActiveSupport::TestCase
    context "a post" do
      strategy_should_work(
        "https://danbooru.donmai.us/posts/7000000",
        image_urls: ["https://cdn.donmai.us/original/8d/81/8d819da4871c3ca39f428999df8220ce.jpg"],
        media_files: [{ file_size: 2_433_964 }],
        tags: %w[4girls absurdres aged_down arch armor beishang_yutou bow bowtie braid chinese_commentary closed_mouth commentary dress green_eyes hair_intakes hair_ornament hairband highres indoors long_hair looking_ahead looking_at_viewer multiple_girls orange_hair portrait profile reverse:1999 sidelighting single_braid sonetto_(reverse:1999) statue upper_body white_dress white_hairband window],
        page_url: "https://danbooru.donmai.us/posts/7000000",
        profile_url: "https://www.pixiv.net/users/80781332",
        artist_name: "悲伤鱼头",
        artist_commentary_title: "注视",
      )
    end

    context "an original image URL" do
      strategy_should_work(
        "https://cdn.donmai.us/original/8d/81/8d819da4871c3ca39f428999df8220ce.jpg",
        image_urls: ["https://cdn.donmai.us/original/8d/81/8d819da4871c3ca39f428999df8220ce.jpg"],
        media_files: [{ file_size: 2_433_964 }],
        tags: %w[4girls absurdres aged_down arch armor beishang_yutou bow bowtie braid chinese_commentary closed_mouth commentary dress green_eyes hair_intakes hair_ornament hairband highres indoors long_hair looking_ahead looking_at_viewer multiple_girls orange_hair portrait profile reverse:1999 sidelighting single_braid sonetto_(reverse:1999) statue upper_body white_dress white_hairband window],
        page_url: "https://danbooru.donmai.us/posts/7000000",
        profile_url: "https://www.pixiv.net/users/80781332",
        artist_name: "悲伤鱼头",
        artist_commentary_title: "注视",
      )
    end

    context "a sample image URL" do
      strategy_should_work(
        "https://cdn.donmai.us/sample/8d/81/__sonetto_reverse_1999_drawn_by_beishang_yutou__sample-8d819da4871c3ca39f428999df8220ce.jpg",
        image_urls: ["https://cdn.donmai.us/original/8d/81/8d819da4871c3ca39f428999df8220ce.jpg"],
        media_files: [{ file_size: 2_433_964 }],
        tags: %w[4girls absurdres aged_down arch armor beishang_yutou bow bowtie braid chinese_commentary closed_mouth commentary dress green_eyes hair_intakes hair_ornament hairband highres indoors long_hair looking_ahead looking_at_viewer multiple_girls orange_hair portrait profile reverse:1999 sidelighting single_braid sonetto_(reverse:1999) statue upper_body white_dress white_hairband window],
        page_url: "https://danbooru.donmai.us/posts/7000000",
        profile_url: "https://www.pixiv.net/users/80781332",
        artist_name: "悲伤鱼头",
        artist_commentary_title: "注视",
      )
    end

    context "a sample image URL for a PNG original" do
      strategy_should_work(
        "https://cdn.donmai.us/sample/fa/dd/__dokibird_indie_virtual_youtuber_drawn_by_aocoa__sample-fadda8ec550a7293bedb7100e54df68c.jpg",
        image_urls: ["https://cdn.donmai.us/original/fa/dd/fadda8ec550a7293bedb7100e54df68c.png"],
        media_files: [{ file_size: 41_634 }],
        tags: %w[1girl :3 aocoa blonde_hair blue_hat crooked_smile dokibird_(vtuber) dokibird_(vtuber)_(retro_doki) earrings green_eyes hair_between_eyes hair_ribbon hat highres indie_virtual_youtuber jewelry long_hair portrait ribbon simple_background single_earring smile solo transparent_background twintails virtual_youtuber],
        page_url: "https://danbooru.donmai.us/posts/7392739",
        profile_url: "https://twitter.com/AoCoa",
        artist_name: "AoCoa",
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
        artist_commentary_title: nil,
      )
    end

    context "A post with a source pointing to itself" do
      strategy_should_work(
        "https://danbooru.donmai.us/posts/4542652",
        image_urls: ["https://cdn.donmai.us/original/b4/44/b44417c286c090059150a5148c36e034.jpg"],
        page_url: "https://danbooru.donmai.us/posts/4542652",
        profile_url: nil,
        artist_name: nil,
        artist_commentary_title: nil,
      )
    end
  end
end
