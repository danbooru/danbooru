require "test_helper"

class MediaFileDupesTest < ActiveSupport::TestCase
  context "a solid black 100x200 grayscale PNG" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/dupes/black-100x200.png")

      assert_equal(100, file.width)
      assert_equal(200, file.height)
      assert_equal(120, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("b93b7b1b7f0091f7098b1003c3e27260", file.md5)
      assert_equal("d7fccdb09eb17ed57ee2aaeff165e415", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "PNG",
        "PNG:ImageWidth" => 100,
        "PNG:ImageHeight" => 200,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "Grayscale",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG-pHYs:PixelsPerUnitX" => 1000,
        "PNG-pHYs:PixelsPerUnitY" => 1000,
        "PNG-pHYs:PixelUnits" => "meters",
      }, file.metadata.to_h)
    end
  end

  context "a solid black 200x100 grayscale PNG" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/dupes/black-200x100.png")

      assert_equal(200, file.width)
      assert_equal(100, file.height)
      assert_equal(119, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("35628feb05390fc0416f0460b903da06", file.md5)
      assert_equal("c1d32710ce71b7c02a9d943e1113b31f", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "PNG",
        "PNG:ImageWidth" => 200,
        "PNG:ImageHeight" => 100,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "Grayscale",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG-pHYs:PixelsPerUnitX" => 1000,
        "PNG-pHYs:PixelsPerUnitY" => 1000,
        "PNG-pHYs:PixelUnits" => "meters",
      }, file.metadata.to_h)
    end
  end

  context "a JPEG with an embedded Adobe RGB color profile" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/dupes/countergirl-adobergb.jpg")

      assert_equal(45, file.width)
      assert_equal(100, file.height)
      assert_equal(3038, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("36661b10c4b4233759ec185ae5e1d357", file.md5)
      assert_equal("5248da00038eb4b74b63c79a446775a0", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:ExifByteOrder" => "Little-endian (Intel, II)",
        "File:ImageWidth" => 45,
        "File:ImageHeight" => 100,
        "File:EncodingProcess" => "Baseline DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 3,
        "File:YCbCrSubSampling" => "YCbCr4:2:0 (2 2)",
        "IFD0:Orientation" => "Horizontal (normal)",
        "IFD0:XResolution" => 25.4,
        "IFD0:YResolution" => 25.4,
        "IFD0:ResolutionUnit" => "inches",
        "IFD0:YCbCrPositioning" => "Centered",
        "ExifIFD:ExifVersion" => "0210",
        "ExifIFD:ComponentsConfiguration" => "Y, Cb, Cr, -",
        "ExifIFD:FlashpixVersion" => "0100",
        "ExifIFD:ColorSpace" => "Uncalibrated",
        "ExifIFD:ExifImageWidth" => 45,
        "ExifIFD:ExifImageHeight" => 100,
        "ICC-header:ProfileCMMType" => "Adobe Systems Inc.",
        "ICC-header:ProfileVersion" => "2.1.0",
        "ICC-header:ProfileClass" => "Display Device Profile",
        "ICC-header:ColorSpaceData" => "RGB ",
        "ICC-header:ProfileConnectionSpace" => "XYZ ",
        "ICC-header:ProfileDateTime" => "1999:06:03 00:00:00",
        "ICC-header:ProfileFileSignature" => "acsp",
        "ICC-header:PrimaryPlatform" => "Apple Computer Inc.",
        "ICC-header:CMMFlags" => "Not Embedded, Independent",
        "ICC-header:DeviceManufacturer" => "none",
        "ICC-header:DeviceModel" => "",
        "ICC-header:DeviceAttributes" => "Reflective, Glossy, Positive, Color",
        "ICC-header:RenderingIntent" => "Perceptual",
        "ICC-header:ConnectionSpaceIlluminant" => "0.9642 1 0.82491",
        "ICC-header:ProfileCreator" => "Adobe Systems Inc.",
        "ICC-header:ProfileID" => 0,
        "ICC_Profile:ProfileCopyright" => "Copyright 1999 Adobe Systems Incorporated",
        "ICC_Profile:ProfileDescription" => "Adobe RGB (1998)",
        "ICC_Profile:MediaWhitePoint" => "0.95045 1 1.08905",
        "ICC_Profile:MediaBlackPoint" => "0 0 0",
        "ICC_Profile:RedMatrixColumn" => "0.60974 0.31111 0.01947",
        "ICC_Profile:GreenMatrixColumn" => "0.20528 0.62567 0.06087",
        "ICC_Profile:BlueMatrixColumn" => "0.14919 0.06322 0.74457",
      }, file.metadata.to_h)
    end
  end

  context "a baseline-encoded JPEG" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/dupes/countergirl-baseline.jpg")

      assert_equal(45, file.width)
      assert_equal(100, file.height)
      assert_equal(2460, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("1839af48fab8688cf72653d6ac4b52ab", file.md5)
      assert_equal("c135caa2229b6d43d06179503f70ed74", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:ExifByteOrder" => "Little-endian (Intel, II)",
        "File:ImageWidth" => 45,
        "File:ImageHeight" => 100,
        "File:EncodingProcess" => "Baseline DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 3,
        "File:YCbCrSubSampling" => "YCbCr4:2:0 (2 2)",
        "IFD0:Orientation" => "Horizontal (normal)",
        "IFD0:XResolution" => 25.4,
        "IFD0:YResolution" => 25.4,
        "IFD0:ResolutionUnit" => "inches",
        "IFD0:YCbCrPositioning" => "Centered",
        "ExifIFD:ExifVersion" => "0210",
        "ExifIFD:ComponentsConfiguration" => "Y, Cb, Cr, -",
        "ExifIFD:FlashpixVersion" => "0100",
        "ExifIFD:ColorSpace" => "Uncalibrated",
        "ExifIFD:ExifImageWidth" => 45,
        "ExifIFD:ExifImageHeight" => 100,
      }, file.metadata.to_h)
    end
  end

  context "a grayscale image saved as an RGB PNG with an sRGB profile" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/dupes/countergirl-grey-srgb.png")

      assert_equal(45, file.width)
      assert_equal(100, file.height)
      assert_equal(1956, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("632766b7230cc2844cf36fa14d2bf765", file.md5)
      assert_equal("d007f30f42cb7c5835fb3d0d9c24587e", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "PNG",
        "File:ExifByteOrder" => "Little-endian (Intel, II)",
        "PNG:ImageWidth" => 45,
        "PNG:ImageHeight" => 100,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "RGB with Alpha",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "IFD0:Orientation" => "Horizontal (normal)",
        "IFD0:XResolution" => 25.4,
        "IFD0:YResolution" => 25.4,
        "IFD0:ResolutionUnit" => "inches",
        "IFD0:YCbCrPositioning" => "Centered",
        "ExifIFD:ExifVersion" => "0210",
        "ExifIFD:ComponentsConfiguration" => "Y, Cb, Cr, -",
        "ExifIFD:FlashpixVersion" => "0100",
        "ExifIFD:ColorSpace" => "Uncalibrated",
        "ExifIFD:ExifImageWidth" => 45,
        "ExifIFD:ExifImageHeight" => 100,
        "PNG-pHYs:PixelsPerUnitX" => 1000,
        "PNG-pHYs:PixelsPerUnitY" => 1000,
        "PNG-pHYs:PixelUnits" => "meters",
        "XMP-x:XMPToolkit" => "Image::ExifTool 12.54",
        "XMP-exif:ComponentsConfiguration" => ["Y", "Cb", "Cr", "-"],
        "XMP-tiff:BitsPerSample" => [8],
        "XMP-tiff:ImageHeight" => 100,
        "XMP-tiff:ImageWidth" => 45,
        "XMP-tiff:YCbCrPositioning" => "Centered",
        "XMP-tiff:YCbCrSubSampling" => "YCbCr4:2:0 (2 2)",
        "ExifTool:Warning" => "[minor] Text/EXIF chunk(s) found after PNG IDAT (may be ignored by some readers)",
      }, file.metadata.to_h)
    end
  end

  context "a grayscale PNG with an alpha channel" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/dupes/countergirl-grey.png")

      assert_equal(45, file.width)
      assert_equal(100, file.height)
      assert_equal(1765, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("1073acb0a8a59139a687360bf9031c7f", file.md5)
      assert_equal("d007f30f42cb7c5835fb3d0d9c24587e", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "PNG",
        "File:ExifByteOrder" => "Little-endian (Intel, II)",
        "PNG:ImageWidth" => 45,
        "PNG:ImageHeight" => 100,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "Grayscale with Alpha",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "IFD0:Orientation" => "Horizontal (normal)",
        "IFD0:XResolution" => 25.4,
        "IFD0:YResolution" => 25.4,
        "IFD0:ResolutionUnit" => "inches",
        "IFD0:YCbCrPositioning" => "Centered",
        "ExifIFD:ExifVersion" => "0210",
        "ExifIFD:ComponentsConfiguration" => "Y, Cb, Cr, -",
        "ExifIFD:FlashpixVersion" => "0100",
        "ExifIFD:ColorSpace" => "Uncalibrated",
        "ExifIFD:ExifImageWidth" => 45,
        "ExifIFD:ExifImageHeight" => 100,
        "PNG-pHYs:PixelsPerUnitX" => 1000,
        "PNG-pHYs:PixelsPerUnitY" => 1000,
        "PNG-pHYs:PixelUnits" => "meters",
        "XMP-x:XMPToolkit" => "Image::ExifTool 12.54",
        "XMP-exif:ComponentsConfiguration" => ["Y", "Cb", "Cr", "-"],
        "XMP-tiff:BitsPerSample" => [8],
        "XMP-tiff:ImageHeight" => 100,
        "XMP-tiff:ImageWidth" => 45,
        "XMP-tiff:YCbCrPositioning" => "Centered",
        "XMP-tiff:YCbCrSubSampling" => "YCbCr4:2:0 (2 2)",
        "ExifTool:Warning" => "[minor] Text/EXIF chunk(s) found after PNG IDAT (may be ignored by some readers)",
      }, file.metadata.to_h)
    end
  end

  context "a JPEG without any EXIF metadata" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/dupes/countergirl-no-exif.jpg")

      assert_equal(45, file.width)
      assert_equal(100, file.height)
      assert_equal(2270, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("fa00b3cc4152933bf98692045fc59a6f", file.md5)
      assert_equal("c135caa2229b6d43d06179503f70ed74", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:ImageWidth" => 45,
        "File:ImageHeight" => 100,
        "File:EncodingProcess" => "Baseline DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 3,
        "File:YCbCrSubSampling" => "YCbCr4:2:0 (2 2)",
      }, file.metadata.to_h)
    end
  end

  context "a PNG without any EXIF metadata" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/dupes/countergirl-no-exif.png")

      assert_equal(45, file.width)
      assert_equal(100, file.height)
      assert_equal(1166, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("830eeb693d0f575ac76c92ed223dc3d8", file.md5)
      assert_equal("2981edc81606af5552b9cd2db0a60a2c", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "PNG",
        "PNG:ImageWidth" => 45,
        "PNG:ImageHeight" => 100,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "RGB with Alpha",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG-pHYs:PixelsPerUnitX" => 1000,
        "PNG-pHYs:PixelsPerUnitY" => 1000,
        "PNG-pHYs:PixelUnits" => "meters",
      }, file.metadata.to_h)
    end
  end

  context "a JPEG with an embedded Display P3 color profile" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/dupes/countergirl-p3.jpg")

      assert_equal(45, file.width)
      assert_equal(100, file.height)
      assert_equal(3026, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("219393b24e3dd7713e2b34c268e3fbf7", file.md5)
      assert_equal("0d45a5397a9180e66be27cf8abaa1c74", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:ExifByteOrder" => "Little-endian (Intel, II)",
        "File:ImageWidth" => 45,
        "File:ImageHeight" => 100,
        "File:EncodingProcess" => "Baseline DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 3,
        "File:YCbCrSubSampling" => "YCbCr4:2:0 (2 2)",
        "IFD0:Orientation" => "Horizontal (normal)",
        "IFD0:XResolution" => 25.4,
        "IFD0:YResolution" => 25.4,
        "IFD0:ResolutionUnit" => "inches",
        "IFD0:YCbCrPositioning" => "Centered",
        "ExifIFD:ExifVersion" => "0210",
        "ExifIFD:ComponentsConfiguration" => "Y, Cb, Cr, -",
        "ExifIFD:FlashpixVersion" => "0100",
        "ExifIFD:ColorSpace" => "Uncalibrated",
        "ExifIFD:ExifImageWidth" => 45,
        "ExifIFD:ExifImageHeight" => 100,
        "ICC-header:ProfileCMMType" => "Apple Computer Inc.",
        "ICC-header:ProfileVersion" => "4.0.0",
        "ICC-header:ProfileClass" => "Display Device Profile",
        "ICC-header:ColorSpaceData" => "RGB ",
        "ICC-header:ProfileConnectionSpace" => "XYZ ",
        "ICC-header:ProfileDateTime" => "2015:10:14 13:08:57",
        "ICC-header:ProfileFileSignature" => "acsp",
        "ICC-header:PrimaryPlatform" => "Apple Computer Inc.",
        "ICC-header:CMMFlags" => "Not Embedded, Independent",
        "ICC-header:DeviceManufacturer" => "Apple Computer Inc.",
        "ICC-header:DeviceModel" => "",
        "ICC-header:DeviceAttributes" => "Reflective, Glossy, Positive, Color",
        "ICC-header:RenderingIntent" => "Perceptual",
        "ICC-header:ConnectionSpaceIlluminant" => "0.9642 1 0.82491",
        "ICC-header:ProfileCreator" => "Apple Computer Inc.",
        "ICC-header:ProfileID" => "e5bb0e9867bd46cd4bbe446ebd1b7598",
        "ICC_Profile:ProfileDescription" => "Display P3",
        "ICC_Profile:ProfileCopyright" => "Copyright Apple Inc., 2015",
        "ICC_Profile:MediaWhitePoint" => "0.95045 1 1.08905",
        "ICC_Profile:RedMatrixColumn" => "0.51512 0.2412 -0.00105",
        "ICC_Profile:GreenMatrixColumn" => "0.29198 0.69225 0.04189",
        "ICC_Profile:BlueMatrixColumn" => "0.1571 0.06657 0.78407",
        "ICC_Profile:ChromaticAdaptation" => "1.04788 0.02292 -0.0502 0.02959 0.99048 -0.01706 -0.00923 0.01508 0.75168",
      }, file.metadata.to_h)
    end
  end

  context "a progressive-encoded JPEG" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/dupes/countergirl-progressive.jpg")

      assert_equal(45, file.width)
      assert_equal(100, file.height)
      assert_equal(2334, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("264cb22336ceaddf8bf2b1ba6d472bb0", file.md5)
      assert_equal("c135caa2229b6d43d06179503f70ed74", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:ExifByteOrder" => "Little-endian (Intel, II)",
        "File:ImageWidth" => 45,
        "File:ImageHeight" => 100,
        "File:EncodingProcess" => "Progressive DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 3,
        "File:YCbCrSubSampling" => "YCbCr4:2:0 (2 2)",
        "IFD0:Orientation" => "Horizontal (normal)",
        "IFD0:XResolution" => 25.4,
        "IFD0:YResolution" => 25.4,
        "IFD0:ResolutionUnit" => "inches",
        "IFD0:YCbCrPositioning" => "Centered",
        "ExifIFD:ExifVersion" => "0210",
        "ExifIFD:ComponentsConfiguration" => "Y, Cb, Cr, -",
        "ExifIFD:FlashpixVersion" => "0100",
        "ExifIFD:ColorSpace" => "Uncalibrated",
        "ExifIFD:ExifImageWidth" => 45,
        "ExifIFD:ExifImageHeight" => 100,
      }, file.metadata.to_h)
    end
  end

  context "a JPEG with an embedded ProPhoto RGB color profile" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/dupes/countergirl-prophoto.jpg")

      assert_equal(45, file.width)
      assert_equal(100, file.height)
      assert_equal(3418, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("29cd7fbe8a76cc2b287290a1d5978247", file.md5)
      assert_equal("d55a89f6780cb8d2c630a0909ae67f2b", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:ExifByteOrder" => "Little-endian (Intel, II)",
        "File:ImageWidth" => 45,
        "File:ImageHeight" => 100,
        "File:EncodingProcess" => "Baseline DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 3,
        "File:YCbCrSubSampling" => "YCbCr4:2:0 (2 2)",
        "IFD0:Orientation" => "Horizontal (normal)",
        "IFD0:XResolution" => 25.4,
        "IFD0:YResolution" => 25.4,
        "IFD0:ResolutionUnit" => "inches",
        "IFD0:YCbCrPositioning" => "Centered",
        "ExifIFD:ExifVersion" => "0210",
        "ExifIFD:ComponentsConfiguration" => "Y, Cb, Cr, -",
        "ExifIFD:FlashpixVersion" => "0100",
        "ExifIFD:ColorSpace" => "Uncalibrated",
        "ExifIFD:ExifImageWidth" => 45,
        "ExifIFD:ExifImageHeight" => 100,
        "ICC-header:ProfileCMMType" => "Unknown (KCMS)",
        "ICC-header:ProfileVersion" => "2.1.0",
        "ICC-header:ProfileClass" => "Display Device Profile",
        "ICC-header:ColorSpaceData" => "RGB ",
        "ICC-header:ProfileConnectionSpace" => "XYZ ",
        "ICC-header:ProfileDateTime" => "1998:12:01 18:58:21",
        "ICC-header:ProfileFileSignature" => "acsp",
        "ICC-header:PrimaryPlatform" => "Microsoft Corporation",
        "ICC-header:CMMFlags" => "Not Embedded, Independent",
        "ICC-header:DeviceManufacturer" => "Kodak",
        "ICC-header:DeviceModel" => "ROMM",
        "ICC-header:DeviceAttributes" => "Reflective, Glossy, Positive, Color",
        "ICC-header:RenderingIntent" => "Perceptual",
        "ICC-header:ConnectionSpaceIlluminant" => "0.9642 1 0.82487",
        "ICC-header:ProfileCreator" => "Kodak",
        "ICC-header:ProfileID" => 0,
        "ICC_Profile:ProfileCopyright" => "Copyright (c) Eastman Kodak Company, 1999, all rights reserved.",
        "ICC_Profile:ProfileDescription" => "ProPhoto RGB",
        "ICC_Profile:MediaWhitePoint" => "0.9642 1 0.82489",
        "ICC_Profile:RedMatrixColumn" => "0.79767 0.28804 0",
        "ICC_Profile:GreenMatrixColumn" => "0.13519 0.71188 0",
        "ICC_Profile:BlueMatrixColumn" => "0.03134 9e-05 0.82491",
        "ICC_Profile:DeviceMfgDesc" => "KODAK",
        "ICC_Profile:DeviceModelDesc" => "Reference Output Medium Metric(ROMM)  ",
      }, file.metadata.to_h)
    end
  end

  context "a color JPEG with an incompatible grayscale color profile" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/dupes/countergirl-rgb-gray.jpg")

      assert_equal(45, file.width)
      assert_equal(100, file.height)
      assert_equal(3200, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("a49d161851f3901864dc72f3727dbe44", file.md5)
      assert_equal("c135caa2229b6d43d06179503f70ed74", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:ImageWidth" => 45,
        "File:ImageHeight" => 100,
        "File:EncodingProcess" => "Baseline DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 3,
        "File:YCbCrSubSampling" => "YCbCr4:2:0 (2 2)",
        "ICC-header:ProfileCMMType" => "Adobe Systems Inc.",
        "ICC-header:ProfileVersion" => "2.1.0",
        "ICC-header:ProfileClass" => "Output Device Profile",
        "ICC-header:ColorSpaceData" => "GRAY",
        "ICC-header:ProfileConnectionSpace" => "XYZ ",
        "ICC-header:ProfileDateTime" => "1999:06:03 00:00:00",
        "ICC-header:ProfileFileSignature" => "acsp",
        "ICC-header:PrimaryPlatform" => "Apple Computer Inc.",
        "ICC-header:CMMFlags" => "Not Embedded, Independent",
        "ICC-header:DeviceManufacturer" => "none",
        "ICC-header:DeviceModel" => "",
        "ICC-header:DeviceAttributes" => "Reflective, Glossy, Positive, Color",
        "ICC-header:RenderingIntent" => "Perceptual",
        "ICC-header:ConnectionSpaceIlluminant" => "0.9642 1 0.82491",
        "ICC-header:ProfileCreator" => "Adobe Systems Inc.",
        "ICC-header:ProfileID" => 0,
        "ICC_Profile:ProfileCopyright" => "Copyright 1999 Adobe Systems Incorporated",
        "ICC_Profile:ProfileDescription" => "Dot Gain 15%",
        "ICC_Profile:MediaWhitePoint" => "0.9642 1 0.82491",
        "ICC_Profile:MediaBlackPoint" => "0 0 0",
      }, file.metadata.to_h)
    end
  end

  context "a JPEG with an embedded sRGB color profile" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/dupes/countergirl-srgb.jpg")

      assert_equal(45, file.width)
      assert_equal(100, file.height)
      assert_equal(63_438, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("c3c0bd5fdedb128a1d41c045196de217", file.md5)
      assert_equal("b0f7550b021e7eed2f81701b629ea553", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:ExifByteOrder" => "Little-endian (Intel, II)",
        "File:ImageWidth" => 45,
        "File:ImageHeight" => 100,
        "File:EncodingProcess" => "Baseline DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 3,
        "File:YCbCrSubSampling" => "YCbCr4:2:0 (2 2)",
        "IFD0:Orientation" => "Horizontal (normal)",
        "IFD0:XResolution" => 25.4,
        "IFD0:YResolution" => 25.4,
        "IFD0:ResolutionUnit" => "inches",
        "IFD0:YCbCrPositioning" => "Centered",
        "ExifIFD:ExifVersion" => "0210",
        "ExifIFD:ComponentsConfiguration" => "Y, Cb, Cr, -",
        "ExifIFD:FlashpixVersion" => "0100",
        "ExifIFD:ColorSpace" => "Uncalibrated",
        "ExifIFD:ExifImageWidth" => 45,
        "ExifIFD:ExifImageHeight" => 100,
        "ICC-header:ProfileCMMType" => "",
        "ICC-header:ProfileVersion" => "4.2.0",
        "ICC-header:ProfileClass" => "ColorSpace Conversion Profile",
        "ICC-header:ColorSpaceData" => "RGB ",
        "ICC-header:ProfileConnectionSpace" => "Lab ",
        "ICC-header:ProfileDateTime" => "2007:07:25 00:05:37",
        "ICC-header:ProfileFileSignature" => "acsp",
        "ICC-header:PrimaryPlatform" => "Unknown ()",
        "ICC-header:CMMFlags" => "Not Embedded, Independent",
        "ICC-header:DeviceManufacturer" => "",
        "ICC-header:DeviceModel" => "",
        "ICC-header:DeviceAttributes" => "Reflective, Glossy, Positive, Color",
        "ICC-header:RenderingIntent" => "Perceptual",
        "ICC-header:ConnectionSpaceIlluminant" => "0.9642 1 0.82491",
        "ICC-header:ProfileCreator" => "",
        "ICC-header:ProfileID" => "34562abf994ccd066d2c5721d0d68c5d",
        "ICC_Profile:ProfileDescription" => "sRGB v4 ICC preference perceptual intent beta",
        "ICC_Profile:PerceptualRenderingIntentGamut" => "Perceptual Reference Medium Gamut",
        "ICC_Profile:MediaWhitePoint" => "0.9642 1 0.82491",
        "ICC_Profile:ProfileCopyright" => "Copyright 2007 International Color Consortium",
        "ICC_Profile:ChromaticAdaptation" => "1.04802 0.02301 -0.05017 0.02972 0.99034 -0.01707 -0.00923 0.01028 0.75214",
      }, file.metadata.to_h)
    end
  end

  context "a PNG with a white background and an opaque alpha channel" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/dupes/countergirl-whitebg-alpha.png")

      assert_equal(45, file.width)
      assert_equal(100, file.height)
      assert_equal(1216, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("a353ab010901216b56a2be2d90fc8bfc", file.md5)
      assert_equal("5199b09cccde8a33c3d204413f5450d9", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "PNG",
        "PNG:ImageWidth" => 45,
        "PNG:ImageHeight" => 100,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "RGB with Alpha",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG-pHYs:PixelsPerUnitX" => 1000,
        "PNG-pHYs:PixelsPerUnitY" => 1000,
        "PNG-pHYs:PixelUnits" => "meters",
      }, file.metadata.to_h)
    end
  end

  context "a GIF with a white background and no alpha channel" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/dupes/countergirl-whitebg-noalpha.gif")

      assert_equal(45, file.width)
      assert_equal(100, file.height)
      assert_equal(1122, file.file_size)
      assert_equal(:gif, file.file_ext)
      assert_equal("image/gif", file.mime_type)
      assert_equal("a4b5924967ace4045546def1609e9abc", file.md5)
      assert_equal("5199b09cccde8a33c3d204413f5450d9", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "GIF",
        "GIF:GIFVersion" => "89a",
        "GIF:ImageWidth" => 45,
        "GIF:ImageHeight" => 100,
        "GIF:HasColorMap" => "Yes",
        "GIF:ColorResolutionDepth" => 1,
        "GIF:BitsPerPixel" => 5,
        "GIF:BackgroundColor" => 0,
        "GIF:AnimationIterations" => "Infinite",
        "GIF:TransparentColor" => 0,
      }, file.metadata.to_h)
    end
  end

  context "a PNG with a white background and no alpha channel" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/dupes/countergirl-whitebg-noalpha.png")

      assert_equal(45, file.width)
      assert_equal(100, file.height)
      assert_equal(1188, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("058a5b03b4b22befe3813f4bc901fe1e", file.md5)
      assert_equal("5199b09cccde8a33c3d204413f5450d9", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "PNG",
        "PNG:ImageWidth" => 45,
        "PNG:ImageHeight" => 100,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "RGB",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG-pHYs:PixelsPerUnitX" => 1000,
        "PNG-pHYs:PixelsPerUnitY" => 1000,
        "PNG-pHYs:PixelUnits" => "meters",
      }, file.metadata.to_h)
    end
  end

  context "a GIF with a transparent alpha channel" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/dupes/countergirl.gif")

      assert_equal(45, file.width)
      assert_equal(100, file.height)
      assert_equal(1045, file.file_size)
      assert_equal(:gif, file.file_ext)
      assert_equal("image/gif", file.mime_type)
      assert_equal("cc2e12de5c11afad72540c230e9dea37", file.md5)
      assert_equal("2981edc81606af5552b9cd2db0a60a2c", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "GIF",
        "GIF:GIFVersion" => "89a",
        "GIF:ImageWidth" => 45,
        "GIF:ImageHeight" => 100,
        "GIF:HasColorMap" => "Yes",
        "GIF:ColorResolutionDepth" => 4,
        "GIF:BitsPerPixel" => 4,
        "GIF:BackgroundColor" => 0,
        "GIF:TransparentColor" => 15,
      }, file.metadata.to_h)
    end
  end

  context "a PNG with a transparent alpha channel" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/dupes/countergirl.png")

      assert_equal(45, file.width)
      assert_equal(100, file.height)
      assert_equal(2363, file.file_size)
      assert_equal(:png, file.file_ext)
      assert_equal("image/png", file.mime_type)
      assert_equal("af529aa2250b21fcb37b781a246937e5", file.md5)
      assert_equal("2981edc81606af5552b9cd2db0a60a2c", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "PNG",
        "File:ExifByteOrder" => "Little-endian (Intel, II)",
        "PNG:ImageWidth" => 45,
        "PNG:ImageHeight" => 100,
        "PNG:BitDepth" => 8,
        "PNG:ColorType" => "RGB with Alpha",
        "PNG:Compression" => "Deflate/Inflate",
        "PNG:Filter" => "Adaptive",
        "PNG:Interlace" => "Noninterlaced",
        "PNG-pHYs:PixelsPerUnitX" => 1000,
        "PNG-pHYs:PixelsPerUnitY" => 1000,
        "PNG-pHYs:PixelUnits" => "meters",
        "XMP-x:XMPToolkit" => "Image::ExifTool 12.54",
        "XMP-exif:ComponentsConfiguration" => ["Y", "Cb", "Cr", "-"],
        "XMP-tiff:BitsPerSample" => [8],
        "XMP-tiff:ImageHeight" => 100,
        "XMP-tiff:ImageWidth" => 45,
        "XMP-tiff:YCbCrPositioning" => "Centered",
        "XMP-tiff:YCbCrSubSampling" => "YCbCr4:2:0 (2 2)",
        "IFD0:Orientation" => "Horizontal (normal)",
        "IFD0:XResolution" => 25.4,
        "IFD0:YResolution" => 25.4,
        "IFD0:ResolutionUnit" => "inches",
        "IFD0:YCbCrPositioning" => "Centered",
        "ExifIFD:ExifVersion" => "0210",
        "ExifIFD:ComponentsConfiguration" => "Y, Cb, Cr, -",
        "ExifIFD:FlashpixVersion" => "0100",
        "ExifIFD:ColorSpace" => "Uncalibrated",
        "ExifIFD:ExifImageWidth" => 45,
        "ExifIFD:ExifImageHeight" => 100,
      }, file.metadata.to_h)
    end
  end
end
