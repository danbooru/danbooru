require "test_helper"

class MediaFileApngTest < ActiveSupport::TestCase
  context "Previews" do
    should "be generated properly" do
      should_generate_previews(
        "apng",
        "test/files/apng/actl_wronglen.png" => [150, 150, "4937cb37134a013ebb73b0b3b5585aa3"],
        "test/files/apng/actl_zero_frames.png" => [150, 150, "4937cb37134a013ebb73b0b3b5585aa3"],
        "test/files/apng/broken.png" => [150, 150, "d4e0a22e295be9d46e98f2b5e97ba67f"],
        "test/files/apng/ezgif-apng.png" => [150, 150, "1c8e552ca0301edd28dea9feeeb98709"],
        "test/files/apng/iend_missing.png" => [150, 150, "4671c4efe129283d31e8f4eeb7a6e552"],
        "test/files/apng/infinite-fps.png" => [150, 113, "098d982a94a93887dfac4a09d9c55291"],
        "test/files/apng/misaligned_chunks.png" => nil,
        "test/files/apng/normal-256x256.png" => [150, 150, "66e519d817ea797a67041c31adaef32d"],
        "test/files/apng/normal.png" => [150, 150, "4671c4efe129283d31e8f4eeb7a6e552"],
        "test/files/apng/not_apng.png" => [16, 16, "6f5f3c8ee91b08d61d21712ee1e93d13"],
        "test/files/apng/single_frame.png" => [150, 86, "70aa74e576f90ee9416681698e593972"],
      )
    end
  end

  context "a normal APNG file" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/apng/normal.png")

      assert_equal(150, file.width)
      assert_equal(150, file.height)
      assert_equal(6679, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("0c7758e594a1d9b83d79e03a8709bedf", file.md5)
      assert_equal("0c7758e594a1d9b83d79e03a8709bedf", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(5.0, file.duration)
      assert_equal(3, file.frame_count)
      assert_equal(0.6, file.frame_rate)
      assert_equal({
        "File:FileType" => "APNG",
        "PNG:ImageWidth" => 150,
        "PNG:ImageHeight" => 150,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "RGB with Alpha",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG:AnimationFrames" => 3,
        "PNG:AnimationPlays" => "inf",
      }, file.metadata.to_h)
    end
  end

  context "a 256x256 animated PNG" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/apng/normal-256x256.png")

      assert_equal(256, file.width)
      assert_equal(256, file.height)
      assert_equal(21_213, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("64872dbdc62b6b02e6fc5f468838f674", file.md5)
      assert_equal("64872dbdc62b6b02e6fc5f468838f674", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(0.75, file.duration)
      assert_equal(5, file.frame_count)
      assert_equal(6.666666666666667, file.frame_rate)
      assert_equal({
        "File:FileType" => "APNG",
        "PNG:ImageWidth" => 256,
        "PNG:ImageHeight" => 256,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "RGB with Alpha",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG:AnimationFrames" => 5,
        "PNG:AnimationPlays" => "inf",
      }, file.metadata.to_h)
    end
  end

  context "a non-animated PNG file" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/apng/not_apng.png")

      assert_equal(16, file.width)
      assert_equal(16, file.height)
      assert_equal(400, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("0077b918ce8e454bc47f1054d57d6bf7", file.md5)
      assert_equal("e99d97607fc43861a0b79eb1527e92e8", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "PNG",
        "PNG:ImageWidth" => 16,
        "PNG:ImageHeight" => 16,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "RGB with Alpha",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG:Gamma" => 2.2,
        "PNG:Software" => "Paint.NET v3.5.11",
      }, file.metadata.to_h)
    end
  end

  context "a single-frame APNG file" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/apng/single_frame.png")

      assert_equal(192, file.width)
      assert_equal(110, file.height)
      assert_equal(11_246, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("360fdda16aa9c86bbde8f30e619e4f98", file.md5)
      assert_equal("c02cf3d1007a7f4a6e42d6b60c3b52f0", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "APNG",
        "PNG:ImageWidth" => 192,
        "PNG:ImageHeight" => 110,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "RGB with Alpha",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG:AnimationFrames" => 1,
        "PNG:AnimationPlays" => "inf",
      }, file.metadata.to_h)
    end
  end
  context "an APNG file with a missing IEND chunk" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/apng/iend_missing.png")

      assert_equal(150, file.width)
      assert_equal(150, file.height)
      assert_equal(6667, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("0d4172d6c000b4ce5522dd24dcfab8dd", file.md5)
      assert_equal("0d4172d6c000b4ce5522dd24dcfab8dd", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(5.0, file.duration)
      assert_equal(3, file.frame_count)
      assert_equal(0.6, file.frame_rate)
      assert_equal({
        "File:FileType" => "APNG",
        "PNG:ImageWidth" => 150,
        "PNG:ImageHeight" => 150,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "RGB with Alpha",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG:AnimationFrames" => 3,
        "PNG:AnimationPlays" => "inf",
        "ExifTool:Warning" => "Truncated PNG image",
      }, file.metadata.to_h)
    end
  end

  context "an APNG file with misaligned chunks" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/apng/misaligned_chunks.png")

      assert_equal(150, file.width)
      assert_equal(150, file.height)
      assert_equal(6679, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("ebfdb8761098f044a5d21fdfce8176ed", file.md5)
      assert_equal("ebfdb8761098f044a5d21fdfce8176ed", file.pixel_hash)
      assert_equal(true, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(0.04, file.duration)
      assert_equal(3, file.frame_count)
      assert_equal(75.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "APNG",
        "PNG:ImageWidth" => 150,
        "PNG:ImageHeight" => 150,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "RGB with Alpha",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG:AnimationFrames" => 3,
        "PNG:AnimationPlays" => "inf",
        "ExifTool:Warning" => "Invalid PNG chunk size",
        "Vips:Error" => "libvips error",
      }, file.metadata.to_h)
    end
  end

  context "a broken, truncated APNG file" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/apng/broken.png")

      assert_equal(150, file.width)
      assert_equal(150, file.height)
      assert_equal(400, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("c14cac2d5c1235aa632c9aa9d6cac3b5", file.md5)
      assert_equal("c14cac2d5c1235aa632c9aa9d6cac3b5", file.pixel_hash)
      assert_equal(true, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(3, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "APNG",
        "PNG:ImageWidth" => 150,
        "PNG:ImageHeight" => 150,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "RGB with Alpha",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG:AnimationFrames" => 3,
        "PNG:AnimationPlays" => "inf",
        "ExifTool:Warning" => "Truncated PNG image",
        "Vips:Error" => "libvips error",
      }, file.metadata.to_h)
    end
  end

  context "an APNG file with a wrong acTL chunk length" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/apng/actl_wronglen.png")

      assert_equal(150, file.width)
      assert_equal(150, file.height)
      assert_equal(6675, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("73080760e76307d3a91e978d87813bb2", file.md5)
      assert_equal("73080760e76307d3a91e978d87813bb2", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(0.04, file.duration)
      assert_equal(3, file.frame_count)
      assert_equal(75.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "APNG",
        "PNG:ImageWidth" => 150,
        "PNG:ImageHeight" => 150,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "RGB with Alpha",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG:AnimationFrames" => 3,
      }, file.metadata.to_h)
    end
  end

  context "an APNG file with an acTL chunk specifying zero frames" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/apng/actl_zero_frames.png")

      assert_equal(150, file.width)
      assert_equal(150, file.height)
      assert_equal(6679, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("f0e1112e64a8f16bec30b4a58405d201", file.md5)
      assert_equal("e8e6e1cfb45f15198b5640cf4f1f0ff5", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(0, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "APNG",
        "PNG:ImageWidth" => 150,
        "PNG:ImageHeight" => 150,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "RGB with Alpha",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG:AnimationFrames" => 0,
        "PNG:AnimationPlays" => "inf",
      }, file.metadata.to_h)
    end
  end

  context "an APNG file with a missing IEND chunk" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/apng/iend_missing.png")

      assert_equal(150, file.width)
      assert_equal(150, file.height)
      assert_equal(6667, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("0d4172d6c000b4ce5522dd24dcfab8dd", file.md5)
      assert_equal("0d4172d6c000b4ce5522dd24dcfab8dd", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(5.0, file.duration)
      assert_equal(3, file.frame_count)
      assert_equal(0.6, file.frame_rate)
      assert_equal({
        "File:FileType" => "APNG",
        "PNG:ImageWidth" => 150,
        "PNG:ImageHeight" => 150,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "RGB with Alpha",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG:AnimationFrames" => 3,
        "PNG:AnimationPlays" => "inf",
        "ExifTool:Warning" => "Truncated PNG image",
      }, file.metadata.to_h)
    end
  end

  context "an animated PNG with an unspecified (infinite) frame rate" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/apng/infinite-fps.png")

      assert_equal(640, file.width)
      assert_equal(480, file.height)
      assert_equal(217_425, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("8b18b12d212e08d1773f6fd329b63b15", file.md5)
      assert_equal("8b18b12d212e08d1773f6fd329b63b15", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(0.6, file.duration)
      assert_equal(2, file.frame_count)
      assert_equal(3.3333333333333335, file.frame_rate)
      assert_equal({
        "File:FileType" => "APNG",
        "PNG:ImageWidth" => 640,
        "PNG:ImageHeight" => 480,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "RGB",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG:AnimationFrames" => 2,
        "PNG:AnimationPlays" => "inf",
        "PNG:Software" => "APNG Assembler 2.0",
        "ExifTool:Warning" => "[minor] Text/EXIF chunk(s) found after APNG IDAT (may be ignored by some readers)",
      }, file.metadata.to_h)
    end
  end

  context "an animated PNG generated by ezgif (fcTL and IDAT separated by a tEXt chunk)" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/apng/ezgif-apng.png")

      assert_equal(720, file.width)
      assert_equal(720, file.height)
      assert_equal(177_678, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("6f7de03721a05021833fb7caa033d1df", file.md5)
      assert_equal("6f7de03721a05021833fb7caa033d1df", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(0.902256, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(11.083328900001774, file.frame_rate)
      assert_equal({
        "File:FileType" => "APNG",
        "PNG:ImageWidth" => 720,
        "PNG:ImageHeight" => 720,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "Palette",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG:Transparency" => 0,
        "PNG:AnimationFrames" => 10,
        "PNG:AnimationPlays" => "inf",
        "PNG:Software" => "ezgif.com",
        "PNG:Comment" => "Converted with https://ezgif.com/gif-to-apng",
      }, file.metadata.to_h)
    end
  end
end
