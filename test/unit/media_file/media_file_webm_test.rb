require "test_helper"

class MediaFileWebmTest < ActiveSupport::TestCase
  context "Previews" do
    should "be generated properly" do
      should_generate_previews(
        "webm",
        "test/files/webm/test-512x512.webm" => [150, 150, "d8472abfc35059d642042ab9206571a7"],
        "test/files/webm/test-aac.webm" => [150, 84, "08be8d772555ee4321bf2adc32ad213a"],
        "test/files/webm/test-audio.webm" => [150, 84, "7b1eb1a0600c0c52f00d1e14bb1d12bd"],
        "test/files/webm/test-av1.webm" => [150, 150, "d1b26385e19709ad1baf514cd889524a"],
        "test/files/webm/test-gbrp-vp9.webm" => [150, 150, "2c2c6f5de44fe9da32cc44d8d8b7f682"],
        "test/files/webm/test-hevc.webm" => [150, 150, "e3a1026bf77c734d781e3403d50f52d1"],
        "test/files/webm/test-silent-audio.webm" => [150, 150, "d8472abfc35059d642042ab9206571a7"],
        "test/files/webm/test-yuv420p10le-vp9.webm" => [150, 100, "1acf79da13ceb3072df62e7151968ecc"],
      )
    end
  end

  context "a vp8 WebM file" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/webm/test-512x512.webm")

      assert_equal(512, file.width)
      assert_equal(512, file.height)
      assert_equal(12_345, file.file_size)
      assert_equal(:webm, file.file_ext)
      assert_equal("video/webm", file.mime_type)
      assert_equal("34dd2489f7aaa9e57eda1b996ff26ff7", file.md5)
      assert_equal("34dd2489f7aaa9e57eda1b996ff26ff7", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(0.48, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(20.833333333333336, file.frame_rate)
      assert_equal({
        "File:FileType" => "WEBM",
        "Matroska:EBMLVersion" => 1,
        "Matroska:EBMLReadVersion" => 1,
        "Matroska:EBMLMaxIDLength" => 4,
        "Matroska:EBMLMaxSizeLength" => 8,
        "Matroska:DocType" => "webm",
        "Matroska:DocTypeVersion" => 2,
        "Matroska:DocTypeReadVersion" => 2,
        "Matroska:SeekID" => "0xc53bb6b (Cues)",
        "Matroska:SeekPosition" => 12_316,
        "Info:TimecodeScale" => "1 ms",
        "Info:MuxingApp" => "Lavf56.16.102",
        "Info:WritingApp" => "Lavf56.16.102",
        "Info:SegmentUID" => "6c3b10b9abab7bacb1f3289196185ac8",
        "Info:Duration" => "0.48 s",
        "Track1:TrackNumber" => 1,
        "Track1:TrackUID" => "01",
        "Track1:TrackLacing" => "No",
        "Track1:TrackLanguage" => "und",
        "Track1:CodecID" => "V_VP8",
        "Track1:TrackType" => "Video",
        "Track1:VideoFrameRate" => 50,
        "Track1:ImageWidth" => 512,
        "Track1:ImageHeight" => 512,
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 10,
        "FFmpeg:VideoCodec" => "vp8",
        "FFmpeg:VideoProfile" => "0",
        "FFmpeg:VideoBitRate" => 196_650,
      }, file.metadata.to_h)
    end
  end

  context "a WebM file with a vp9 video track and an AAC audio track" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/webm/test-aac.webm")

      assert_equal(1280, file.width)
      assert_equal(720, file.height)
      assert_equal(58_943, file.file_size)
      assert_equal(:webm, file.file_ext)
      assert_equal("video/webm", file.mime_type)
      assert_equal("6f6bf9c91a81746558f79d7d767323cd", file.md5)
      assert_equal("6f6bf9c91a81746558f79d7d767323cd", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(1.03, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(9.70873786407767, file.frame_rate)
      assert_equal({
        "File:FileType" => "WEBM",
        "Matroska:EBMLVersion" => 1,
        "Matroska:EBMLReadVersion" => 1,
        "Matroska:EBMLMaxIDLength" => 4,
        "Matroska:EBMLMaxSizeLength" => 8,
        "Matroska:DocType" => "webm",
        "Matroska:DocTypeVersion" => 2,
        "Matroska:DocTypeReadVersion" => 2,
        "Matroska:SeekID" => "0xc53bb6b (Cues)",
        "Matroska:SeekPosition" => 58_921,
        "Matroska:CompatibleBrands" => "mp42mp41iso4",
        "Matroska:MajorBrand" => "mp42",
        "Matroska:MinorVersion" => 0,
        "Info:TimecodeScale" => "1 ms",
        "Info:MuxingApp" => "Lavf",
        "Info:WritingApp" => "Lavf",
        "Info:Duration" => "1.03 s",
        "Track1:TrackNumber" => 1,
        "Track1:TrackUID" => "",
        "Track1:TrackLacing" => "No",
        "Track1:TrackLanguage" => "und",
        "Track1:CodecID" => "V_VP9",
        "Track1:TrackType" => "Video",
        "Track1:VideoFrameRate" => 10,
        "Track1:ImageWidth" => 1280,
        "Track1:ImageHeight" => 720,
        "Track1:VideoScanType" => "Progressive",
        "Track1:Matroska_0x15b0" => "U??\u0001U??\u0001U??\u0002",
        "Track2:TrackNumber" => 2,
        "Track2:TrackUID" => "",
        "Track2:TrackLacing" => "No",
        "Track2:TrackLanguage" => "und",
        "Track2:CodecID" => "A_AAC",
        "Track2:Matroska_0x16aa" => "\u0001E?U",
        "Track2:TrackType" => "Audio",
        "Track2:AudioChannels" => 2,
        "Track2:AudioSampleRate" => 48_000,
        "Track2:AudioBitsPerSample" => 32,
        "Track2:Encoder" => "Lavc libvpx-vp9",
        "Track2:HandlerName" => "Vireo Eyes v2.6.2",
        "Track2:VendorId" => "[0][0][0][0]",
        "Track2:Duration" => "00:00:01.000000000",
        "Track2:TagTrackUID" => "",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 10,
        "FFmpeg:VideoCodec" => "vp9",
        "FFmpeg:VideoProfile" => "Profile 0",
        "FFmpeg:VideoBitRate" => 420_924,
        "FFmpeg:AudioCodec" => "aac",
        "FFmpeg:AudioProfile" => "LC",
        "FFmpeg:AudioLayout" => "stereo",
        "FFmpeg:AudioBitRate" => 27_596,
        "FFmpeg:AudioPeakLoudness" => 0.1273503081016662,
        "FFmpeg:AudioAverageLoudness" => 0.018620871366628676,
        "FFmpeg:AudioLoudnessRange" => 0.0,
        "FFmpeg:AudioSilencePercentage" => 0.7360029126213592,
      }, file.metadata.to_h)
    end
  end

  context "a WebM file with a vp9 video track and an Opus audio track" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/webm/test-audio.webm")

      assert_equal(1280, file.width)
      assert_equal(720, file.height)
      assert_equal(62_428, file.file_size)
      assert_equal(:webm, file.file_ext)
      assert_equal("video/webm", file.mime_type)
      assert_equal("fb5e462a7fcf0331c2537ca74582bfce", file.md5)
      assert_equal("fb5e462a7fcf0331c2537ca74582bfce", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(1.01, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(9.900990099009901, file.frame_rate)
      assert_equal({
        "File:FileType" => "WEBM",
        "Matroska:EBMLVersion" => 1,
        "Matroska:EBMLReadVersion" => 1,
        "Matroska:EBMLMaxIDLength" => 4,
        "Matroska:EBMLMaxSizeLength" => 8,
        "Matroska:DocType" => "webm",
        "Matroska:DocTypeVersion" => 4,
        "Matroska:DocTypeReadVersion" => 2,
        "Matroska:SeekID" => "0xc53bb6b (Cues)",
        "Matroska:SeekPosition" => 62_406,
        "Matroska:MajorBrand" => "mp42",
        "Matroska:MinorVersion" => 0,
        "Matroska:CompatibleBrands" => "mp42mp41iso4",
        "Matroska:Encoder" => "Lavf58.76.100",
        "Info:TimecodeScale" => "1 ms",
        "Info:MuxingApp" => "Lavf58.76.100",
        "Info:WritingApp" => "Lavf58.76.100",
        "Info:Duration" => "1.01 s",
        "Track1:TrackNumber" => 1,
        "Track1:TrackUID" => "e69cabe28b2eebe9",
        "Track1:TrackLacing" => "No",
        "Track1:TrackLanguage" => "und",
        "Track1:CodecID" => "V_VP9",
        "Track1:TrackType" => "Video",
        "Track1:VideoFrameRate" => 10,
        "Track1:ImageWidth" => 1280,
        "Track1:ImageHeight" => 720,
        "Track1:VideoScanType" => "Progressive",
        "Track1:Matroska_0x15b0" => "U??\u0001U??\u0002",
        "Track1:TagTrackUID" => "e69cabe28b2eebe9",
        "Track1:HandlerName" => "Vireo Eyes v2.6.2",
        "Track1:VendorId" => "[0][0][0][0]",
        "Track1:Encoder" => "Lavc58.134.100 libvpx-vp9",
        "Track1:Duration" => "00:00:01.007000000",
        "Track2:TrackNumber" => 2,
        "Track2:TrackUID" => "ea843da9bde1501d",
        "Track2:TrackLacing" => "No",
        "Track2:TrackLanguage" => "und",
        "Track2:CodecID" => "A_OPUS",
        "Track2:Matroska_0x16aa" => "c.?",
        "Track2:Matroska_0x16bb" => "\u0004Ĵ",
        "Track2:TrackType" => "Audio",
        "Track2:AudioChannels" => 2,
        "Track2:AudioSampleRate" => 48_000,
        "Track2:AudioBitsPerSample" => 32,
        "Track2:TagTrackUID" => "ea843da9bde1501d",
        "Track2:HandlerName" => "Vireo Ears v2.6.2",
        "Track2:VendorId" => "[0][0][0][0]",
        "Track2:Encoder" => "Lavc58.134.100 libopus",
        "Track2:Duration" => "00:00:01.010000000",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 10,
        "FFmpeg:VideoCodec" => "vp9",
        "FFmpeg:VideoProfile" => "Profile 0",
        "FFmpeg:VideoBitRate" => 432_546,
        "FFmpeg:AudioCodec" => "opus",
        "FFmpeg:AudioLayout" => "stereo",
        "FFmpeg:AudioBitRate" => 50_661,
        "FFmpeg:AudioPeakLoudness" => 0.1273503081016662,
        "FFmpeg:AudioAverageLoudness" => 0.018620871366628676,
        "FFmpeg:AudioLoudnessRange" => 0.0,
        "FFmpeg:AudioSilencePercentage" => 0.7506188118811882,
      }, file.metadata.to_h)
    end
  end

  context "an av1 WebM file" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/webm/test-av1.webm")

      assert_equal(512, file.width)
      assert_equal(512, file.height)
      assert_equal(4826, file.file_size)
      assert_equal(:webm, file.file_ext)
      assert_equal("video/webm", file.mime_type)
      assert_equal("41fd57d945e65457dc8b182c12262710", file.md5)
      assert_equal("41fd57d945e65457dc8b182c12262710", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(0.48, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(20.833333333333336, file.frame_rate)
      assert_equal({
        "File:FileType" => "WEBM",
        "Matroska:EBMLVersion" => 1,
        "Matroska:EBMLReadVersion" => 1,
        "Matroska:EBMLMaxIDLength" => 4,
        "Matroska:EBMLMaxSizeLength" => 8,
        "Matroska:DocType" => "webm",
        "Matroska:DocTypeVersion" => 2,
        "Matroska:DocTypeReadVersion" => 2,
        "Matroska:SeekID" => "0xc53bb6b (Cues)",
        "Matroska:SeekPosition" => 4804,
        "Info:TimecodeScale" => "1 ms",
        "Info:MuxingApp" => "Lavf",
        "Info:WritingApp" => "Lavf",
        "Info:Duration" => "0.48 s",
        "Track1:TrackNumber" => 1,
        "Track1:TrackUID" => "",
        "Track1:TrackLacing" => "No",
        "Track1:TrackLanguage" => "und",
        "Track1:CodecID" => "V_AV1",
        "Track1:TrackType" => "Video",
        "Track1:VideoFrameRate" => 50,
        "Track1:ImageWidth" => 512,
        "Track1:ImageHeight" => 512,
        "Track1:VideoScanType" => "Progressive",
        "Track1:Matroska_0x15b0" => "U??\u0005U??\u0001",
        "Track1:TagTrackUID" => "",
        "Track1:Encoder" => "Lavc libaom-av1",
        "Track1:Duration" => "00:00:00.480000000",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 10,
        "FFmpeg:VideoCodec" => "av1",
        "FFmpeg:VideoProfile" => "Main",
        "FFmpeg:VideoBitRate" => 63_650,
      }, file.metadata.to_h)
    end
  end

  context "a vp9 WebM file with GBR pixel format" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/webm/test-gbrp-vp9.webm")

      assert_equal(512, file.width)
      assert_equal(512, file.height)
      assert_equal(14_795, file.file_size)
      assert_equal(:webm, file.file_ext)
      assert_equal("video/webm", file.mime_type)
      assert_equal("1bba50d6d331798c22c036b88b954748", file.md5)
      assert_equal("1bba50d6d331798c22c036b88b954748", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(0.48, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(20.833333333333336, file.frame_rate)
      assert_equal({
        "File:FileType" => "WEBM",
        "Matroska:EBMLVersion" => 1,
        "Matroska:EBMLReadVersion" => 1,
        "Matroska:EBMLMaxIDLength" => 4,
        "Matroska:EBMLMaxSizeLength" => 8,
        "Matroska:DocType" => "webm",
        "Matroska:DocTypeVersion" => 2,
        "Matroska:DocTypeReadVersion" => 2,
        "Matroska:SeekID" => "0xc53bb6b (Cues)",
        "Matroska:SeekPosition" => 14_773,
        "Matroska:Encoder" => "Lavf58.76.100",
        "Info:TimecodeScale" => "1 ms",
        "Info:MuxingApp" => "Lavf58.76.100",
        "Info:WritingApp" => "Lavf58.76.100",
        "Info:Duration" => "0.48 s",
        "Track1:TrackNumber" => 1,
        "Track1:TrackUID" => "14fa6ebe3d63c583",
        "Track1:TrackLacing" => "No",
        "Track1:TrackLanguage" => "und",
        "Track1:CodecID" => "V_VP9",
        "Track1:TrackType" => "Video",
        "Track1:VideoFrameRate" => 50,
        "Track1:ImageWidth" => 512,
        "Track1:ImageHeight" => 512,
        "Track1:VideoScanType" => "Progressive",
        "Track1:Matroska_0x15b0" => "U??U??\u0002",
        "Track1:TagTrackUID" => "14fa6ebe3d63c583",
        "Track1:Encoder" => "Lavc58.134.100 libvpx-vp9",
        "Track1:Duration" => "00:00:00.480000000",
        "FFmpeg:PixFmt" => "gbrp",
        "FFmpeg:FrameCount" => 10,
        "FFmpeg:VideoCodec" => "vp9",
        "FFmpeg:VideoProfile" => "Profile 1",
        "FFmpeg:VideoBitRate" => 236_350,
      }, file.metadata.to_h)
    end
  end

  context "an h265/HEVC WebM file" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/webm/test-hevc.webm")

      assert_equal(512, file.width)
      assert_equal(512, file.height)
      assert_equal(8686, file.file_size)
      assert_equal(:webm, file.file_ext)
      assert_equal("video/webm", file.mime_type)
      assert_equal("b9e1352a07667d546d14f6f85db6601e", file.md5)
      assert_equal("b9e1352a07667d546d14f6f85db6601e", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(0.48, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(20.833333333333336, file.frame_rate)
      assert_equal({
        "File:FileType" => "WEBM",
        "Matroska:EBMLVersion" => 1,
        "Matroska:EBMLReadVersion" => 1,
        "Matroska:EBMLMaxIDLength" => 4,
        "Matroska:EBMLMaxSizeLength" => 8,
        "Matroska:DocType" => "webm",
        "Matroska:DocTypeVersion" => 2,
        "Matroska:DocTypeReadVersion" => 2,
        "Matroska:SeekID" => "0xc53bb6b (Cues)",
        "Matroska:SeekPosition" => 8664,
        "Info:TimecodeScale" => "1 ms",
        "Info:MuxingApp" => "Lavf",
        "Info:WritingApp" => "Lavf",
        "Info:Duration" => "0.48 s",
        "Track1:TrackNumber" => 1,
        "Track1:TrackUID" => "",
        "Track1:TrackLacing" => "No",
        "Track1:TrackLanguage" => "und",
        "Track1:CodecID" => "V_MPEGH/ISO/HEVC",
        "Track1:TrackType" => "Video",
        "Track1:VideoFrameRate" => 50,
        "Track1:ImageWidth" => 512,
        "Track1:ImageHeight" => 512,
        "Track1:VideoScanType" => "Progressive",
        "Track1:Matroska_0x15b0" => "U??\u0005U??\u0001",
        "Track1:TagTrackUID" => "",
        "Track1:Encoder" => "Lavc libx265",
        "Track1:Duration" => "00:00:00.480000000",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 10,
        "FFmpeg:VideoCodec" => "hevc",
        "FFmpeg:VideoProfile" => "Main",
        "FFmpeg:VideoBitRate" => 95_800,
      }, file.metadata.to_h)
    end
  end

  context "a WebM file with a silent Opus audio track" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/webm/test-silent-audio.webm")

      assert_equal(512, file.width)
      assert_equal(512, file.height)
      assert_equal(12_786, file.file_size)
      assert_equal(:webm, file.file_ext)
      assert_equal("video/webm", file.mime_type)
      assert_equal("0f97e9a5f9493ac52aad4eee1ba28d8c", file.md5)
      assert_equal("0f97e9a5f9493ac52aad4eee1ba28d8c", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(0.501, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(19.960079840319363, file.frame_rate)
      assert_equal({
        "File:FileType" => "WEBM",
        "Matroska:EBMLVersion" => 1,
        "Matroska:EBMLReadVersion" => 1,
        "Matroska:EBMLMaxIDLength" => 4,
        "Matroska:EBMLMaxSizeLength" => 8,
        "Matroska:DocType" => "webm",
        "Matroska:DocTypeVersion" => 4,
        "Matroska:DocTypeReadVersion" => 2,
        "Matroska:SeekID" => "0xc53bb6b (Cues)",
        "Matroska:SeekPosition" => 12_764,
        "Matroska:Encoder" => "Lavf58.76.100",
        "Info:TimecodeScale" => "1 ms",
        "Info:MuxingApp" => "Lavf58.76.100",
        "Info:WritingApp" => "Lavf58.76.100",
        "Info:Duration" => "0.50 s",
        "Track1:TrackNumber" => 1,
        "Track1:TrackUID" => "4efd50a222543e15",
        "Track1:TrackLacing" => "No",
        "Track1:TrackLanguage" => "und",
        "Track1:CodecID" => "V_VP8",
        "Track1:TrackType" => "Video",
        "Track1:VideoFrameRate" => 50,
        "Track1:ImageWidth" => 512,
        "Track1:ImageHeight" => 512,
        "Track1:VideoScanType" => "Progressive",
        "Track1:TagTrackUID" => "4efd50a222543e15",
        "Track1:Duration" => "00:00:00.487000000",
        "Track2:TrackNumber" => 2,
        "Track2:TrackUID" => "fdb73abc369ba046",
        "Track2:TrackLacing" => "No",
        "Track2:TrackLanguage" => "und",
        "Track2:CodecID" => "A_OPUS",
        "Track2:Matroska_0x16aa" => "c.?",
        "Track2:Matroska_0x16bb" => "\u0004Ĵ",
        "Track2:TrackType" => "Audio",
        "Track2:AudioChannels" => 2,
        "Track2:AudioSampleRate" => 48_000,
        "Track2:AudioBitsPerSample" => 16,
        "Track2:TagTrackUID" => "fdb73abc369ba046",
        "Track2:Encoder" => "Lavc58.134.100 libopus",
        "Track2:Duration" => "00:00:00.501000000",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 10,
        "FFmpeg:VideoCodec" => "vp8",
        "FFmpeg:VideoProfile" => "0",
        "FFmpeg:VideoBitRate" => 188_407,
        "FFmpeg:AudioCodec" => "opus",
        "FFmpeg:AudioLayout" => "stereo",
        "FFmpeg:AudioBitRate" => 1197,
        "FFmpeg:AudioPeakLoudness" => 1.0e-50,
        "FFmpeg:AudioAverageLoudness" => 0.00031622776601683794,
        "FFmpeg:AudioLoudnessRange" => 0.0,
        "FFmpeg:AudioSilencePercentage" => 0.9850299401197604,
      }, file.metadata.to_h)
    end
  end

  context "a 10-bit vp9 WebM file" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/webm/test-yuv420p10le-vp9.webm")

      assert_equal(720, file.width)
      assert_equal(480, file.height)
      assert_equal(7215, file.file_size)
      assert_equal(:webm, file.file_ext)
      assert_equal("video/webm", file.mime_type)
      assert_equal("a5674fdb66d86f1bed8470fc32b8c590", file.md5)
      assert_equal("a5674fdb66d86f1bed8470fc32b8c590", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(10.0, file.duration)
      assert_equal(50, file.frame_count)
      assert_equal(5.0, file.frame_rate)
      assert_equal({
        "File:FileType" => "WEBM",
        "Matroska:EBMLVersion" => 1,
        "Matroska:EBMLReadVersion" => 1,
        "Matroska:EBMLMaxIDLength" => 4,
        "Matroska:EBMLMaxSizeLength" => 8,
        "Matroska:DocType" => "webm",
        "Matroska:DocTypeVersion" => 2,
        "Matroska:DocTypeReadVersion" => 2,
        "Matroska:SeekID" => "0xc53bb6b (Cues)",
        "Matroska:SeekPosition" => 7193,
        "Matroska:MajorBrand" => "isom",
        "Matroska:MinorVersion" => 512,
        "Matroska:CompatibleBrands" => "isomiso2mp41",
        "Matroska:Encoder" => "Lavf58.76.100",
        "Info:TimecodeScale" => "1 ms",
        "Info:MuxingApp" => "Lavf58.76.100",
        "Info:WritingApp" => "Lavf58.76.100",
        "Info:Duration" => "10.00 s",
        "Track1:TrackNumber" => 1,
        "Track1:TrackUID" => "7e18800b4ded454b",
        "Track1:TrackLacing" => "No",
        "Track1:TrackLanguage" => "und",
        "Track1:CodecID" => "V_VP9",
        "Track1:TrackType" => "Video",
        "Track1:VideoFrameRate" => 5,
        "Track1:ImageWidth" => 720,
        "Track1:ImageHeight" => 480,
        "Track1:VideoScanType" => "Progressive",
        "Track1:Matroska_0x15b0" => "U??\u0002U??\u0001U??\u0002",
        "Track1:TagTrackUID" => "7e18800b4ded454b",
        "Track1:HandlerName" => "VideoHandler",
        "Track1:VendorId" => "[0][0][0][0]",
        "Track1:Encoder" => "Lavc58.134.100 libvpx-vp9",
        "Track1:Duration" => "00:00:10.000000000",
        "FFmpeg:PixFmt" => "yuv420p10le",
        "FFmpeg:FrameCount" => 50,
        "FFmpeg:VideoCodec" => "vp9",
        "FFmpeg:VideoProfile" => "Profile 2",
        "FFmpeg:VideoBitRate" => 4935,
      }, file.metadata.to_h)
    end
  end
end
