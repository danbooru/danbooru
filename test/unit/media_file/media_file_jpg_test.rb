require "test_helper"

class MediaFileJpgTest < ActiveSupport::TestCase
  context "Previews" do
    should "be generated properly" do
      should_generate_previews(
        "jpg",
        failures: [],
      )
    end
  end

  context "a normal JPEG file" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/jpg/test.jpg")

      assert_equal(500, file.width)
      assert_equal(335, file.height)
      assert_equal(28_086, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76", file.md5)
      assert_equal("01cb481ec7730b7cfced57ffa5abd196", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:ExifByteOrder" => "Little-endian (Intel, II)",
        "File:ImageWidth" => 500,
        "File:ImageHeight" => 335,
        "File:EncodingProcess" => "Baseline DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 3,
        "File:YCbCrSubSampling" => "YCbCr4:2:0 (2 2)",
        "JFIF:JFIFVersion" => 1.01,
        "JFIF:ResolutionUnit" => "inches",
        "JFIF:XResolution" => 72,
        "JFIF:YResolution" => 72,
        "IFD0:ImageDescription" => "SONY DSC                    ",
        "IFD0:Make" => "SONY",
        "IFD0:Model" => "DSLR-A100",
        "IFD0:Orientation" => "Horizontal (normal)",
        "IFD0:XResolution" => 72,
        "IFD0:YResolution" => 72,
        "IFD0:ResolutionUnit" => "inches",
        "IFD0:Software" => "GIMP 2.4.2",
        "IFD0:ModifyDate" => "2008:01:30 21:03:30",
        "IFD0:YCbCrPositioning" => "Co-sited",
        "IFD0:CustomRendered" => "Normal",
        "IFD0:ExposureMode" => "Auto",
        "IFD0:WhiteBalance" => "Manual",
        "IFD0:SceneCaptureType" => "Standard",
        "IFD0:Contrast" => "Normal",
        "IFD0:Saturation" => "Normal",
        "IFD0:Sharpness" => "Normal",
        "ExifIFD:ExposureTime" => "1/320",
        "ExifIFD:FNumber" => 5.6,
        "ExifIFD:ExposureProgram" => "Shutter speed priority AE",
        "ExifIFD:ISO" => 100,
        "ExifIFD:ExifVersion" => "0221",
        "ExifIFD:DateTimeOriginal" => "2007:07:15 16:08:55",
        "ExifIFD:CreateDate" => "2007:07:15 16:08:55",
        "ExifIFD:ComponentsConfiguration" => "Y, Cb, Cr, -",
        "ExifIFD:CompressedBitsPerPixel" => 8,
        "ExifIFD:ExposureCompensation" => 0,
        "ExifIFD:MaxApertureValue" => 5.6,
        "ExifIFD:MeteringMode" => "Multi-segment",
        "ExifIFD:LightSource" => "Unknown",
        "ExifIFD:Flash" => "Off, Did not fire",
        "ExifIFD:FocalLength" => "300.0 mm",
        "ExifIFD:FlashpixVersion" => "0100",
        "ExifIFD:ColorSpace" => "sRGB",
        "ExifIFD:ExifImageWidth" => 3872,
        "ExifIFD:ExifImageHeight" => 2592,
        "IFD1:Compression" => "JPEG (old-style)",
        "IFD1:XResolution" => 72,
        "IFD1:YResolution" => 72,
        "IFD1:ResolutionUnit" => "inches",
        "IFD1:ThumbnailOffset" => 780,
        "IFD1:ThumbnailLength" => 3496,
        "ICC-header:ProfileCMMType" => "Linotronic",
        "ICC-header:ProfileVersion" => "2.1.0",
        "ICC-header:ProfileClass" => "Display Device Profile",
        "ICC-header:ColorSpaceData" => "RGB ",
        "ICC-header:ProfileConnectionSpace" => "XYZ ",
        "ICC-header:ProfileDateTime" => "1998:02:09 06:49:00",
        "ICC-header:ProfileFileSignature" => "acsp",
        "ICC-header:PrimaryPlatform" => "Microsoft Corporation",
        "ICC-header:CMMFlags" => "Not Embedded, Independent",
        "ICC-header:DeviceManufacturer" => "Hewlett-Packard",
        "ICC-header:DeviceModel" => "sRGB",
        "ICC-header:DeviceAttributes" => "Reflective, Glossy, Positive, Color",
        "ICC-header:RenderingIntent" => "Perceptual",
        "ICC-header:ConnectionSpaceIlluminant" => "0.9642 1 0.82491",
        "ICC-header:ProfileCreator" => "Hewlett-Packard",
        "ICC-header:ProfileID" => 0,
        "ICC_Profile:ProfileCopyright" => "Copyright (c) 1998 Hewlett-Packard Company",
        "ICC_Profile:ProfileDescription" => "sRGB IEC61966-2.1",
        "ICC_Profile:MediaWhitePoint" => "0.95045 1 1.08905",
        "ICC_Profile:MediaBlackPoint" => "0 0 0",
        "ICC_Profile:RedMatrixColumn" => "0.43607 0.22249 0.01392",
        "ICC_Profile:GreenMatrixColumn" => "0.38515 0.71687 0.09708",
        "ICC_Profile:BlueMatrixColumn" => "0.14307 0.06061 0.7141",
        "ICC_Profile:DeviceMfgDesc" => "IEC http://www.iec.ch",
        "ICC_Profile:DeviceModelDesc" => "IEC 61966-2.1 Default RGB colour space - sRGB",
        "ICC_Profile:ViewingCondDesc" => "Reference Viewing Condition in IEC61966-2.1",
        "ICC_Profile:Luminance" => "76.03647 80 87.12462",
        "ICC_Profile:Technology" => "Cathode Ray Tube Display",
        "ICC-view:ViewingCondIlluminant" => "19.6445 20.3718 16.8089",
        "ICC-view:ViewingCondSurround" => "3.92889 4.07439 3.36179",
        "ICC-view:ViewingCondIlluminantType" => "D50",
        "ICC-meas:MeasurementObserver" => "CIE 1931",
        "ICC-meas:MeasurementBacking" => "0 0 0",
        "ICC-meas:MeasurementGeometry" => "Unknown",
        "ICC-meas:MeasurementFlare" => "0.999%",
        "ICC-meas:MeasurementIlluminant" => "D65",
        "Composite:Aperture" => 5.6,
        "Composite:ShutterSpeed" => "1/320",
        "Composite:FocalLength35efl" => "300.0 mm",
        "Composite:LightValue" => 13.3,
      }, file.metadata.to_h)
    end
  end

  context "a truncated JPEG that libvips can't decode" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/jpg/test-blank.jpg")

      assert_equal(668, file.width)
      assert_equal(996, file.height)
      assert_equal(1024, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("674c66d7b7b901cfa6dd87d9bd01a17a", file.md5)
      assert_equal("674c66d7b7b901cfa6dd87d9bd01a17a", file.pixel_hash)
      assert_equal(true, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:ImageWidth" => 668,
        "File:ImageHeight" => 996,
        "File:EncodingProcess" => "Baseline DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 3,
        "File:YCbCrSubSampling" => "YCbCr4:4:4 (1 1)",
        "Vips:Error" => "libvips error",
      }, file.metadata.to_h)
    end
  end

  context "a CMYK JPEG without an embedded color profile" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/jpg/test-cmyk-no-profile.jpg")

      assert_equal(197, file.width)
      assert_equal(256, file.height)
      assert_equal(30_550, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("22bcb13a72131c922dfeb3dcfad1457a", file.md5)
      assert_equal("69e64bd6e054757ac6ec67d1da3ad4fc", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:ImageWidth" => 197,
        "File:ImageHeight" => 256,
        "File:EncodingProcess" => "Baseline DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 4,
        "Adobe:DCTEncodeVersion" => 100,
        "Adobe:APP14Flags0" => "(none)",
        "Adobe:APP14Flags1" => "(none)",
        "Adobe:ColorTransform" => "YCCK",
      }, file.metadata.to_h)
    end

    should "generate a thumbnail with the correct colors" do
      file = MediaFile.open("test/files/jpg/test-cmyk-no-profile.jpg").preview(180, 180)
      assert_equal("7577481a2a688e6e5e9ec901addcf0e3", file.pixel_hash)
    end
  end

  context "a corrupt JPEG" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/jpg/test-corrupt.jpg")

      assert_equal(1024, file.width)
      assert_equal(768, file.height)
      assert_equal(3000, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("7df25d6181c015d4cf3e003d5d84a0d9", file.md5)
      assert_equal("7df25d6181c015d4cf3e003d5d84a0d9", file.pixel_hash)
      assert_equal(true, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:ImageWidth" => 1024,
        "File:ImageHeight" => 768,
        "File:EncodingProcess" => "Baseline DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 1,
        "JFIF:JFIFVersion" => 1.01,
        "JFIF:ResolutionUnit" => "None",
        "JFIF:XResolution" => 1,
        "JFIF:YResolution" => 1,
        "Vips:Error" => "libvips error",
      }, file.metadata.to_h)
    end
  end

  context "a truncated JPEG with EXIF and XMP metadata" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/jpg/test-exif-small.jpg")

      assert_equal(529, file.width)
      assert_equal(600, file.height)
      assert_equal(40_000, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("ed46f3279411f2979cc24c991e2bc75f", file.md5)
      assert_equal("ed46f3279411f2979cc24c991e2bc75f", file.pixel_hash)
      assert_equal(true, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:ExifByteOrder" => "Big-endian (Motorola, MM)",
        "File:ImageWidth" => 529,
        "File:ImageHeight" => 600,
        "File:EncodingProcess" => "Progressive DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 3,
        "File:YCbCrSubSampling" => "YCbCr4:4:4 (1 1)",
        "IFD0:Orientation" => "Horizontal (normal)",
        "IFD0:XResolution" => 600,
        "IFD0:YResolution" => 600,
        "IFD0:ResolutionUnit" => "inches",
        "IFD0:Software" => "Adobe Photoshop CC (Macintosh)",
        "IFD0:ModifyDate" => "2013:08:02 23:57:43",
        "ExifIFD:ColorSpace" => "sRGB",
        "ExifIFD:ExifImageWidth" => 529,
        "ExifIFD:ExifImageHeight" => 600,
        "IFD1:Compression" => "JPEG (old-style)",
        "IFD1:XResolution" => 72,
        "IFD1:YResolution" => 72,
        "IFD1:ResolutionUnit" => "inches",
        "IFD1:ThumbnailOffset" => 318,
        "IFD1:ThumbnailLength" => 11_216,
        "Photoshop:IPTCDigest" => "00000000000000000000000000000000",
        "Photoshop:PrintInfo2" => "\u0010\u0001\vprintOutput\u0005PstSbool\u0001InteenumInteImg \u000FprintSixteenBitbool\vprinterNameTEXT\u000EEPSON PX-404A\u000FprintProofSetupObjc\u0005h!kc?-[?\nproofSetup\u0001Bltnenum\fbuiltinProof\tproofCMYK",
        "Photoshop:XResolution" => 600,
        "Photoshop:DisplayedUnitsX" => "inches",
        "Photoshop:YResolution" => 600,
        "Photoshop:DisplayedUnitsY" => "inches",
        "Photoshop:PrintStyle" => "Centered",
        "Photoshop:PrintPosition" => "0 0",
        "Photoshop:PrintScale" => 1,
        "Photoshop:GlobalAngle" => 120,
        "Photoshop:GlobalAltitude" => 30,
        "Photoshop:PrintFlags" => "Print flags",
        "Photoshop:PrintFlagsInfo" => "\u0001\u0002",
        "Photoshop:ColorHalftoningInfo" => "/ff\u0001lff\u0006\u0001/ff\u0001???\u0006\u00012\u0001Z\u0006\u00015\u0001-\u0006\u0001",
        "Photoshop:ColorTransferFuncs" => "??????????????????????\u0003???????????????????????\u0003???????????????????????\u0003???????????????????????\u0003?",
        "Photoshop:TargetLayerID" => 1,
        "Photoshop:LayersGroupInfo" => "0 0 0",
        "Photoshop:LayerGroupsEnabledID" => "1 1 1",
        "Photoshop:LayerSelectionIDs" => 4,
        "Photoshop:GridGuidesInfo" => "\u0001\u0002@\u0002@",
        "Photoshop:URL_List" => [],
        "Photoshop:SlicesGroupName" => "名称未設定 1",
        "Photoshop:NumSlices" => 1,
        "Photoshop:PixelAspectRatio" => 1,
        "Photoshop:IDsBaseValue" => 5,
        "Photoshop:HasRealMergedData" => "Yes",
        "Photoshop:WriterName" => "Adobe Photoshop",
        "Photoshop:ReaderName" => "Adobe Photoshop CC",
        "Photoshop:PhotoshopQuality" => 12,
        "Photoshop:PhotoshopFormat" => "Progressive",
        "Photoshop:ProgressiveScans" => "3 Scans",
        "XMP-x:XMPToolkit" => "Adobe XMP Core 5.5-c014 79.151481, 2013/03/13-12:09:15        ",
        "XMP-xmp:CreatorTool" => "Adobe Photoshop CC (Macintosh)",
        "XMP-xmp:CreateDate" => "2013:08:02 23:57:43+09:00",
        "XMP-xmp:MetadataDate" => "2013:08:02 23:57:43+09:00",
        "XMP-xmp:ModifyDate" => "2013:08:02 23:57:43+09:00",
        "XMP-xmpMM:InstanceID" => "xmp.iid:829ee79b-296d-4628-b7ef-6081a92a433a",
        "XMP-xmpMM:DocumentID" => "xmp.did:aafebfb1-2fc5-4966-9e84-4c34f812db83",
        "XMP-xmpMM:OriginalDocumentID" => "xmp.did:aafebfb1-2fc5-4966-9e84-4c34f812db83",
        "XMP-xmpMM:History" => [{ "Action" => "created", "InstanceID" => "xmp.iid:aafebfb1-2fc5-4966-9e84-4c34f812db83", "SoftwareAgent" => "Adobe Photoshop CC (Macintosh)", "When" => "2013:08:02 23:57:43+09:00" }, { "Action" => "saved", "Changed" => "/", "InstanceID" => "xmp.iid:829ee79b-296d-4628-b7ef-6081a92a433a", "SoftwareAgent" => "Adobe Photoshop CC (Macintosh)", "When" => "2013:08:02 23:57:43+09:00" }],
        "XMP-photoshop:ColorMode" => "RGB",
        "XMP-photoshop:ICCProfileName" => "sRGB IEC61966-2.1",
        "XMP-photoshop:TextLayers" => [{ "LayerName" => "sample", "LayerText" => "sample" }, { "LayerName" => "at_classics", "LayerText" => "at_classics" }],
        "XMP-photoshop:DocumentAncestors" => ["D1769ACD956C5F38A3EB2E447447CBB4", "D8F4A84F0F974CE291BB7E0EB3B8D9D5"],
        "XMP-dc:Format" => "image/jpeg",
        "ICC-header:ProfileCMMType" => "Linotronic",
        "ICC-header:ProfileVersion" => "2.1.0",
        "ICC-header:ProfileClass" => "Display Device Profile",
        "ICC-header:ColorSpaceData" => "RGB ",
        "ICC-header:ProfileConnectionSpace" => "XYZ ",
        "ICC-header:ProfileDateTime" => "1998:02:09 06:49:00",
        "ICC-header:ProfileFileSignature" => "acsp",
        "ICC-header:PrimaryPlatform" => "Microsoft Corporation",
        "ICC-header:CMMFlags" => "Not Embedded, Independent",
        "ICC-header:DeviceManufacturer" => "Hewlett-Packard",
        "ICC-header:DeviceModel" => "sRGB",
        "ICC-header:DeviceAttributes" => "Reflective, Glossy, Positive, Color",
        "ICC-header:RenderingIntent" => "Perceptual",
        "ICC-header:ConnectionSpaceIlluminant" => "0.9642 1 0.82491",
        "ICC-header:ProfileCreator" => "Hewlett-Packard",
        "ICC-header:ProfileID" => 0,
        "ICC_Profile:ProfileCopyright" => "Copyright (c) 1998 Hewlett-Packard Company",
        "ICC_Profile:ProfileDescription" => "sRGB IEC61966-2.1",
        "ICC_Profile:MediaWhitePoint" => "0.95045 1 1.08905",
        "ICC_Profile:MediaBlackPoint" => "0 0 0",
        "ICC_Profile:RedMatrixColumn" => "0.43607 0.22249 0.01392",
        "ICC_Profile:GreenMatrixColumn" => "0.38515 0.71687 0.09708",
        "ICC_Profile:BlueMatrixColumn" => "0.14307 0.06061 0.7141",
        "ICC_Profile:DeviceMfgDesc" => "IEC http://www.iec.ch",
        "ICC_Profile:DeviceModelDesc" => "IEC 61966-2.1 Default RGB colour space - sRGB",
        "ICC_Profile:ViewingCondDesc" => "Reference Viewing Condition in IEC61966-2.1",
        "ICC_Profile:Luminance" => "76.03647 80 87.12462",
        "ICC_Profile:Technology" => "Cathode Ray Tube Display",
        "ICC-view:ViewingCondIlluminant" => "19.6445 20.3718 16.8089",
        "ICC-view:ViewingCondSurround" => "3.92889 4.07439 3.36179",
        "ICC-view:ViewingCondIlluminantType" => "D50",
        "ICC-meas:MeasurementObserver" => "CIE 1931",
        "ICC-meas:MeasurementBacking" => "0 0 0",
        "ICC-meas:MeasurementGeometry" => "Unknown",
        "ICC-meas:MeasurementFlare" => "0.999%",
        "ICC-meas:MeasurementIlluminant" => "D65",
        "Adobe:DCTEncodeVersion" => 100,
        "Adobe:APP14Flags0" => "[14]",
        "Adobe:APP14Flags1" => "(none)",
        "Adobe:ColorTransform" => "YCbCr",
        "Vips:Error" => "libvips error",
      }, file.metadata.to_h)
    end
  end

  context "a grayscale JPEG without an embedded color profile" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/jpg/test-grey-no-profile.jpg")

      assert_equal(535, file.width)
      assert_equal(290, file.height)
      assert_equal(9895, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("fa73e31a9d4c04ff87da3846faee0de6", file.md5)
      assert_equal("85e9fde0ba6cc7d4fedf24c71bb6277b", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:ImageWidth" => 535,
        "File:ImageHeight" => 290,
        "File:EncodingProcess" => "Progressive DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 1,
        "JFIF:JFIFVersion" => 1.01,
        "JFIF:ResolutionUnit" => "inches",
        "JFIF:XResolution" => 300,
        "JFIF:YResolution" => 300,
      }, file.metadata.to_h)
    end
  end

  context "a large corrupt JPEG that libvips can't decode" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/jpg/test-large.jpg")

      assert_equal(1356, file.width)
      assert_equal(911, file.height)
      assert_equal(91_047, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("8e147f02611a9286870a97c726338e62", file.md5)
      assert_equal("8e147f02611a9286870a97c726338e62", file.pixel_hash)
      assert_equal(true, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:Comment" => "File written by Adobe Photoshop? 4.0",
        "File:ImageWidth" => 1356,
        "File:ImageHeight" => 911,
        "File:EncodingProcess" => "Baseline DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 3,
        "File:YCbCrSubSampling" => "YCbCr4:2:0 (2 2)",
        "JFIF:JFIFVersion" => 1.02,
        "JFIF:ResolutionUnit" => "inches",
        "JFIF:XResolution" => 339,
        "JFIF:YResolution" => 339,
        "Photoshop:MacintoshPrintInfo" => "\u0003HH\u0002?\u0002(????\u0002?\u0002E\u0003G\u0005(\u0003?\u0002HH\u0002?\u0002(\u0001d\u0001\u0003\u0003\u0003\u0001'\u000F\u0001\u0001`\b\u0019\u0001?",
        "Photoshop:XResolution" => 339,
        "Photoshop:DisplayedUnitsX" => "inches",
        "Photoshop:YResolution" => 339,
        "Photoshop:DisplayedUnitsY" => "inches",
        "Photoshop:PrintFlags" => "(none)",
        "Photoshop:CopyrightFlag" => false,
        "Photoshop:PrintFlagsInfo" => "\u0001\u0002",
        "Photoshop:ColorHalftoningInfo" => "/ff\u0001lff\u0006\u0001/ff\u0001???\u0006\u00012\u0001Z\u0006\u00015\u0001-\u0006\u0001",
        "Photoshop:ColorTransferFuncs" => "??????????????????????\u0003???????????????????????\u0003???????????????????????\u0003???????????????????????\u0003?",
        "Photoshop:GridGuidesInfo" => "\u0001\u0002@\u0002@",
        "Photoshop:PhotoshopQuality" => 5,
        "Photoshop:PhotoshopFormat" => "Optimized",
        "Adobe:DCTEncodeVersion" => 100,
        "Adobe:APP14Flags0" => "Encoded with Blend=1 downsampling",
        "Adobe:APP14Flags1" => "(none)",
        "Adobe:ColorTransform" => "YCbCr",
        "Vips:Error" => "libvips error",
      }, file.metadata.to_h)
    end
  end

  context "a JPEG rotated 180 degrees via an EXIF orientation flag" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/jpg/test-rotation-180.jpg")

      assert_equal(66, file.width)
      assert_equal(100, file.height)
      assert_equal(30_695, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("afa74b7021a5fe96195a24c7052b15c3", file.md5)
      assert_equal("510aa465afbba3d7d818038b7aa7bb6f", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:Comment" => "Paint Tool -SAI- JPEG Encoder v1.00",
        "File:ExifByteOrder" => "Big-endian (Motorola, MM)",
        "File:ImageWidth" => 66,
        "File:ImageHeight" => 100,
        "File:EncodingProcess" => "Baseline DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 3,
        "File:YCbCrSubSampling" => "YCbCr4:2:0 (2 2)",
        "JFIF:JFIFVersion" => 1.01,
        "JFIF:ResolutionUnit" => "inches",
        "JFIF:XResolution" => 400,
        "JFIF:YResolution" => 400,
        "IFD0:ProcessingSoftware" => "Windows Photo Editor 10.0.10011.16384",
        "IFD0:Orientation" => "Rotate 180",
        "IFD0:Software" => "Windows Photo Editor 10.0.10011.16384",
        "IFD0:ModifyDate" => "2016:09:22 21:56:04",
        "ExifIFD:DateTimeOriginal" => "2016:09:22 21:43:51",
        "ExifIFD:CreateDate" => "2016:09:22 21:43:51",
        "ExifIFD:SubSecTimeOriginal" => 34,
        "ExifIFD:SubSecTimeDigitized" => 34,
        "ExifIFD:ColorSpace" => "sRGB",
        "IFD1:Compression" => "JPEG (old-style)",
        "IFD1:XResolution" => 96,
        "IFD1:YResolution" => 96,
        "IFD1:ResolutionUnit" => "inches",
        "IFD1:ThumbnailOffset" => 4585,
        "IFD1:ThumbnailLength" => 9811,
        "XMP-rdf:About" => "uuid:faf5bdd5-ba3d-11da-ad31-d33d75182f1b",
        "XMP-xmp:CreatorTool" => "Windows Photo Editor 10.0.10011.16384",
        "XMP-xmp:CreateDate" => "2016:09:22 21:43:51.341",
        "Composite:SubSecCreateDate" => "2016:09:22 21:43:51.34",
        "Composite:SubSecDateTimeOriginal" => "2016:09:22 21:43:51.34",
      }, file.metadata.to_h)
    end
  end

  context "a JPEG rotated 270 degrees clockwise via an EXIF orientation flag" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/jpg/test-rotation-270cw.jpg")

      assert_equal(100, file.width)
      assert_equal(66, file.height)
      assert_equal(40_731, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("61828111dcec04e021521a7cedcba64c", file.md5)
      assert_equal("ac0220aea5683e3c4ffcb2c7b34078e8", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:ExifByteOrder" => "Little-endian (Intel, II)",
        "File:MakerNoteByteOrder" => "Big-endian (Motorola, MM)",
        "File:ImageWidth" => 66,
        "File:ImageHeight" => 100,
        "File:EncodingProcess" => "Baseline DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 3,
        "File:YCbCrSubSampling" => "YCbCr4:2:0 (2 2)",
        "JFIF:JFIFVersion" => 1.01,
        "JFIF:ResolutionUnit" => "inches",
        "JFIF:XResolution" => 300,
        "JFIF:YResolution" => 300,
        "IFD0:Make" => "NIKON CORPORATION",
        "IFD0:Model" => "NIKON D70",
        "IFD0:Orientation" => "Rotate 270 CW",
        "IFD0:XResolution" => 300,
        "IFD0:YResolution" => 300,
        "IFD0:ResolutionUnit" => "inches",
        "IFD0:Software" => "Ver.2.00",
        "IFD0:ModifyDate" => "2006:10:01 20:17:29",
        "IFD0:YCbCrPositioning" => "Co-sited",
        "IFD0:CustomRendered" => "Normal",
        "IFD0:ExposureMode" => "Auto",
        "IFD0:WhiteBalance" => "Auto",
        "IFD0:DigitalZoomRatio" => 1,
        "IFD0:FocalLengthIn35mmFormat" => "36 mm",
        "IFD0:SceneCaptureType" => "Standard",
        "IFD0:GainControl" => "None",
        "IFD0:Contrast" => "Normal",
        "IFD0:Saturation" => "Normal",
        "IFD0:Sharpness" => "Normal",
        "IFD0:SubjectDistanceRange" => "Unknown",
        "ExifIFD:ExposureTime" => "1/60",
        "ExifIFD:FNumber" => 4.0,
        "ExifIFD:ExposureProgram" => "Not Defined",
        "ExifIFD:ExifVersion" => "0221",
        "ExifIFD:DateTimeOriginal" => "2006:10:01 20:17:29",
        "ExifIFD:CreateDate" => "2006:10:01 20:17:29",
        "ExifIFD:ComponentsConfiguration" => "Y, Cb, Cr, -",
        "ExifIFD:CompressedBitsPerPixel" => 4,
        "ExifIFD:ExposureCompensation" => 0,
        "ExifIFD:MaxApertureValue" => 3.9,
        "ExifIFD:MeteringMode" => "Multi-segment",
        "ExifIFD:LightSource" => "Unknown",
        "ExifIFD:Flash" => "Auto, Fired, Return detected",
        "ExifIFD:FocalLength" => "24.0 mm",
        "ExifIFD:UserComment" => "",
        "ExifIFD:SubSecTime" => 20,
        "ExifIFD:SubSecTimeOriginal" => 20,
        "ExifIFD:SubSecTimeDigitized" => 20,
        "ExifIFD:FlashpixVersion" => "0100",
        "ExifIFD:ColorSpace" => "sRGB",
        "ExifIFD:ExifImageWidth" => 3008,
        "ExifIFD:ExifImageHeight" => 2000,
        "ExifIFD:SensingMethod" => "One-chip color area",
        "ExifIFD:FileSource" => "Digital Camera",
        "ExifIFD:SceneType" => "Directly photographed",
        "ExifIFD:CFAPattern" => "[Blue,Green][Green,Red]",
        "Nikon:MakerNoteVersion" => 2.1,
        "Nikon:ISO" => 500,
        "Nikon:Quality" => "Fine",
        "Nikon:WhiteBalance" => "Auto",
        "Nikon:Sharpness" => "Auto",
        "Nikon:FocusMode" => "AF-S",
        "Nikon:FlashSetting" => "Normal",
        "Nikon:FlashType" => "Built-in,TTL",
        "Nikon:WhiteBalanceFineTune" => 0,
        "Nikon:ProgramShift" => 0,
        "Nikon:ExposureDifference" => -1.6,
        "Nikon:FlashExposureComp" => 0,
        "Nikon:ISOSetting" => 500,
        "Nikon:ImageBoundary" => "0 0 3008 2000",
        "Nikon:ExternalFlashExposureComp" => 0,
        "Nikon:FlashExposureBracketValue" => 0.0,
        "Nikon:ExposureBracketValue" => 0,
        "Nikon:ToneComp" => "Auto",
        "Nikon:LensType" => "G",
        "Nikon:Lens" => "18-50mm f/3.5-5.6",
        "Nikon:FlashMode" => "Fired, TTL Mode",
        "Nikon:AFAreaMode" => "Dynamic Area (closest subject)",
        "Nikon:AFPoint" => "Center",
        "Nikon:AFPointsInFocus" => "Center",
        "Nikon:ShootingMode" => "Single-Frame",
        "Nikon:Nikon_0x008a" => 0,
        "Nikon:ColorHue" => "Mode1a",
        "Nikon:LightSource" => "Speedlight",
        "Nikon:ShotInfoVersion" => "0103",
        "Nikon:HueAdjustment" => 0,
        "Nikon:NoiseReduction" => "Off",
        "Nikon:WB_RGBGLevels" => "531 256 466 256",
        "Nikon:LensDataVersion" => "0101",
        "Nikon:ExitPupilPosition" => "64.0 mm",
        "Nikon:AFAperture" => 3.9,
        "Nikon:FocusPosition" => "0x11",
        "Nikon:FocusDistance" => "0.40 m",
        "Nikon:FocalLength" => "23.8 mm",
        "Nikon:LensIDNumber" => 38,
        "Nikon:LensFStops" => 5.33,
        "Nikon:MinFocalLength" => "18.3 mm",
        "Nikon:MaxFocalLength" => "50.4 mm",
        "Nikon:MaxApertureAtMinFocal" => 3.6,
        "Nikon:MaxApertureAtMaxFocal" => 5.7,
        "Nikon:MCUVersion" => 28,
        "Nikon:EffectiveMaxAperture" => 3.9,
        "Nikon:SensorPixelSize" => "7.8 x 7.8 um",
        "Nikon:SerialNumber" => "No= -100072a",
        "Nikon:ImageDataSize" => 2_815_619,
        "Nikon:Nikon_0x00a3" => 0,
        "Nikon:ShutterCount" => 2688,
        "Nikon:FlashInfoVersion" => "0100",
        "Nikon:FlashSource" => "None",
        "Nikon:ExternalFlashFirmware" => "n/a",
        "Nikon:ExternalFlashFlags" => "(none)",
        "Nikon:FlashCommanderMode" => "Off",
        "Nikon:FlashControlMode" => "Off",
        "Nikon:FlashCompensation" => 0,
        "Nikon:FlashGNDistance" => 0,
        "Nikon:FlashGroupAControlMode" => "Off",
        "Nikon:FlashGroupBControlMode" => "Off",
        "Nikon:FlashGroupACompensation" => 0,
        "Nikon:FlashGroupBCompensation" => 0,
        "Nikon:ImageOptimization" => "",
        "Nikon:Saturation" => "Normal",
        "Nikon:VariProgram" => "Auto",
        "PreviewIFD:Compression" => "JPEG (old-style)",
        "PreviewIFD:XResolution" => 300,
        "PreviewIFD:YResolution" => 300,
        "PreviewIFD:ResolutionUnit" => "inches",
        "PreviewIFD:PreviewImageStart" => 2344,
        "PreviewIFD:PreviewImageLength" => 27_807,
        "PreviewIFD:YCbCrPositioning" => "Co-sited",
        "IFD1:Compression" => "JPEG (old-style)",
        "IFD1:XResolution" => 300,
        "IFD1:YResolution" => 300,
        "IFD1:ResolutionUnit" => "inches",
        "IFD1:ThumbnailOffset" => 30_310,
        "IFD1:ThumbnailLength" => 8551,
        "IFD1:YCbCrPositioning" => "Co-sited",
        "Composite:Aperture" => 4.0,
        "Composite:BlueBalance" => 1.820313,
        "Composite:RedBalance" => 2.074219,
        "Composite:ScaleFactor35efl" => 1.5,
        "Composite:ShutterSpeed" => "1/60",
        "Composite:SubSecCreateDate" => "2006:10:01 20:17:29.20",
        "Composite:SubSecDateTimeOriginal" => "2006:10:01 20:17:29.20",
        "Composite:SubSecModifyDate" => "2006:10:01 20:17:29.20",
        "Composite:AutoFocus" => "On",
        "Composite:LensID" => "Sigma 18-50mm F3.5-5.6 DC",
        "Composite:LensSpec" => "18-50mm f/3.5-5.6 G",
        "Composite:CircleOfConfusion" => "0.020 mm",
        "Composite:DOF" => "0.04 m (0.38 - 0.42 m)",
        "Composite:FOV" => "50.3 deg (0.37 m)",
        "Composite:FocalLength35efl" => "24.0 mm (35 mm equivalent: 36.0 mm)",
        "Composite:HyperfocalDistance" => "7.19 m",
        "Composite:LightValue" => 7.6,
      }, file.metadata.to_h)
    end
  end

  context "a large JPEG rotated 270 degrees clockwise via an EXIF orientation flag" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/jpg/test-rotation-270cw-large.jpg")

      assert_equal(1104, file.width)
      assert_equal(736, file.height)
      assert_equal(85_328, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("b9f80b26f56c1877b8a7f12b42e76909", file.md5)
      assert_equal("f4602dd62706f8607b86cec90b51d498", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:ExifByteOrder" => "Big-endian (Motorola, MM)",
        "File:ImageWidth" => 736,
        "File:ImageHeight" => 1104,
        "File:EncodingProcess" => "Progressive DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 3,
        "File:YCbCrSubSampling" => "YCbCr4:2:0 (2 2)",
        "JFIF:JFIFVersion" => 1.01,
        "JFIF:ResolutionUnit" => "inches",
        "JFIF:XResolution" => 72,
        "JFIF:YResolution" => 72,
        "IFD0:Orientation" => "Rotate 270 CW",
        "IFD1:Compression" => "JPEG (old-style)",
        "IFD1:XResolution" => 72,
        "IFD1:YResolution" => 72,
        "IFD1:ResolutionUnit" => "inches",
        "IFD1:ThumbnailOffset" => 150,
        "IFD1:ThumbnailLength" => 3650,
      }, file.metadata.to_h)
    end
  end

  context "a JPEG rotated 90 degrees clockwise via an EXIF orientation flag" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/jpg/test-rotation-90cw.jpg")

      assert_equal(96, file.width)
      assert_equal(128, file.height)
      assert_equal(4184, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("6e6c1f2c2e082afa7a26d748dfaf4c79", file.md5)
      assert_equal("7bc62a583c0eb07de4fb7fa0dc9e0851", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:ExifByteOrder" => "Little-endian (Intel, II)",
        "File:ImageWidth" => 128,
        "File:ImageHeight" => 96,
        "File:EncodingProcess" => "Baseline DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 3,
        "File:YCbCrSubSampling" => "YCbCr4:2:0 (2 2)",
        "JFIF:JFIFVersion" => 1.01,
        "JFIF:ResolutionUnit" => "None",
        "JFIF:XResolution" => 1,
        "JFIF:YResolution" => 1,
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

  context "a JPEG with a weird embedded color profile" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/jpg/test-weird-profile.jpg")

      assert_equal(154, file.width)
      assert_equal(192, file.height)
      assert_equal(36_068, file.file_size)
      assert_equal(:jpg, file.file_ext)
      assert_equal("image/jpeg", file.mime_type)
      assert_equal("51385a274e9a5454c1432358e93e1c61", file.md5)
      assert_equal("0365fdfe0e905167c14c67e2bbdf8110", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "JPEG",
        "File:ImageWidth" => 154,
        "File:ImageHeight" => 192,
        "File:EncodingProcess" => "Baseline DCT, Huffman coding",
        "File:BitsPerSample" => 8,
        "File:ColorComponents" => 3,
        "File:YCbCrSubSampling" => "YCbCr4:4:4 (1 1)",
        "JFIF:JFIFVersion" => 1.01,
        "JFIF:ResolutionUnit" => "None",
        "JFIF:XResolution" => 1,
        "JFIF:YResolution" => 1,
        "ExifTool:Warning" => "Bad length ICC_Profile (length 8716)",
        "ICC-header:ProfileCMMType" => "Unknown (WCS )",
        "ICC-header:ProfileVersion" => "2.1.0",
        "ICC-header:ProfileClass" => "Display Device Profile",
        "ICC-header:ColorSpaceData" => "RGB ",
        "ICC-header:ProfileConnectionSpace" => "XYZ ",
        "ICC-header:ProfileDateTime" => "2016:06:09 19:08:21",
        "ICC-header:ProfileFileSignature" => "acsp",
        "ICC-header:PrimaryPlatform" => "Microsoft Corporation",
        "ICC-header:CMMFlags" => "Not Embedded, Independent",
        "ICC-header:DeviceManufacturer" => "Microsoft Corporation",
        "ICC-header:DeviceModel" => "MS30",
        "ICC-header:DeviceAttributes" => "Reflective, Glossy, Positive, Color",
        "ICC-header:RenderingIntent" => "Media-Relative Colorimetric",
        "ICC-header:ConnectionSpaceIlluminant" => "0.9642 1 0.82491",
        "ICC-header:ProfileCreator" => "Microsoft Corporation",
        "ICC-header:ProfileID" => 0,
        "ICC_Profile:ProfileCopyright" => "Copyright 2016 Microsoft Corporation.",
        "ICC_Profile:ProfileDescription-ar-XM" => "محسن",
        "ICC_Profile:ProfileDescription-bg-BG" => "Подобрен",
        "ICC_Profile:ProfileDescription-cs-CZ" => "Vylepšený",
        "ICC_Profile:ProfileDescription-da-DK" => "Forbedret",
        "ICC_Profile:ProfileDescription-de-AT" => "Verbessert",
        "ICC_Profile:ProfileDescription-de-CH" => "Verbessert",
        "ICC_Profile:ProfileDescription-de-DE" => "Verbessert",
        "ICC_Profile:ProfileDescription-el-GR" => "Βελτιωμένα",
        "ICC_Profile:ProfileDescription-en-AU" => "Enhanced",
        "ICC_Profile:ProfileDescription-en-CA" => "Enhanced",
        "ICC_Profile:ProfileDescription-en-GB" => "Enhanced",
        "ICC_Profile:ProfileDescription-en-HK" => "Enhanced",
        "ICC_Profile:ProfileDescription-en-ID" => "Enhanced",
        "ICC_Profile:ProfileDescription-en-IE" => "Enhanced",
        "ICC_Profile:ProfileDescription-en-IN" => "Enhanced",
        "ICC_Profile:ProfileDescription-en-MY" => "Enhanced",
        "ICC_Profile:ProfileDescription-en-NZ" => "Enhanced",
        "ICC_Profile:ProfileDescription-en-PH" => "Enhanced",
        "ICC_Profile:ProfileDescription-en-SG" => "Enhanced",
        "ICC_Profile:ProfileDescription" => "Enhanced",
        "ICC_Profile:ProfileDescription-en-ZA" => "Enhanced",
        "ICC_Profile:ProfileDescription-es-AR" => "Mejorado",
        "ICC_Profile:ProfileDescription-es-CL" => "Mejorado",
        "ICC_Profile:ProfileDescription-es-CO" => "Mejorado",
        "ICC_Profile:ProfileDescription-es-ES" => "Mejorado",
        "ICC_Profile:ProfileDescription-es-MX" => "Mejorado",
        "ICC_Profile:ProfileDescription-es-XL" => "Mejorado",
        "ICC_Profile:ProfileDescription-et-EE" => "Täiustatud",
        "ICC_Profile:ProfileDescription-fi-FI" => "Tehostettu",
        "ICC_Profile:ProfileDescription-fr-BE" => "Amélioré",
        "ICC_Profile:ProfileDescription-fr-CA" => "Amélioré",
        "ICC_Profile:ProfileDescription-fr-CH" => "Amélioré",
        "ICC_Profile:ProfileDescription-fr-FR" => "Amélioré",
        "ICC_Profile:ProfileDescription-fr-XF" => "Amélioré",
        "ICC_Profile:ProfileDescription-he-IL" => "משופר",
        "ICC_Profile:ProfileDescription-hr-HR" => "Poboljšani",
        "ICC_Profile:ProfileDescription-hu-HU" => "Kibővített",
        "ICC_Profile:ProfileDescription-is-IS" => "Enhanced",
        "ICC_Profile:ProfileDescription-it-IT" => "Migliorato",
        "ICC_Profile:ProfileDescription-ja-JP" => "エンハンス",
        "ICC_Profile:ProfileDescription-ko-KR" => "고급",
        "ICC_Profile:ProfileDescription-lt-LT" => "Patobulintas",
        "ICC_Profile:ProfileDescription-lv-LV" => "Uzlabots",
        "ICC_Profile:ProfileDescription-nb-NO" => "Forbedret",
        "ICC_Profile:ProfileDescription-nl-BE" => "Verbeterd",
        "ICC_Profile:ProfileDescription-nl-NL" => "Verbeterd",
        "ICC_Profile:ProfileDescription-pl-PL" => "Poprawiony",
        "ICC_Profile:ProfileDescription-pt-BR" => "Melhorada",
        "ICC_Profile:ProfileDescription-pt-PT" => "Melhorado",
        "ICC_Profile:ProfileDescription-ro-RO" => "Îmbunătățit",
        "ICC_Profile:ProfileDescription-ru-RU" => "Улучшенный",
        "ICC_Profile:ProfileDescription-sk-SK" => "Vylepšený",
        "ICC_Profile:ProfileDescription-sl-SI" => "Izboljšano",
        "ICC_Profile:ProfileDescription-sr-RS" => "Poboljšano",
        "ICC_Profile:ProfileDescription-sv-SE" => "Förbättrad",
        "ICC_Profile:ProfileDescription-th-TH" => "เพิ่มคุณภาพ",
        "ICC_Profile:ProfileDescription-tr-TR" => "Gelişmiş",
        "ICC_Profile:ProfileDescription-uk-UA" => "Покращений",
        "ICC_Profile:ProfileDescription-vi-VN" => "Nâng cao",
        "ICC_Profile:ProfileDescription-zh-CN" => "增强",
        "ICC_Profile:ProfileDescription-zh-HK" => "增強",
        "ICC_Profile:ProfileDescription-zh-TW" => "增強",
        "ICC_Profile:MediaWhitePoint" => "0.9642 1 0.82512",
        "ICC_Profile:MediaBlackPoint" => "0.01205 0.0125 0.01031",
        "ICC_Profile:DeviceMfgDesc" => "MSFT http://www.microsoft.com",
        "ICC_Profile:DeviceModelDesc" => "Surface",
        "ICC_Profile:Luminance" => "380.18799 400 435.532",
        "ICC_Profile:Technology" => "Active Matrix Display",
        "ICC_Profile:ChromaticAdaptation" => "1.04788 0.02292 -0.05016 0.02959 0.99046 -0.01706 -0.00923 0.01505 0.752",
        "ICC_Profile:RedMatrixColumn" => "0.43594 0.22244 0.0139",
        "ICC_Profile:GreenMatrixColumn" => "0.38524 0.71703 0.09709",
        "ICC_Profile:BlueMatrixColumn" => "0.14287 0.06055 0.71329",
      }, file.metadata.to_h)
    end
  end
end
