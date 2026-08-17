require "test_helper"

class MediaFileDupesTest < ActiveSupport::TestCase
  context "#pixel_hash" do
    should "compute the same pixel hash for images with different EXIF metadata" do
      assert_equal("1839af48fab8688cf72653d6ac4b52ab", MediaFile.md5("test/files/dupes/countergirl-baseline.jpg"))
      assert_equal("fa00b3cc4152933bf98692045fc59a6f", MediaFile.md5("test/files/dupes/countergirl-no-exif.jpg"))

      assert_equal("c135caa2229b6d43d06179503f70ed74", MediaFile.pixel_hash("test/files/dupes/countergirl-baseline.jpg"))
      assert_equal("c135caa2229b6d43d06179503f70ed74", MediaFile.pixel_hash("test/files/dupes/countergirl-no-exif.jpg"))
    end

    should "compute the same pixel hash for progressive and baseline encoded JPEGs" do
      assert_equal("1839af48fab8688cf72653d6ac4b52ab", MediaFile.md5("test/files/dupes/countergirl-baseline.jpg"))
      assert_equal("264cb22336ceaddf8bf2b1ba6d472bb0", MediaFile.md5("test/files/dupes/countergirl-progressive.jpg"))

      assert_equal("c135caa2229b6d43d06179503f70ed74", MediaFile.pixel_hash("test/files/dupes/countergirl-baseline.jpg"))
      assert_equal("c135caa2229b6d43d06179503f70ed74", MediaFile.pixel_hash("test/files/dupes/countergirl-progressive.jpg"))
    end

    should "compute the same pixel hash for greyscale and sRGB images" do
      assert_equal("1073acb0a8a59139a687360bf9031c7f", MediaFile.md5("test/files/dupes/countergirl-grey.png"))
      assert_equal("632766b7230cc2844cf36fa14d2bf765", MediaFile.md5("test/files/dupes/countergirl-grey-srgb.png"))

      assert_equal("d007f30f42cb7c5835fb3d0d9c24587e", MediaFile.pixel_hash("test/files/dupes/countergirl-grey.png"))
      assert_equal("d007f30f42cb7c5835fb3d0d9c24587e", MediaFile.pixel_hash("test/files/dupes/countergirl-grey-srgb.png"))
    end

    should "compute the same pixel hash for a color image with an incompatible greyscale color profile" do
      assert_equal("c135caa2229b6d43d06179503f70ed74", MediaFile.pixel_hash("test/files/dupes/countergirl-no-exif.jpg"))
      assert_equal("c135caa2229b6d43d06179503f70ed74", MediaFile.pixel_hash("test/files/dupes/countergirl-rgb-gray.jpg"))
    end

    should "compute the same pixel hash for images with a transparent alpha channel" do
      assert_equal("cc2e12de5c11afad72540c230e9dea37", MediaFile.md5("test/files/dupes/countergirl.gif"))
      assert_equal("af529aa2250b21fcb37b781a246937e5", MediaFile.md5("test/files/dupes/countergirl.png"))
      assert_equal("830eeb693d0f575ac76c92ed223dc3d8", MediaFile.md5("test/files/dupes/countergirl-no-exif.png"))

      assert_equal("2981edc81606af5552b9cd2db0a60a2c", MediaFile.pixel_hash("test/files/dupes/countergirl.gif"))
      assert_equal("2981edc81606af5552b9cd2db0a60a2c", MediaFile.pixel_hash("test/files/dupes/countergirl.png"))
      assert_equal("2981edc81606af5552b9cd2db0a60a2c", MediaFile.pixel_hash("test/files/dupes/countergirl-no-exif.png"))
    end

    should "compute the same pixel hash for images with an opaque alpha channel" do
      assert_equal("a353ab010901216b56a2be2d90fc8bfc", MediaFile.md5("test/files/dupes/countergirl-whitebg-alpha.png"))
      assert_equal("a4b5924967ace4045546def1609e9abc", MediaFile.md5("test/files/dupes/countergirl-whitebg-noalpha.gif"))
      assert_equal("058a5b03b4b22befe3813f4bc901fe1e", MediaFile.md5("test/files/dupes/countergirl-whitebg-noalpha.png"))

      assert_equal("5199b09cccde8a33c3d204413f5450d9", MediaFile.pixel_hash("test/files/dupes/countergirl-whitebg-alpha.png"))
      assert_equal("5199b09cccde8a33c3d204413f5450d9", MediaFile.pixel_hash("test/files/dupes/countergirl-whitebg-noalpha.gif"))
      assert_equal("5199b09cccde8a33c3d204413f5450d9", MediaFile.pixel_hash("test/files/dupes/countergirl-whitebg-noalpha.png"))
    end

    should "compute different pixel hashes for images with the same pixels but with different dimensions" do
      assert_equal("d7fccdb09eb17ed57ee2aaeff165e415", MediaFile.pixel_hash("test/files/dupes/black-100x200.png"))
      assert_equal("c1d32710ce71b7c02a9d943e1113b31f", MediaFile.pixel_hash("test/files/dupes/black-200x100.png"))
    end

    should "compute different pixel hashes for images with the same pixel values but with different embedded color profiles" do
      assert_equal("51b5c7fe125eca4048cd963617df5668", MediaFile.pixel_hash("test/files/dupes/countergirl-srgb.jpg"))
      assert_equal("56092d3fb1e5b803b4f89c039c4e46b4", MediaFile.pixel_hash("test/files/dupes/countergirl-p3.jpg"))
      assert_equal("ddd8706eb76f051d57bdbab45d7347d5", MediaFile.pixel_hash("test/files/dupes/countergirl-prophoto.jpg"))
      assert_equal("92df52d799527a96819e8aa52c16967f", MediaFile.pixel_hash("test/files/dupes/countergirl-adobergb.jpg"))
    end
  end
end
