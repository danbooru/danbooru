require "test_helper"

class MediaFileApngTest < ActiveSupport::TestCase
  context "#dimensions" do
    should "determine the correct dimensions for a png file" do
      assert_equal([150, 150], MediaFile.open("test/files/apng/normal_apng.png").dimensions)
    end
  end

  context "#file_ext" do
    should "determine the correct extension for a png file" do
      assert_equal(:png, MediaFile.open("test/files/apng/normal_apng.png").file_ext)
    end
  end

  context "#preview" do
    should "generate a preview image for an animated image" do
      skip unless MediaFile.videos_enabled?
      assert_equal([150, 150], MediaFile.open("test/files/apng/normal_apng.png").preview(150, 150).dimensions)
    end
  end

  context "#duration" do
    should "get the correct duration for animated files" do
      assert_equal(5.0, MediaFile.open("test/files/apng/normal_apng.png").duration)
      assert_nil(MediaFile.open("test/files/apng/normal_apng.png").vips_duration)
      assert_equal(5.0, MediaFile.open("test/files/apng/normal_apng.png").ffmpeg_duration)
    end
  end

  context "a PNG file" do
    context "that is not animated" do
      should "not be detected as animated" do
        file = MediaFile.open("test/files/apng/not_apng.png")

        assert_equal(false, file.is_corrupt?)
        assert_equal(false, file.is_animated?)
        assert_nil(file.duration)
        assert_nil(file.frame_rate)
        assert_equal(1, file.frame_count)
      end
    end

    context "that is animated" do
      should "be detected as animated" do
        file = MediaFile.open("test/files/apng/normal_apng.png")

        assert_equal(false, file.is_corrupt?)
        assert_equal(true, file.is_animated?)
        assert_equal(5.0, file.duration)
        assert_nil(file.vips_duration)
        assert_equal(5.0, file.ffmpeg_duration)
        assert_equal(0.6, file.frame_rate)
        assert_equal(3, file.frame_count)
      end
    end

    context "that is animated but with only one frame" do
      should "not be detected as animated" do
        file = MediaFile.open("test/files/apng/single_frame.png")

        assert_equal(false, file.is_corrupt?)
        assert_equal(false, file.is_animated?)
        assert_nil(file.duration)
        assert_nil(file.frame_rate)
        assert_equal(1, file.frame_count)
      end
    end

    context "that is animated but malformed" do
      should "be handled correctly" do
        file = MediaFile.open("test/files/apng/iend_missing.png")
        assert_equal(false, file.is_corrupt?)
        assert_equal(true, file.is_animated?)

        file = MediaFile.open("test/files/apng/misaligned_chunks.png")
        assert_equal(true, file.is_corrupt?)
        assert_equal(true, file.is_animated?)

        file = MediaFile.open("test/files/apng/broken.png")
        assert_equal(true, file.is_corrupt?)
        assert_equal(true, file.is_animated?)

        file = MediaFile.open("test/files/apng/actl_wronglen.png")
        assert_equal(false, file.is_corrupt?)
        assert_equal(true, file.is_animated?)

        file = MediaFile.open("test/files/apng/actl_zero_frames.png")
        assert_equal(false, file.is_corrupt?)
        assert_equal(false, file.is_animated?)
        assert_equal(0, file.frame_count)
      end
    end
  end
end
