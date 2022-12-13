require "test_helper"

module Sources
  class MoebooruTest < ActiveSupport::TestCase
    context "For Yande.re," do
      context "a post" do
        strategy_should_work(
          "https://yande.re/post/show/482880",
          image_urls: ["https://files.yande.re/image/7ecfdead705d7b956b26b1d37b98d089/yande.re%20482880.jpg"],
          download_size: 362_554,
          tags: ["bayashiko", "journey_to_the_west", "sun_wukong"],
          page_url: "https://yande.re/post/show/482880",
          profile_url: "https://twitter.com/apononori"
        )
      end

      context "a https://yande.re/sample/:hash/:file.jpg" do
        strategy_should_work(
          "https://files.yande.re/sample/7ecfdead705d7b956b26b1d37b98d089/yande.re%20482880%20sample%20bayashiko%20journey_to_the_west%20sun_wukong.jpg",
          image_urls: ["https://files.yande.re/image/7ecfdead705d7b956b26b1d37b98d089/yande.re%20482880.jpg"],
          download_size: 362_554,
          tags: ["bayashiko", "journey_to_the_west", "sun_wukong"],
          page_url: "https://yande.re/post/show/482880",
          profile_url: "https://twitter.com/apononori"
        )
      end

      context "a 'https://yande.re/jpeg/:hash/:file.jpg' jpeg sample url" do
        strategy_should_work(
          "https://yande.re/jpeg/2c6876ac2317fce617e3c5f1a642123b/yande.re%20292092%20hatsune_miku%20tid%20vocaloid.jpg",
          image_urls: ["https://files.yande.re/image/2c6876ac2317fce617e3c5f1a642123b/yande.re%20292092.png"],
          download_size: 1_050_117
        )
      end

      context "a deleted yande.re post with the post id" do
        strategy_should_work(
          "https://files.yande.re/sample/fb27a7ea6c48b2ef76fe915e378b9098/yande.re%20398018%20detexted%20misaki_kurehito%20saenai_heroine_no_sodatekata%20sawamura_spencer_eriri%20thighhighs.jpg",
          image_urls: ["https://files.yande.re/image/fb27a7ea6c48b2ef76fe915e378b9098/yande.re%20398018.png"],
          page_url: "https://yande.re/post/show/398018",
          tags: ["misaki_kurehito", "saenai_heroine_no_sodatekata", "sawamura_spencer_eriri", "detexted", "thighhighs"],
          download_size: 9_118_998
        )
      end

      context "a deleted yande.re post without the post id" do
        strategy_should_work(
          "https://files.yande.re/jpeg/fb27a7ea6c48b2ef76fe915e378b9098.jpg",
          image_urls: ["https://files.yande.re/image/fb27a7ea6c48b2ef76fe915e378b9098.png"],
          download_size: 9_118_998
        )
      end

      context "a yande.re post with a saucenao referer" do
        strategy_should_work(
          "https://yande.re/post/show/469929",
          referer: "https://saucenao.com",
          image_urls: ["https://files.yande.re/image/36b031b266605d89aed2b62d479e64b1/yande.re%20469929.jpg"],
          page_url: "https://yande.re/post/show/469929",
          tags: %w[anchovy bandages darjeeling girls_und_panzer katyusha kay_(girls_und_panzer) mika_(girls_und_panzer) nishi_kinuyo nishizumi_maho nishizumi_miho shimada_arisu uniform]
        )
      end

      context "a https://yande.re/post/show?md5=<md5> URL" do
        strategy_should_work(
          "https://yande.re/post/show?md5=7ecfdead705d7b956b26b1d37b98d089",
          image_urls: ["https://files.yande.re/image/7ecfdead705d7b956b26b1d37b98d089/yande.re%20482880.jpg"],
          download_size: 362_554,
          tags: ["bayashiko", "journey_to_the_west", "sun_wukong"],
          page_url: "https://yande.re/post/show/482880",
          profile_url: "https://twitter.com/apononori"
        )
      end
    end

    context "For konachan.com," do
      context "a sample url" do
        strategy_should_work(
          "https://konachan.com/sample/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916%20sample.jpg",
          image_urls: ["https://konachan.com/image/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916.png"],
          download_size: 8_167_593,
          tags: %w[anthropomorphism bed blonde_hair bow brown_eyes doll girls_frontline hara_shoutarou hoodie long_hair pantyhose scar skirt twintails ump-45_(girls_frontline) ump-9_(girls_frontline)],
          profile_url: "https://www.pixiv.net/users/22528152"
        )
      end

      context "a jpeg url" do
        strategy_should_work(
          "https://konachan.com/jpeg/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916%20anthropomorphism%20bed%20blonde_hair%20bow%20brown_eyes%20doll%20girls_frontline%20hara_shoutarou%20hoodie%20long_hair%20pantyhose%20scar%20skirt%20twintails.jpg",
          image_urls: ["https://konachan.com/image/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916.png"],
          download_size: 8_167_593,
          tags: %w[anthropomorphism bed blonde_hair bow brown_eyes doll girls_frontline hara_shoutarou hoodie long_hair pantyhose scar skirt twintails ump-45_(girls_frontline) ump-9_(girls_frontline)],
          profile_url: "https://www.pixiv.net/users/22528152"
        )
      end

      context "a full-size image url" do
        strategy_should_work(
          "https://konachan.com/image/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916.png",
          image_urls: ["https://konachan.com/image/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916.png"],
          download_size: 8_167_593,
          tags: %w[anthropomorphism bed blonde_hair bow brown_eyes doll girls_frontline hara_shoutarou hoodie long_hair pantyhose scar skirt twintails ump-45_(girls_frontline) ump-9_(girls_frontline)],
          profile_url: "https://www.pixiv.net/users/22528152"
        )
      end

      context "a post url" do
        strategy_should_work(
          "https://konachan.com/post/show/270916",
          image_urls: ["https://konachan.com/image/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916.png"],
          download_size: 8_167_593,
          tags: %w[anthropomorphism bed blonde_hair bow brown_eyes doll girls_frontline hara_shoutarou hoodie long_hair pantyhose scar skirt twintails ump-45_(girls_frontline) ump-9_(girls_frontline)],
          profile_url: "https://www.pixiv.net/users/22528152"
        )
      end

      context "a https://konachan.com/post/show?md5=<md5>" do
        strategy_should_work(
          "https://konachan.com/post/show?md5=ca12cdb79a66d242e95a6f958341bf05",
          image_urls: ["https://konachan.com/image/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916.png"],
          download_size: 8_167_593,
          tags: %w[anthropomorphism bed blonde_hair bow brown_eyes doll girls_frontline hara_shoutarou hoodie long_hair pantyhose scar skirt twintails ump-45_(girls_frontline) ump-9_(girls_frontline)],
          profile_url: "https://www.pixiv.net/users/22528152"
        )
      end
    end

    should "Parse yande.re URLs correctly" do
      assert_equal("https://yande.re/post/show/377828", Source::URL.page_url("https://files.yande.re/image/b66909b940e8d77accab7c9b25aa4dc3/yande.re%20377828.png"))
      assert_equal("https://yande.re/post/show/349790", Source::URL.page_url("https://files.yande.re/image/2a5d1d688f565cb08a69ecf4e35017ab/yande.re%20349790%20breast_hold%20kurashima_tomoyasu%20mahouka_koukou_no_rettousei%20naked%20nipples.jpg"))
      assert_equal("https://yande.re/post/show/469784", Source::URL.page_url("https://files.yande.re/image/e4c2ba38de88ff1640aaebff84c84e81/469784.jpg"))
      assert_equal("https://yande.re/post/show?md5=b4b1d11facd1700544554e4805d47bb6", Source::URL.page_url("https://yande.re/image/b4b1d11facd1700544554e4805d47bb6/.png"))
      assert_equal("https://yande.re/post/show?md5=22577d2344fe694cf47f80563031b3cd", Source::URL.page_url("https://yande.re/jpeg/22577d2344fe694cf47f80563031b3cd.jpg"))

      assert(Source::URL.image_url?("https://yande.re/sample/ceb6a12e87945413a95b90fada406f91/.jpg"))
      assert(Source::URL.image_url?("https://yande.re/jpeg/22577d2344fe694cf47f80563031b3cd.jpg"))
      assert(Source::URL.image_url?("https://assets.yande.re/data/preview/7e/cf/7ecfdead705d7b956b26b1d37b98d089.jpg"))
      assert(Source::URL.image_url?("https://ayase.yande.re/image/2d0d229fd8465a325ee7686fcc7f75d2/yande.re%20192481%20animal_ears%20bunny_ears%20garter_belt%20headphones%20mitha%20stockings%20thighhighs.jpg"))
      assert(Source::URL.image_url?("https://yuno.yande.re/image/1764b95ae99e1562854791c232e3444b/yande.re%20281544%20cameltoe%20erect_nipples%20fundoshi%20horns%20loli%20miyama-zero%20sarashi%20sling_bikini%20swimsuits.jpg"))

      assert(Source::URL.page_url?("https://yande.re/post/show?md5=2c95b8975b73744da2bcbed9619c1d59"))
      assert(Source::URL.page_url?("https://yande.re/post?tags=md5:2c95b8975b73744da2bcbed9619c1d59"))
      assert(Source::URL.page_url?("https://yande.re/post/show/3"))
    end

    should "Parse konachan.com URLs correctly" do
      assert_equal("https://konachan.com/post/show/270807", Source::URL.page_url("https://konachan.com/image/5d633771614e4bf5c17df19a0f0f333f/Konachan.com%20-%20270807%20black_hair%20bokuden%20clouds%20grass%20landscape%20long_hair%20original%20phone%20rope%20scenic%20seifuku%20skirt%20sky%20summer%20torii%20tree.jpg"))
      assert_equal("https://konachan.com/post/show/270803", Source::URL.page_url("https://konachan.com/sample/e2e2994bae738ff52fff7f4f50b069d5/Konachan.com%20-%20270803%20sample.jpg"))
      assert_equal("https://konachan.com/post/show?md5=99a3c4f10c327d54486259a74173fc0b", Source::URL.page_url("https://konachan.com/image/99a3c4f10c327d54486259a74173fc0b.jpg"))

      assert(Source::URL.image_url?("https://konachan.com/data/preview/5d/63/5d633771614e4bf5c17df19a0f0f333f.jpg"))
      assert(Source::URL.image_url?("https://konachan.com/sample/e2e2994bae738ff52fff7f4f50b069d5/Konachan.com%20-%20270803%20sample.jpg"))
      assert(Source::URL.image_url?("https://konachan.com/jpeg/e2e2994bae738ff52fff7f4f50b069d5/Konachan.com%20-%20270803%20banishment%20bicycle%20grass%20group%20male%20night%20original%20rooftop%20scenic%20signed%20stars%20tree.jpg"))

      assert(Source::URL.page_url?("https://konachan.com/post/show?md5=955aa45f3b452b415509b47dcc9475ac"))
      assert(Source::URL.page_url?("https://konachan.com/post?tags=md5:955aa45f3b452b415509b47dcc9475ac"))
      assert(Source::URL.page_url?("https://konachan.com/post/show/270803/banishment-bicycle-grass-group-male-night-original"))
    end
  end
end
