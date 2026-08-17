require "test_helper"

class MediaFilePngTest < ActiveSupport::TestCase
  context "#dimensions" do
    should "determine the correct dimensions for a png file" do
      assert_equal([768, 1024], MediaFile.open("test/files/png/test.png").dimensions)
      assert_equal([85, 62], MediaFile.open("test/files/png/alpha.png").dimensions)
    end
  end

  context "#file_ext" do
    should "determine the correct extension for a png file" do
      assert_equal(:png, MediaFile.open("test/files/png/test.png").file_ext)
      assert_equal(:png, MediaFile.open("test/files/png/alpha.png").file_ext)
    end
  end

  context "#preview" do
    should "generate a preview image for a static image" do
      assert_equal([113, 150], MediaFile.open("test/files/png/test.png").preview(150, 150).dimensions)
    end

    should "generate a preview image for an animated image" do
      skip unless MediaFile.videos_enabled?
      assert_equal([150, 150], MediaFile.open("test/files/png/test-animated-256x256.png").preview(150, 150).dimensions)
    end
  end

  context "#duration" do
    should "get the correct duration for animated files" do
      assert_equal(0.75, MediaFile.open("test/files/png/test-animated-256x256.png").duration)
      assert_nil(MediaFile.open("test/files/png/test-animated-256x256.png").vips_duration)
      assert_equal(0.75, MediaFile.open("test/files/png/test-animated-256x256.png").ffmpeg_duration)
    end
  end

  context "#pixel_hash" do
    should "return the file's md5 for corrupted files" do
      assert_equal(MediaFile.md5("test/files/png/test-corrupt.png"), MediaFile.pixel_hash("test/files/png/test-corrupt.png"))
    end

    should "return the file's md5 for animated files" do
      assert_equal("64872dbdc62b6b02e6fc5f468838f674", MediaFile.pixel_hash("test/files/png/test-animated-256x256.png"))
      assert_equal("8b18b12d212e08d1773f6fd329b63b15", MediaFile.pixel_hash("test/files/png/test-animated-inf-fps.png"))
    end

    should "work for normal images" do
      assert_equal("5daef1f4d42b97cc5cda14f93867b085", MediaFile.pixel_hash("test/files/png/alpha.png"))
      assert_equal("d351db38efb2697d355cf89853099539", MediaFile.pixel_hash("test/files/png/test.png"))
      assert_equal("723bce01fcc6b8444ae362467e8628af", MediaFile.pixel_hash("test/files/png/test-rotation-90cw.png"))
    end
  end

  context "a PNG file" do
    context "that is animated but with an unspecified frame rate" do
      should "have an assumed frame rate of ~6.66 FPS" do
        file = MediaFile.open("test/files/png/test-animated-inf-fps.png")

        assert_equal(false, file.is_corrupt?)
        assert_equal(true, file.is_animated?)
        assert_equal(0.6, file.duration)
        assert_nil(file.vips_duration)
        assert_equal(0.6, file.ffmpeg_duration)
        assert_equal(2, file.frame_count)
        assert_equal(2 / 0.6, file.frame_rate)
      end
    end
  end

  context "a corrupt PNG" do
    should "still read the metadata" do
      @file = MediaFile.open("test/files/png/test-corrupt.png")
      @metadata = @file.metadata

      assert_equal(true, @file.is_corrupt?)
      assert_equal("libvips error", @file.error)
      assert_equal("Grayscale", @metadata["PNG:ColorType"])
      assert_equal(10, @metadata.count)
    end
  end

  context "a PNG with an exif orientation flag" do
    should "not rotate the image" do
      @file = MediaFile.open("test/files/png/test-rotation-90cw.png")

      assert_equal([128, 96], @file.dimensions)
      assert_equal([64, 48], @file.preview(64, 64).dimensions)
      assert_equal("723bce01fcc6b8444ae362467e8628af", @file.pixel_hash)
    end
  end
end
