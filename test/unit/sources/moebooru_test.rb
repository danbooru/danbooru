require "test_helper"

module Sources
  class MoebooruTest < ActiveSupport::TestCase
    context "Yande.re:" do
      context "A 'https://yande.re/jpeg/:hash/:file.jpg' jpeg sample url" do
        should "download the original file" do
          @source = "https://yande.re/jpeg/2c6876ac2317fce617e3c5f1a642123b/yande.re%20292092%20hatsune_miku%20tid%20vocaloid.jpg"
          @rewrite = "https://yande.re/image/2c6876ac2317fce617e3c5f1a642123b/yande.re%20292092%20hatsune_miku%20tid%20vocaloid.png"
          assert_rewritten(@rewrite, @source)
          assert_downloaded(1_050_117, @source)
        end
      end

      context "A 'https://files.yande.re/sample/:hash/:file.jpg' sample url" do
        should "work" do
          @site = Sources::Strategies.find("https://files.yande.re/sample/7ecfdead705d7b956b26b1d37b98d089/yande.re%20482880%20sample%20bayashiko%20journey_to_the_west%20sun_wukong.jpg")

          assert_equal("yande.re", @site.site_name)
          assert_equal(@site.image_url, @site.canonical_url)
          assert_nothing_raised { @site.to_h }
        end
      end
    end
  end
end
