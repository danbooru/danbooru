require "test_helper"

class MediaFileJpgTest < ActiveSupport::TestCase
  context "#dimensions" do
    should "determine the correct dimensions for a jpeg file" do
      assert_equal([500, 335], MediaFile.open("test/files/jpg/test.jpg").dimensions)
      assert_equal([668, 996], MediaFile.open("test/files/jpg/test-blank.jpg").dimensions)
      assert_equal([529, 600], MediaFile.open("test/files/jpg/test-exif-small.jpg").dimensions)
      assert_equal([1356, 911], MediaFile.open("test/files/jpg/test-large.jpg").dimensions)
    end
  end

  context "#file_ext" do
    should "determine the correct extension for a jpeg file" do
      assert_equal(:jpg, MediaFile.open("test/files/jpg/test.jpg").file_ext)
      assert_equal(:jpg, MediaFile.open("test/files/jpg/test-blank.jpg").file_ext)
      assert_equal(:jpg, MediaFile.open("test/files/jpg/test-exif-small.jpg").file_ext)
      assert_equal(:jpg, MediaFile.open("test/files/jpg/test-large.jpg").file_ext)
    end
  end

  should "determine the correct md5 for a jpeg file" do
    assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76", MediaFile.open("test/files/jpg/test.jpg").md5)
  end

  should "determine the correct filesize for a jpeg file" do
    assert_equal(28_086, MediaFile.open("test/files/jpg/test.jpg").file_size)
  end

  context "#preview" do
    should "generate a preview image for a static image" do
      assert_equal([150, 101], MediaFile.open("test/files/jpg/test.jpg").preview(150, 150).dimensions)
    end

    should "be able to fit to width only" do
      assert_equal([400, 268], MediaFile.open("test/files/jpg/test.jpg").preview(400, nil).dimensions)
    end

    should "generate a thumbnail with the correct colors for a CMYK image with no color profile" do
      assert_equal("4c9515d85842a291f6512c93458dd7b8", MediaFile.open("test/files/jpg/test-cmyk-no-profile.jpg").preview(180, 180).pixel_hash)
    end
  end

  context "#pixel_hash" do
    should "return the file's md5 for corrupted files" do
      assert_equal(MediaFile.md5("test/files/jpg/test-blank.jpg"), MediaFile.pixel_hash("test/files/jpg/test-blank.jpg"))
      assert_equal(MediaFile.md5("test/files/jpg/test-corrupt.jpg"), MediaFile.pixel_hash("test/files/jpg/test-corrupt.jpg"))
      assert_equal(MediaFile.md5("test/files/jpg/test-exif-small.jpg"), MediaFile.pixel_hash("test/files/jpg/test-exif-small.jpg"))
      assert_equal(MediaFile.md5("test/files/jpg/test-large.jpg"), MediaFile.pixel_hash("test/files/jpg/test-large.jpg"))
    end

    should "work for normal images" do
      assert_equal("01cb481ec7730b7cfced57ffa5abd196", MediaFile.pixel_hash("test/files/jpg/test.jpg"))
      assert_equal("dfcdf4d8e525ffd7057f103384126cf0", MediaFile.pixel_hash("test/files/jpg/test-cmyk-no-profile.jpg"))
      assert_equal("85e9fde0ba6cc7d4fedf24c71bb6277b", MediaFile.pixel_hash("test/files/jpg/test-grey-no-profile.jpg"))
      assert_equal("7bc62a583c0eb07de4fb7fa0dc9e0851", MediaFile.pixel_hash("test/files/jpg/test-rotation-90cw.jpg"))
      assert_equal("510aa465afbba3d7d818038b7aa7bb6f", MediaFile.pixel_hash("test/files/jpg/test-rotation-180.jpg"))
      assert_equal("ac0220aea5683e3c4ffcb2c7b34078e8", MediaFile.pixel_hash("test/files/jpg/test-rotation-270cw.jpg"))
      assert_equal("0365fdfe0e905167c14c67e2bbdf8110", MediaFile.pixel_hash("test/files/jpg/test-weird-profile.jpg"))
    end
  end

  context "a corrupt JPEG" do
    should "still read the metadata" do
      @file = MediaFile.open("test/files/jpg/test-corrupt.jpg")
      @metadata = @file.metadata

      assert_equal(true, @file.is_corrupt?)
      assert_equal("libvips error", @file.error)
      assert_equal(1, @metadata["File:ColorComponents"])
      assert_equal(11, @metadata.count)
    end
  end

  context "a greyscale image without an embedded color profile" do
    should "successfully generate a thumbnail" do
      @image = MediaFile.open("test/files/jpg/test-grey-no-profile.jpg")
      @preview = @image.preview(150, 150)

      assert_equal(1, @image.channels)
      assert_equal(:"b-w", @image.colorspace)
      assert_equal([535, 290], @image.dimensions)

      # XXX This will fail on libvips lower than 8.10. Before 8.10 it's 3
      # channel srgb, after 8.10 it's 1 channel greyscale.
      assert_equal(1, @preview.channels)
      assert_equal(:"b-w", @preview.colorspace)
      assert_equal([150, 81], @preview.dimensions)
    end
  end

  context "a CMYK image without an embedded color profile" do
    should "successfully generate a thumbnail" do
      @image = MediaFile.open("test/files/jpg/test-cmyk-no-profile.jpg")
      @preview = @image.preview(150, 150)

      assert_equal(4, @image.channels)
      assert_equal(:cmyk, @image.colorspace)
      assert_equal([197, 256], @image.dimensions)

      assert_equal(4, @preview.channels)
      assert_equal(:cmyk, @preview.colorspace)
      assert_equal([115, 150], @preview.dimensions)
    end
  end

  context "an image with a weird embedded color profile" do
    should "successfully generate a thumbnail" do
      @image = MediaFile.open("test/files/jpg/test-weird-profile.jpg")
      @preview = @image.preview(150, 150)

      assert_equal(3, @image.channels)
      assert_equal(:srgb, @image.colorspace)
      assert_equal([154, 192], @image.dimensions)

      assert_equal(3, @preview.channels)
      assert_equal(:srgb, @preview.colorspace)
      assert_equal([120, 150], @preview.dimensions)
    end
  end

  context "a large JPEG with an orientation flag" do
    should "read the whole image without `out of order read` errors" do
      @file = MediaFile.open("test/files/jpg/test-rotation-270cw-large.jpg")

      assert_equal([1104, 736], @file.dimensions)
      assert_equal([180, 120], @file.preview(180, 180).dimensions)
      assert_nil(@file.error)
      assert_equal("b9f80b26f56c1877b8a7f12b42e76909", @file.md5)
      assert_equal("f4602dd62706f8607b86cec90b51d498", @file.pixel_hash)
    end
  end

  context "a JPEG that is rotated 90 degrees clockwise" do
    should "rotate the image correctly" do
      @file = MediaFile.open("test/files/jpg/test-rotation-90cw.jpg")

      assert_equal([96, 128], @file.dimensions)
      assert_equal([48, 64], @file.preview(64, 64).dimensions)
      assert_equal("7bc62a583c0eb07de4fb7fa0dc9e0851", @file.pixel_hash)
    end
  end

  context "a JPEG that is rotated 270 degrees clockwise" do
    should "rotate the image correctly" do
      @file = MediaFile.open("test/files/jpg/test-rotation-270cw.jpg")

      assert_equal([100, 66], @file.dimensions)
      assert_equal([50, 33], @file.preview(50, 50).dimensions)
      assert_equal("ac0220aea5683e3c4ffcb2c7b34078e8", @file.pixel_hash)
    end
  end

  context "a JPEG that is rotated 180 degrees" do
    should "rotate the image correctly" do
      @file = MediaFile.open("test/files/jpg/test-rotation-180.jpg")

      assert_equal([66, 100], @file.dimensions)
      assert_equal([33, 50], @file.preview(50, 50).dimensions)
      assert_equal("510aa465afbba3d7d818038b7aa7bb6f", @file.pixel_hash)
    end
  end
end
