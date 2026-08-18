require "test_helper"

class MediaFileAvifTest < ActiveSupport::TestCase
  context "Previews" do
    should "be generated properly" do
      should_generate_previews(
        "avif",
        failures: [
          "test/files/apng/misaligned_chunks.png",
        ],
      )
    end
  end

  context "an HDR AVIF with limited-range 4:2:0 chroma subsampling" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/avif/hdr_cosmos01000_cicp9-16-9_yuv420_limited_qp40.avif")

      assert_equal(2048, file.width)
      assert_equal(858, file.height)
      assert_equal(9829, file.file_size)
      assert_equal(:avif, file.file_ext)
      assert_equal("image/avif", file.mime_type)
      assert_equal("e4484f092e696eb3599428d42d0faa5f", file.md5)
      assert_equal("5f5b6a2c44efda3f496868cf9b83c4f0", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "AVIF",
        "File:ImageWidth" => 2048,
        "File:ImageHeight" => 858,
        "QuickTime:MajorBrand" => "AV1 Image File Format (.AVIF)",
        "QuickTime:MinorVersion" => "0.0.0",
        "QuickTime:CompatibleBrands" => ["avif", "mif1", "miaf", "MA1B"],
        "QuickTime:HandlerType" => "Picture",
        "QuickTime:HandlerDescription" => "libavif",
        "QuickTime:ImageSpatialExtent" => "2048x858",
        "QuickTime:ImagePixelDepth" => "10 10 10",
        "QuickTime:AV1ConfigurationVersion" => 1,
        "QuickTime:SeqProfile" => 0,
        "QuickTime:SeqLevelIdx0" => 8,
        "QuickTime:SeqTier0" => 0,
        "QuickTime:HighBitDepth" => 1,
        "QuickTime:TwelveBit" => 0,
        "QuickTime:ChromaFormat" => "YUV 4:2:0",
        "QuickTime:ChromaSamplePosition" => "Unknown",
        "QuickTime:InitialDelaySamples" => 1,
        "QuickTime:ColorProfiles" => "nclx",
        "QuickTime:ColorPrimaries" => "BT.2020, BT.2100",
        "QuickTime:TransferCharacteristics" => "SMPTE ST 2084, ITU BT.2100 PQ",
        "QuickTime:MatrixCoefficients" => "BT.2020 non-constant luminance, BT.2100 YCbCr",
        "QuickTime:VideoFullRangeFlag" => "Limited",
        "QuickTime:MediaDataSize" => 9547,
        "QuickTime:MediaDataOffset" => 282,
        "Meta:PrimaryItemReference" => 1,
      }, file.metadata.to_h)
    end
  end

  context "an HDR AVIF with full-range 4:4:4 chroma subsampling" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/avif/hdr_cosmos01000_cicp9-16-9_yuv444_full_qp40.avif")

      assert_equal(2048, file.width)
      assert_equal(858, file.height)
      assert_equal(12_877, file.file_size)
      assert_equal(:avif, file.file_ext)
      assert_equal("image/avif", file.mime_type)
      assert_equal("ed78c8cb4e09371401b759f59e38b8c6", file.md5)
      assert_equal("9dbd09c0727a93cfda4084f234a2bb38", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "AVIF",
        "File:ImageWidth" => 2048,
        "File:ImageHeight" => 858,
        "QuickTime:MajorBrand" => "AV1 Image File Format (.AVIF)",
        "QuickTime:MinorVersion" => "0.0.0",
        "QuickTime:CompatibleBrands" => ["avif", "mif1", "miaf", "MA1A"],
        "QuickTime:HandlerType" => "Picture",
        "QuickTime:HandlerDescription" => "libavif",
        "QuickTime:ImageSpatialExtent" => "2048x858",
        "QuickTime:ImagePixelDepth" => "10 10 10",
        "QuickTime:AV1ConfigurationVersion" => 1,
        "QuickTime:SeqProfile" => 1,
        "QuickTime:SeqLevelIdx0" => 8,
        "QuickTime:SeqTier0" => 0,
        "QuickTime:HighBitDepth" => 1,
        "QuickTime:TwelveBit" => 0,
        "QuickTime:ChromaFormat" => "YUV 4:4:4",
        "QuickTime:ChromaSamplePosition" => "Unknown",
        "QuickTime:InitialDelaySamples" => 1,
        "QuickTime:ColorProfiles" => "nclx",
        "QuickTime:ColorPrimaries" => "BT.2020, BT.2100",
        "QuickTime:TransferCharacteristics" => "SMPTE ST 2084, ITU BT.2100 PQ",
        "QuickTime:MatrixCoefficients" => "BT.2020 non-constant luminance, BT.2100 YCbCr",
        "QuickTime:VideoFullRangeFlag" => "Full",
        "QuickTime:MediaDataSize" => 12_595,
        "QuickTime:MediaDataOffset" => 282,
        "Meta:PrimaryItemReference" => 1,
      }, file.metadata.to_h)
    end
  end

  context "an AVIF file with an EXIF orientation of 0 (normal)" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/avif/Exif0.avif")

      assert_equal(640, file.width)
      assert_equal(427, file.height)
      assert_equal(53_466, file.file_size)
      assert_equal(:avif, file.file_ext)
      assert_equal("image/avif", file.mime_type)
      assert_equal("cf3f924c16476aa38af4b4764dd8e2d3", file.md5)
      assert_equal("7542bba93c64d7c294a48c6a5ceb9815", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "AVIF",
        "File:ImageWidth" => 640,
        "File:ImageHeight" => 427,
        "QuickTime:MajorBrand" => "AV1 Image File Format (.AVIF)",
        "QuickTime:MinorVersion" => "0.0.0",
        "QuickTime:CompatibleBrands" => ["avif", "mif1", "miaf", "MA1A"],
        "QuickTime:HandlerType" => "Picture",
        "QuickTime:HandlerDescription" => "libavif",
        "QuickTime:ImageSpatialExtent" => "640x427",
        "QuickTime:ImagePixelDepth" => "8 8 8",
        "QuickTime:AV1ConfigurationVersion" => 1,
        "QuickTime:SeqProfile" => 1,
        "QuickTime:SeqLevelIdx0" => 31,
        "QuickTime:SeqTier0" => 0,
        "QuickTime:HighBitDepth" => 0,
        "QuickTime:TwelveBit" => 0,
        "QuickTime:ChromaFormat" => "YUV 4:4:4",
        "QuickTime:ChromaSamplePosition" => "Unknown",
        "QuickTime:InitialDelaySamples" => 1,
        "QuickTime:ColorProfiles" => "nclx",
        "QuickTime:ColorPrimaries" => "BT.709",
        "QuickTime:TransferCharacteristics" => "sRGB or sYCC",
        "QuickTime:MatrixCoefficients" => "BT.601",
        "QuickTime:VideoFullRangeFlag" => "Full",
        "QuickTime:MediaDataSize" => 53_184,
        "QuickTime:MediaDataOffset" => 282,
        "Meta:PrimaryItemReference" => 1,
      }, file.metadata.to_h)
    end
  end

  context "an AVIF file with an EXIF orientation of 6 (rotated)" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/avif/Exif6.avif")

      assert_equal(427, file.width)
      assert_equal(640, file.height)
      assert_equal(54_018, file.file_size)
      assert_equal(:avif, file.file_ext)
      assert_equal("image/avif", file.mime_type)
      assert_equal("82925be44d39c5a8273f9ab6355b83ca", file.md5)
      assert_equal("2cd7cd5f7f67a786c1b14d60ed7b6c25", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "AVIF",
        "File:ExifByteOrder" => "Big-endian (Motorola, MM)",
        "File:ImageWidth" => 427,
        "File:ImageHeight" => 640,
        "QuickTime:MajorBrand" => "AV1 Image File Format (.AVIF)",
        "QuickTime:MinorVersion" => "0.0.0",
        "QuickTime:CompatibleBrands" => ["avif", "mif1", "miaf", "MA1A"],
        "QuickTime:HandlerType" => "Picture",
        "QuickTime:HandlerDescription" => "libavif",
        "QuickTime:ImageSpatialExtent" => "427x640",
        "QuickTime:ImagePixelDepth" => "8 8 8",
        "QuickTime:AV1ConfigurationVersion" => 1,
        "QuickTime:SeqProfile" => 1,
        "QuickTime:SeqLevelIdx0" => 31,
        "QuickTime:SeqTier0" => 0,
        "QuickTime:HighBitDepth" => 0,
        "QuickTime:TwelveBit" => 0,
        "QuickTime:ChromaFormat" => "YUV 4:4:4",
        "QuickTime:ChromaSamplePosition" => "Unknown",
        "QuickTime:InitialDelaySamples" => 1,
        "QuickTime:ColorProfiles" => "nclx",
        "QuickTime:ColorPrimaries" => "BT.709",
        "QuickTime:TransferCharacteristics" => "sRGB or sYCC",
        "QuickTime:MatrixCoefficients" => "BT.601",
        "QuickTime:VideoFullRangeFlag" => "Full",
        "QuickTime:MediaDataSize" => 53_675,
        "QuickTime:MediaDataOffset" => 343,
        "Meta:PrimaryItemReference" => 1,
        "IFD0:Orientation" => "Rotate 90 CW",
        "IFD0:XResolution" => 72,
        "IFD0:YResolution" => 72,
        "IFD0:ResolutionUnit" => "inches",
        "IFD0:YCbCrPositioning" => "Centered",
      }, file.metadata.to_h)
    end
  end

  context "an AVIF image built from a grid of tiles" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/avif/Image grid example.avif")

      assert_equal(512, file.width)
      assert_equal(512, file.height)
      assert_equal(5740, file.file_size)
      assert_equal(:avif, file.file_ext)
      assert_equal("image/avif", file.mime_type)
      assert_equal("3e7e1e24f500fa7b9a29d7ea115a27fa", file.md5)
      assert_equal("8a327310e80d13e1f6ae230fbefa81c6", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "AVIF",
        "File:ExifByteOrder" => "Little-endian (Intel, II)",
        "File:ImageWidth" => 512,
        "File:ImageHeight" => 512,
        "QuickTime:MajorBrand" => "AV1 Image File Format (.AVIF)",
        "QuickTime:MinorVersion" => "0.0.0",
        "QuickTime:CompatibleBrands" => ["avif", "mif1", "miaf", "MA1B"],
        "QuickTime:HandlerType" => "Picture",
        "QuickTime:HandlerDescription" => "PDNavif",
        "QuickTime:PixelAspectRatio" => "1 1",
        "QuickTime:AV1ConfigurationVersion" => 1,
        "QuickTime:SeqProfile" => 0,
        "QuickTime:SeqLevelIdx0" => 0,
        "QuickTime:SeqTier0" => 0,
        "QuickTime:HighBitDepth" => 0,
        "QuickTime:TwelveBit" => 0,
        "QuickTime:ChromaFormat" => "YUV 4:2:0",
        "QuickTime:ChromaSamplePosition" => "Unknown",
        "QuickTime:InitialDelaySamples" => 1,
        "QuickTime:ImagePixelDepth" => "8 8 8",
        "QuickTime:ImageSpatialExtent" => "512x512",
        "QuickTime:ColorProfiles" => "nclx",
        "QuickTime:ColorPrimaries" => "BT.709",
        "QuickTime:TransferCharacteristics" => "sRGB or sYCC",
        "QuickTime:MatrixCoefficients" => "BT.709",
        "QuickTime:VideoFullRangeFlag" => "Full",
        "QuickTime:MediaDataSize" => 5143,
        "QuickTime:MediaDataOffset" => 597,
        "Meta:PrimaryItemReference" => 5,
        "IFD0:Orientation" => "Horizontal (normal)",
        "IFD0:XResolution" => 95.986,
        "IFD0:YResolution" => 95.986,
        "IFD0:ResolutionUnit" => "inches",
        "IFD0:Software" => "paint.net 4.2.14",
        "ExifIFD:ExifVersion" => "0230",
        "ExifIFD:ColorSpace" => "sRGB",
        "ExifIFD:ExifImageWidth" => 512,
        "ExifIFD:ExifImageHeight" => 512,
      }, file.metadata.to_h)
    end
  end

  context "an animated AVIF sequence with an alpha channel" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/avif/alpha_video.avif")

      assert_equal(640, file.width)
      assert_equal(480, file.height)
      assert_equal(10_755, file.file_size)
      assert_equal(:avif, file.file_ext)
      assert_equal("image/avif", file.mime_type)
      assert_equal("5ad19202d4cd9b0e90587f56ff648c28", file.md5)
      assert_equal("5ad19202d4cd9b0e90587f56ff648c28", file.pixel_hash)
      assert_equal(true, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(1.92, file.duration)
      assert_equal(48, file.frame_count)
      assert_equal(25.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "File:ImageWidth" => 640,
        "File:ImageHeight" => 480,
        "QuickTime:MajorBrand" => "Unknown (avis)",
        "QuickTime:MinorVersion" => "0.0.0",
        "QuickTime:CompatibleBrands" => ["mif1", "avif", "iso4", "av01", "avis", "msf1", "miaf", "MA1B"],
        "QuickTime:HandlerType" => "Picture",
        "QuickTime:HandlerDescription" => "GPAC pict Handler",
        "QuickTime:ImageSpatialExtent" => "640x480",
        "QuickTime:PixelAspectRatio" => "1 1",
        "QuickTime:AuxiliaryImageType" => "urn:mpeg:mpegB:cicp:systems:auxiliary:alpha",
        "QuickTime:AV1ConfigurationVersion" => 1,
        "QuickTime:SeqProfile" => 0,
        "QuickTime:SeqLevelIdx0" => 4,
        "QuickTime:SeqTier0" => 0,
        "QuickTime:HighBitDepth" => 0,
        "QuickTime:TwelveBit" => 0,
        "QuickTime:ChromaFormat" => "YUV 4:2:0",
        "QuickTime:ChromaSamplePosition" => "Unknown",
        "QuickTime:InitialDelaySamples" => 1,
        "QuickTime:ImagePixelDepth" => "8 8 8",
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "2019:02:04 21:19:42",
        "QuickTime:ModifyDate" => "2019:02:04 21:19:42",
        "QuickTime:TimeScale" => 600,
        "QuickTime:Duration" => "1.92 s",
        "QuickTime:PreferredRate" => 1,
        "QuickTime:PreferredVolume" => "100.00%",
        "QuickTime:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "QuickTime:PreviewTime" => "0 s",
        "QuickTime:PreviewDuration" => "0 s",
        "QuickTime:PosterTime" => "0 s",
        "QuickTime:SelectionTime" => "0 s",
        "QuickTime:SelectionDuration" => "0 s",
        "QuickTime:CurrentTime" => "0 s",
        "QuickTime:NextTrackID" => 3,
        "QuickTime:MediaDataSize" => 8440,
        "QuickTime:MediaDataOffset" => 2234,
        "Meta:PrimaryItemReference" => 4,
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "2019:02:04 21:19:42",
        "Track1:TrackModifyDate" => "2019:02:04 21:19:42",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "1.92 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 640,
        "Track1:ImageHeight" => 480,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "2019:02:04 21:19:42",
        "Track1:MediaModifyDate" => "2019:02:04 21:19:42",
        "Track1:MediaTimeScale" => 25_000,
        "Track1:MediaDuration" => "1.92 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Picture",
        "Track1:HandlerDescription" => "GPAC avifs",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:OtherFormat" => "av01",
        "Track2:TrackHeaderVersion" => 0,
        "Track2:TrackCreateDate" => "2019:02:04 21:19:42",
        "Track2:TrackModifyDate" => "2019:02:04 21:19:42",
        "Track2:TrackID" => 2,
        "Track2:TrackDuration" => "1.92 s",
        "Track2:TrackLayer" => 0,
        "Track2:TrackVolume" => "0.00%",
        "Track2:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track2:ImageWidth" => 640,
        "Track2:ImageHeight" => 480,
        "Track2:MediaHeaderVersion" => 0,
        "Track2:MediaCreateDate" => "2019:02:04 21:19:42",
        "Track2:MediaModifyDate" => "2019:02:04 21:19:42",
        "Track2:MediaTimeScale" => 25_000,
        "Track2:MediaDuration" => "1.92 s",
        "Track2:MediaLanguageCode" => "und",
        "Track2:HandlerType" => "Unknown (auxv)",
        "Track2:HandlerDescription" => "GPAC avifs alpha",
        "Track2:GraphicsMode" => "srcCopy",
        "Track2:OpColor" => "0 0 0",
        "Track2:OtherFormat" => "av01",
        "Composite:AvgBitrate" => "35.2 kbps",
        "Vips:Error" => "libvips error",
      }, file.metadata.to_h)
    end
  end

  context "a monochrome 8bpc AVIF with 4:2:0 chroma subsampling" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/avif/fox.profile0.8bpc.yuv420.monochrome.avif")

      assert_equal(1204, file.width)
      assert_equal(800, file.height)
      assert_equal(69_856, file.file_size)
      assert_equal(:avif, file.file_ext)
      assert_equal("image/avif", file.mime_type)
      assert_equal("c06b602f8232c1e3987e5a131d5feb54", file.md5)
      assert_equal("21e8133c81d6e30cec95127973a1793a", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "AVIF",
        "File:ImageWidth" => 1204,
        "File:ImageHeight" => 800,
        "QuickTime:MajorBrand" => "AV1 Image File Format (.AVIF)",
        "QuickTime:MinorVersion" => "0.0.0",
        "QuickTime:CompatibleBrands" => ["avif", "mif1", "miaf", "MA1B"],
        "QuickTime:HandlerType" => "Picture",
        "QuickTime:HandlerDescription" => "cavif - https://github.com/link-u/cavif",
        "QuickTime:PixelAspectRatio" => "1 1",
        "QuickTime:ImageSpatialExtent" => "1204x800",
        "QuickTime:ImagePixelDepth" => 8,
        "QuickTime:AV1ConfigurationVersion" => 1,
        "QuickTime:SeqProfile" => 0,
        "QuickTime:SeqLevelIdx0" => 5,
        "QuickTime:SeqTier0" => 0,
        "QuickTime:HighBitDepth" => 0,
        "QuickTime:TwelveBit" => 0,
        "QuickTime:ChromaFormat" => "Monochrome 4:0:0",
        "QuickTime:ChromaSamplePosition" => "Unknown",
        "QuickTime:InitialDelaySamples" => 1,
        "QuickTime:MediaDataSize" => 69_533,
        "QuickTime:MediaDataOffset" => 323,
        "Meta:PrimaryItemReference" => 1,
      }, file.metadata.to_h)
    end
  end

  context "an AVIF file with a clean-aperture crop transform applied" do
    # XXX: if we ever support this we'll have to check if previews are generated properly for crops
    should "be parsed correctly" do
      file = MediaFile.open("test/files/avif/kimono.crop.avif")

      assert_equal(385, file.width)
      assert_equal(330, file.height)
      assert_equal(85_486, file.file_size)
      assert_equal(:avif, file.file_ext)
      assert_equal("image/avif", file.mime_type)
      assert_equal("008f35103ff2d4113d4c33e9fca91b8a", file.md5)
      assert_equal("b96a0ff19d76e29cc57f417c7b1582da", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "AVIF",
        "File:ImageWidth" => 722,
        "File:ImageHeight" => 1024,
        "QuickTime:MajorBrand" => "AV1 Image File Format (.AVIF)",
        "QuickTime:MinorVersion" => "0.0.0",
        "QuickTime:CompatibleBrands" => ["avif", "mif1", "miaf", "MA1B"],
        "QuickTime:HandlerType" => "Picture",
        "QuickTime:HandlerDescription" => "cavif - https://github.com/link-u/cavif",
        "QuickTime:PixelAspectRatio" => "1 1",
        "QuickTime:CleanAperture" => "385 330 103 -308",
        "QuickTime:ImageSpatialExtent" => "722x1024",
        "QuickTime:ImagePixelDepth" => "8 8 8",
        "QuickTime:AV1ConfigurationVersion" => 1,
        "QuickTime:SeqProfile" => 0,
        "QuickTime:SeqLevelIdx0" => 5,
        "QuickTime:SeqTier0" => 0,
        "QuickTime:HighBitDepth" => 0,
        "QuickTime:TwelveBit" => 0,
        "QuickTime:ChromaFormat" => "YUV 4:2:0",
        "QuickTime:ChromaSamplePosition" => "Unknown",
        "QuickTime:InitialDelaySamples" => 1, "QuickTime:MediaDataSize" => 85_120,
        "QuickTime:MediaDataOffset" => 366,
        "Meta:PrimaryItemReference" => 1,
      }, file.metadata.to_h)
    end
  end

  context "an AVIF file with a horizontal mirror transform applied" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/avif/kimono.mirror-horizontal.avif")

      assert_equal(722, file.width)
      assert_equal(1024, file.height)
      assert_equal(84_996, file.file_size)
      assert_equal(:avif, file.file_ext)
      assert_equal("image/avif", file.mime_type)
      assert_equal("2a0b88e1f3b98c1bfe12d75c698175ee", file.md5)
      assert_equal("5788fde7c564e3f237439f377277971e", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "AVIF",
        "File:ImageWidth" => 722,
        "File:ImageHeight" => 1024,
        "QuickTime:MajorBrand" => "AV1 Image File Format (.AVIF)",
        "QuickTime:MinorVersion" => "0.0.0",
        "QuickTime:CompatibleBrands" => ["avif", "mif1", "miaf", "MA1B"],
        "QuickTime:HandlerType" => "Picture",
        "QuickTime:HandlerDescription" => "cavif - https://github.com/link-u/cavif",
        "QuickTime:PixelAspectRatio" => "1 1",
        "QuickTime:Mirroring" => "Horizontal",
        "QuickTime:ImageSpatialExtent" => "722x1024",
        "QuickTime:ImagePixelDepth" => "8 8 8",
        "QuickTime:AV1ConfigurationVersion" => 1,
        "QuickTime:SeqProfile" => 0,
        "QuickTime:SeqLevelIdx0" => 5,
        "QuickTime:SeqTier0" => 0,
        "QuickTime:HighBitDepth" => 0,
        "QuickTime:TwelveBit" => 0,
        "QuickTime:ChromaFormat" => "YUV 4:2:0",
        "QuickTime:ChromaSamplePosition" => "Unknown",
        "QuickTime:InitialDelaySamples" => 1,
        "QuickTime:MediaDataSize" => 84_661,
        "QuickTime:MediaDataOffset" => 335,
        "Meta:PrimaryItemReference" => 1,
      }, file.metadata.to_h)
    end
  end

  context "an AVIF file with a 90 degree rotation transform applied" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/avif/kimono.rotate90.avif")

      assert_equal(722, file.width)
      assert_equal(1024, file.height)
      assert_equal(84_837, file.file_size)
      assert_equal(:avif, file.file_ext)
      assert_equal("image/avif", file.mime_type)
      assert_equal("1ec8cc77c70f62f22651f93b7d8f375b", file.md5)
      assert_equal("8b8e4fb3720036c15a4e7cf367e838c7", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "AVIF",
        "File:ImageWidth" => 1024,
        "File:ImageHeight" => 722,
        "QuickTime:MajorBrand" => "AV1 Image File Format (.AVIF)",
        "QuickTime:MinorVersion" => "0.0.0",
        "QuickTime:CompatibleBrands" => ["avif", "mif1", "miaf", "MA1B"],
        "QuickTime:HandlerType" => "Picture",
        "QuickTime:HandlerDescription" => "cavif - https://github.com/link-u/cavif",
        "QuickTime:PixelAspectRatio" => "1 1",
        "QuickTime:Rotation" => "Rotate 90 CW",
        "QuickTime:ImageSpatialExtent" => "1024x722",
        "QuickTime:ImagePixelDepth" => "8 8 8",
        "QuickTime:AV1ConfigurationVersion" => 1,
        "QuickTime:SeqProfile" => 0,
        "QuickTime:SeqLevelIdx0" => 5,
        "QuickTime:SeqTier0" => 0,
        "QuickTime:HighBitDepth" => 0,
        "QuickTime:TwelveBit" => 0,
        "QuickTime:ChromaFormat" => "YUV 4:2:0",
        "QuickTime:ChromaSamplePosition" => "Unknown",
        "QuickTime:InitialDelaySamples" => 1,
        "QuickTime:MediaDataSize" => 84_502,
        "QuickTime:MediaDataOffset" => 335,
        "Meta:PrimaryItemReference" => 1,
      }, file.metadata.to_h)
    end
  end

  context "an AVIF file with embedded ICC, EXIF, and XMP metadata" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/avif/paris_icc_exif_xmp.avif")

      assert_equal(403, file.width)
      assert_equal(302, file.height)
      assert_equal(21_132, file.file_size)
      assert_equal(:avif, file.file_ext)
      assert_equal("image/avif", file.mime_type)
      assert_equal("cd0befc23b8d7d8a49cefd09763f960b", file.md5)
      assert_equal("5e8c58d1198f2aa4109d2c198498dfd8", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "AVIF",
        "File:ExifByteOrder" => "Little-endian (Intel, II)",
        "File:ImageWidth" => 403,
        "File:ImageHeight" => 302,
        "QuickTime:MajorBrand" => "AV1 Image File Format (.AVIF)",
        "QuickTime:MinorVersion" => "0.0.0",
        "QuickTime:CompatibleBrands" => ["avif", "mif1", "miaf", "MA1A"],
        "QuickTime:HandlerType" => "Picture",
        "QuickTime:HandlerDescription" => "libavif",
        "QuickTime:ImageSpatialExtent" => "403x302",
        "QuickTime:ImagePixelDepth" => "8 8 8",
        "QuickTime:AV1ConfigurationVersion" => 1,
        "QuickTime:SeqProfile" => 1,
        "QuickTime:SeqLevelIdx0" => 0,
        "QuickTime:SeqTier0" => 0,
        "QuickTime:HighBitDepth" => 0,
        "QuickTime:TwelveBit" => 0,
        "QuickTime:ChromaFormat" => "YUV 4:4:4",
        "QuickTime:ChromaSamplePosition" => "Unknown",
        "QuickTime:InitialDelaySamples" => 1,
        "QuickTime:ColorProfiles" => "nclx",
        "QuickTime:ColorPrimaries" => "Unspecified",
        "QuickTime:TransferCharacteristics" => "Unspecified",
        "QuickTime:MatrixCoefficients" => "BT.601",
        "QuickTime:VideoFullRangeFlag" => "Full",
        "QuickTime:MediaDataSize" => 20_104,
        "QuickTime:MediaDataOffset" => 1028,
        "Meta:PrimaryItemReference" => 1,
        "IFD0:Make" => "Google",
        "IFD0:Model" => "Pixel 4a",
        "IFD0:Orientation" => "Horizontal (normal)",
        "IFD0:XResolution" => 300,
        "IFD0:YResolution" => 300,
        "IFD0:ResolutionUnit" => "inches",
        "IFD0:Software" => "GIMP 2.10.32",
        "IFD0:ModifyDate" => "2022:08:24 22:07:42",
        "IFD0:YCbCrPositioning" => "Centered",
        "ExifIFD:ExposureTime" => "1/1067",
        "ExifIFD:FNumber" => 1.7,
        "ExifIFD:ExposureProgram" => "Program AE",
        "ExifIFD:ISO" => 47,
        "ExifIFD:ExifVersion" => "0232",
        "ExifIFD:DateTimeOriginal" => "2022:08:22 20:30:46",
        "ExifIFD:CreateDate" => "2022:08:22 20:30:46",
        "ExifIFD:OffsetTime" => "+02:00",
        "ExifIFD:OffsetTimeOriginal" => "+02:00",
        "ExifIFD:OffsetTimeDigitized" => "+02:00",
        "ExifIFD:ComponentsConfiguration" => "Y, Cb, Cr, -",
        "ExifIFD:ShutterSpeedValue" => "1/1067",
        "ExifIFD:ApertureValue" => 1.7,
        "ExifIFD:BrightnessValue" => 7.73,
        "ExifIFD:ExposureCompensation" => 0,
        "ExifIFD:MaxApertureValue" => 1.7,
        "ExifIFD:SubjectDistance" => "4294967295 m",
        "ExifIFD:MeteringMode" => "Center-weighted average",
        "ExifIFD:Flash" => "Off, Did not fire",
        "ExifIFD:FocalLength" => "4.4 mm",
        "ExifIFD:SubSecTime" => "023",
        "ExifIFD:SubSecTimeOriginal" => "023",
        "ExifIFD:SubSecTimeDigitized" => "023",
        "ExifIFD:FlashpixVersion" => "0100",
        "ExifIFD:ExifImageWidth" => 4032,
        "ExifIFD:ExifImageHeight" => 3024,
        "ExifIFD:SensingMethod" => "One-chip color area",
        "ExifIFD:SceneType" => "Directly photographed",
        "ExifIFD:CustomRendered" => "Custom",
        "ExifIFD:ExposureMode" => "Auto",
        "ExifIFD:WhiteBalance" => "Auto",
        "ExifIFD:DigitalZoomRatio" => 1.95,
        "ExifIFD:FocalLengthIn35mmFormat" => "27 mm",
        "ExifIFD:SceneCaptureType" => "Standard",
        "ExifIFD:Contrast" => "Normal",
        "ExifIFD:Saturation" => "Normal",
        "ExifIFD:Sharpness" => "Normal",
        "ExifIFD:SubjectDistanceRange" => "Distant",
        "ExifIFD:LensMake" => "Google",
        "ExifIFD:LensModel" => "Pixel 4a back camera 4.38mm f/1.73",
        "ExifIFD:CompositeImage" => "Composite Image Captured While Shooting",
        "GPS:GPSLatitudeRef" => "North",
        "GPS:GPSLatitude" => "0 deg 0' 0.00\"",
        "GPS:GPSLongitudeRef" => "East",
        "GPS:GPSLongitude" => "0 deg 0' 0.00\"",
        "GPS:GPSAltitudeRef" => "Above Sea Level",
        "GPS:GPSAltitude" => "0 m",
        "GPS:GPSTimeStamp" => "18:30:31",
        "GPS:GPSImgDirectionRef" => "Magnetic North",
        "GPS:GPSImgDirection" => 7,
        "GPS:GPSDateStamp" => "2022:08:22",
        "XMP-x:XMPToolkit" => "XMP Core 4.4.0-Exiv2",
        "XMP-xmpMM:DocumentID" => "gimp:docid:gimp:d19d8265-6ba3-418e-9f89-cefba3ef5b22",
        "XMP-xmpMM:InstanceID" => "xmp.iid:a21468a0-72ee-489e-8927-2f380856cb8c",
        "XMP-xmpMM:OriginalDocumentID" => "xmp.did:915da93c-438f-425b-b7c0-ddd63bad346b",
        "XMP-xmpMM:History" => [{ "Action" => "saved", "Changed" => "/", "InstanceID" => "xmp.iid:f13d68d8-4ce1-4b96-8693-06fa2b068a09", "SoftwareAgent" => "Gimp 2.10 (Linux)", "When" => "2022:08:24 21:15:28+02:00" }, { "Action" => "saved", "Changed" => "/", "InstanceID" => "xmp.iid:22108f79-8464-416c-9df2-f0a964bf865d", "SoftwareAgent" => "Gimp 2.10 (Linux)", "When" => "2022:08:24 21:16:53+02:00" }, { "Action" => "saved", "Changed" => "/metadata", "InstanceID" => "xmp.iid:d1f1b9bd-d635-4bb2-8267-e847d9e0c892", "SoftwareAgent" => "Gimp 2.10 (Linux)", "When" => "2022:08:24 22:05:15+02:00" }, { "Action" => "saved", "Changed" => "/", "InstanceID" => "xmp.iid:c7acfa6c-c977-410c-92ff-c3b900b7af4b", "SoftwareAgent" => "Gimp 2.10 (Linux)", "When" => "2022:08:24 22:07:22+02:00" }],
        "XMP-dc:Format" => "image/jpeg",
        "XMP-DICOM:PatientSex" => "other",
        "XMP-GIMP:Api" => 2.0,
        "XMP-GIMP:Platform" => "Linux",
        "XMP-GIMP:TimeStamp" => "1661371642640328",
        "XMP-GIMP:Version" => "2.10.32",
        "XMP-xmp:CreatorTool" => "GIMP 2.10",
        "XMP-xmp:MetadataDate" => "2022:08:24T22:07:07+02:00",
        "XMP-xmp:ModifyDate" => "2022:08:24T22:07:07+02:00",
        "ICC-header:ProfileCMMType" => "",
        "ICC-header:ProfileVersion" => "4.0.0",
        "ICC-header:ProfileClass" => "Display Device Profile",
        "ICC-header:ColorSpaceData" => "RGB ",
        "ICC-header:ProfileConnectionSpace" => "XYZ ",
        "ICC-header:ProfileDateTime" => "2016:12:08 09:38:28",
        "ICC-header:ProfileFileSignature" => "acsp",
        "ICC-header:PrimaryPlatform" => "Unknown ()",
        "ICC-header:CMMFlags" => "Not Embedded, Independent",
        "ICC-header:DeviceManufacturer" => "Google",
        "ICC-header:DeviceModel" => "",
        "ICC-header:DeviceAttributes" => "Reflective, Glossy, Positive, Color",
        "ICC-header:RenderingIntent" => "Perceptual",
        "ICC-header:ConnectionSpaceIlluminant" => "0.9642 1 0.82491",
        "ICC-header:ProfileCreator" => "Google",
        "ICC-header:ProfileID" => "75e1a6b13c34376310c8ab660632a28a",
        "ICC_Profile:ProfileDescription" => "sRGB IEC61966-2.1",
        "ICC_Profile:ProfileCopyright" => "Copyright (c) 2016 Google Inc.",
        "ICC_Profile:MediaWhitePoint" => "0.95045 1 1.08905",
        "ICC_Profile:MediaBlackPoint" => "0 0 0",
        "ICC_Profile:RedMatrixColumn" => "0.43604 0.22249 0.01392",
        "ICC_Profile:GreenMatrixColumn" => "0.38512 0.7169 0.09706",
        "ICC_Profile:BlueMatrixColumn" => "0.14305 0.06061 0.71391",
        "ICC_Profile:ChromaticAdaptation" => "1.04788 0.02292 -0.05019 0.02959 0.99048 -0.01704 -0.00922 0.01508 0.75168",
        "Composite:Aperture" => 1.7,
        "Composite:ScaleFactor35efl" => 6.1,
        "Composite:ShutterSpeed" => "1/1067",
        "Composite:SubSecCreateDate" => "2022:08:22 20:30:46.023+02:00",
        "Composite:SubSecDateTimeOriginal" => "2022:08:22 20:30:46.023+02:00",
        "Composite:SubSecModifyDate" => "2022:08:24 22:07:42.023+02:00",
        "Composite:GPSAltitude" => "0 m Above Sea Level",
        "Composite:GPSDateTime" => "2022:08:22 18:30:31Z",
        "Composite:GPSLatitude" => "0 deg 0' 0.00\" N",
        "Composite:GPSLongitude" => "0 deg 0' 0.00\" E",
        "Composite:CircleOfConfusion" => "0.005 mm",
        "Composite:DOF" => "inf (2.33 m - inf)",
        "Composite:FOV" => "67.4 deg",
        "Composite:FocalLength35efl" => "4.4 mm (35 mm equivalent: 27.0 mm)",
        "Composite:GPSPosition" => "0 deg 0' 0.00\" N, 0 deg 0' 0.00\" E",
        "Composite:HyperfocalDistance" => "2.33 m",
        "Composite:LightValue" => 12.7,
        "Composite:LensID" => "Pixel 4a back camera 4.38mm f/1.73",
      }, file.metadata.to_h)
    end
  end

  context "a 8bpc AVIF with a full alpha channel" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/avif/plum-blossom-small.profile0.8bpc.yuv420.alpha-full.avif")

      assert_equal(128, file.width)
      assert_equal(128, file.height)
      assert_equal(3284, file.file_size)
      assert_equal(:avif, file.file_ext)
      assert_equal("image/avif", file.mime_type)
      assert_equal("9feec41695beb2f433c016f7c7b58915", file.md5)
      assert_equal("37c7b302578c098f280d4140afbcf118", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "AVIF",
        "File:ImageWidth" => 128,
        "File:ImageHeight" => 128,
        "QuickTime:MajorBrand" => "AV1 Image File Format (.AVIF)",
        "QuickTime:MinorVersion" => "0.0.0",
        "QuickTime:CompatibleBrands" => ["avif", "mif1", "miaf", "MA1B"],
        "QuickTime:HandlerType" => "Picture",
        "QuickTime:HandlerDescription" => "cavif - https://github.com/link-u/cavif",
        "QuickTime:PixelAspectRatio" => "1 1",
        "QuickTime:ImageSpatialExtent" => "128x128",
        "QuickTime:ImagePixelDepth" => "8 8 8",
        "QuickTime:AV1ConfigurationVersion" => 1,
        "QuickTime:SeqProfile" => 0,
        "QuickTime:SeqLevelIdx0" => 0,
        "QuickTime:SeqTier0" => 0,
        "QuickTime:HighBitDepth" => 0,
        "QuickTime:TwelveBit" => 0,
        "QuickTime:ChromaFormat" => "YUV 4:2:0",
        "QuickTime:ChromaSamplePosition" => "Unknown",
        "QuickTime:InitialDelaySamples" => 1,
        "QuickTime:AuxiliaryImageType" => "urn:mpeg:mpegB:cicp:systems:auxiliary:alpha",
        "QuickTime:MediaDataSize" => 1810,
        "QuickTime:MediaDataOffset" => 1474,
        "Meta:PrimaryItemReference" => 1,
      }, file.metadata.to_h)
    end
  end

  context "an animated AVIF sequence with a primary item and an avif major brand" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/avif/sequence-with-pitm-avif-major.avif")

      assert_equal(640, file.width)
      assert_equal(480, file.height)
      assert_equal(10_755, file.file_size)
      assert_equal(:avif, file.file_ext)
      assert_equal("image/avif", file.mime_type)
      assert_equal("a83e809b3d35ebab1469054c8a60b7dd", file.md5)
      assert_equal("a83e809b3d35ebab1469054c8a60b7dd", file.pixel_hash)
      assert_equal(true, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(1.92, file.duration)
      assert_equal(48, file.frame_count)
      assert_equal(25.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "AVIF",
        "File:ImageWidth" => 640,
        "File:ImageHeight" => 480,
        "QuickTime:MajorBrand" => "AV1 Image File Format (.AVIF)",
        "QuickTime:MinorVersion" => "0.0.0",
        "QuickTime:CompatibleBrands" => ["mif1", "avif", "iso4", "av01", "avis", "msf1", "miaf", "MA1B"],
        "QuickTime:HandlerType" => "Picture",
        "QuickTime:HandlerDescription" => "GPAC pict Handler",
        "QuickTime:ImageSpatialExtent" => "640x480",
        "QuickTime:PixelAspectRatio" => "1 1",
        "QuickTime:AuxiliaryImageType" => "urn:mpeg:mpegB:cicp:systems:auxiliary:alpha",
        "QuickTime:AV1ConfigurationVersion" => 1,
        "QuickTime:SeqProfile" => 0,
        "QuickTime:SeqLevelIdx0" => 4,
        "QuickTime:SeqTier0" => 0,
        "QuickTime:HighBitDepth" => 0,
        "QuickTime:TwelveBit" => 0,
        "QuickTime:ChromaFormat" => "YUV 4:2:0",
        "QuickTime:ChromaSamplePosition" => "Unknown",
        "QuickTime:InitialDelaySamples" => 1,
        "QuickTime:ImagePixelDepth" => "8 8 8",
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "2019:02:04 21:19:42",
        "QuickTime:ModifyDate" => "2019:02:04 21:19:42",
        "QuickTime:TimeScale" => 600,
        "QuickTime:Duration" => "1.92 s",
        "QuickTime:PreferredRate" => 1,
        "QuickTime:PreferredVolume" => "100.00%",
        "QuickTime:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "QuickTime:PreviewTime" => "0 s",
        "QuickTime:PreviewDuration" => "0 s",
        "QuickTime:PosterTime" => "0 s",
        "QuickTime:SelectionTime" => "0 s",
        "QuickTime:SelectionDuration" => "0 s",
        "QuickTime:CurrentTime" => "0 s",
        "QuickTime:NextTrackID" => 3,
        "QuickTime:MediaDataSize" => 8440,
        "QuickTime:MediaDataOffset" => 2234,
        "Meta:PrimaryItemReference" => 4,
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "2019:02:04 21:19:42",
        "Track1:TrackModifyDate" => "2019:02:04 21:19:42",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "1.92 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 640,
        "Track1:ImageHeight" => 480,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "2019:02:04 21:19:42",
        "Track1:MediaModifyDate" => "2019:02:04 21:19:42",
        "Track1:MediaTimeScale" => 25_000,
        "Track1:MediaDuration" => "1.92 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Picture",
        "Track1:HandlerDescription" => "GPAC avifs",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:OtherFormat" => "av01",
        "Track2:TrackHeaderVersion" => 0,
        "Track2:TrackCreateDate" => "2019:02:04 21:19:42",
        "Track2:TrackModifyDate" => "2019:02:04 21:19:42",
        "Track2:TrackID" => 2,
        "Track2:TrackDuration" => "1.92 s",
        "Track2:TrackLayer" => 0,
        "Track2:TrackVolume" => "0.00%",
        "Track2:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track2:ImageWidth" => 640,
        "Track2:ImageHeight" => 480,
        "Track2:MediaHeaderVersion" => 0,
        "Track2:MediaCreateDate" => "2019:02:04 21:19:42",
        "Track2:MediaModifyDate" => "2019:02:04 21:19:42",
        "Track2:MediaTimeScale" => 25_000,
        "Track2:MediaDuration" => "1.92 s",
        "Track2:MediaLanguageCode" => "und",
        "Track2:HandlerType" => "Unknown (auxv)",
        "Track2:HandlerDescription" => "GPAC avifs alpha",
        "Track2:GraphicsMode" => "srcCopy",
        "Track2:OpColor" => "0 0 0",
        "Track2:OtherFormat" => "av01",
        "Composite:AvgBitrate" => "35.2 kbps",
        "Vips:Error" => "libvips error",
      }, file.metadata.to_h)
    end
  end

  context "an animated AVIF sequence with a primary item" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/avif/sequence-with-pitm.avif")

      assert_equal(640, file.width)
      assert_equal(480, file.height)
      assert_equal(10_755, file.file_size)
      assert_equal(:avif, file.file_ext)
      assert_equal("image/avif", file.mime_type)
      assert_equal("5ad19202d4cd9b0e90587f56ff648c28", file.md5)
      assert_equal("5ad19202d4cd9b0e90587f56ff648c28", file.pixel_hash)
      assert_equal(true, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(1.92, file.duration)
      assert_equal(48, file.frame_count)
      assert_equal(25.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "File:ImageWidth" => 640,
        "File:ImageHeight" => 480,
        "QuickTime:MajorBrand" => "Unknown (avis)",
        "QuickTime:MinorVersion" => "0.0.0",
        "QuickTime:CompatibleBrands" => ["mif1", "avif", "iso4", "av01", "avis", "msf1", "miaf", "MA1B"],
        "QuickTime:HandlerType" => "Picture",
        "QuickTime:HandlerDescription" => "GPAC pict Handler",
        "QuickTime:ImageSpatialExtent" => "640x480",
        "QuickTime:PixelAspectRatio" => "1 1",
        "QuickTime:AuxiliaryImageType" => "urn:mpeg:mpegB:cicp:systems:auxiliary:alpha",
        "QuickTime:AV1ConfigurationVersion" => 1,
        "QuickTime:SeqProfile" => 0,
        "QuickTime:SeqLevelIdx0" => 4,
        "QuickTime:SeqTier0" => 0,
        "QuickTime:HighBitDepth" => 0,
        "QuickTime:TwelveBit" => 0,
        "QuickTime:ChromaFormat" => "YUV 4:2:0",
        "QuickTime:ChromaSamplePosition" => "Unknown",
        "QuickTime:InitialDelaySamples" => 1,
        "QuickTime:ImagePixelDepth" => "8 8 8",
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "2019:02:04 21:19:42",
        "QuickTime:ModifyDate" => "2019:02:04 21:19:42",
        "QuickTime:TimeScale" => 600,
        "QuickTime:Duration" => "1.92 s",
        "QuickTime:PreferredRate" => 1,
        "QuickTime:PreferredVolume" => "100.00%",
        "QuickTime:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "QuickTime:PreviewTime" => "0 s",
        "QuickTime:PreviewDuration" => "0 s",
        "QuickTime:PosterTime" => "0 s",
        "QuickTime:SelectionTime" => "0 s",
        "QuickTime:SelectionDuration" => "0 s",
        "QuickTime:CurrentTime" => "0 s",
        "QuickTime:NextTrackID" => 3,
        "QuickTime:MediaDataSize" => 8440,
        "QuickTime:MediaDataOffset" => 2234,
        "Meta:PrimaryItemReference" => 4,
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "2019:02:04 21:19:42",
        "Track1:TrackModifyDate" => "2019:02:04 21:19:42",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "1.92 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 640,
        "Track1:ImageHeight" => 480,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "2019:02:04 21:19:42",
        "Track1:MediaModifyDate" => "2019:02:04 21:19:42",
        "Track1:MediaTimeScale" => 25_000,
        "Track1:MediaDuration" => "1.92 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Picture",
        "Track1:HandlerDescription" => "GPAC avifs",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:OtherFormat" => "av01",
        "Track2:TrackHeaderVersion" => 0,
        "Track2:TrackCreateDate" => "2019:02:04 21:19:42",
        "Track2:TrackModifyDate" => "2019:02:04 21:19:42",
        "Track2:TrackID" => 2,
        "Track2:TrackDuration" => "1.92 s",
        "Track2:TrackLayer" => 0,
        "Track2:TrackVolume" => "0.00%",
        "Track2:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track2:ImageWidth" => 640,
        "Track2:ImageHeight" => 480,
        "Track2:MediaHeaderVersion" => 0,
        "Track2:MediaCreateDate" => "2019:02:04 21:19:42",
        "Track2:MediaModifyDate" => "2019:02:04 21:19:42",
        "Track2:MediaTimeScale" => 25_000,
        "Track2:MediaDuration" => "1.92 s",
        "Track2:MediaLanguageCode" => "und",
        "Track2:HandlerType" => "Unknown (auxv)",
        "Track2:HandlerDescription" => "GPAC avifs alpha",
        "Track2:GraphicsMode" => "srcCopy",
        "Track2:OpColor" => "0 0 0",
        "Track2:OtherFormat" => "av01",
        "Composite:AvgBitrate" => "35.2 kbps",
        "Vips:Error" => "libvips error",
      }, file.metadata.to_h)
    end
  end

  context "an animated AVIF sequence without a primary item" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/avif/sequence-without-pitm.avif")

      assert_equal(480, file.width)
      assert_equal(270, file.height)
      assert_equal(164_509, file.file_size)
      assert_equal(:avif, file.file_ext)
      assert_equal("image/avif", file.mime_type)
      assert_equal("98ecf29eb4d26ebc6aef8ecfa8399b36", file.md5)
      assert_equal("98ecf29eb4d26ebc6aef8ecfa8399b36", file.pixel_hash)
      assert_equal(true, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(3.962292, file.duration)
      assert_equal(95, file.frame_count)
      assert_equal(23.976021959007564, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "Unknown (avis)",
        "QuickTime:MinorVersion" => "0.0.0",
        "QuickTime:CompatibleBrands" => ["avis", "msf1", "miaf", "MA1B"],
        "QuickTime:HandlerType" => "Picture",
        "QuickTime:HandlerDescription" => "GPAC pict Handler",
        "QuickTime:ImageSpatialExtent" => "480x270",
        "QuickTime:PixelAspectRatio" => "1 1",
        "QuickTime:AV1ConfigurationVersion" => 1,
        "QuickTime:SeqProfile" => 0,
        "QuickTime:SeqLevelIdx0" => 0,
        "QuickTime:SeqTier0" => 0,
        "QuickTime:HighBitDepth" => 1,
        "QuickTime:TwelveBit" => 0,
        "QuickTime:ChromaFormat" => "YUV 4:2:0",
        "QuickTime:ChromaSamplePosition" => "Unknown",
        "QuickTime:InitialDelaySamples" => 1,
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "2019:02:05 06:01:53",
        "QuickTime:ModifyDate" => "2019:02:05 06:01:53",
        "QuickTime:TimeScale" => 600,
        "QuickTime:Duration" => "3.96 s",
        "QuickTime:PreferredRate" => 1,
        "QuickTime:PreferredVolume" => "100.00%",
        "QuickTime:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "QuickTime:PreviewTime" => "0 s",
        "QuickTime:PreviewDuration" => "0 s",
        "QuickTime:PosterTime" => "0 s",
        "QuickTime:SelectionTime" => "0 s",
        "QuickTime:SelectionDuration" => "0 s",
        "QuickTime:CurrentTime" => "0 s",
        "QuickTime:NextTrackID" => 3,
        "QuickTime:MediaDataSize" => 163_051,
        "QuickTime:MediaDataOffset" => 1374,
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "2018:08:31 01:00:48",
        "Track1:TrackModifyDate" => "2019:02:05 06:01:53",
        "Track1:TrackID" => 2,
        "Track1:TrackDuration" => "3.96 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 480,
        "Track1:ImageHeight" => 270,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "2018:08:31 01:00:48",
        "Track1:MediaModifyDate" => "2019:02:05 06:01:53",
        "Track1:MediaTimeScale" => 24_000,
        "Track1:MediaDuration" => "3.96 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Picture",
        "Track1:HandlerDescription" => "GPAC avifs",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:OtherFormat" => "av01",
        "Composite:AvgBitrate" => "329 kbps",
        "Vips:Error" => "libvips error",
      }, file.metadata.to_h)
    end
  end

  context "an animated 8bpc AVIF file" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/avif/star-8bpc.avif")

      assert_equal(159, file.width)
      assert_equal(159, file.height)
      assert_equal(15_679, file.file_size)
      assert_equal(:avif, file.file_ext)
      assert_equal("image/avif", file.mime_type)
      assert_equal("d3c8457af803e2b17aa68fa13ddf25f6", file.md5)
      assert_equal("d3c8457af803e2b17aa68fa13ddf25f6", file.pixel_hash)
      assert_equal(true, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(0.5, file.duration)
      assert_equal(5, file.frame_count)
      assert_equal(10.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "File:ImageWidth" => 159,
        "File:ImageHeight" => 159,
        "QuickTime:MajorBrand" => "Unknown (avis)",
        "QuickTime:MinorVersion" => "0.0.0",
        "QuickTime:CompatibleBrands" => ["avis", "msf1", "miaf", "MA1B"],
        "QuickTime:HandlerType" => "Picture",
        "QuickTime:HandlerDescription" => "GPAC pict Handler",
        "QuickTime:ImageSpatialExtent" => "159x159",
        "QuickTime:PixelAspectRatio" => "1 1",
        "QuickTime:AV1ConfigurationVersion" => 1,
        "QuickTime:SeqProfile" => 0,
        "QuickTime:SeqLevelIdx0" => 0,
        "QuickTime:SeqTier0" => 0,
        "QuickTime:HighBitDepth" => 0,
        "QuickTime:TwelveBit" => 0,
        "QuickTime:ChromaFormat" => "YUV 4:2:0",
        "QuickTime:ChromaSamplePosition" => "Unknown",
        "QuickTime:InitialDelaySamples" => 1,
        "QuickTime:ImagePixelDepth" => "8 8 8",
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "2020:04:07 16:39:21",
        "QuickTime:ModifyDate" => "2020:04:07 16:39:21",
        "QuickTime:TimeScale" => 1000,
        "QuickTime:Duration" => "0.50 s",
        "QuickTime:PreferredRate" => 1,
        "QuickTime:PreferredVolume" => "100.00%",
        "QuickTime:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "QuickTime:PreviewTime" => "0 s",
        "QuickTime:PreviewDuration" => "0 s",
        "QuickTime:PosterTime" => "0 s",
        "QuickTime:SelectionTime" => "0 s",
        "QuickTime:SelectionDuration" => "0 s",
        "QuickTime:CurrentTime" => "0 s",
        "QuickTime:NextTrackID" => 2,
        "QuickTime:MediaDataSize" => 14_556,
        "QuickTime:MediaDataOffset" => 1051,
        "Meta:PrimaryItemReference" => 1,
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "2020:04:07 16:39:21",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "0.50 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 159,
        "Track1:ImageHeight" => 159,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "2020:04:07 16:39:21",
        "Track1:MediaTimeScale" => 10_240,
        "Track1:MediaDuration" => "0.50 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Picture",
        "Track1:HandlerDescription" => "GPAC avifs",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:OtherFormat" => "av01",
        "Composite:AvgBitrate" => "233 kbps",
        "Vips:Error" => "libvips error",
      }, file.metadata.to_h)
    end
  end

  context "a layered AVIF file with a single resolution" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/avif/tiger_3layer_1res.avif")

      assert_equal(1216, file.width)
      assert_equal(832, file.height)
      assert_equal(70_944, file.file_size)
      assert_equal(:avif, file.file_ext)
      assert_equal("image/avif", file.mime_type)
      assert_equal("5ec0304e50634d10e1c8828bc38e7fd4", file.md5)
      assert_equal("ee37cdac9538d31a1574acb9d1e9e3f3", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_equal(1, file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "AVIF",
        "File:ImageWidth" => 1216,
        "File:ImageHeight" => 832,
        "QuickTime:MajorBrand" => "AV1 Image File Format (.AVIF)",
        "QuickTime:MinorVersion" => "0.0.0",
        "QuickTime:CompatibleBrands" => ["mif1", "avif", "miaf"],
        "QuickTime:HandlerType" => "Picture",
        "QuickTime:HandlerDescription" => "GPAC pict Handler",
        "QuickTime:ImageSpatialExtent" => "1216x832",
        "QuickTime:PixelAspectRatio" => "1 1",
        "QuickTime:AV1ConfigurationVersion" => 1,
        "QuickTime:SeqProfile" => 0,
        "QuickTime:SeqLevelIdx0" => 5,
        "QuickTime:SeqTier0" => 0,
        "QuickTime:HighBitDepth" => 0,
        "QuickTime:TwelveBit" => 0,
        "QuickTime:ChromaFormat" => "YUV 4:2:0",
        "QuickTime:ChromaSamplePosition" => "Unknown",
        "QuickTime:InitialDelaySamples" => 1,
        "QuickTime:ImagePixelDepth" => "8 8 8",
        "QuickTime:MediaDataSize" => 70_551,
        "QuickTime:MediaDataOffset" => 301,
        "Meta:PrimaryItemReference" => 1,
      }, file.metadata.to_h)
    end
  end
end
