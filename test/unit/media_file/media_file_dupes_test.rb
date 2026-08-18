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
      assert_equal("b0f7550b021e7eed2f81701b629ea553", MediaFile.pixel_hash("test/files/dupes/countergirl-srgb.jpg"))
      assert_equal("0d45a5397a9180e66be27cf8abaa1c74", MediaFile.pixel_hash("test/files/dupes/countergirl-p3.jpg"))
      assert_equal("d55a89f6780cb8d2c630a0909ae67f2b", MediaFile.pixel_hash("test/files/dupes/countergirl-prophoto.jpg"))
      assert_equal("5248da00038eb4b74b63c79a446775a0", MediaFile.pixel_hash("test/files/dupes/countergirl-adobergb.jpg"))
    end
  end
end
