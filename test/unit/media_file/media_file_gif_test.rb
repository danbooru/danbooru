require "test_helper"

class MediaFileGifTest < ActiveSupport::TestCase
  context "#dimensions" do
    should "determine the correct dimensions for a gif file" do
      assert_equal([400, 400], MediaFile.open("test/files/gif/test.gif").dimensions)
      assert_equal([86, 52], MediaFile.open("test/files/gif/test-animated-86x52.gif").dimensions)
      assert_equal([32, 32], MediaFile.open("test/files/gif/test-static-32x32.gif").dimensions)
    end
  end

  context "#file_ext" do
    should "determine the correct extension for a gif file" do
      assert_equal(:gif, MediaFile.open("test/files/gif/test.gif").file_ext)
      assert_equal(:gif, MediaFile.open("test/files/gif/test-animated-86x52.gif").file_ext)
      assert_equal(:gif, MediaFile.open("test/files/gif/test-static-32x32.gif").file_ext)
    end
  end

  context "#preview" do
    should "generate a preview image for a static image" do
      assert_equal([150, 150], MediaFile.open("test/files/gif/test.gif").preview(150, 150).dimensions)
    end

    should "generate a preview image for an animated image" do
      skip unless MediaFile.videos_enabled?
      assert_equal([86, 52], MediaFile.open("test/files/gif/test-animated-86x52.gif").preview(150, 150).dimensions)
      assert_equal([150, 105], MediaFile.open("test/files/gif/test-animated-400x281.gif").preview(150, 150).dimensions)
    end
  end

  context "#duration" do
    should "get the correct duration for animated files" do
      assert_equal(0.4,  MediaFile.open("test/files/gif/test-animated-86x52.gif").duration)
      assert_equal(1.0,  MediaFile.open("test/files/gif/test-animated-400x281.gif").duration)
      assert_equal(3.35, MediaFile.open("test/files/gif/test-animated-3.35s.gif").duration)
      assert_equal(1.2,  MediaFile.open("test/files/gif/test-animated-1.2s.gif").duration)

      assert_equal(0.4,  MediaFile.open("test/files/gif/test-animated-86x52.gif").vips_duration)
      assert_equal(1.0,  MediaFile.open("test/files/gif/test-animated-400x281.gif").vips_duration)
      assert_equal(3.35, MediaFile.open("test/files/gif/test-animated-3.35s.gif").vips_duration)
      assert_equal(1.2,  MediaFile.open("test/files/gif/test-animated-1.2s.gif").vips_duration)

      assert_equal(0.4,  MediaFile.open("test/files/gif/test-animated-86x52.gif").ffmpeg_duration)
      assert_equal(1.0,  MediaFile.open("test/files/gif/test-animated-400x281.gif").ffmpeg_duration)
      assert_equal(1.37, MediaFile.open("test/files/gif/test-animated-3.35s.gif").ffmpeg_duration) # XXX wrong in ffmpeg 7.1
      assert_equal(0.12, MediaFile.open("test/files/gif/test-animated-1.2s.gif").ffmpeg_duration) # XXX wrong in ffmpeg 7.1
    end
  end

  context "#pixel_hash" do
    should "return the file's md5 for corrupted files" do
      assert_equal(MediaFile.md5("test/files/gif/test-corrupt.gif"), MediaFile.pixel_hash("test/files/gif/test-corrupt.gif"))
    end

    should "return the file's md5 for animated files" do
      assert_equal("77d89bda37ea3af09158ed3282f8334f", MediaFile.pixel_hash("test/files/gif/test-animated-86x52.gif"))
    end

    should "work for normal images" do
      assert_equal("446ddbb45f40265e565efbc8229d5eea", MediaFile.pixel_hash("test/files/gif/test.gif"))
      assert_equal("d42cd8553aa008b4ef9bc253ff4f1239", MediaFile.pixel_hash("test/files/gif/test-static-32x32.gif"))
    end
  end

  context "an animated GIF file" do
    should "determine the duration of the animation" do
      file = MediaFile.open("test/files/gif/test-animated-86x52.gif")
      assert_equal(0.4, file.duration)
      assert_equal(0.4, file.vips_duration)
      assert_equal(0.4, file.ffmpeg_duration)
      assert_equal(10, file.frame_rate)
      assert_equal(4, file.frame_count)
    end
  end

  context "a corrupt GIF" do
    should "still read the metadata" do
      @file = MediaFile.open("test/files/gif/test-corrupt.gif")
      @metadata = @file.metadata

      assert_equal(true, @file.is_corrupt?)
      assert_equal("libvips error", @file.error)
      assert_equal([475, 600], @file.dimensions)
      assert_equal("File format error", @metadata["ExifTool:Error"])
      assert_equal("89a", @metadata["GIF:GIFVersion"])
      assert_equal(10, @metadata.count)
    end

    should "not raise an exception when reading the frame count" do
      @file = MediaFile.open("test/files/gif/corrupt-static.gif")
      @metadata = @file.metadata

      assert_equal(true, @file.is_corrupt?)
      assert_equal("libvips error", @file.error)
      assert_equal(1, @file.frame_count)
      assert_equal([575, 800], @file.dimensions)
      assert_equal("File format error", @metadata["ExifTool:Error"])
      assert_equal("89a", @metadata["GIF:GIFVersion"])
      assert_equal(10, @metadata.count)
      assert_nothing_raised { @file.attributes }
    end
  end
end
