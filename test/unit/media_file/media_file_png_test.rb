require "test_helper"

class MediaFilePngTest < ActiveSupport::TestCase
  context "Previews" do
    should "be generated properly" do
      should_generate_previews(
        "png",
        failures: ["test/files/png/empty.png"],
      )
    end
  end

  context "a normal PNG file" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/png/test.png")

      assert_equal(768, file.width)
      assert_equal(1024, file.height)
      assert_equal(446_148, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("081a5c3b92d8980d1aadbd215bfac5b9", file.md5)
      assert_equal("d351db38efb2697d355cf89853099539", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "PNG",
        "PNG:ImageWidth" => 768,
        "PNG:ImageHeight" => 1024,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "RGB",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG:VirtualImageWidth" => 768,
        "PNG:VirtualImageHeight" => 1024,
        "PNG:VirtualPageUnits" => 0,
        "PNG-pHYs:PixelsPerUnitX" => 2834,
        "PNG-pHYs:PixelsPerUnitY" => 2834,
        "PNG-pHYs:PixelUnits" => "meters",
      }, file.metadata.to_h)
    end
  end

  context "a PNG with an alpha channel" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/png/alpha.png")

      assert_equal(85, file.width)
      assert_equal(62, file.height)
      assert_equal(1136, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("200be2be97a465ecd2054a51522f65b5", file.md5)
      assert_equal("5daef1f4d42b97cc5cda14f93867b085", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "PNG",
        "PNG:ImageWidth" => 85,
        "PNG:ImageHeight" => 62,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "Palette",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
      }, file.metadata.to_h)
    end
  end

  context "a corrupt PNG" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/png/test-corrupt.png")

      assert_equal(32, file.width)
      assert_equal(32, file.height)
      assert_equal(61, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("45be9407698ec596ae981ce82488deb1", file.md5)
      assert_equal("45be9407698ec596ae981ce82488deb1", file.pixel_hash)
      assert_equal(true, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "PNG",
        "PNG:ImageWidth" => 32,
        "PNG:ImageHeight" => 32,
        "PNG:BitDepth" => 1,
        "PNG:ColorType" => "Grayscale",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG:Gamma" => 1,
        "Vips:Error" => "libvips error",
      }, file.metadata.to_h)
    end
  end

  context "a PNG with a non-standard EXIF orientation flag" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/png/test-rotation-bad-chunk.png")

      assert_equal(128, file.width)
      assert_equal(96, file.height)
      assert_equal(27_176, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("469dae61c1642a527009dc387fb38629", file.md5)
      assert_equal("723bce01fcc6b8444ae362467e8628af", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "PNG",
        "File:ExifByteOrder" => "Little-endian (Intel, II)",
        "PNG:ImageWidth" => 128,
        "PNG:ImageHeight" => 96,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "RGB",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG:Gamma" => 2.2,
        "PNG:WhitePointX" => 0.3127,
        "PNG:WhitePointY" => 0.329,
        "PNG:RedX" => 0.64,
        "PNG:RedY" => 0.33,
        "PNG:GreenX" => 0.3,
        "PNG:GreenY" => 0.6,
        "PNG:BlueX" => 0.15,
        "PNG:BlueY" => 0.06,
        "PNG:BackgroundColor" => "255 255 255",
        "PNG:Datecreate" => "2021-09-22T20:48:24-05:00",
        "PNG:Datemodify" => "2021-09-21T11:17:35-05:00",
        "PNG:ExifColorSpace" => 65_535,
        "PNG:ExifExifOffset" => 90,
        "PNG:ExifExifVersion" => "48, 50, 49, 48",
        "PNG:ExifFlashPixVersion" => "48, 49, 48, 48",
        "PNG:ExifPixelXDimension" => 128,
        "PNG:ExifPixelYDimension" => 96,
        "PNG-pHYs:PixelsPerUnitX" => 11_811,
        "PNG-pHYs:PixelsPerUnitY" => 11_811,
        "PNG-pHYs:PixelUnits" => "meters",
        "ExifTool:Warning" => "[minor] Text/EXIF chunk(s) found after PNG IDAT (may be ignored by some readers) [x9]",
        "IFD0:Orientation" => "Rotate 90 CW",
        "IFD0:XResolution" => 300,
        "IFD0:YResolution" => 300,
        "IFD0:ResolutionUnit" => "inches",
        "ExifIFD:ExifVersion" => "0210",
        "ExifIFD:FlashpixVersion" => "0100",
        "ExifIFD:ColorSpace" => "Uncalibrated",
        "ExifIFD:ExifImageWidth" => 128,
        "ExifIFD:ExifImageHeight" => 96,
      }, file.metadata.to_h)
    end
  end

  context "a PNG with a standard EXIF orientation flag" do
    should "be parsed correctly, with the width and height swapped to match the rotation" do
      file = MediaFile.open("test/files/png/test-rotation-good-chunk.png")

      assert_equal(64, file.width)
      assert_equal(128, file.height)
      assert_equal(21_557, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("af7c636bf780b300a9070ed51accf80e", file.md5)
      assert_equal("74a09fe28c95001f3ddd251a9fbb5d3a", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "PNG",
        "File:ExifByteOrder" => "Little-endian (Intel, II)",
        "PNG:ImageWidth" => 128,
        "PNG:ImageHeight" => 64,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "RGB",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "IFD0:Orientation" => "Rotate 90 CW",
        "IFD0:XResolution" => 144,
        "IFD0:YResolution" => 144,
        "IFD0:ResolutionUnit" => "inches",
        "IFD0:YCbCrPositioning" => "Centered",
        "ExifIFD:ExifVersion" => "0210",
        "ExifIFD:ComponentsConfiguration" => "Y, Cb, Cr, -",
        "ExifIFD:UserComment" => "Sc",
        "ExifIFD:FlashpixVersion" => "0100",
        "ExifIFD:ColorSpace" => "sRGB",
        "ExifIFD:ExifImageWidth" => 128,
        "ExifIFD:ExifImageHeight" => 64,
        "PNG-pHYs:PixelsPerUnitX" => 1000,
        "PNG-pHYs:PixelsPerUnitY" => 1000,
        "PNG-pHYs:PixelUnits" => "meters",
      }, file.metadata.to_h)
    end

    should "generate a rotated thumbnail" do
      file = MediaFile.open("test/files/png/test-rotation-good-chunk.png")

      assert_equal([32, 64], file.preview(64, 64).dimensions)
    end
  end

  context "an empty file with a .png extension" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/png/empty.png")

      assert_equal(0, file.width)
      assert_equal(0, file.height)
      assert_equal(0, file.file_size)
      assert_equal(:bin, file.file_ext)
      assert_equal("application/octet-stream", file.mime_type)
      assert_equal("d41d8cd98f00b204e9800998ecf8427e", file.md5)
      assert_equal("d41d8cd98f00b204e9800998ecf8427e", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "ExifTool:Error" => "File is empty",
      }, file.metadata.to_h)
    end
  end

  context "a JPEG file saved with a .png extension" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/png/jpg.png")

      assert_equal(16, file.width)
      assert_equal(16, file.height)
      assert_equal(989, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("474cf654bff1204d1041b8e92f93d7a4", file.md5)
      assert_equal("acf4c4064d6e19ac268d4610051b78fc", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:ExifByteOrder" => "Little-endian (Intel, II)",
        "File:ImageWidth" => 16,
        "File:ImageHeight" => 16,
        "File:EncodingProcess" => "Baseline DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 3,
        "File:YCbCrSubSampling" => "YCbCr4:2:0 (2 2)",
        "JFIF:JFIFVersion" => 1.01,
        "JFIF:ResolutionUnit" => "inches",
        "JFIF:XResolution" => 96,
        "JFIF:YResolution" => 96,
        "IFD0:XResolution" => 96,
        "IFD0:YResolution" => 96,
        "IFD0:ResolutionUnit" => "inches",
        "IFD0:Software" => "Paint.NET v3.5.11",
        "IFD0:Exif_0x0301" => 2.199978,
      }, file.metadata.to_h)
    end
  end

  context "a PNG with a SMPTE ST 2084 (PQ) color profile" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/png/test-smpte-st-2084-profile.png")

      assert_equal(500, file.width)
      assert_equal(500, file.height)
      assert_equal(7564, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("6ed0112a3660aabfade57b1a1e09a1dd", file.md5)
      assert_equal("2414f820b2ec4d91867c10e1a59d493b", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "PNG",
        "PNG:ImageWidth" => 500,
        "PNG:ImageHeight" => 500,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "RGB",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Adam7 Interlace",
        "PNG:ProfileName" => "ITUR_2100_PQ_FULL",
        "ICC-header:ProfileCMMType" => "Adobe Systems Inc.",
        "ICC-header:ProfileVersion" => "4.2.0",
        "ICC-header:ProfileClass" => "Display Device Profile",
        "ICC-header:ColorSpaceData" => "RGB ",
        "ICC-header:ProfileConnectionSpace" => "XYZ ",
        "ICC-header:ProfileDateTime" => "2015:08:25 21:16:58",
        "ICC-header:ProfileFileSignature" => "acsp",
        "ICC-header:PrimaryPlatform" => "Unknown ()",
        "ICC-header:CMMFlags" => "Not Embedded, Independent",
        "ICC-header:DeviceManufacturer" => "",
        "ICC-header:DeviceModel" => "",
        "ICC-header:DeviceAttributes" => "Reflective, Glossy, Positive, Color",
        "ICC-header:RenderingIntent" => "Media-Relative Colorimetric",
        "ICC-header:ConnectionSpaceIlluminant" => "0.9642 1 0.82491",
        "ICC-header:ProfileCreator" => "Adobe Systems Inc.",
        "ICC-header:ProfileID" => "eeac2efe66dc8a0fae5fea828f2c4ebc",
        "ICC_Profile:ProfileDescription" => "High Dynamic Range UHDTV Wide Color Gamut Display (Rec. 2020) - SMPTE ST 2084 PQ EOTF",
        "ICC_Profile:ProfileCopyright" => "Copyright 2015 Adobe Systems Incorporated",
        "ICC_Profile:MediaWhitePoint" => "0.9642 1 0.82491",
        "ICC_Profile:ChromaticAdaptation" => "1.0479 0.02292 -0.05022 0.02959 0.99048 -0.01707 -0.00925 0.01508 0.75168",
        "ICC_Profile:Technology" => "Video Monitor",
        "ICC_Profile:Luminance" => "0 100 0",
        "PNG-pHYs:PixelsPerUnitX" => 11_811,
        "PNG-pHYs:PixelsPerUnitY" => 11_811,
        "PNG-pHYs:PixelUnits" => "meters",
      }, file.metadata.to_h)
    end

    should "generate a thumbnail with the correct colors" do
      file = MediaFile.open("test/files/png/test-smpte-st-2084-profile.png").preview(180, 180)
      # XXX: this is the wrong thumbnail. See issue #5621. When this changes, hopefully it means libvips will have fixed this issue.
      assert_equal("b133ee75ca930f185a1bf605d7d2460c", file.pixel_hash)
    end
  end
end
