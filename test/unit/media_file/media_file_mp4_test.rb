require "test_helper"

class MediaFileMp4Test < ActiveSupport::TestCase
  context "Previews" do
    should "be generated properly" do
      should_generate_previews(
        "mp4",
        failures: ["test/files/mp4/test-corrupt.mp4"]
      )
    end
  end

  context "a normal h264 MP4" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-300x300.mp4")

      assert_equal(300, file.width)
      assert_equal(300, file.height)
      assert_equal(18_677, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("865c93102cad3e8a893d6aac6b51b0d2", file.md5)
      assert_equal("865c93102cad3e8a893d6aac6b51b0d2", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(5.7, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(1.7543859649122806, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 v2 [ISO 14496-14]",
        "QuickTime:MinorVersion" => "0.0.0",
        "QuickTime:CompatibleBrands" => ["mp42", "mp41", "isom"],
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "2017:09:27 13:02:06",
        "QuickTime:ModifyDate" => "2017:09:27 13:02:06",
        "QuickTime:TimeScale" => 600,
        "QuickTime:Duration" => "5.70 s",
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
        "QuickTime:MediaDataSize" => 17_815,
        "QuickTime:MediaDataOffset" => 862,
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "2017:09:27 13:02:06",
        "Track1:TrackModifyDate" => "2017:09:27 13:02:06",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "5.70 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 300,
        "Track1:ImageHeight" => 300,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "2017:09:27 13:02:06",
        "Track1:MediaModifyDate" => "2017:09:27 13:02:06",
        "Track1:MediaTimeScale" => 1000,
        "Track1:MediaDuration" => "5.70 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "Twitter v1.0-757770b7c8e9d79a526cdff77e74666386274fdf",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "avc1",
        "Track1:SourceImageWidth" => 300,
        "Track1:SourceImageHeight" => 300,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:CompressorName" => "AVC Coding",
        "Track1:BitDepth" => 0,
        "Track1:VideoFrameRate" => 1.754,
        "Composite:AvgBitrate" => "25 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "mp42",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 10,
        "FFmpeg:VideoCodec" => "h264",
        "FFmpeg:VideoProfile" => "Constrained Baseline",
        "FFmpeg:VideoBitRate" => 25_003,
      }, file.metadata.to_h)
    end
  end


  context "a 3GPP-brand h264 MP4" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-300x300-3gp5.mp4")

      assert_equal(300, file.width)
      assert_equal(300, file.height)
      assert_equal(18_770, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("837285a79b84d4a924db7ae9eb4a2ec0", file.md5)
      assert_equal("837285a79b84d4a924db7ae9eb4a2ec0", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(5.7, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(1.7543859649122806, file.frame_rate)
      assert_equal({
        "File:FileType" => "3GP",
        "QuickTime:MajorBrand" => "3GPP Media (.3GP) Release 5",
        "QuickTime:MinorVersion" => "0.2.0",
        "QuickTime:CompatibleBrands" => ["3gp5", "iso2", "avc1", "mp41"],
        "QuickTime:MediaDataSize" => 17_815,
        "QuickTime:MediaDataOffset" => 48,
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "0000:00:00 00:00:00",
        "QuickTime:ModifyDate" => "0000:00:00 00:00:00",
        "QuickTime:TimeScale" => 1000,
        "QuickTime:Duration" => "5.70 s",
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
        "QuickTime:HandlerType" => "Metadata",
        "QuickTime:HandlerVendorID" => "Apple",
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "5.70 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 300,
        "Track1:ImageHeight" => 300,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track1:MediaTimeScale" => 16_000,
        "Track1:MediaDuration" => "5.70 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "Twitter v1.0-757770b7c8e9d79a526cdff77e74666386274fdf",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "avc1",
        "Track1:SourceImageWidth" => 300,
        "Track1:SourceImageHeight" => 300,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:BitDepth" => 24,
        "Track1:BufferSize" => 0,
        "Track1:MaxBitrate" => 25_003,
        "Track1:AverageBitrate" => 25_003,
        "Track1:VideoFrameRate" => 1.754,
        "ItemList:Encoder" => "Lavf58.76.100",
        "Composite:AvgBitrate" => "25 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "3gp5",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 10,
        "FFmpeg:VideoCodec" => "h264",
        "FFmpeg:VideoProfile" => "Constrained Baseline",
        "FFmpeg:VideoBitRate" => 25_003,
      }, file.metadata.to_h)
    end
  end

  context "an av1 MP4" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-300x300-av1.mp4")

      assert_equal(300, file.width)
      assert_equal(300, file.height)
      assert_equal(25_640, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("887ae69b62ae55ff1de737cb6a2b5fbf", file.md5)
      assert_equal("887ae69b62ae55ff1de737cb6a2b5fbf", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(5.8, file.duration)
      assert_equal(58, file.frame_count)
      assert_equal(10.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 Base Media v1 [IS0 14496-12:2003]",
        "QuickTime:MinorVersion" => "0.2.0",
        "QuickTime:CompatibleBrands" => ["isom", "av01", "iso2", "mp41"],
        "QuickTime:MediaDataSize" => 24_543,
        "QuickTime:MediaDataOffset" => 48,
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "0000:00:00 00:00:00",
        "QuickTime:ModifyDate" => "0000:00:00 00:00:00",
        "QuickTime:TimeScale" => 1000,
        "QuickTime:Duration" => "5.80 s",
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
        "QuickTime:HandlerType" => "Metadata",
        "QuickTime:HandlerVendorID" => "Apple",
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "5.80 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 300,
        "Track1:ImageHeight" => 300,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track1:MediaTimeScale" => 10_240,
        "Track1:MediaDuration" => "5.80 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "Twitter v1.0-757770b7c8e9d79a526cdff77e74666386274fdf",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "av01",
        "Track1:SourceImageWidth" => 300,
        "Track1:SourceImageHeight" => 300,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:BitDepth" => 24,
        "Track1:VideoFieldOrder" => "Progressive; 0",
        "Track1:BufferSize" => 0,
        "Track1:MaxBitrate" => 33_852,
        "Track1:AverageBitrate" => 33_852,
        "Track1:VideoFrameRate" => 10,
        "ItemList:Encoder" => "Lavf58.76.100",
        "Composite:AvgBitrate" => "33.9 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "isom",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 58,
        "FFmpeg:VideoCodec" => "av1",
        "FFmpeg:VideoProfile" => "Main",
        "FFmpeg:VideoBitRate" => 33_852,
      }, file.metadata.to_h)
    end
  end

  context "an h265/HEVC MP4" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-300x300-h265.mp4")

      assert_equal(300, file.width)
      assert_equal(300, file.height)
      assert_equal(22_148, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("fd2a8afb766000b26ca42710dd5938df", file.md5)
      assert_equal("fd2a8afb766000b26ca42710dd5938df", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(5.8, file.duration)
      assert_equal(58, file.frame_count)
      assert_equal(10.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 Base Media v1 [IS0 14496-12:2003]",
        "QuickTime:MinorVersion" => "0.2.0",
        "QuickTime:CompatibleBrands" => ["isom", "iso2", "mp41"],
        "QuickTime:MediaDataSize" => 18_178,
        "QuickTime:MediaDataOffset" => 44,
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "0000:00:00 00:00:00",
        "QuickTime:ModifyDate" => "0000:00:00 00:00:00",
        "QuickTime:TimeScale" => 1000,
        "QuickTime:Duration" => "5.80 s",
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
        "QuickTime:HandlerType" => "Metadata",
        "QuickTime:HandlerVendorID" => "Apple",
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "5.80 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 300,
        "Track1:ImageHeight" => 300,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track1:MediaTimeScale" => 10_240,
        "Track1:MediaDuration" => "5.80 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "Twitter v1.0-757770b7c8e9d79a526cdff77e74666386274fdf",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "hev1",
        "Track1:SourceImageWidth" => 300,
        "Track1:SourceImageHeight" => 300,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:BitDepth" => 24,
        "Track1:VideoFieldOrder" => "Progressive; 0",
        "Track1:BufferSize" => 0,
        "Track1:MaxBitrate" => 25_073,
        "Track1:AverageBitrate" => 25_073,
        "Track1:VideoFrameRate" => 10,
        "ItemList:Encoder" => "Lavf58.76.100",
        "Composite:AvgBitrate" => "25.1 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "isom",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 58,
        "FFmpeg:VideoCodec" => "hevc",
        "FFmpeg:VideoProfile" => "Main",
        "FFmpeg:VideoBitRate" => 25_073,
      }, file.metadata.to_h)
    end
  end

  context "an MP4 with invalid UTF-8 metadata" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-300x300-invalid-utf8-metadata.mp4")

      assert_equal(300, file.width)
      assert_equal(300, file.height)
      assert_equal(18_823, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("f8cc77195d2fe496ab56c68fdc495d20", file.md5)
      assert_equal("f8cc77195d2fe496ab56c68fdc495d20", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(5.7, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(1.7543859649122806, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 Base Media v1 [IS0 14496-12:2003]",
        "QuickTime:MinorVersion" => "0.2.0",
        "QuickTime:CompatibleBrands" => ["isom", "iso2", "avc1", "mp41"],
        "QuickTime:MediaDataSize" => 17_815,
        "QuickTime:MediaDataOffset" => 48,
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "0000:00:00 00:00:00",
        "QuickTime:ModifyDate" => "0000:00:00 00:00:00",
        "QuickTime:TimeScale" => 1000,
        "QuickTime:Duration" => "5.70 s",
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
        "QuickTime:HandlerType" => "Metadata",
        "QuickTime:HandlerVendorID" => "Apple",
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "5.70 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 300,
        "Track1:ImageHeight" => 300,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track1:MediaTimeScale" => 16_000,
        "Track1:MediaDuration" => "5.70 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "Twitter v1.0-757770b7c8e9d79a526cdff77e74666386274fdf",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "avc1",
        "Track1:SourceImageWidth" => 300,
        "Track1:SourceImageHeight" => 300,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:BitDepth" => 24,
        "Track1:BufferSize" => 0,
        "Track1:MaxBitrate" => 25_003,
        "Track1:AverageBitrate" => 25_003,
        "Track1:VideoFrameRate" => 1.754,
        "ItemList:Encoder" => "Lavf58.76.100",
        "ItemList:Comment" => "invalid character: \"?\" (0xFF)",
        "Composite:AvgBitrate" => "25 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "isom",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 10,
        "FFmpeg:VideoCodec" => "h264",
        "FFmpeg:VideoProfile" => "Constrained Baseline",
        "FFmpeg:VideoBitRate" => 25_003,
      }, file.metadata.to_h)
    end
  end

  context "an iso4-brand h264 MP4" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-300x300-iso4.mp4")

      assert_equal(300, file.width)
      assert_equal(300, file.height)
      assert_equal(24_015, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("3b8effafa5e65bf71b356e5a50308232", file.md5)
      assert_equal("3b8effafa5e65bf71b356e5a50308232", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(5.8, file.duration)
      assert_equal(58, file.frame_count)
      assert_equal(10.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 Base Media v4",
        "QuickTime:MinorVersion" => "0.2.0",
        "QuickTime:CompatibleBrands" => ["iso4", "iso2", "avc1", "mp41"],
        "QuickTime:MediaDataSize" => 22_427,
        "QuickTime:MediaDataOffset" => 48,
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "0000:00:00 00:00:00",
        "QuickTime:ModifyDate" => "0000:00:00 00:00:00",
        "QuickTime:TimeScale" => 1000,
        "QuickTime:Duration" => "5.80 s",
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
        "QuickTime:HandlerType" => "Metadata",
        "QuickTime:HandlerVendorID" => "Apple",
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "5.80 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 300,
        "Track1:ImageHeight" => 300,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track1:MediaTimeScale" => 10_240,
        "Track1:MediaDuration" => "5.80 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "Twitter v1.0-757770b7c8e9d79a526cdff77e74666386274fdf",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "avc1",
        "Track1:SourceImageWidth" => 300,
        "Track1:SourceImageHeight" => 300,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:BitDepth" => 24,
        "Track1:BufferSize" => 0,
        "Track1:MaxBitrate" => 30_933,
        "Track1:AverageBitrate" => 30_933,
        "Track1:VideoFrameRate" => 10,
        "ItemList:Encoder" => "Lavf58.76.100",
        "Composite:AvgBitrate" => "30.9 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "iso4",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 58,
        "FFmpeg:VideoCodec" => "h264",
        "FFmpeg:VideoProfile" => "High",
        "FFmpeg:VideoBitRate" => 30_933,
      }, file.metadata.to_h)
    end
  end

  context "an mpeg4 MP4" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-300x300-mpeg4.mp4")

      assert_equal(300, file.width)
      assert_equal(300, file.height)
      assert_equal(171_168, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("8c8729bdd45423a27f599e63fcac0793", file.md5)
      assert_equal("8c8729bdd45423a27f599e63fcac0793", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(5.8, file.duration)
      assert_equal(58, file.frame_count)
      assert_equal(10.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 Base Media v1 [IS0 14496-12:2003]",
        "QuickTime:MinorVersion" => "0.2.0",
        "QuickTime:CompatibleBrands" => ["isom", "iso2", "mp41"],
        "QuickTime:MediaDataSize" => 169_997,
        "QuickTime:MediaDataOffset" => 44,
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "0000:00:00 00:00:00",
        "QuickTime:ModifyDate" => "0000:00:00 00:00:00",
        "QuickTime:TimeScale" => 1000,
        "QuickTime:Duration" => "5.80 s",
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
        "QuickTime:HandlerType" => "Metadata",
        "QuickTime:HandlerVendorID" => "Apple",
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "5.80 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 300,
        "Track1:ImageHeight" => 300,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track1:MediaTimeScale" => 10_240,
        "Track1:MediaDuration" => "5.80 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "Twitter v1.0-757770b7c8e9d79a526cdff77e74666386274fdf",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "mp4v",
        "Track1:SourceImageWidth" => 300,
        "Track1:SourceImageHeight" => 300,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:BitDepth" => 24,
        "Track1:BufferSize" => 0,
        "Track1:MaxBitrate" => 234_478,
        "Track1:AverageBitrate" => 234_478,
        "Track1:VideoFrameRate" => 10,
        "ItemList:Encoder" => "Lavf58.76.100",
        "Composite:AvgBitrate" => "234 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "isom",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 58,
        "FFmpeg:VideoCodec" => "mpeg4",
        "FFmpeg:VideoProfile" => "Simple Profile",
        "FFmpeg:VideoBitRate" => 234_478,
      }, file.metadata.to_h)
    end
  end

  context "a vp9 MP4" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-300x300-vp9.mp4")

      assert_equal(300, file.width)
      assert_equal(300, file.height)
      assert_equal(24_738, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("60f468d43b6b62d162977a144d984990", file.md5)
      assert_equal("60f468d43b6b62d162977a144d984990", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(5.8, file.duration)
      assert_equal(58, file.frame_count)
      assert_equal(10.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 Base Media v1 [IS0 14496-12:2003]",
        "QuickTime:MinorVersion" => "0.2.0",
        "QuickTime:CompatibleBrands" => ["isom", "iso2", "mp41"],
        "QuickTime:MediaDataSize" => 23_650,
        "QuickTime:MediaDataOffset" => 44,
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "0000:00:00 00:00:00",
        "QuickTime:ModifyDate" => "0000:00:00 00:00:00",
        "QuickTime:TimeScale" => 1000,
        "QuickTime:Duration" => "5.80 s",
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
        "QuickTime:HandlerType" => "Metadata",
        "QuickTime:HandlerVendorID" => "Apple",
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "5.80 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 300,
        "Track1:ImageHeight" => 300,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track1:MediaTimeScale" => 10_240,
        "Track1:MediaDuration" => "5.80 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "Twitter v1.0-757770b7c8e9d79a526cdff77e74666386274fdf",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "vp09",
        "Track1:SourceImageWidth" => 300,
        "Track1:SourceImageHeight" => 300,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:BitDepth" => 24,
        "Track1:VideoFieldOrder" => "Progressive; 0",
        "Track1:BufferSize" => 0,
        "Track1:MaxBitrate" => 32_620,
        "Track1:AverageBitrate" => 32_620,
        "Track1:VideoFrameRate" => 10,
        "ItemList:Encoder" => "Lavf58.76.100",
        "Composite:AvgBitrate" => "32.6 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "isom",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 58,
        "FFmpeg:VideoCodec" => "vp9",
        "FFmpeg:VideoProfile" => "Profile 0",
        "FFmpeg:VideoBitRate" => 32_620,
      }, file.metadata.to_h)
    end
  end

  context "an h264 MP4 with 4:4:4 chroma subsampling" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-300x300-yuv444p-h264.mp4")

      assert_equal(300, file.width)
      assert_equal(300, file.height)
      assert_equal(23_959, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("507a7c170b03085f6048170b6415db9f", file.md5)
      assert_equal("507a7c170b03085f6048170b6415db9f", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(5.8, file.duration)
      assert_equal(58, file.frame_count)
      assert_equal(10.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 Base Media v1 [IS0 14496-12:2003]",
        "QuickTime:MinorVersion" => "0.2.0",
        "QuickTime:CompatibleBrands" => ["isom", "iso2", "avc1", "mp41"],
        "QuickTime:MediaDataSize" => 22_370,
        "QuickTime:MediaDataOffset" => 48,
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "0000:00:00 00:00:00",
        "QuickTime:ModifyDate" => "0000:00:00 00:00:00",
        "QuickTime:TimeScale" => 1000,
        "QuickTime:Duration" => "5.80 s",
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
        "QuickTime:HandlerType" => "Metadata",
        "QuickTime:HandlerVendorID" => "Apple",
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "5.80 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 300,
        "Track1:ImageHeight" => 300,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track1:MediaTimeScale" => 10_240,
        "Track1:MediaDuration" => "5.80 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "Twitter v1.0-757770b7c8e9d79a526cdff77e74666386274fdf",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "avc1",
        "Track1:SourceImageWidth" => 300,
        "Track1:SourceImageHeight" => 300,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:BitDepth" => 24,
        "Track1:BufferSize" => 0,
        "Track1:MaxBitrate" => 30_855,
        "Track1:AverageBitrate" => 30_855,
        "Track1:VideoFrameRate" => 10,
        "ItemList:Encoder" => "Lavf58.76.100",
        "Composite:AvgBitrate" => "30.9 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "isom",
        "FFmpeg:PixFmt" => "yuv444p",
        "FFmpeg:FrameCount" => 58,
        "FFmpeg:VideoCodec" => "h264",
        "FFmpeg:VideoProfile" => "High 4:4:4 Predictive",
        "FFmpeg:VideoBitRate" => 30_855,
      }, file.metadata.to_h)
    end
  end

  context "an h264 MP4 with full-range 4:2:0 chroma subsampling" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-300x300-yuvj420p-h264.mp4")

      assert_equal(300, file.width)
      assert_equal(300, file.height)
      assert_equal(24_863, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("a830bdb18e6531ee9228976019254134", file.md5)
      assert_equal("a830bdb18e6531ee9228976019254134", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(5.8, file.duration)
      assert_equal(58, file.frame_count)
      assert_equal(10.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 Base Media v1 [IS0 14496-12:2003]",
        "QuickTime:MinorVersion" => "0.2.0",
        "QuickTime:CompatibleBrands" => ["isom", "iso2", "avc1", "mp41"],
        "QuickTime:MediaDataSize" => 23_266,
        "QuickTime:MediaDataOffset" => 48,
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "0000:00:00 00:00:00",
        "QuickTime:ModifyDate" => "0000:00:00 00:00:00",
        "QuickTime:TimeScale" => 1000,
        "QuickTime:Duration" => "5.80 s",
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
        "QuickTime:HandlerType" => "Metadata",
        "QuickTime:HandlerVendorID" => "Apple",
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "5.80 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 300,
        "Track1:ImageHeight" => 300,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track1:MediaTimeScale" => 10_240,
        "Track1:MediaDuration" => "5.80 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "Twitter v1.0-757770b7c8e9d79a526cdff77e74666386274fdf",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "avc1",
        "Track1:SourceImageWidth" => 300,
        "Track1:SourceImageHeight" => 300,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:BitDepth" => 24,
        "Track1:BufferSize" => 0,
        "Track1:MaxBitrate" => 32_091,
        "Track1:AverageBitrate" => 32_091,
        "Track1:VideoFrameRate" => 10,
        "ItemList:Encoder" => "Lavf58.76.100",
        "Composite:AvgBitrate" => "32.1 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "isom",
        "FFmpeg:PixFmt" => "yuvj420p",
        "FFmpeg:FrameCount" => 58,
        "FFmpeg:VideoCodec" => "h264",
        "FFmpeg:VideoProfile" => "High",
        "FFmpeg:VideoBitRate" => 32_091,
      }, file.metadata.to_h)
    end
  end

  context "an MP4 with an AC3 audio track" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-audio-ac3.mp4")

      assert_equal(1280, file.width)
      assert_equal(720, file.height)
      assert_equal(62_587, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("ac1e50093a7d8a673af3e4f7919d981f", file.md5)
      assert_equal("ac1e50093a7d8a673af3e4f7919d981f", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(1.018, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(9.823182711198427, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 Base Media v1 [IS0 14496-12:2003]",
        "QuickTime:MinorVersion" => "0.2.0",
        "QuickTime:CompatibleBrands" => ["isom", "iso2", "avc1", "mp41"],
        "QuickTime:MediaDataSize" => 61_029,
        "QuickTime:MediaDataOffset" => 48,
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "0000:00:00 00:00:00",
        "QuickTime:ModifyDate" => "0000:00:00 00:00:00",
        "QuickTime:TimeScale" => 1000,
        "QuickTime:Duration" => "1.02 s",
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
        "QuickTime:HandlerType" => "Metadata",
        "QuickTime:HandlerVendorID" => "Apple",
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "1.00 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 1280,
        "Track1:ImageHeight" => 720,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track1:MediaTimeScale" => 90_000,
        "Track1:MediaDuration" => "1.00 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "Vireo Eyes v2.6.2",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "avc1",
        "Track1:SourceImageWidth" => 1280,
        "Track1:SourceImageHeight" => 720,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:BitDepth" => 24,
        "Track1:BufferSize" => 0,
        "Track1:MaxBitrate" => 291_624,
        "Track1:AverageBitrate" => 291_624,
        "Track1:VideoFrameRate" => 10,
        "Track2:TrackHeaderVersion" => 0,
        "Track2:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track2:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track2:TrackID" => 2,
        "Track2:TrackDuration" => "1.02 s",
        "Track2:TrackLayer" => 0,
        "Track2:TrackVolume" => "100.00%",
        "Track2:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track2:MediaHeaderVersion" => 0,
        "Track2:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track2:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track2:MediaTimeScale" => 48_000,
        "Track2:MediaDuration" => "1.02 s",
        "Track2:MediaLanguageCode" => "und",
        "Track2:HandlerType" => "Audio Track",
        "Track2:HandlerDescription" => "Vireo Ears v2.6.2",
        "Track2:Balance" => 0,
        "Track2:AudioChannels" => 2,
        "Track2:AudioBitsPerSample" => 16,
        "Track2:AudioSampleRate" => 48_000,
        "Track2:BufferSize" => 0,
        "Track2:MaxBitrate" => 192_000,
        "Track2:AverageBitrate" => 192_000,
        "ItemList:Encoder" => "Lavf58.76.100",
        "Composite:AvgBitrate" => "479 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "isom",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 10,
        "FFmpeg:VideoCodec" => "h264",
        "FFmpeg:VideoProfile" => "High",
        "FFmpeg:VideoBitRate" => 291_624,
        "FFmpeg:AudioCodec" => "ac3",
        "FFmpeg:AudioLayout" => "stereo",
        "FFmpeg:AudioBitRate" => 192_000,
        "FFmpeg:AudioPeakLoudness" => 0.13182567385564067,
        "FFmpeg:AudioAverageLoudness" => 0.019275249131909367,
        "FFmpeg:AudioLoudnessRange" => 0.0,
        "FFmpeg:AudioSilencePercentage" => 0.7448015717092338,
      }, file.metadata.to_h)
    end
  end

  context "an MP4 with an MP2 audio track" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-audio-mp2.mp4")

      assert_equal(1280, file.width)
      assert_equal(720, file.height)
      assert_equal(49_835, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("7e241992b8ffb2c9e91de0aac3d64003", file.md5)
      assert_equal("7e241992b8ffb2c9e91de0aac3d64003", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(1.0, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(10.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 Base Media v1 [IS0 14496-12:2003]",
        "QuickTime:MinorVersion" => "0.2.0",
        "QuickTime:CompatibleBrands" => ["isom", "iso2", "avc1", "mp41"],
        "QuickTime:MediaDataSize" => 48_129,
        "QuickTime:MediaDataOffset" => 48,
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "0000:00:00 00:00:00",
        "QuickTime:ModifyDate" => "0000:00:00 00:00:00",
        "QuickTime:TimeScale" => 1000,
        "QuickTime:Duration" => "1.00 s",
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
        "QuickTime:HandlerType" => "Metadata",
        "QuickTime:HandlerVendorID" => "Apple",
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "1.00 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 1280,
        "Track1:ImageHeight" => 720,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track1:MediaTimeScale" => 90_000,
        "Track1:MediaDuration" => "1.00 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "Vireo Eyes v2.6.2",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "avc1",
        "Track1:SourceImageWidth" => 1280,
        "Track1:SourceImageHeight" => 720,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:BitDepth" => 24,
        "Track1:BufferSize" => 0,
        "Track1:MaxBitrate" => 291_624,
        "Track1:AverageBitrate" => 291_624,
        "Track1:VideoFrameRate" => 10,
        "Track2:TrackHeaderVersion" => 0,
        "Track2:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track2:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track2:TrackID" => 2,
        "Track2:TrackDuration" => "0.73 s",
        "Track2:TrackLayer" => 0,
        "Track2:TrackVolume" => "100.00%",
        "Track2:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track2:MediaHeaderVersion" => 0,
        "Track2:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track2:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track2:MediaTimeScale" => 44_100,
        "Track2:MediaDuration" => "0.73 s",
        "Track2:MediaLanguageCode" => "eng",
        "Track2:HandlerType" => "Audio Track",
        "Track2:HandlerDescription" => "SoundHandler",
        "Track2:Balance" => 0,
        "Track2:AudioFormat" => "mp4a",
        "Track2:AudioChannels" => 2,
        "Track2:AudioBitsPerSample" => 16,
        "Track2:AudioSampleRate" => 44_100,
        "Track2:BufferSize" => 0,
        "Track2:MaxBitrate" => 127_654,
        "Track2:AverageBitrate" => 127_654,
        "ItemList:Encoder" => "Lavf58.76.100",
        "Composite:AvgBitrate" => "385 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "isom",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 10,
        "FFmpeg:VideoCodec" => "h264",
        "FFmpeg:VideoProfile" => "High",
        "FFmpeg:VideoBitRate" => 291_624,
        "FFmpeg:AudioCodec" => "mp2",
        "FFmpeg:AudioLayout" => "stereo",
        "FFmpeg:AudioBitRate" => 127_654,
        "FFmpeg:AudioPeakLoudness" => 1.0e-50,
        "FFmpeg:AudioAverageLoudness" => 0.00031622776601683794,
        "FFmpeg:AudioLoudnessRange" => 0.0,
        "FFmpeg:AudioSilencePercentage" => 0.731633,
      }, file.metadata.to_h)
    end
  end

  context "an MP4 with an MP3 audio track" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-audio-mp3.mp4")

      assert_equal(1280, file.width)
      assert_equal(720, file.height)
      assert_equal(54_576, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("3efd92e36e81d67378b051e1e32f4c3b", file.md5)
      assert_equal("3efd92e36e81d67378b051e1e32f4c3b", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(1.002, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(9.980039920159681, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 Base Media v1 [IS0 14496-12:2003]",
        "QuickTime:MinorVersion" => "0.2.0",
        "QuickTime:CompatibleBrands" => ["isom", "iso2", "avc1", "mp41"],
        "QuickTime:MediaDataSize" => 52_965,
        "QuickTime:MediaDataOffset" => 48,
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "0000:00:00 00:00:00",
        "QuickTime:ModifyDate" => "0000:00:00 00:00:00",
        "QuickTime:TimeScale" => 1000,
        "QuickTime:Duration" => "1.00 s",
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
        "QuickTime:HandlerType" => "Metadata",
        "QuickTime:HandlerVendorID" => "Apple",
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "1.00 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 1280,
        "Track1:ImageHeight" => 720,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track1:MediaTimeScale" => 90_000,
        "Track1:MediaDuration" => "1.00 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "Vireo Eyes v2.6.2",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "avc1",
        "Track1:SourceImageWidth" => 1280,
        "Track1:SourceImageHeight" => 720,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:BitDepth" => 24,
        "Track1:BufferSize" => 0,
        "Track1:MaxBitrate" => 291_624,
        "Track1:AverageBitrate" => 291_624,
        "Track1:VideoFrameRate" => 10,
        "Track2:TrackHeaderVersion" => 0,
        "Track2:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track2:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track2:TrackID" => 2,
        "Track2:TrackDuration" => "1.00 s",
        "Track2:TrackLayer" => 0,
        "Track2:TrackVolume" => "100.00%",
        "Track2:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track2:MediaHeaderVersion" => 0,
        "Track2:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track2:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track2:MediaTimeScale" => 48_000,
        "Track2:MediaDuration" => "1.00 s",
        "Track2:MediaLanguageCode" => "und",
        "Track2:HandlerType" => "Audio Track",
        "Track2:HandlerDescription" => "Vireo Ears v2.6.2",
        "Track2:Balance" => 0,
        "Track2:AudioFormat" => "mp4a",
        "Track2:AudioChannels" => 2,
        "Track2:AudioBitsPerSample" => 16,
        "Track2:AudioSampleRate" => 48_000,
        "Track2:BufferSize" => 0,
        "Track2:MaxBitrate" => 128_787,
        "Track2:AverageBitrate" => 128_787,
        "ItemList:Encoder" => "Lavf58.76.100",
        "Composite:AvgBitrate" => "422 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "isom",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 10,
        "FFmpeg:VideoCodec" => "h264",
        "FFmpeg:VideoProfile" => "High",
        "FFmpeg:VideoBitRate" => 291_624,
        "FFmpeg:AudioCodec" => "mp3",
        "FFmpeg:AudioLayout" => "stereo",
        "FFmpeg:AudioBitRate" => 131_744,
        "FFmpeg:AudioPeakLoudness" => 0.12589254117941673,
        "FFmpeg:AudioAverageLoudness" => 0.018197008586099843,
        "FFmpeg:AudioLoudnessRange" => 0.0,
        "FFmpeg:AudioSilencePercentage" => 0.7545329341317365,
      }, file.metadata.to_h)
    end
  end

  context "an MP4 with an Opus audio track" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-audio-opus.mp4")

      assert_equal(1280, file.width)
      assert_equal(720, file.height)
      assert_equal(44_677, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("469c1c65bbf2c38fceade19e1f0cbcab", file.md5)
      assert_equal("469c1c65bbf2c38fceade19e1f0cbcab", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(1.002667, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(9.973400939693837, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 Base Media v1 [IS0 14496-12:2003]",
        "QuickTime:MinorVersion" => "0.2.0",
        "QuickTime:CompatibleBrands" => ["isom", "iso2", "avc1", "mp41"],
        "QuickTime:MediaDataSize" => 42_849,
        "QuickTime:MediaDataOffset" => 48,
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "0000:00:00 00:00:00",
        "QuickTime:ModifyDate" => "0000:00:00 00:00:00",
        "QuickTime:TimeScale" => 1000,
        "QuickTime:Duration" => "1.00 s",
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
        "QuickTime:HandlerType" => "Metadata",
        "QuickTime:HandlerVendorID" => "Apple",
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "1.00 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 1280,
        "Track1:ImageHeight" => 720,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track1:MediaTimeScale" => 90_000,
        "Track1:MediaDuration" => "1.00 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "Vireo Eyes v2.6.2",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "avc1",
        "Track1:SourceImageWidth" => 1280,
        "Track1:SourceImageHeight" => 720,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:BitDepth" => 24,
        "Track1:BufferSize" => 0,
        "Track1:MaxBitrate" => 291_624,
        "Track1:AverageBitrate" => 291_624,
        "Track1:VideoFrameRate" => 10,
        "Track2:TrackHeaderVersion" => 0,
        "Track2:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track2:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track2:TrackID" => 2,
        "Track2:TrackDuration" => "1.00 s",
        "Track2:TrackLayer" => 0,
        "Track2:TrackVolume" => "100.00%",
        "Track2:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track2:MediaHeaderVersion" => 0,
        "Track2:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track2:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track2:MediaTimeScale" => 48_000,
        "Track2:MediaDuration" => "1.00 s",
        "Track2:MediaLanguageCode" => "und",
        "Track2:HandlerType" => "Audio Track",
        "Track2:HandlerDescription" => "Vireo Ears v2.6.2",
        "Track2:Balance" => 0,
        "Track2:AudioFormat" => "Opus",
        "Track2:AudioChannels" => 2,
        "Track2:AudioBitsPerSample" => 16,
        "Track2:AudioSampleRate" => 48_000,
        "Track2:BufferSize" => 0,
        "Track2:MaxBitrate" => 96_000,
        "Track2:AverageBitrate" => 50_703,
        "ItemList:Encoder" => "Lavf58.76.100",
        "Composite:AvgBitrate" => "342 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "isom",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 10,
        "FFmpeg:VideoCodec" => "h264",
        "FFmpeg:VideoProfile" => "High",
        "FFmpeg:VideoBitRate" => 291_624,
        "FFmpeg:AudioCodec" => "opus",
        "FFmpeg:AudioLayout" => "stereo",
        "FFmpeg:AudioBitRate" => 51_031,
        "FFmpeg:AudioPeakLoudness" => 0.1273503081016662,
        "FFmpeg:AudioAverageLoudness" => 0.018620871366628676,
        "FFmpeg:AudioLoudnessRange" => 0.0,
        "FFmpeg:AudioSilencePercentage" => 0.756108458740539,
      }, file.metadata.to_h)
    end
  end

  context "an MP4 with a Vorbis audio track" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-audio-vorbis.mp4")

      assert_equal(1280, file.width)
      assert_equal(720, file.height)
      assert_equal(44_075, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("1a4ba2727030e7f9fb86e48ca586cb13", file.md5)
      assert_equal("1a4ba2727030e7f9fb86e48ca586cb13", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(1.002667, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(9.973400939693837, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 Base Media v1 [IS0 14496-12:2003]",
        "QuickTime:MinorVersion" => "0.2.0",
        "QuickTime:CompatibleBrands" => ["isom", "iso2", "avc1", "mp41"],
        "QuickTime:MediaDataSize" => 38_208,
        "QuickTime:MediaDataOffset" => 48,
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "0000:00:00 00:00:00",
        "QuickTime:ModifyDate" => "0000:00:00 00:00:00",
        "QuickTime:TimeScale" => 1000,
        "QuickTime:Duration" => "1.00 s",
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
        "QuickTime:HandlerType" => "Metadata",
        "QuickTime:HandlerVendorID" => "Apple",
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "1.00 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 1280,
        "Track1:ImageHeight" => 720,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track1:MediaTimeScale" => 90_000,
        "Track1:MediaDuration" => "1.00 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "Vireo Eyes v2.6.2",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "avc1",
        "Track1:SourceImageWidth" => 1280,
        "Track1:SourceImageHeight" => 720,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:BitDepth" => 24,
        "Track1:BufferSize" => 0,
        "Track1:MaxBitrate" => 291_624,
        "Track1:AverageBitrate" => 291_624,
        "Track1:VideoFrameRate" => 10,
        "Track2:TrackHeaderVersion" => 0,
        "Track2:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track2:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track2:TrackID" => 2,
        "Track2:TrackDuration" => "1.00 s",
        "Track2:TrackLayer" => 0,
        "Track2:TrackVolume" => "100.00%",
        "Track2:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track2:MediaHeaderVersion" => 0,
        "Track2:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track2:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track2:MediaTimeScale" => 48_000,
        "Track2:MediaDuration" => "1.00 s",
        "Track2:MediaLanguageCode" => "und",
        "Track2:HandlerType" => "Audio Track",
        "Track2:HandlerDescription" => "Vireo Ears v2.6.2",
        "Track2:Balance" => 0,
        "Track2:AudioFormat" => "mp4a",
        "Track2:AudioChannels" => 2,
        "Track2:AudioBitsPerSample" => 16,
        "Track2:AudioSampleRate" => 48_000,
        "Track2:BufferSize" => 0,
        "Track2:MaxBitrate" => 13_965,
        "Track2:AverageBitrate" => 13_965,
        "ItemList:Encoder" => "Lavf58.76.100",
        "Composite:AvgBitrate" => "305 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "isom",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 10,
        "FFmpeg:VideoCodec" => "h264",
        "FFmpeg:VideoProfile" => "High",
        "FFmpeg:VideoBitRate" => 291_624,
        "FFmpeg:AudioCodec" => "vorbis",
        "FFmpeg:AudioLayout" => "stereo",
        "FFmpeg:AudioBitRate" => 14_002,
        "FFmpeg:AudioPeakLoudness" => 0.13182567385564067,
        "FFmpeg:AudioAverageLoudness" => 0.018407720014689554,
        "FFmpeg:AudioLoudnessRange" => 0.0,
        "FFmpeg:AudioSilencePercentage" => 0.7561912379683384,
      }, file.metadata.to_h)
    end
  end

  context "an M4V file with an AAC audio track" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-audio.m4v")

      assert_equal(1280, file.width)
      assert_equal(720, file.height)
      assert_equal(54_324, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("306ab6be039b95ff25dfe666bffa6d62", file.md5)
      assert_equal("306ab6be039b95ff25dfe666bffa6d62", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(1.002667, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(9.973400939693837, file.frame_rate)
      assert_equal({
        "File:FileType" => "M4V",
        "QuickTime:MajorBrand" => "Apple iTunes Video (.M4V) Video",
        "QuickTime:MinorVersion" => "0.2.0",
        "QuickTime:CompatibleBrands" => ["isom", "iso2", "avc1"],
        "QuickTime:MediaDataSize" => 52_496,
        "QuickTime:MediaDataOffset" => 44,
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "0000:00:00 00:00:00",
        "QuickTime:ModifyDate" => "0000:00:00 00:00:00",
        "QuickTime:TimeScale" => 1000,
        "QuickTime:Duration" => "1.00 s",
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
        "QuickTime:HandlerType" => "Metadata",
        "QuickTime:HandlerVendorID" => "Apple",
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "1.00 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 1280,
        "Track1:ImageHeight" => 720,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track1:MediaTimeScale" => 90_000,
        "Track1:MediaDuration" => "1.00 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "Vireo Eyes v2.6.2",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "avc1",
        "Track1:SourceImageWidth" => 1280,
        "Track1:SourceImageHeight" => 720,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:BitDepth" => 24,
        "Track1:VideoFrameRate" => 10,
        "Track2:TrackHeaderVersion" => 0,
        "Track2:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track2:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track2:TrackID" => 2,
        "Track2:TrackDuration" => "1.00 s",
        "Track2:TrackLayer" => 0,
        "Track2:TrackVolume" => "100.00%",
        "Track2:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track2:MediaHeaderVersion" => 0,
        "Track2:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track2:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track2:MediaTimeScale" => 48_000,
        "Track2:MediaDuration" => "1.00 s",
        "Track2:MediaLanguageCode" => "und",
        "Track2:HandlerType" => "Audio Track",
        "Track2:HandlerDescription" => "Vireo Ears v2.6.2",
        "Track2:Balance" => 0,
        "Track2:AudioFormat" => "mp4a",
        "Track2:AudioChannels" => 2,
        "Track2:AudioBitsPerSample" => 16,
        "Track2:AudioSampleRate" => 48_000,
        "ItemList:Encoder" => "Lavf58.29.100",
        "Composite:AvgBitrate" => "419 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "M4V ",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 10,
        "FFmpeg:VideoCodec" => "h264",
        "FFmpeg:VideoProfile" => "High",
        "FFmpeg:VideoBitRate" => 291_624,
        "FFmpeg:AudioCodec" => "aac",
        "FFmpeg:AudioProfile" => "LC",
        "FFmpeg:AudioLayout" => "stereo",
        "FFmpeg:AudioBitRate" => 128_002,
        "FFmpeg:AudioPeakLoudness" => 0.13182567385564067,
        "FFmpeg:AudioAverageLoudness" => 0.019275249131909367,
        "FFmpeg:AudioLoudnessRange" => 0.0,
        "FFmpeg:AudioSilencePercentage" => 0.7561912379683384,
      }, file.metadata.to_h)
    end
  end

  context "an MP4 with an AAC audio track" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-audio.mp4")

      assert_equal(1280, file.width)
      assert_equal(720, file.height)
      assert_equal(54_082, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("5e619c2b036bc0cf7a787d2639aa4c61", file.md5)
      assert_equal("5e619c2b036bc0cf7a787d2639aa4c61", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(1.002667, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(9.973400939693837, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 v2 [ISO 14496-14]",
        "QuickTime:MinorVersion" => "0.0.0",
        "QuickTime:CompatibleBrands" => ["mp42", "mp41", "iso4"],
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "2020:12:26 05:49:12",
        "QuickTime:ModifyDate" => "2020:12:26 05:49:12",
        "QuickTime:TimeScale" => 90_000,
        "QuickTime:Duration" => "1.00 s",
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
        "QuickTime:MediaDataSize" => 52_496,
        "QuickTime:MediaDataOffset" => 1586,
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "2020:12:26 05:49:12",
        "Track1:TrackModifyDate" => "2020:12:26 05:49:12",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "1.00 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 1280,
        "Track1:ImageHeight" => 720,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "2020:12:26 05:49:12",
        "Track1:MediaModifyDate" => "2020:12:26 05:49:12",
        "Track1:MediaTimeScale" => 90_000,
        "Track1:MediaDuration" => "1.00 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "Vireo Eyes v2.6.2",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "avc1",
        "Track1:SourceImageWidth" => 1280,
        "Track1:SourceImageHeight" => 720,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:CompressorName" => "AVC Coding",
        "Track1:BitDepth" => 0,
        "Track1:BufferSize" => 25_986,
        "Track1:MaxBitrate" => 291_624,
        "Track1:AverageBitrate" => 291_624,
        "Track1:VideoFrameRate" => 10,
        "Track2:TrackHeaderVersion" => 0,
        "Track2:TrackCreateDate" => "2020:12:26 05:49:12",
        "Track2:TrackModifyDate" => "2020:12:26 05:49:12",
        "Track2:TrackID" => 2,
        "Track2:TrackDuration" => "1.00 s",
        "Track2:TrackLayer" => 0,
        "Track2:TrackVolume" => "100.00%",
        "Track2:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track2:MediaHeaderVersion" => 0,
        "Track2:MediaCreateDate" => "2020:12:26 05:49:12",
        "Track2:MediaModifyDate" => "2020:12:26 05:49:12",
        "Track2:MediaTimeScale" => 48_000,
        "Track2:MediaDuration" => "1.00 s",
        "Track2:MediaLanguageCode" => "und",
        "Track2:HandlerType" => "Audio Track",
        "Track2:HandlerDescription" => "Vireo Ears v2.6.2",
        "Track2:Balance" => 0,
        "Track2:AudioFormat" => "mp4a",
        "Track2:AudioChannels" => 2,
        "Track2:AudioBitsPerSample" => 16,
        "Track2:AudioSampleRate" => 48_000,
        "Composite:AvgBitrate" => "419 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "mp42",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 10,
        "FFmpeg:VideoCodec" => "h264",
        "FFmpeg:VideoProfile" => "High",
        "FFmpeg:VideoBitRate" => 291_624,
        "FFmpeg:AudioCodec" => "aac",
        "FFmpeg:AudioProfile" => "LC",
        "FFmpeg:AudioLayout" => "stereo",
        "FFmpeg:AudioBitRate" => 128_002,
        "FFmpeg:AudioPeakLoudness" => 0.13182567385564067,
        "FFmpeg:AudioAverageLoudness" => 0.019275249131909367,
        "FFmpeg:AudioLoudnessRange" => 0.0,
        "FFmpeg:AudioSilencePercentage" => 0.7561912379683384,
      }, file.metadata.to_h)
    end
  end

  context "a corrupt MP4" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-corrupt.mp4")

      assert_equal(300, file.width)
      assert_equal(300, file.height)
      assert_equal(10_240, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("d03cc2fa224f9f8fd9cdf81487d93ddc", file.md5)
      assert_equal("d03cc2fa224f9f8fd9cdf81487d93ddc", file.pixel_hash)
      assert_equal(true, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(5.7, file.duration)
      assert_equal(0, file.frame_count)
      assert_equal(0.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 v2 [ISO 14496-14]",
        "QuickTime:MinorVersion" => "0.0.0",
        "QuickTime:CompatibleBrands" => ["mp42", "mp41", "isom"],
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "2017:09:27 13:02:06",
        "QuickTime:ModifyDate" => "2017:09:27 13:02:06",
        "QuickTime:TimeScale" => 600,
        "QuickTime:Duration" => "5.70 s",
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
        "QuickTime:MediaDataSize" => 17_815,
        "QuickTime:MediaDataOffset" => 862,
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "2017:09:27 13:02:06",
        "Track1:TrackModifyDate" => "2017:09:27 13:02:06",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "5.70 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 300,
        "Track1:ImageHeight" => 300,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "2017:09:27 13:02:06",
        "Track1:MediaModifyDate" => "2017:09:27 13:02:06",
        "Track1:MediaTimeScale" => 1000,
        "Track1:MediaDuration" => "5.70 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "Twitter v1.0-757770b7c8e9d79a526cdff77e74666386274fdf",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "avc1",
        "Track1:SourceImageWidth" => 300,
        "Track1:SourceImageHeight" => 300,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:CompressorName" => "AVC Coding",
        "Track1:BitDepth" => 0,
        "Track1:VideoFrameRate" => 1.754,
        "ExifTool:Warning" => "Unknown trailer with truncated 'mdat' data (missing 8437 bytes)",
        "Composite:AvgBitrate" => "25 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:Error" => "ffmpeg failed: [h264 @ 0xADDRESS] Invalid NAL unit size (10738 > 8793).\n[h264 @ 0xADDRESS] missing picture in access unit with size 9378\n[h264 @ 0xADDRESS] Error splitting the input into NAL units.\n[h264 @ 0xADDRESS] Invalid NAL unit size (10738 > 8793).\n[h264 @ 0xADDRESS] Error splitting the input into NAL units.",
        "FFmpeg:MajorBrand" => "mp42",
        "FFmpeg:FrameCount" => 0,
        "FFmpeg:VideoCodec" => "h264",
        "FFmpeg:VideoBitRate" => 25_003,
      }, file.metadata.to_h.merge("FFmpeg:Error" => file.metadata["FFmpeg:Error"].gsub(/0x[0-9a-f]+/, "0xADDRESS")))
    end
  end

  context "an iso5-brand h264 MP4" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-iso5.mp4")

      assert_equal(1280, file.width)
      assert_equal(864, file.height)
      assert_equal(58_223, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("0beb4e44da808a22cfa316385f9fe3eb", file.md5)
      assert_equal("0beb4e44da808a22cfa316385f9fe3eb", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(2.09, file.duration)
      assert_equal(26, file.frame_count)
      assert_equal(12.440191387559809, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 Base Media v5",
        "QuickTime:MinorVersion" => "0.2.0",
        "QuickTime:CompatibleBrands" => ["iso6", "mp41"],
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "0000:00:00 00:00:00",
        "QuickTime:ModifyDate" => "0000:00:00 00:00:00",
        "QuickTime:TimeScale" => 100,
        "QuickTime:Duration" => "2.09 s",
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
        "QuickTime:MediaDataSize" => 57_163,
        "QuickTime:MediaDataOffset" => 1060,
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "2.09 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 1280,
        "Track1:ImageHeight" => 864,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track1:MediaTimeScale" => 100,
        "Track1:MediaDuration" => "2.09 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "Twitter-vork muxer",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "avc1",
        "Track1:SourceImageWidth" => 1280,
        "Track1:SourceImageHeight" => 864,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:BitDepth" => 24,
        "Track1:PixelAspectRatio" => "1:1",
        "Track1:VideoFrameRate" => 12.44,
        "Composite:AvgBitrate" => "219 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "iso5",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 26,
        "FFmpeg:VideoCodec" => "h264",
        "FFmpeg:VideoProfile" => "Main",
        "FFmpeg:VideoBitRate" => 218_805,
      }, file.metadata.to_h)
    end
  end

  context "an MP4 with a silent AAC audio track" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-silent-audio.mp4")

      assert_equal(300, file.width)
      assert_equal(300, file.height)
      assert_equal(22_001, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("f89115e8f35bef2028155312c51964f8", file.md5)
      assert_equal("f89115e8f35bef2028155312c51964f8", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(5.735011, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(1.7436758185816905, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 Base Media v1 [IS0 14496-12:2003]",
        "QuickTime:MinorVersion" => "0.2.0",
        "QuickTime:CompatibleBrands" => ["isom", "iso2", "avc1", "mp41"],
        "QuickTime:MediaDataSize" => 19_321,
        "QuickTime:MediaDataOffset" => 48,
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "0000:00:00 00:00:00",
        "QuickTime:ModifyDate" => "0000:00:00 00:00:00",
        "QuickTime:TimeScale" => 1000,
        "QuickTime:Duration" => "5.74 s",
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
        "QuickTime:HandlerType" => "Metadata",
        "QuickTime:HandlerVendorID" => "Apple",
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "5.70 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 300,
        "Track1:ImageHeight" => 300,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track1:MediaTimeScale" => 16_000,
        "Track1:MediaDuration" => "5.70 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "Twitter v1.0-757770b7c8e9d79a526cdff77e74666386274fdf",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "avc1",
        "Track1:SourceImageWidth" => 300,
        "Track1:SourceImageHeight" => 300,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:BitDepth" => 24,
        "Track1:BufferSize" => 0,
        "Track1:MaxBitrate" => 25_003,
        "Track1:AverageBitrate" => 25_003,
        "Track1:VideoFrameRate" => 1.754,
        "Track2:TrackHeaderVersion" => 0,
        "Track2:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track2:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track2:TrackID" => 2,
        "Track2:TrackDuration" => "5.74 s",
        "Track2:TrackLayer" => 0,
        "Track2:TrackVolume" => "100.00%",
        "Track2:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track2:MediaHeaderVersion" => 0,
        "Track2:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track2:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track2:MediaTimeScale" => 44_100,
        "Track2:MediaDuration" => "5.74 s",
        "Track2:MediaLanguageCode" => "und",
        "Track2:HandlerType" => "Audio Track",
        "Track2:HandlerDescription" => "SoundHandler",
        "Track2:Balance" => 0,
        "Track2:AudioFormat" => "mp4a",
        "Track2:AudioChannels" => 2,
        "Track2:AudioBitsPerSample" => 16,
        "Track2:AudioSampleRate" => 44_100,
        "Track2:BufferSize" => 0,
        "Track2:MaxBitrate" => 128_000,
        "Track2:AverageBitrate" => 2092,
        "ItemList:Encoder" => "Lavf58.76.100",
        "Composite:AvgBitrate" => "26.9 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "isom",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 10,
        "FFmpeg:VideoCodec" => "h264",
        "FFmpeg:VideoProfile" => "Constrained Baseline",
        "FFmpeg:VideoBitRate" => 25_003,
        "FFmpeg:AudioCodec" => "aac",
        "FFmpeg:AudioProfile" => "LC",
        "FFmpeg:AudioLayout" => "stereo",
        "FFmpeg:AudioBitRate" => 2100,
        "FFmpeg:AudioPeakLoudness" => 1.0e-50,
        "FFmpeg:AudioAverageLoudness" => 0.00031622776601683794,
        "FFmpeg:AudioLoudnessRange" => 0.0,
        "FFmpeg:AudioSilencePercentage" => 1.0,
      }, file.metadata.to_h)
    end
  end

  context "a 10-bit av1 MP4" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-yuv420p10le-av1.mp4")

      assert_equal(720, file.width)
      assert_equal(480, file.height)
      assert_equal(6022, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("9def4b3931a1d63ea8708c285033fff6", file.md5)
      assert_equal("9def4b3931a1d63ea8708c285033fff6", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(10.0, file.duration)
      assert_equal(50, file.frame_count)
      assert_equal(5.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 Base Media v1 [IS0 14496-12:2003]",
        "QuickTime:MinorVersion" => "0.2.0",
        "QuickTime:CompatibleBrands" => ["isom", "av01", "iso2", "mp41"],
        "QuickTime:MediaDataSize" => 4998,
        "QuickTime:MediaDataOffset" => 48,
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "0000:00:00 00:00:00",
        "QuickTime:ModifyDate" => "0000:00:00 00:00:00",
        "QuickTime:TimeScale" => 1000,
        "QuickTime:Duration" => "10.00 s",
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
        "QuickTime:HandlerType" => "Metadata",
        "QuickTime:HandlerVendorID" => "Apple",
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "10.00 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 720,
        "Track1:ImageHeight" => 480,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track1:MediaTimeScale" => 10_240,
        "Track1:MediaDuration" => "10.00 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "VideoHandler",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "av01",
        "Track1:SourceImageWidth" => 720,
        "Track1:SourceImageHeight" => 480,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:BitDepth" => 24,
        "Track1:VideoFieldOrder" => "Progressive; 0",
        "Track1:BufferSize" => 0,
        "Track1:MaxBitrate" => 3998,
        "Track1:AverageBitrate" => 3998,
        "Track1:VideoFrameRate" => 5,
        "ItemList:Encoder" => "Lavf58.76.100",
        "Composite:AvgBitrate" => "4 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "isom",
        "FFmpeg:PixFmt" => "yuv420p10le",
        "FFmpeg:FrameCount" => 50,
        "FFmpeg:VideoCodec" => "av1",
        "FFmpeg:VideoProfile" => "Main",
        "FFmpeg:VideoBitRate" => 3998,
      }, file.metadata.to_h)
    end
  end

  context "a 10-bit h264 MP4" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-yuv420p10le-h264.mp4")

      assert_equal(720, file.width)
      assert_equal(480, file.height)
      assert_equal(8718, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("dca6c8c7c62edf35c8df9b092376414e", file.md5)
      assert_equal("dca6c8c7c62edf35c8df9b092376414e", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(10.0, file.duration)
      assert_equal(50, file.frame_count)
      assert_equal(5.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 Base Media v1 [IS0 14496-12:2003]",
        "QuickTime:MinorVersion" => "0.2.0",
        "QuickTime:CompatibleBrands" => ["isom", "iso2", "avc1", "mp41"],
        "QuickTime:MediaDataSize" => 7260,
        "QuickTime:MediaDataOffset" => 48,
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "0000:00:00 00:00:00",
        "QuickTime:ModifyDate" => "0000:00:00 00:00:00",
        "QuickTime:TimeScale" => 1000,
        "QuickTime:Duration" => "10.00 s",
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
        "QuickTime:HandlerType" => "Metadata",
        "QuickTime:HandlerVendorID" => "Apple",
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "10.00 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 720,
        "Track1:ImageHeight" => 480,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track1:MediaTimeScale" => 10_240,
        "Track1:MediaDuration" => "10.00 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "VideoHandler",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "avc1",
        "Track1:SourceImageWidth" => 720,
        "Track1:SourceImageHeight" => 480,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:BitDepth" => 24,
        "Track1:BufferSize" => 0,
        "Track1:MaxBitrate" => 5808,
        "Track1:AverageBitrate" => 5808,
        "Track1:VideoFrameRate" => 5,
        "ItemList:Encoder" => "Lavf58.76.100",
        "Composite:AvgBitrate" => "5.81 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "isom",
        "FFmpeg:PixFmt" => "yuv420p10le",
        "FFmpeg:FrameCount" => 50,
        "FFmpeg:VideoCodec" => "h264",
        "FFmpeg:VideoProfile" => "High 10",
        "FFmpeg:VideoBitRate" => 5808,
      }, file.metadata.to_h)
    end
  end

  context "a 10-bit vp9 MP4" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mp4/test-yuv420p10le-vp9.mp4")

      assert_equal(720, file.width)
      assert_equal(480, file.height)
      assert_equal(7184, file.file_size)
      assert_equal(:mp4, file.file_ext)
      assert_equal("video/mp4", file.mime_type)
      assert_equal("5ba5fdadcb5b31dcb7296dea16903e61", file.md5)
      assert_equal("5ba5fdadcb5b31dcb7296dea16903e61", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(10.0, file.duration)
      assert_equal(50, file.frame_count)
      assert_equal(5.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "MP4",
        "QuickTime:MajorBrand" => "MP4 Base Media v1 [IS0 14496-12:2003]",
        "QuickTime:MinorVersion" => "0.2.0",
        "QuickTime:CompatibleBrands" => ["isom", "iso2", "mp41"],
        "QuickTime:MediaDataSize" => 6169,
        "QuickTime:MediaDataOffset" => 44,
        "QuickTime:MovieHeaderVersion" => 0,
        "QuickTime:CreateDate" => "0000:00:00 00:00:00",
        "QuickTime:ModifyDate" => "0000:00:00 00:00:00",
        "QuickTime:TimeScale" => 1000,
        "QuickTime:Duration" => "10.00 s",
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
        "QuickTime:HandlerType" => "Metadata",
        "QuickTime:HandlerVendorID" => "Apple",
        "Track1:TrackHeaderVersion" => 0,
        "Track1:TrackCreateDate" => "0000:00:00 00:00:00",
        "Track1:TrackModifyDate" => "0000:00:00 00:00:00",
        "Track1:TrackID" => 1,
        "Track1:TrackDuration" => "10.00 s",
        "Track1:TrackLayer" => 0,
        "Track1:TrackVolume" => "0.00%",
        "Track1:MatrixStructure" => "1 0 0 0 1 0 0 0 1",
        "Track1:ImageWidth" => 720,
        "Track1:ImageHeight" => 480,
        "Track1:MediaHeaderVersion" => 0,
        "Track1:MediaCreateDate" => "0000:00:00 00:00:00",
        "Track1:MediaModifyDate" => "0000:00:00 00:00:00",
        "Track1:MediaTimeScale" => 10_240,
        "Track1:MediaDuration" => "10.00 s",
        "Track1:MediaLanguageCode" => "und",
        "Track1:HandlerType" => "Video Track",
        "Track1:HandlerDescription" => "VideoHandler",
        "Track1:GraphicsMode" => "srcCopy",
        "Track1:OpColor" => "0 0 0",
        "Track1:CompressorID" => "vp09",
        "Track1:SourceImageWidth" => 720,
        "Track1:SourceImageHeight" => 480,
        "Track1:XResolution" => 72,
        "Track1:YResolution" => 72,
        "Track1:BitDepth" => 24,
        "Track1:VideoFieldOrder" => "Progressive; 0",
        "Track1:BufferSize" => 0,
        "Track1:MaxBitrate" => 4935,
        "Track1:AverageBitrate" => 4935,
        "Track1:VideoFrameRate" => 5,
        "ItemList:Encoder" => "Lavf58.76.100",
        "Composite:AvgBitrate" => "4.93 kbps",
        "Composite:Rotation" => 0,
        "FFmpeg:MajorBrand" => "isom",
        "FFmpeg:PixFmt" => "yuv420p10le",
        "FFmpeg:FrameCount" => 50,
        "FFmpeg:VideoCodec" => "vp9",
        "FFmpeg:VideoProfile" => "Profile 2",
        "FFmpeg:VideoBitRate" => 4935,
      }, file.metadata.to_h)
    end
  end
end
