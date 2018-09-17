require "test_helper"

module Sources
  class MoebooruTest < ActiveSupport::TestCase
    def assert_source_data_equals(url, referer = nil, site_name: nil, image_url: nil, page_url: nil, size: nil)
      site = Sources::Strategies.find(url)

      assert_equal(site_name, site.site_name)
      assert_equal(image_url, site.image_url)
      assert_equal([image_url], site.image_urls)
      assert_equal(image_url, site.canonical_url)
      assert_equal(page_url, site.page_url) if page_url.present?
      assert_equal(size, site.size)
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

      context "Fetching data for an active yande.re .jpg post" do
        should "work" do
          @samp = "https://files.yande.re/sample/7ecfdead705d7b956b26b1d37b98d089/yande.re%20482880%20sample%20bayashiko%20journey_to_the_west%20sun_wukong.jpg"
          @full = "https://files.yande.re/image/7ecfdead705d7b956b26b1d37b98d089/yande.re%20482880.jpg"
          @page = "https://yande.re/post/show/482880"
          @size = 362_554

          assert_source_data_equals(@samp, site_name: "yande.re", image_url: @full, page_url: @page, size: @size)
          assert_source_data_equals(@full, site_name: "yande.re", image_url: @full, page_url: @page, size: @size)
          assert_source_data_equals(@page, site_name: "yande.re", image_url: @full, page_url: @page, size: @size)
        end
      end

      context "Fetching data for a deleted yande.re .png post with the post id" do
        should "work" do
          @samp = "https://files.yande.re/sample/fb27a7ea6c48b2ef76fe915e378b9098/yande.re%20398018%20detexted%20misaki_kurehito%20saenai_heroine_no_sodatekata%20sawamura_spencer_eriri%20thighhighs.jpg"
          @jpeg = "https://files.yande.re/sample/fb27a7ea6c48b2ef76fe915e378b9098/yande.re%20398018%20detexted%20misaki_kurehito%20saenai_heroine_no_sodatekata%20sawamura_spencer_eriri%20thighhighs.jpg"
          @full = "https://files.yande.re/image/fb27a7ea6c48b2ef76fe915e378b9098/yande.re%20398018.png"
          @page = "https://yande.re/post/show/398018"
          @size = 9_118_998

          assert_source_data_equals(@samp, site_name: "yande.re", image_url: @full, page_url: @page, size: @size)
          assert_source_data_equals(@jpeg, site_name: "yande.re", image_url: @full, page_url: @page, size: @size)
          assert_source_data_equals(@full, site_name: "yande.re", image_url: @full, page_url: @page, size: @size)
          assert_source_data_equals(@page, site_name: "yande.re", image_url: @full, page_url: @page, size: @size)
        end
      end

      context "Fetching data for a deleted yande.re .png post without the post id" do
        should "work" do
          @samp = "https://files.yande.re/sample/fb27a7ea6c48b2ef76fe915e378b9098.jpg"
          @jpeg = "https://files.yande.re/jpeg/fb27a7ea6c48b2ef76fe915e378b9098.jpg"
          @full = "https://files.yande.re/image/fb27a7ea6c48b2ef76fe915e378b9098.png"
          @size = 9_118_998

          assert_source_data_equals(@samp, site_name: "yande.re", image_url: @full, size: @size)
          assert_source_data_equals(@jpeg, site_name: "yande.re", image_url: @full, size: @size)
          assert_source_data_equals(@full, site_name: "yande.re", image_url: @full, size: @size)
        end
      end
    end

    context "Konachan.com:" do
      context "Fetching data for an active konachan.com .png post" do
        should "work" do
          @samp = "https://konachan.com/sample/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916%20sample.jpg"
          @jpeg = "https://konachan.com/jpeg/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916%20anthropomorphism%20bed%20blonde_hair%20bow%20brown_eyes%20doll%20girls_frontline%20hara_shoutarou%20hoodie%20long_hair%20pantyhose%20scar%20skirt%20twintails.jpg"
          @full = "https://konachan.com/image/ca12cdb79a66d242e95a6f958341bf05/Konachan.com%20-%20270916.png"
          @page = "https://konachan.com/post/show/270916"
          @size = 8_167_593

          assert_source_data_equals(@samp, site_name: "konachan.com", image_url: @full, page_url: @page, size: @size)
          assert_source_data_equals(@jpeg, site_name: "konachan.com", image_url: @full, page_url: @page, size: @size)
          assert_source_data_equals(@full, site_name: "konachan.com", image_url: @full, page_url: @page, size: @size)
          assert_source_data_equals(@page, site_name: "konachan.com", image_url: @full, page_url: @page, size: @size)
        end
      end
    end
  end
end
