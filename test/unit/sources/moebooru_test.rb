require "test_helper"

module Sources
  class MoebooruTest < ActiveSupport::TestCase
    def assert_source_data_equals(url, referer = nil, site_name: nil, image_url: nil, page_url: nil, preview_url: nil, size: nil, tags: [], profile_url: nil, **params)
      site = Sources::Strategies.find(url)

      assert_equal(site_name, site.site_name)
      assert_equal(image_url, site.image_url)
      assert_equal([image_url], site.image_urls)
      assert_equal(image_url, site.canonical_url)
      assert_equal(preview_url, site.preview_url)
      assert_equal([preview_url], site.preview_urls)
      assert_equal(page_url, site.page_url) if page_url.present?
      assert_equal(tags.sort, site.tags.map(&:first).sort)
      assert_equal(profile_url.to_s, site.profile_url.to_s)
      assert_equal(size, site.remote_size)
      assert_nothing_raised { site.to_h }
    end

    context "Yande.re:" do
      context "A 'https://yande.re/jpeg/:hash/:file.jpg' jpeg sample url" do
        should "download the original file" do
          @source = "https://yande.re/jpeg/2c6876ac2317fce617e3c5f1a642123b/yande.re%20292092%20hatsune_miku%20tid%20vocaloid.jpg"
          @rewrite = "https://files.yande.re/image/2c6876ac2317fce617e3c5f1a642123b/yande.re%20292092.png"
          assert_rewritten(@rewrite, @source)
          assert_downloaded(1_050_117, @source)
        end
      end

      context "A 'https://assets.yande.re/preview/:hh/:hh/:file.jpg' preview url" do
        should "return a non-empty list of preview_urls" do
          url = "https://assets.yande.re/data/preview/7c/d1/7cd124fc28203233cce3bade26651d43.jpg"
          site = Sources::Strategies.find(url)

          assert_equal([url], site.preview_urls)
        end
      end

      context "Fetching data for an active yande.re .jpg post" do
        should "work" do
          @prev = "https://files.yande.re/data/preview/7e/cf/7ecfdead705d7b956b26b1d37b98d089.jpg"
          @samp = "https://files.yande.re/sample/7ecfdead705d7b956b26b1d37b98d089/yande.re%20482880%20sample%20bayashiko%20journey_to_the_west%20sun_wukong.jpg"
          @full = "https://files.yande.re/image/7ecfdead705d7b956b26b1d37b98d089/yande.re%20482880.jpg"
          @page = "https://yande.re/post/show/482880"
          @tags = ["bayashiko", "journey_to_the_west", "sun_wukong"]
          @size = 362_554
          @profile_url = "https://twitter.com/apononori"
          @data = { site_name: "yande.re", preview_url: @prev, image_url: @full, page_url: @page, size: @size, tags: @tags, profile_url: @profile_url }

          assert_source_data_equals(@samp, **@data)
          assert_source_data_equals(@full, **@data)
          assert_source_data_equals(@page, **@data)
        end
      end

      context "Fetching data for a deleted yande.re .png post with the post id" do
        should "work" do
          @prev = "https://files.yande.re/data/preview/fb/27/fb27a7ea6c48b2ef76fe915e378b9098.jpg"
          @samp = "https://files.yande.re/sample/fb27a7ea6c48b2ef76fe915e378b9098/yande.re%20398018%20detexted%20misaki_kurehito%20saenai_heroine_no_sodatekata%20sawamura_spencer_eriri%20thighhighs.jpg"
          @jpeg = "https://files.yande.re/sample/fb27a7ea6c48b2ef76fe915e378b9098/yande.re%20398018%20detexted%20misaki_kurehito%20saenai_heroine_no_sodatekata%20sawamura_spencer_eriri%20thighhighs.jpg"
          @full = "https://files.yande.re/image/fb27a7ea6c48b2ef76fe915e378b9098/yande.re%20398018.png"
          @page = "https://yande.re/post/show/398018"
          @tags = ["misaki_kurehito", "saenai_heroine_no_sodatekata", "sawamura_spencer_eriri", "detexted", "thighhighs"]
          @size = 9_118_998
          @data = { site_name: "yande.re", preview_url: @prev, image_url: @full, page_url: @page, size: @size, tags: @tags, profile_url: nil }

          assert_source_data_equals(@samp, **@data)
          assert_source_data_equals(@jpeg, **@data)
          assert_source_data_equals(@full, **@data)
          assert_source_data_equals(@page, **@data)
        end
      end

      context "Fetching data for a deleted yande.re .png post without the post id" do
        should "work" do
          @prev = "https://files.yande.re/data/preview/fb/27/fb27a7ea6c48b2ef76fe915e378b9098.jpg"
          @samp = "https://files.yande.re/sample/fb27a7ea6c48b2ef76fe915e378b9098.jpg"
          @jpeg = "https://files.yande.re/jpeg/fb27a7ea6c48b2ef76fe915e378b9098.jpg"
          @full = "https://files.yande.re/image/fb27a7ea6c48b2ef76fe915e378b9098.png"
          @tags = []
          @size = 9_118_998
          @data = { site_name: "yande.re", preview_url: @prev, image_url: @full, page_url: @page, size: @size, tags: @tags, profile_url: nil }

          assert_source_data_equals(@samp, **@data)
          assert_source_data_equals(@jpeg, **@data)
          assert_source_data_equals(@full, **@data)
        end
      end
    end

    context "Konachan.com:" do
      context "Fetching data for an active konachan.com .png post" do
        should "work" do
          @prev = "https://konachan.com/data/preview/ca/12/ca12cdb79a66d242e95a6f958341bf05.jpg"
          @samp = "https://konachan.com/sample/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916%20sample.jpg"
          @jpeg = "https://konachan.com/jpeg/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916%20anthropomorphism%20bed%20blonde_hair%20bow%20brown_eyes%20doll%20girls_frontline%20hara_shoutarou%20hoodie%20long_hair%20pantyhose%20scar%20skirt%20twintails.jpg"
          @full = "https://konachan.com/image/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916.png"
          @page = "https://konachan.com/post/show/270916"
          @size = 8_167_593
          @tags = %w[
            anthropomorphism bed blonde_hair bow brown_eyes doll
            girls_frontline hara_shoutarou hoodie long_hair pantyhose scar skirt
            twintails ump-45_(girls_frontline) ump-9_(girls_frontline)
          ]
          @profile_url = "https://www.pixiv.net/users/22528152"

          @data = { site_name: "konachan.com", preview_url: @prev, image_url: @full, page_url: @page, size: @size, tags: @tags, profile_url: @profile_url }
          assert_source_data_equals(@samp, **@data)
          assert_source_data_equals(@jpeg, **@data)
          assert_source_data_equals(@full, **@data)
          assert_source_data_equals(@page, **@data)
        end
      end
    end

    context "normalizing for source" do
      should "normalize yande.re sources correctly" do
        source1 = "https://files.yande.re/image/b66909b940e8d77accab7c9b25aa4dc3/yande.re%20377828.png"
        source2 = "https://files.yande.re/image/2a5d1d688f565cb08a69ecf4e35017ab/yande.re%20349790%20breast_hold%20kurashima_tomoyasu%20mahouka_koukou_no_rettousei%20naked%20nipples.jpg"
        source3 = "https://files.yande.re/image/e4c2ba38de88ff1640aaebff84c84e81/469784.jpg"
        source4 = "https://yande.re/image/b4b1d11facd1700544554e4805d47bb6/.png"
        source5 = "https://yande.re/jpeg/22577d2344fe694cf47f80563031b3cd.jpg"

        assert_equal("https://yande.re/post/show/377828", Sources::Strategies.normalize_source(source1))
        assert_equal("https://yande.re/post/show/349790", Sources::Strategies.normalize_source(source2))
        assert_equal("https://yande.re/post/show/469784", Sources::Strategies.normalize_source(source3))
        assert_equal("https://yande.re/post?tags=md5:b4b1d11facd1700544554e4805d47bb6", Sources::Strategies.normalize_source(source4))
        assert_equal("https://yande.re/post?tags=md5:22577d2344fe694cf47f80563031b3cd", Sources::Strategies.normalize_source(source5))
      end

      should "normalize konachan.com sources correctly" do
        source1 = "https://konachan.com/image/5d633771614e4bf5c17df19a0f0f333f/Konachan.com%20-%20270807%20black_hair%20bokuden%20clouds%20grass%20landscape%20long_hair%20original%20phone%20rope%20scenic%20seifuku%20skirt%20sky%20summer%20torii%20tree.jpg"
        source2 = "https://konachan.com/sample/e2e2994bae738ff52fff7f4f50b069d5/Konachan.com%20-%20270803%20sample.jpg"
        source3 = "https://konachan.com/image/99a3c4f10c327d54486259a74173fc0b.jpg"

        assert_equal("https://konachan.com/post/show/270807", Sources::Strategies.normalize_source(source1))
        assert_equal("https://konachan.com/post/show/270803", Sources::Strategies.normalize_source(source2))
        assert_equal("https://konachan.com/post?tags=md5:99a3c4f10c327d54486259a74173fc0b", Sources::Strategies.normalize_source(source3))
      end
    end
  end
end
