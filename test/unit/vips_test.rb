require "test_helper"

class VipsTest < ActiveSupport::TestCase
  context "libvips" do
    should "not load file types we don't support" do
      Danbooru::Tempfile.create(["danbooru-test-", ".ppm"]) do |file|
        file.write("P5\n1 1\n255\n\x00")
        file.flush

        assert_raises(Vips::Error) { Vips::Image.new_from_file(file.path).avg }
      end
    end

    should "load file types we support" do
      %w[jpg/test.jpg png/test.png gif/test.gif webp/test.webp avif/paris_icc_exif_xmp.avif].each do |path|
        assert_operator(Vips::Image.new_from_file("test/files/#{path}").width, :>, 0, path)
      end
    end
  end
end
