require "test_helper"

class MediaFileVideoTest < ActiveSupport::TestCase
  context "#dimensions" do
    should "determine the correct dimensions for a webm file" do
      skip unless MediaFile.videos_enabled?
      assert_equal([512, 512], MediaFile.open("test/files/webm/test-512x512.webm").dimensions)
    end

    should "determine the correct dimensions for a mp4 file" do
      skip unless MediaFile.videos_enabled?
      assert_equal([300, 300], MediaFile.open("test/files/mp4/test-300x300.mp4").dimensions)
    end
  end

  context "#file_ext" do
    should "determine the correct extension for a webm file" do
      assert_equal(:webm, MediaFile.open("test/files/webm/test-512x512.webm").file_ext)
    end

    should "determine the correct extension for a mp4 file" do
      assert_equal(:mp4, MediaFile.open("test/files/mp4/test-300x300.mp4").file_ext)
    end

    should "determine the correct extension for a m4v file" do
      assert_equal(:mp4, MediaFile.open("test/files/mp4/test-audio.m4v").file_ext)
    end

    should "determine the correct extension for an iso5 mp4 file" do
      assert_equal(:mp4, MediaFile.open("test/files/mp4/test-iso5.mp4").file_ext)
    end
  end

  context "#preview" do
    should "generate a preview image for a video" do
      skip unless MediaFile.videos_enabled?

      Dir.glob("test/files/**/*.{webm,mp4}").grep_v(/corrupt/).each do |file|
        assert_equal(:jpg, MediaFile.open(file).preview(150, 150).file_ext)
      end
    end
  end

  context "#pixel_hash" do
    should "return the file's md5 for video files" do
      assert_equal("34dd2489f7aaa9e57eda1b996ff26ff7", MediaFile.pixel_hash("test/files/webm/test-512x512.webm"))
      assert_equal("865c93102cad3e8a893d6aac6b51b0d2", MediaFile.pixel_hash("test/files/mp4/test-300x300.mp4"))
    end
  end

  context "for an mp4 file " do
    should "detect videos with audio" do
      assert_equal(true, MediaFile.open("test/files/mp4/test-audio.mp4").has_audio?)
      assert_equal(false, MediaFile.open("test/files/mp4/test-300x300.mp4").has_audio?)
    end

    should "determine the metadata for a video with audio" do
      file = MediaFile.open("test/files/mp4/test-audio.mp4")
      assert_equal(false, file.is_corrupt?)
      assert_equal(1.002667, file.duration)
      assert_equal(10 / 1.002667, file.frame_rate)
      assert_equal(10, file.frame_count)
      assert_equal(10, file.metadata["FFmpeg:FrameCount"])
      assert_equal("mp42", file.metadata["FFmpeg:MajorBrand"])
      assert_equal("yuv420p", file.metadata["FFmpeg:PixFmt"])
      assert_equal("h264", file.metadata["FFmpeg:VideoCodec"])
      assert_equal("High", file.metadata["FFmpeg:VideoProfile"])
      assert_equal(291_624, file.metadata["FFmpeg:VideoBitRate"])
      assert_equal("aac", file.metadata["FFmpeg:AudioCodec"])
      assert_equal("LC", file.metadata["FFmpeg:AudioProfile"])
      assert_equal("stereo", file.metadata["FFmpeg:AudioLayout"])
      assert_equal(128_002, file.metadata["FFmpeg:AudioBitRate"])
      assert_equal(0.1318, file.metadata["FFmpeg:AudioPeakLoudness"].round(4))
      assert_equal(0.0193, file.metadata["FFmpeg:AudioAverageLoudness"].round(4))
      assert_equal(0, file.metadata["FFmpeg:AudioLoudnessRange"])
      assert_equal(0.7562, file.metadata["FFmpeg:AudioSilencePercentage"].round(4))
    end

    should "determine the metadata for a video with silent audio" do
      file = MediaFile.open("test/files/mp4/test-silent-audio.mp4")

      assert_equal(false, file.is_corrupt?)
      assert_equal(5.735011, file.duration)
      assert_equal(1.74, file.frame_rate.round(2))
      assert_equal(10, file.frame_count)
      assert_equal(10, file.metadata["FFmpeg:FrameCount"])
      assert_equal("isom", file.metadata["FFmpeg:MajorBrand"])
      assert_equal("yuv420p", file.metadata["FFmpeg:PixFmt"])
      assert_equal("h264", file.metadata["FFmpeg:VideoCodec"])
      assert_equal("Constrained Baseline", file.metadata["FFmpeg:VideoProfile"])
      assert_equal(25_003, file.metadata["FFmpeg:VideoBitRate"])
      assert_equal("aac", file.metadata["FFmpeg:AudioCodec"])
      assert_equal("LC", file.metadata["FFmpeg:AudioProfile"])
      assert_equal("stereo", file.metadata["FFmpeg:AudioLayout"])
      assert_equal(2100, file.metadata["FFmpeg:AudioBitRate"])
      assert_equal(0, file.metadata["FFmpeg:AudioPeakLoudness"].round(4))
      assert_equal(0.0003, file.metadata["FFmpeg:AudioAverageLoudness"].round(4))
      assert_equal(0, file.metadata["FFmpeg:AudioLoudnessRange"])
      assert_equal(1.0, file.metadata["FFmpeg:AudioSilencePercentage"].round(4))
    end

    should "determine the metadata for a video without audio" do
      file = MediaFile.open("test/files/mp4/test-300x300.mp4")
      assert_equal(false, file.is_corrupt?)
      assert_equal(5.7, file.duration)
      assert_equal(1.75, file.frame_rate.round(2))
      assert_equal(10, file.frame_count)
      assert_equal(10, file.metadata["FFmpeg:FrameCount"])
      assert_equal("mp42", file.metadata["FFmpeg:MajorBrand"])
      assert_equal("yuv420p", file.metadata["FFmpeg:PixFmt"])
      assert_equal("h264", file.metadata["FFmpeg:VideoCodec"])
      assert_equal("Constrained Baseline", file.metadata["FFmpeg:VideoProfile"])
      assert_equal(25_003, file.metadata["FFmpeg:VideoBitRate"])
    end

    should "determine the pixel format of the video" do
      assert_equal("yuv420p", MediaFile.open("test/files/mp4/test-300x300-av1.mp4").pix_fmt)
      assert_equal("yuv420p", MediaFile.open("test/files/mp4/test-300x300-h265.mp4").pix_fmt)
      assert_equal("yuv420p", MediaFile.open("test/files/mp4/test-300x300-vp9.mp4").pix_fmt)
      assert_equal("yuv420p", MediaFile.open("test/files/mp4/test-300x300.mp4").pix_fmt)
      assert_equal("yuv420p", MediaFile.open("test/files/mp4/test-300x300-invalid-utf8-metadata.mp4").pix_fmt)
      assert_equal("yuv420p", MediaFile.open("test/files/mp4/test-audio.m4v").pix_fmt)
      assert_equal("yuv420p", MediaFile.open("test/files/mp4/test-audio.mp4").pix_fmt)
      assert_equal("yuv420p", MediaFile.open("test/files/mp4/test-300x300-iso4.mp4").pix_fmt)
      assert_equal("yuv420p", MediaFile.open("test/files/mp4/test-iso5.mp4").pix_fmt)
      assert_equal("yuv444p", MediaFile.open("test/files/mp4/test-300x300-yuv444p-h264.mp4").pix_fmt)
      assert_equal("yuvj420p", MediaFile.open("test/files/mp4/test-300x300-yuvj420p-h264.mp4").pix_fmt)
      assert_equal("yuv420p10le", MediaFile.open("test/files/mp4/test-yuv420p10le-av1.mp4").pix_fmt)
      assert_equal("yuv420p10le", MediaFile.open("test/files/mp4/test-yuv420p10le-h264.mp4").pix_fmt)
      assert_equal("yuv420p10le", MediaFile.open("test/files/mp4/test-yuv420p10le-vp9.mp4").pix_fmt)
    end

    should "detect corrupt videos" do
      assert_equal(true, MediaFile.open("test/files/mp4/test-corrupt.mp4").is_corrupt?)
    end

    should "handle all supported video types" do
      Dir.glob("test/files/mp4/*.{mp4,m4v}").grep_v(/corrupt/).each do |file|
        MediaFile.open(file) do |media|
          assert_equal(false, media.is_corrupt?, "#{file} #{media.error}")
        end
      end
    end

    should "detect supported files" do
      assert_equal(true, MediaFile.open("test/files/mp4/test-300x300.mp4").is_supported?)
      assert_equal(true, MediaFile.open("test/files/mp4/test-300x300-vp9.mp4").is_supported?)
      assert_equal(true, MediaFile.open("test/files/mp4/test-300x300-yuvj420p-h264.mp4").is_supported?)
      assert_equal(true, MediaFile.open("test/files/mp4/test-300x300-iso4.mp4").is_supported?)
      assert_equal(true, MediaFile.open("test/files/mp4/test-300x300-3gp5.mp4").is_supported?)
      assert_equal(true, MediaFile.open("test/files/mp4/test-audio.mp4").is_supported?)
      assert_equal(true, MediaFile.open("test/files/mp4/test-audio-mp3.mp4").is_supported?)
      assert_equal(true, MediaFile.open("test/files/mp4/test-audio-opus.mp4").is_supported?)
      assert_equal(true, MediaFile.open("test/files/mp4/test-300x300-invalid-utf8-metadata.mp4").is_supported?)
      assert_equal(true, MediaFile.open("test/files/mp4/test-300x300-h265.mp4").is_supported?)
      assert_equal(true, MediaFile.open("test/files/mp4/test-300x300-av1.mp4").is_supported?)

      # assert_equal(true, MediaFile.open("test/files/mp4/test-audio-flac.mp4").is_supported?)

      assert_equal(false, MediaFile.open("test/files/mp4/test-300x300-yuv444p-h264.mp4").is_supported?)
      assert_equal(false, MediaFile.open("test/files/mp4/test-yuv420p10le-av1.mp4").is_supported?)
      assert_equal(false, MediaFile.open("test/files/mp4/test-yuv420p10le-h264.mp4").is_supported?)
      assert_equal(false, MediaFile.open("test/files/mp4/test-yuv420p10le-vp9.mp4").is_supported?)

      assert_equal(false, MediaFile.open("test/files/mp4/test-audio-ac3.mp4").is_supported?)
      assert_equal(false, MediaFile.open("test/files/mp4/test-audio-mp2.mp4").is_supported?)
      assert_equal(false, MediaFile.open("test/files/mp4/test-audio-vorbis.mp4").is_supported?)
    end

    should "not fail during decoding if the video contains invalid UTF-8 characters in the file metadata" do
      assert_not_nil(MediaFile.open("test/files/mp4/test-300x300-invalid-utf8-metadata.mp4").attributes)
    end
  end

  context "for a webm file" do
    should "determine the metadata for a video with audio" do
      file = MediaFile.open("test/files/webm/test-audio.webm")

      assert_equal(1.01, file.duration) # 1.01
      assert_equal(10 / 1.01, file.frame_rate)
      assert_equal(10, file.frame_count)
      assert_equal(10, file.metadata["FFmpeg:FrameCount"])
      assert_equal("yuv420p", file.metadata["FFmpeg:PixFmt"])
      assert_equal("vp9", file.metadata["FFmpeg:VideoCodec"])
      assert_equal("Profile 0", file.metadata["FFmpeg:VideoProfile"])
      assert_equal(432_546, file.metadata["FFmpeg:VideoBitRate"])
      assert_equal("opus", file.metadata["FFmpeg:AudioCodec"])
      assert_equal("stereo", file.metadata["FFmpeg:AudioLayout"])
      assert_equal(50_661, file.metadata["FFmpeg:AudioBitRate"])
      assert_equal(0.1274, file.metadata["FFmpeg:AudioPeakLoudness"].round(4))
      assert_equal(0.0186, file.metadata["FFmpeg:AudioAverageLoudness"].round(4))
      assert_equal(0, file.metadata["FFmpeg:AudioLoudnessRange"])
      assert_equal(0.7506, file.metadata["FFmpeg:AudioSilencePercentage"].round(4))
    end

    should "determine the metadata for a video with silent audio" do
      file = MediaFile.open("test/files/webm/test-silent-audio.webm")

      assert_equal(0.501, file.duration)
      assert_equal(10 / 0.501, file.frame_rate) # 19.96
      assert_equal(10, file.frame_count)
      assert_equal(10, file.metadata["FFmpeg:FrameCount"])
      assert_equal("yuv420p", file.metadata["FFmpeg:PixFmt"])
      assert_equal("vp8", file.metadata["FFmpeg:VideoCodec"])
      assert_equal("0", file.metadata["FFmpeg:VideoProfile"])
      assert_equal(188_407, file.metadata["FFmpeg:VideoBitRate"])
      assert_equal("opus", file.metadata["FFmpeg:AudioCodec"])
      assert_equal("stereo", file.metadata["FFmpeg:AudioLayout"])
      assert_equal(1197, file.metadata["FFmpeg:AudioBitRate"])
      assert_equal(0, file.metadata["FFmpeg:AudioPeakLoudness"].round(4))
      assert_equal(0.0003, file.metadata["FFmpeg:AudioAverageLoudness"].round(4))
      assert_equal(0, file.metadata["FFmpeg:AudioLoudnessRange"])
      assert_equal(0.985, file.metadata["FFmpeg:AudioSilencePercentage"].round(4))
    end

    should "determine the metadata for a video without audio" do
      file = MediaFile.open("test/files/webm/test-512x512.webm")
      assert_equal(0.48, file.duration)
      assert_equal(10 / 0.48, file.frame_rate)
      assert_equal(10, file.frame_count)
      assert_equal(10, file.metadata["FFmpeg:FrameCount"])
      assert_equal("yuv420p", file.metadata["FFmpeg:PixFmt"])
      assert_equal("vp8", file.metadata["FFmpeg:VideoCodec"])
      assert_equal("0", file.metadata["FFmpeg:VideoProfile"])
      assert_equal(196_650, file.metadata["FFmpeg:VideoBitRate"])
    end

    should "detect supported files" do
      assert_equal(true, MediaFile.open("test/files/webm/test-512x512.webm").is_supported?)
      assert_equal(true, MediaFile.open("test/files/webm/test-gbrp-vp9.webm").is_supported?)
      assert_equal(true, MediaFile.open("test/files/webm/test-av1.webm").is_supported?)

      assert_equal(false, MediaFile.open("test/files/webm/test-512x512.mkv").is_supported?)
      assert_equal(false, MediaFile.open("test/files/webm/test-yuv420p10le-vp9.webm").is_supported?)
      assert_equal(false, MediaFile.open("test/files/webm/test-hevc.webm").is_supported?)
      assert_equal(false, MediaFile.open("test/files/webm/test-aac.webm").is_supported?)
    end

    should "handle all supported video types" do
      Dir.glob("test/files/webm/*.{webm,mkv}").each do |file|
        assert_equal(false, MediaFile.open(file).is_corrupt?)
      end
    end
  end
end
