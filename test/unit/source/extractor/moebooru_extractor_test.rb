require "test_helper"

module Source::Tests::Extractor
  class MoebooruExtractorTest < ActiveSupport::ExtractorTestCase
    context "For Yande.re," do
      context "a post" do
        strategy_should_work(
          "https://yande.re/post/show/482880",
          image_urls: ["https://files.yande.re/image/7ecfdead705d7b956b26b1d37b98d089/yande.re%20482880.jpg"],
          media_files: [{ file_size: 362_554 }],
          tags: ["bayashiko", "journey_to_the_west", "sun_wukong"],
          page_url: "https://yande.re/post/show/482880",
          profile_url: "https://twitter.com/apononori",
        )
      end

      context "a https://yande.re/sample/:hash/:file.jpg" do
        strategy_should_work(
          "https://files.yande.re/sample/7ecfdead705d7b956b26b1d37b98d089/yande.re%20482880%20sample%20bayashiko%20journey_to_the_west%20sun_wukong.jpg",
          image_urls: ["https://files.yande.re/image/7ecfdead705d7b956b26b1d37b98d089/yande.re%20482880.jpg"],
          media_files: [{ file_size: 362_554 }],
          tags: ["bayashiko", "journey_to_the_west", "sun_wukong"],
          page_url: "https://yande.re/post/show/482880",
          profile_url: "https://twitter.com/apononori",
        )
      end

      context "a 'https://yande.re/jpeg/:hash/:file.jpg' jpeg sample url" do
        strategy_should_work(
          "https://yande.re/jpeg/2c6876ac2317fce617e3c5f1a642123b/yande.re%20292092%20hatsune_miku%20tid%20vocaloid.jpg",
          image_urls: ["https://files.yande.re/image/2c6876ac2317fce617e3c5f1a642123b/yande.re%20292092.png"],
          media_files: [{ file_size: 1_050_117 }],
        )
      end

      context "a deleted yande.re post with the post id" do
        strategy_should_work(
          "https://files.yande.re/sample/fb27a7ea6c48b2ef76fe915e378b9098/yande.re%20398018%20detexted%20misaki_kurehito%20saenai_heroine_no_sodatekata%20sawamura_spencer_eriri%20thighhighs.jpg",
          image_urls: ["https://files.yande.re/image/fb27a7ea6c48b2ef76fe915e378b9098/yande.re%20398018.png"],
          page_url: "https://yande.re/post/show/398018",
          tags: ["misaki_kurehito", "saenai_heroine_no_sodatekata", "sawamura_spencer_eriri", "detexted", "thighhighs"],
          media_files: [{ file_size: 9_118_998 }],
        )
      end

      context "a deleted yande.re post without the post id" do
        strategy_should_work(
          "https://files.yande.re/jpeg/fb27a7ea6c48b2ef76fe915e378b9098.jpg",
          image_urls: ["https://files.yande.re/image/fb27a7ea6c48b2ef76fe915e378b9098.png"],
          media_files: [{ file_size: 9_118_998 }],
        )
      end

      context "a yande.re post with a saucenao referer" do
        strategy_should_work(
          "https://yande.re/post/show/469929",
          referer: "https://saucenao.com",
          image_urls: ["https://files.yande.re/image/36b031b266605d89aed2b62d479e64b1/yande.re%20469929.jpg"],
          page_url: "https://yande.re/post/show/469929",
          tags: %w[anchovy bandages darjeeling girls_und_panzer katyusha kay_(girls_und_panzer) mika_(girls_und_panzer) nishi_kinuyo nishizumi_maho nishizumi_miho shimada_arisu uniform],
        )
      end

      context "a https://yande.re/post/show?md5=<md5> URL" do
        strategy_should_work(
          "https://yande.re/post/show?md5=7ecfdead705d7b956b26b1d37b98d089",
          image_urls: ["https://files.yande.re/image/7ecfdead705d7b956b26b1d37b98d089/yande.re%20482880.jpg"],
          media_files: [{ file_size: 362_554 }],
          tags: ["bayashiko", "journey_to_the_west", "sun_wukong"],
          page_url: "https://yande.re/post/show/482880",
          profile_url: "https://twitter.com/apononori",
        )
      end
    end

    context "For konachan.com," do
      context "a sample url" do
        strategy_should_work(
          "https://konachan.com/sample/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916%20sample.jpg",
          image_urls: ["https://konachan.com/image/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916.png"],
          media_files: [{ file_size: 8_167_593 }],
          tags: %w[anthropomorphism bed blonde_hair bow brown_eyes doll girls_frontline hara_shoutarou hood long_hair pantyhose scar skirt twintails ump-45_(girls_frontline) ump-9_(girls_frontline)],
          profile_url: "https://www.pixiv.net/users/22528152",
        )
      end

      context "a jpeg url" do
        strategy_should_work(
          "https://konachan.com/jpeg/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916%20anthropomorphism%20bed%20blonde_hair%20bow%20brown_eyes%20doll%20girls_frontline%20hara_shoutarou%20hoodie%20long_hair%20pantyhose%20scar%20skirt%20twintails.jpg",
          image_urls: ["https://konachan.com/image/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916.png"],
          media_files: [{ file_size: 8_167_593 }],
          tags: %w[anthropomorphism bed blonde_hair bow brown_eyes doll girls_frontline hara_shoutarou hood long_hair pantyhose scar skirt twintails ump-45_(girls_frontline) ump-9_(girls_frontline)],
          profile_url: "https://www.pixiv.net/users/22528152",
        )
      end

      context "a full-size image url" do
        strategy_should_work(
          "https://konachan.com/image/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916.png",
          image_urls: ["https://konachan.com/image/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916.png"],
          media_files: [{ file_size: 8_167_593 }],
          tags: %w[anthropomorphism bed blonde_hair bow brown_eyes doll girls_frontline hara_shoutarou hood long_hair pantyhose scar skirt twintails ump-45_(girls_frontline) ump-9_(girls_frontline)],
          profile_url: "https://www.pixiv.net/users/22528152",
        )
      end

      context "a post url" do
        strategy_should_work(
          "https://konachan.com/post/show/270916",
          image_urls: ["https://konachan.com/image/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916.png"],
          media_files: [{ file_size: 8_167_593 }],
          tags: %w[anthropomorphism bed blonde_hair bow brown_eyes doll girls_frontline hara_shoutarou hood long_hair pantyhose scar skirt twintails ump-45_(girls_frontline) ump-9_(girls_frontline)],
          profile_url: "https://www.pixiv.net/users/22528152",
        )
      end

      context "a https://konachan.com/post/show?md5=<md5>" do
        strategy_should_work(
          "https://konachan.com/post/show?md5=ca12cdb79a66d242e95a6f958341bf05",
          image_urls: ["https://konachan.com/image/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916.png"],
          media_files: [{ file_size: 8_167_593 }],
          tags: %w[anthropomorphism bed blonde_hair bow brown_eyes doll girls_frontline hara_shoutarou hood long_hair pantyhose scar skirt twintails ump-45_(girls_frontline) ump-9_(girls_frontline)],
          profile_url: "https://www.pixiv.net/users/22528152",
        )
      end
    end
  end
end
