require "test_helper"

class MediaFileWebpTest < ActiveSupport::TestCase
  context "Previews" do
    should "be generated properly" do
      should_generate_previews(
        "webp",
        "test/files/webp/2_webp_a.webp" => [147, 150, "2a1c65258494c447ea026c04ae85350c"],
        "test/files/webp/2_webp_ll.webp" => [147, 150, "7a8c8ed338849b36543bdf0d9a2e4230"],
        "test/files/webp/Exif2.webp" => [150, 100, "91be6db5c38df446e6ab58d4e68bb6f6"],
        "test/files/webp/Exif6.webp" => [100, 150, "6dd3a521c7f0a5eb2ee6a5434d7f976e"],
        "test/files/webp/fjord.webp" => [150, 100, "90e2538fc83d51f5ccf84c5887a35e5f"],
        "test/files/webp/lossless1.webp" => [150, 46, "a28dbaf0962fd276c29921fd044e8a40"],
        "test/files/webp/lossy_alpha1.webp" => [150, 46, "2c36503197cce0a92d65950a91ad2cae"],
        "test/files/webp/nyancat.webp" => [150, 150, "93b7e41c7c7c58ff6e597757a5f693f7"],
        "test/files/webp/test.webp" => [128, 128, "682e1ab8f62b408304402f3a52265764"],
        "test/files/webp/truncated.webp" => nil,
      )
    end
  end

  context "a normal WebP file" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/webp/test.webp")

      assert_equal(128, file.width)
      assert_equal(128, file.height)
      assert_equal(4928, file.file_size)
      assert_equal(:webp, file.file_ext)
      assert_equal("image/webp", file.mime_type)
      assert_equal("ddf8da7d873240cffeb0f617f5b9b69d", file.md5)
      assert_equal("3d9213ea387706db93f0b39247d77573", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "WEBP",
        "RIFF:VP8Version" => "0 (bicubic reconstruction, normal loop)",
        "RIFF:ImageWidth" => 128,
        "RIFF:HorizontalScale" => 0,
        "RIFF:ImageHeight" => 128,
        "RIFF:VerticalScale" => 0,
      }, file.metadata.to_h)
    end
  end

  context "a normal lossy WebP file" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/webp/fjord.webp")

      assert_equal(550, file.width)
      assert_equal(368, file.height)
      assert_equal(30_320, file.file_size)
      assert_equal(:webp, file.file_ext)
      assert_equal("image/webp", file.mime_type)
      assert_equal("0e2687e3a6c95084e6ce912aa45d3803", file.md5)
      assert_equal("3fc1c886c264b8dd6a80222d8a5ebde2", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "WEBP",
        "RIFF:VP8Version" => "1 (bilinear reconstruction, simple loop)",
        "RIFF:ImageWidth" => 550,
        "RIFF:HorizontalScale" => 0,
        "RIFF:ImageHeight" => 368,
        "RIFF:VerticalScale" => 0,
      }, file.metadata.to_h)
    end
  end

  context "a lossless WebP file" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/webp/lossless1.webp")

      assert_equal(1000, file.width)
      assert_equal(307, file.height)
      assert_equal(15_368, file.file_size)
      assert_equal(:webp, file.file_ext)
      assert_equal("image/webp", file.mime_type)
      assert_equal("31c6e080cf753d20ce25253249cf47c8", file.md5)
      assert_equal("fd52591b61fc34192d7c337fa024bf12", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "WEBP (lossless)",
        "RIFF:ImageWidth" => 1000,
        "RIFF:ImageHeight" => 307,
        "RIFF:AlphaIsUsed" => "Yes",
      }, file.metadata.to_h)
    end
  end

  context "a WebP file with an alpha channel" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/webp/2_webp_a.webp")

      assert_equal(386, file.width)
      assert_equal(395, file.height)
      assert_equal(14_082, file.file_size)
      assert_equal(:webp, file.file_ext)
      assert_equal("image/webp", file.mime_type)
      assert_equal("68269516f9121935d7f087028b8808b8", file.md5)
      assert_equal("84039ce251a945b5dfd888268b49709f", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "Extended WEBP",
        "RIFF:WebP_Flags" => "Alpha",
        "RIFF:ImageWidth" => 386,
        "RIFF:ImageHeight" => 395,
        "RIFF:AlphaPreprocessing" => "Level Reduction",
        "RIFF:AlphaFiltering" => "Horizontal",
        "RIFF:AlphaCompression" => "Lossless",
        "RIFF:VP8Version" => "0 (bicubic reconstruction, normal loop)",
        "RIFF:HorizontalScale" => 0,
        "RIFF:VerticalScale" => 0,
      }, file.metadata.to_h)
    end
  end

  context "a lossy WebP file with an alpha channel" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/webp/lossy_alpha1.webp")

      assert_equal(1000, file.width)
      assert_equal(307, file.height)
      assert_equal(19_478, file.file_size)
      assert_equal(:webp, file.file_ext)
      assert_equal("image/webp", file.mime_type)
      assert_equal("ccfaf36ce6e5b66de46559084f105492", file.md5)
      assert_equal("c5c77aff5b4015d3416817d12c2c2377", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "Extended WEBP",
        "RIFF:WebP_Flags" => "Alpha",
        "RIFF:ImageWidth" => 1000,
        "RIFF:ImageHeight" => 307,
        "RIFF:AlphaPreprocessing" => "Level Reduction",
        "RIFF:AlphaFiltering" => "Horizontal",
        "RIFF:AlphaCompression" => "Lossless",
        "RIFF:VP8Version" => "1 (bilinear reconstruction, simple loop)",
        "RIFF:HorizontalScale" => 0,
        "RIFF:VerticalScale" => 0,
      }, file.metadata.to_h)
    end
  end

  context "a lossless WebP file with an alpha channel" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/webp/2_webp_ll.webp")

      assert_equal(386, file.width)
      assert_equal(395, file.height)
      assert_equal(27_650, file.file_size)
      assert_equal(:webp, file.file_ext)
      assert_equal("image/webp", file.mime_type)
      assert_equal("291654feb88606970e927f32b08e2621", file.md5)
      assert_equal("39225408c7673a19a5c69f596c0d1032", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "WEBP (lossless)",
        "RIFF:ImageWidth" => 386,
        "RIFF:ImageHeight" => 395,
        "RIFF:AlphaIsUsed" => "Yes",
      }, file.metadata.to_h)
    end
  end

  context "a WebP file with an EXIF orientation of 2" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/webp/Exif2.webp")

      assert_equal(640, file.width)
      assert_equal(427, file.height)
      assert_equal(62_274, file.file_size)
      assert_equal(:webp, file.file_ext)
      assert_equal("image/webp", file.mime_type)
      assert_equal("f0c76f9c5511d1868c6ae80dc29be0d9", file.md5)
      assert_equal("96d0f06ba512efea2de7bda8b5775106", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "Extended WEBP",
        "File:ExifByteOrder" => "Little-endian (Intel, II)",
        "RIFF:WebP_Flags" => "EXIF",
        "RIFF:ImageWidth" => 640,
        "RIFF:ImageHeight" => 427,
        "RIFF:VP8Version" => "0 (bicubic reconstruction, normal loop)",
        "RIFF:HorizontalScale" => 0,
        "RIFF:VerticalScale" => 0,
        "IFD0:Orientation" => "Mirror horizontal",
      }, file.metadata.to_h)
    end

    should "should have its rotation ignored like browsers do" do
      assert_equal(false, MediaFile.open("test/files/webp/Exif2.webp").metadata.is_rotated?)
    end
  end

  context "a WebP file with an EXIF orientation of 6" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/webp/Exif6.webp")

      assert_equal(427, file.width)
      assert_equal(640, file.height)
      assert_equal(61_968, file.file_size)
      assert_equal(:webp, file.file_ext)
      assert_equal("image/webp", file.mime_type)
      assert_equal("0aaf50e75b4e5e340d011a5fece876cb", file.md5)
      assert_equal("4811ad7d928dbf069ef991bb3051d7f6", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "Extended WEBP",
        "File:ExifByteOrder" => "Little-endian (Intel, II)",
        "RIFF:WebP_Flags" => "EXIF",
        "RIFF:ImageWidth" => 427,
        "RIFF:ImageHeight" => 640,
        "RIFF:VP8Version" => "0 (bicubic reconstruction, normal loop)",
        "RIFF:HorizontalScale" => 0,
        "RIFF:VerticalScale" => 0,
        "IFD0:Orientation" => "Rotate 90 CW",
      }, file.metadata.to_h)
    end

    should "should have its rotation ignored like browsers do" do
      assert_equal(false, MediaFile.open("test/files/webp/Exif2.webp").metadata.is_rotated?)
    end
  end

  context "an animated WebP file that has wrong duration in some ffmpeg versions" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/webp/nyancat.webp")

      assert_equal(400, file.width)
      assert_equal(400, file.height)
      assert_equal(37_342, file.file_size)
      assert_equal(:webp, file.file_ext)
      assert_equal("image/webp", file.mime_type)
      assert_equal("f9961d54b2290c36ad3e54995d9d2dcf", file.md5)
      assert_equal("f9961d54b2290c36ad3e54995d9d2dcf", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(0.84, file.duration)
      assert_equal(12, file.frame_count)
      assert_equal(14.285714285714286, file.frame_rate)
      assert_equal({
        "File:FileType" => "Extended WEBP",
        "RIFF:WebP_Flags" => "Animation, Alpha",
        "RIFF:ImageWidth" => 400,
        "RIFF:ImageHeight" => 400,
        "RIFF:BackgroundColor" => "0 0 0 255",
        "RIFF:AnimationLoopCount" => "inf",
        "RIFF:Duration" => "0.84 s",
      }, file.metadata.to_h)
    end
  end

  context "a truncated, corrupt WebP file" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/webp/truncated.webp")

      assert_equal(800, file.width)
      assert_equal(1067, file.height)
      assert_equal(1024, file.file_size)
      assert_equal(:webp, file.file_ext)
      assert_equal("image/webp", file.mime_type)
      assert_equal("ef85c9fdee9f8419ce6a832440b79087", file.md5)
      assert_equal("ef85c9fdee9f8419ce6a832440b79087", file.pixel_hash)
      assert_equal(true, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "Extended WEBP",
        "RIFF:WebP_Flags" => "ICC Profile",
        "RIFF:ImageWidth" => 800,
        "RIFF:ImageHeight" => 1067,
        "ICC-header:ProfileCMMType" => "Apple Computer Inc.",
        "ICC-header:ProfileVersion" => "4.0.0",
        "ICC-header:ProfileClass" => "Display Device Profile",
        "ICC-header:ColorSpaceData" => "RGB ",
        "ICC-header:ProfileConnectionSpace" => "XYZ ",
        "ICC-header:ProfileDateTime" => "2017:07:07 13:22:32",
        "ICC-header:ProfileFileSignature" => "acsp",
        "ICC-header:PrimaryPlatform" => "Apple Computer Inc.",
        "ICC-header:CMMFlags" => "Not Embedded, Independent",
        "ICC-header:DeviceManufacturer" => "Apple Computer Inc.",
        "ICC-header:DeviceModel" => "",
        "ICC-header:DeviceAttributes" => "Reflective, Glossy, Positive, Color",
        "ICC-header:RenderingIntent" => "Perceptual",
        "ICC-header:ConnectionSpaceIlluminant" => "0.9642 1 0.82491",
        "ICC-header:ProfileCreator" => "Apple Computer Inc.",
        "ICC-header:ProfileID" => "ca1a9582257f104d389913d5d1ea1582",
        "ICC_Profile:ProfileDescription" => "Display P3",
        "ICC_Profile:ProfileCopyright" => "Copyright Apple Inc., 2017",
        "ICC_Profile:MediaWhitePoint" => "0.95045 1 1.08905",
        "ICC_Profile:RedMatrixColumn" => "0.51512 0.2412 -0.00105",
        "ICC_Profile:GreenMatrixColumn" => "0.29198 0.69225 0.04189",
        "ICC_Profile:BlueMatrixColumn" => "0.1571 0.06657 0.78407",
        "ICC_Profile:ChromaticAdaptation" => "1.04788 0.02292 -0.0502 0.02959 0.99048 -0.01706 -0.00923 0.01508 0.75168",
        "ExifTool:Warning" => "Error reading RIFF file (corrupted?)",
        "Vips:Error" => "libvips error",
      }, file.metadata.to_h)
    end
  end
end
