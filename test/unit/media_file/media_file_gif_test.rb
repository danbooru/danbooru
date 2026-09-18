require "test_helper"

class MediaFileGifTest < ActiveSupport::TestCase
  context "Previews" do
    should "be generated properly" do
      should_generate_previews(
        "gif",
        "test/files/gif/corrupt-static.gif" => [108, 150, "b682795b5f58612cd858e088d2c47dd3"],
        "test/files/gif/test-animated-1.2s.gif" => [126, 150, "b5a93be8b7d47213b5c9e1c4e6755bb9"],
        "test/files/gif/test-animated-3.35s.gif" => [150, 111, "3004d35ab841650ba3ed5df9f2ec9051"],
        "test/files/gif/test-animated-400x281.gif" => [150, 105, "9609c853f2784ca933ea56c87f6ecc2e"],
        "test/files/gif/test-animated-86x52-loop-1.gif" => [86, 52, "7461dfb4079b3d6184764f68f1b91546"],
        "test/files/gif/test-animated-86x52-loop-2.gif" => [86, 52, "7461dfb4079b3d6184764f68f1b91546"],
        "test/files/gif/test-animated-86x52.gif" => [86, 52, "7461dfb4079b3d6184764f68f1b91546"],
        "test/files/gif/test-corrupt.gif" => [119, 150, "99cc466982582c6b827deb5a84e04cc4"],
        "test/files/gif/test-static-32x32.gif" => [32, 32, "0350b62780a6fcad56455248de1f9eba"],
        "test/files/gif/test.gif" => [150, 150, "be48f1fc16c4d41bd10193f4f2a11f90"],
      )
    end
  end

  context "a normal animated GIF" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/gif/test.gif")

      assert_equal(400, file.width)
      assert_equal(400, file.height)
      assert_equal(50_679, file.file_size)
      assert_equal(:gif, file.file_ext)
      assert_equal("image/gif", file.mime_type)
      assert_equal("1e2edf6bdbd971d8c3cc4da0f98f38ab", file.md5)
      assert_equal("446ddbb45f40265e565efbc8229d5eea", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "GIF",
        "GIF:GIFVersion" => "89a",
        "GIF:ImageWidth" => 400,
        "GIF:ImageHeight" => 400,
        "GIF:HasColorMap" => "Yes",
        "GIF:ColorResolutionDepth" => 6,
        "GIF:BitsPerPixel" => 6,
        "GIF:BackgroundColor" => 0,
      }, file.metadata.to_h)
    end
  end

  context "another animated GIF" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/gif/test-animated-400x281.gif")

      assert_equal(400, file.width)
      assert_equal(281, file.height)
      assert_equal(16_454, file.file_size)
      assert_equal(:gif, file.file_ext)
      assert_equal("image/gif", file.mime_type)
      assert_equal("86111e25a4d51e7eb5b7ac6ed29cf22c", file.md5)
      assert_equal("86111e25a4d51e7eb5b7ac6ed29cf22c", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(1.0, file.duration)
      assert_equal(2, file.frame_count)
      assert_equal(2.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "GIF",
        "GIF:GIFVersion" => "89a",
        "GIF:ImageWidth" => 400,
        "GIF:ImageHeight" => 281,
        "GIF:HasColorMap" => "Yes",
        "GIF:ColorResolutionDepth" => 6,
        "GIF:BitsPerPixel" => 6,
        "GIF:BackgroundColor" => 47,
        "GIF:AnimationIterations" => "Infinite",
        "GIF:TransparentColor" => 47,
        "GIF:FrameCount" => 2,
        "GIF:Duration" => "1.00 s",
      }, file.metadata.to_h)
    end
  end

  context "yet another animated GIF" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/gif/test-animated-86x52.gif")

      assert_equal(86, file.width)
      assert_equal(52, file.height)
      assert_equal(1122, file.file_size)
      assert_equal(:gif, file.file_ext)
      assert_equal("image/gif", file.mime_type)
      assert_equal("77d89bda37ea3af09158ed3282f8334f", file.md5)
      assert_equal("77d89bda37ea3af09158ed3282f8334f", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(0.4, file.duration)
      assert_equal(4, file.frame_count)
      assert_equal(10.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "GIF",
        "GIF:GIFVersion" => "89a",
        "GIF:ImageWidth" => 86,
        "GIF:ImageHeight" => 52,
        "GIF:HasColorMap" => "Yes",
        "GIF:ColorResolutionDepth" => 5,
        "GIF:BitsPerPixel" => 5,
        "GIF:BackgroundColor" => 26,
        "GIF:AnimationIterations" => "Infinite",
        "GIF:TransparentColor" => 26,
        "GIF:FrameCount" => 4,
        "GIF:Duration" => "0.40 s",
      }, file.metadata.to_h)
    end
  end

  context "a corrupt static GIF" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/gif/corrupt-static.gif")

      assert_equal(575, file.width)
      assert_equal(800, file.height)
      assert_equal(40_524, file.file_size)
      assert_equal(:gif, file.file_ext)
      assert_equal("image/gif", file.mime_type)
      assert_equal("edf5df0fbbafb63c1690ed2ac415d148", file.md5)
      assert_equal("edf5df0fbbafb63c1690ed2ac415d148", file.pixel_hash)
      assert_equal(true, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "GIF",
        "GIF:GIFVersion" => "89a",
        "GIF:ImageWidth" => 575,
        "GIF:ImageHeight" => 800,
        "GIF:HasColorMap" => "Yes",
        "GIF:ColorResolutionDepth" => 3,
        "GIF:BitsPerPixel" => 3,
        "GIF:BackgroundColor" => 0,
        "ExifTool:Error" => "File format error",
        "Vips:Error" => "libvips error",
      }, file.metadata.to_h)
    end
  end

  context "an animated GIF that ffmpeg detects with wrong duration" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/gif/test-animated-1.2s.gif")

      assert_equal(241, file.width)
      assert_equal(286, file.height)
      assert_equal(84_661, file.file_size)
      assert_equal(:gif, file.file_ext)
      assert_equal("image/gif", file.mime_type)
      assert_equal("b1a5600b05e5c3ba928d3d0c449cdb51", file.md5)
      assert_equal("b1a5600b05e5c3ba928d3d0c449cdb51", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(1.2, file.duration)
      assert_equal(12, file.frame_count)
      assert_equal(10.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "GIF",
        "GIF:GIFVersion" => "89a",
        "GIF:ImageWidth" => 241,
        "GIF:ImageHeight" => 286,
        "GIF:HasColorMap" => "Yes",
        "GIF:ColorResolutionDepth" => 5,
        "GIF:BitsPerPixel" => 7,
        "GIF:BackgroundColor" => 74,
        "GIF:AnimationIterations" => "Infinite",
        "GIF:TransparentColor" => 127,
        "GIF:FrameCount" => 12,
        "GIF:Duration" => "0.12 s", # XXX wrong value from ffmpeg 7.1
      }, file.metadata.to_h)
    end
  end

  context "another animated GIF that ffmpeg detects with wrong duration" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/gif/test-animated-3.35s.gif")

      assert_equal(241, file.width)
      assert_equal(178, file.height)
      assert_equal(97_782, file.file_size)
      assert_equal(:gif, file.file_ext)
      assert_equal("image/gif", file.mime_type)
      assert_equal("19edaa531608a8cb88ba6218ba0be056", file.md5)
      assert_equal("19edaa531608a8cb88ba6218ba0be056", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(3.35, file.duration)
      assert_equal(47, file.frame_count)
      assert_equal(14.029850746268655, file.frame_rate)
      assert_equal({
        "File:FileType" => "GIF",
        "GIF:GIFVersion" => "89a",
        "GIF:ImageWidth" => 241,
        "GIF:ImageHeight" => 178,
        "GIF:HasColorMap" => "Yes",
        "GIF:ColorResolutionDepth" => 5,
        "GIF:BitsPerPixel" => 5,
        "GIF:BackgroundColor" => 255,
        "GIF:AnimationIterations" => "Infinite",
        "GIF:TransparentColor" => 28,
        "GIF:FrameCount" => 47,
        "GIF:Duration" => "1.37 s", # XXX wrong value from ffmpeg 7.1
      }, file.metadata.to_h)
    end
  end

  context "an animated GIF that loops once" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/gif/test-animated-86x52-loop-1.gif")

      assert_equal(86, file.width)
      assert_equal(52, file.height)
      assert_equal(1102, file.file_size)
      assert_equal(:gif, file.file_ext)
      assert_equal("image/gif", file.mime_type)
      assert_equal("ef253e042e4361c42e0364c9cc604884", file.md5)
      assert_equal("ef253e042e4361c42e0364c9cc604884", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(0.4, file.duration)
      assert_equal(4, file.frame_count)
      assert_equal(10.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "GIF",
        "GIF:GIFVersion" => "89a",
        "GIF:ImageWidth" => 86,
        "GIF:ImageHeight" => 52,
        "GIF:HasColorMap" => "Yes",
        "GIF:ColorResolutionDepth" => 8,
        "GIF:BitsPerPixel" => 5,
        "GIF:BackgroundColor" => 0,
        "GIF:TransparentColor" => 26,
        "GIF:FrameCount" => 4,
        "GIF:Duration" => "0.40 s",
      }, file.metadata.to_h)
    end
  end

  context "an animated GIF that loops twice" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/gif/test-animated-86x52-loop-2.gif")

      assert_equal(86, file.width)
      assert_equal(52, file.height)
      assert_equal(1121, file.file_size)
      assert_equal(:gif, file.file_ext)
      assert_equal("image/gif", file.mime_type)
      assert_equal("8bdff44c32f8150c1f315172f09ed0da", file.md5)
      assert_equal("8bdff44c32f8150c1f315172f09ed0da", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(0.4, file.duration)
      assert_equal(4, file.frame_count)
      assert_equal(10.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "GIF",
        "GIF:GIFVersion" => "89a",
        "GIF:ImageWidth" => 86,
        "GIF:ImageHeight" => 52,
        "GIF:HasColorMap" => "Yes",
        "GIF:ColorResolutionDepth" => 8,
        "GIF:BitsPerPixel" => 5,
        "GIF:BackgroundColor" => 0,
        "GIF:AnimationIterations" => 1,
        "GIF:TransparentColor" => 26,
        "GIF:FrameCount" => 4,
        "GIF:Duration" => "0.40 s",
      }, file.metadata.to_h)
    end
  end

  context "a corrupt animated GIF" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/gif/test-corrupt.gif")

      assert_equal(475, file.width)
      assert_equal(600, file.height)
      assert_equal(52_645, file.file_size)
      assert_equal(:gif, file.file_ext)
      assert_equal("image/gif", file.mime_type)
      assert_equal("10c6d2a8934a6efacb8b864a512e0f74", file.md5)
      assert_equal("10c6d2a8934a6efacb8b864a512e0f74", file.pixel_hash)
      assert_equal(true, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "GIF",
        "GIF:GIFVersion" => "89a",
        "GIF:ImageWidth" => 475,
        "GIF:ImageHeight" => 600,
        "GIF:HasColorMap" => "Yes",
        "GIF:ColorResolutionDepth" => 4,
        "GIF:BitsPerPixel" => 4,
        "GIF:BackgroundColor" => 0,
        "ExifTool:Error" => "File format error",
        "Vips:Error" => "libvips error",
      }, file.metadata.to_h)
    end
  end

  context "a static GIF" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/gif/test-static-32x32.gif")

      assert_equal(32, file.width)
      assert_equal(32, file.height)
      assert_equal(408, file.file_size)
      assert_equal(:gif, file.file_ext)
      assert_equal("image/gif", file.mime_type)
      assert_equal("ab59748c2e84717552dca68feaac58cb", file.md5)
      assert_equal("d42cd8553aa008b4ef9bc253ff4f1239", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "GIF",
        "GIF:GIFVersion" => "89a",
        "GIF:ImageWidth" => 32,
        "GIF:ImageHeight" => 32,
        "GIF:HasColorMap" => "Yes",
        "GIF:ColorResolutionDepth" => 5,
        "GIF:BitsPerPixel" => 5,
        "GIF:BackgroundColor" => 25,
        "GIF:TransparentColor" => 25,
      }, file.metadata.to_h)
    end
  end
end
