require "test_helper"

class MediaFileWebmTest < ActiveSupport::TestCase
  context "Previews" do
    should "be generated properly" do
      should_generate_previews(
        "mkv",
        "test/files/mkv/test-512x512.mkv" => [150, 150, "136b63fc719803c2525c74ed5067b6d4"],
      )
    end
  end

  context "an MKV file with an h264 video track" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/mkv/test-512x512.mkv")

      assert_equal(512, file.width)
      assert_equal(512, file.height)
      assert_equal(9148, file.file_size)
      assert_equal(:webm, file.file_ext)
      assert_equal("video/webm", file.mime_type)
      assert_equal("7fc69fa1248d001723d8fd6c8d06d242", file.md5)
      assert_equal("7fc69fa1248d001723d8fd6c8d06d242", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(false, file.is_supported?)
      assert_equal(true, file.is_animated?)
      assert_equal(0.48, file.duration)
      assert_equal(10, file.frame_count)
      assert_equal(20.833333333333336, file.frame_rate)
      assert_equal({
        "File:FileType" => "MKV",
        "Matroska:EBMLVersion" => 1,
        "Matroska:EBMLReadVersion" => 1,
        "Matroska:EBMLMaxIDLength" => 4,
        "Matroska:EBMLMaxSizeLength" => 8,
        "Matroska:DocType" => "matroska",
        "Matroska:DocTypeVersion" => 4,
        "Matroska:DocTypeReadVersion" => 2,
        "Matroska:SeekID" => "0xc53bb6b (Cues)",
        "Matroska:SeekPosition" => 9120,
        "Matroska:CRC-32" => 694_197_395,
        "Matroska:Encoder" => "Lavf58.76.100",
        "Info:CRC-32" => 585_098_764,
        "Info:TimecodeScale" => "1 ms",
        "Info:MuxingApp" => "Lavf58.76.100",
        "Info:WritingApp" => "Lavf58.76.100",
        "Info:SegmentUID" => "63900d05b1ba047fcf90061b903aabc4",
        "Info:Duration" => "0.48 s",
        "Track1:TrackNumber" => 1,
        "Track1:TrackUID" => "303d0389cfbe6557",
        "Track1:TrackLacing" => "No",
        "Track1:TrackLanguage" => "und",
        "Track1:CodecID" => "V_MPEG4/ISO/AVC",
        "Track1:TrackType" => "Video",
        "Track1:VideoFrameRate" => 50,
        "Track1:ImageWidth" => 512,
        "Track1:ImageHeight" => 512,
        "Track1:VideoScanType" => "Progressive",
        "Track1:Matroska_0x15b0" => "U??\u0005U??\u0001",
        "Track1:TagTrackUID" => "303d0389cfbe6557",
        "Track1:Encoder" => "Lavc58.134.100 libx264",
        "Track1:Duration" => "00:00:00.480000000",
        "FFmpeg:PixFmt" => "yuv420p",
        "FFmpeg:FrameCount" => 10,
        "FFmpeg:VideoCodec" => "h264",
        "FFmpeg:VideoProfile" => "High",
        "FFmpeg:VideoBitRate" => 140_333,
      }, file.metadata.to_h)
    end
  end
end
