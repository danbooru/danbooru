require "test_helper"

module Downloads
  class MoebooruTest < ActiveSupport::TestCase
    context "downloading a 'https://yande.re/jpeg/:hash/:file.jpg' jpeg sample url" do
      should "download the original file" do
        @source = "https://yande.re/jpeg/2c6876ac2317fce617e3c5f1a642123b/yande.re%20292092%20hatsune_miku%20tid%20vocaloid.jpg"
        @rewrite = "https://yande.re/image/2c6876ac2317fce617e3c5f1a642123b/yande.re%20292092%20hatsune_miku%20tid%20vocaloid.png"
        assert_rewritten(@rewrite, @source)
        assert_downloaded(1_050_117, @source)
      end
    end
  end
end
