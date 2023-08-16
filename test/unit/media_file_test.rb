require 'test_helper'

class MediaFileTest < ActiveSupport::TestCase
  context "#dimensions" do
    should "determine the correct dimensions for a jpeg file" do
      assert_equal([500, 335], MediaFile.open("test/files/test.jpg").dimensions)
      assert_equal([668, 996], MediaFile.open("test/files/test-blank.jpg").dimensions)
      assert_equal([529, 600], MediaFile.open("test/files/test-exif-small.jpg").dimensions)
      assert_equal([1356, 911], MediaFile.open("test/files/test-large.jpg").dimensions)
    end

    should "determine the correct dimensions for a png file" do
      assert_equal([768, 1024], MediaFile.open("test/files/test.png").dimensions)
      assert_equal([150, 150], MediaFile.open("test/files/apng/normal_apng.png").dimensions)
      assert_equal([85, 62], MediaFile.open("test/files/alpha.png").dimensions)
    end

    should "determine the correct dimensions for a gif file" do
      assert_equal([400, 400], MediaFile.open("test/files/test.gif").dimensions)
      assert_equal([86, 52], MediaFile.open("test/files/test-animated-86x52.gif").dimensions)
      assert_equal([32, 32], MediaFile.open("test/files/test-static-32x32.gif").dimensions)
    end

    should "determine the correct dimensions for a WebP file" do
      assert_equal([550, 368], MediaFile.open("test/files/webp/fjord.webp").dimensions)
    end

    should "determine the correct dimensions for an AVIF file" do
      assert_equal([2048, 858], MediaFile.open("test/files/avif/hdr_cosmos01000_cicp9-16-9_yuv420_limited_qp40.avif").dimensions)
    end

    should "determine the correct dimensions for a webm file" do
      skip unless MediaFile.videos_enabled?
      assert_equal([512, 512], MediaFile.open("test/files/webm/test-512x512.webm").dimensions)
    end

    should "determine the correct dimensions for a mp4 file" do
      skip unless MediaFile.videos_enabled?
      assert_equal([300, 300], MediaFile.open("test/files/mp4/test-300x300.mp4").dimensions)
    end

    should "determine the correct dimensions for a ugoira file" do
      skip unless MediaFile.videos_enabled?
      frame_delays = JSON.parse(File.read("test/files/ugoira.json")).pluck("delay")
      assert_equal([60, 60], MediaFile.open("test/files/ugoira.zip", frame_delays: frame_delays).dimensions)
    end

    should "determine the correct dimensions for a flash file" do
      assert_equal([608, 757], MediaFile.open("test/files/compressed.swf").dimensions)
    end

    should "work if called twice" do
      mf = MediaFile.open("test/files/test.jpg")
      assert_equal([500, 335], mf.dimensions)
      assert_equal([500, 335], mf.dimensions)

      mf = MediaFile.open("test/files/compressed.swf")
      assert_equal([608, 757], mf.dimensions)
      assert_equal([608, 757], mf.dimensions)
    end

    should "work for a video if called twice" do
      skip unless MediaFile.videos_enabled?

      mf = MediaFile.open("test/files/webm/test-512x512.webm")
      assert_equal([512, 512], mf.dimensions)
      assert_equal([512, 512], mf.dimensions)

      frame_delays = JSON.parse(File.read("test/files/ugoira.json")).pluck("delay")
      mf = MediaFile.open("test/files/ugoira.zip", frame_delays: frame_delays)
      assert_equal([60, 60], mf.dimensions)
      assert_equal([60, 60], mf.dimensions)
    end
  end

  context "#file_ext" do
    should "determine the correct extension for a jpeg file" do
      assert_equal(:jpg, MediaFile.open("test/files/test.jpg").file_ext)
      assert_equal(:jpg, MediaFile.open("test/files/test-blank.jpg").file_ext)
      assert_equal(:jpg, MediaFile.open("test/files/test-exif-small.jpg").file_ext)
      assert_equal(:jpg, MediaFile.open("test/files/test-large.jpg").file_ext)
    end

    should "determine the correct extension for a png file" do
      assert_equal(:png, MediaFile.open("test/files/test.png").file_ext)
      assert_equal(:png, MediaFile.open("test/files/apng/normal_apng.png").file_ext)
      assert_equal(:png, MediaFile.open("test/files/alpha.png").file_ext)
    end

    should "determine the correct extension for a gif file" do
      assert_equal(:gif, MediaFile.open("test/files/test.gif").file_ext)
      assert_equal(:gif, MediaFile.open("test/files/test-animated-86x52.gif").file_ext)
      assert_equal(:gif, MediaFile.open("test/files/test-static-32x32.gif").file_ext)
    end

    should "determine the correct extension for a WebP file" do
      Dir["test/files/webp/*.webp"].each do |file|
        assert_equal(:webp, MediaFile.open(file).file_ext)
      end
    end

    should "determine the correct extension for an AVIF file" do
      Dir["test/files/avif/*.avif"].each do |file|
        assert_equal(:avif, MediaFile.open(file).file_ext)
      end
    end

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

    should "determine the correct extension for a ugoira file" do
      assert_equal(:zip, MediaFile.open("test/files/ugoira.zip").file_ext)
    end

    should "determine the correct extension for a flash file" do
      assert_equal(:swf, MediaFile.open("test/files/compressed.swf").file_ext)
    end

    should "not fail for empty files" do
      assert_equal(:bin, MediaFile.open("test/files/test-empty.bin").file_ext)
    end
  end

  should "determine the correct md5 for a jpeg file" do
    assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76", MediaFile.open("test/files/test.jpg").md5)
  end

  should "determine the correct filesize for a jpeg file" do
    assert_equal(28086, MediaFile.open("test/files/test.jpg").file_size)
  end

  context "#preview" do
    should "generate a preview image for a static image" do
      assert_equal([150, 101], MediaFile.open("test/files/test.jpg").preview(150, 150).dimensions)
      assert_equal([113, 150], MediaFile.open("test/files/test.png").preview(150, 150).dimensions)
      assert_equal([150, 150], MediaFile.open("test/files/test.gif").preview(150, 150).dimensions)
      assert_equal([150, 100], MediaFile.open("test/files/webp/fjord.webp").preview(150, 150).dimensions)
      assert_equal([150, 63], MediaFile.open("test/files/avif/hdr_cosmos01000_cicp9-16-9_yuv420_limited_qp40.avif").preview(150, 150).dimensions)
    end

    should "generate a preview image for an animated image" do
      skip unless MediaFile.videos_enabled?
      assert_equal([86, 52], MediaFile.open("test/files/test-animated-86x52.gif").preview(150, 150).dimensions)
      assert_equal([150, 105], MediaFile.open("test/files/test-animated-400x281.gif").preview(150, 150).dimensions)
      assert_equal([150, 150], MediaFile.open("test/files/test-animated-256x256.png").preview(150, 150).dimensions)
      assert_equal([150, 150], MediaFile.open("test/files/apng/normal_apng.png").preview(150, 150).dimensions)
      # assert_equal([150, 150], MediaFile.open("test/files/webp/nyancat.webp").preview(150, 150).dimensions) # XXX not supported by FFmpeg (https://trac.ffmpeg.org/ticket/4907)
      assert_equal([150, 113], MediaFile.open("test/files/avif/sequence-with-pitm.avif").preview(150, 150).dimensions)
      assert_equal([150, 84], MediaFile.open("test/files/avif/sequence-without-pitm.avif").preview(150, 150).dimensions)
      assert_equal([150, 150], MediaFile.open("test/files/avif/star-8bpc.avif").preview(150, 150).dimensions)
      assert_equal([150, 113], MediaFile.open("test/files/avif/alpha_video.avif").preview(150, 150).dimensions)
    end

    should "generate a preview image for a video" do
      skip unless MediaFile.videos_enabled?

      Dir.glob("test/files/**/*.{webm,mp4}").grep_v(/corrupt/).each do |file|
        assert_equal(:jpg, MediaFile.open(file).preview(150, 150).file_ext)
      end
    end

    should "be able to fit to width only" do
      assert_equal([400, 268], MediaFile.open("test/files/test.jpg").preview(400, nil).dimensions)
    end

    should "generate a thumbnail with the correct colors for a CMYK image with no color profile" do
      assert_equal("7577481a2a688e6e5e9ec901addcf0e3", MediaFile.open("test/files/test-cmyk-no-profile.jpg").preview(180, 180).pixel_hash)
    end
  end

  context "#pixel_hash" do
    should "return the file's md5 for corrupted files" do
      assert_equal(MediaFile.md5("test/files/test-blank.jpg"), MediaFile.pixel_hash("test/files/test-blank.jpg"))
      assert_equal(MediaFile.md5("test/files/test-corrupt.jpg"), MediaFile.pixel_hash("test/files/test-corrupt.jpg"))
      assert_equal(MediaFile.md5("test/files/test-exif-small.jpg"), MediaFile.pixel_hash("test/files/test-exif-small.jpg"))
      assert_equal(MediaFile.md5("test/files/test-large.jpg"), MediaFile.pixel_hash("test/files/test-large.jpg"))
      assert_equal(MediaFile.md5("test/files/test-corrupt.png"), MediaFile.pixel_hash("test/files/test-corrupt.png"))
      assert_equal(MediaFile.md5("test/files/test-corrupt.gif"), MediaFile.pixel_hash("test/files/test-corrupt.gif"))
      assert_equal(MediaFile.md5("test/files/webp/truncated.webp"), MediaFile.pixel_hash("test/files/webp/truncated.webp"))
    end

    should "return the file's md5 for animated files" do
      assert_equal("64872dbdc62b6b02e6fc5f468838f674", MediaFile.pixel_hash("test/files/test-animated-256x256.png"))
      assert_equal("8b18b12d212e08d1773f6fd329b63b15", MediaFile.pixel_hash("test/files/test-animated-inf-fps.png"))
      assert_equal("77d89bda37ea3af09158ed3282f8334f", MediaFile.pixel_hash("test/files/test-animated-86x52.gif"))
      assert_equal("f9961d54b2290c36ad3e54995d9d2dcf", MediaFile.pixel_hash("test/files/webp/nyancat.webp"))
      assert_equal("5ad19202d4cd9b0e90587f56ff648c28", MediaFile.pixel_hash("test/files/avif/alpha_video.avif"))
    end

    should "return the file's md5 for Flash files" do
      assert_equal("1f9a43dbebb2195a8f7d9e0eede51e4b", MediaFile.pixel_hash("test/files/compressed.swf"))
    end

    should "return the file's md5 for Ugoira files" do
      frame_delays = JSON.parse(File.read("test/files/ugoira.json")).pluck("delay")
      ugoira = MediaFile.open("test/files/ugoira.zip", frame_delays: frame_delays)
      assert_equal("0d94800c4b520bf3d8adda08f95d31e2", ugoira.pixel_hash)
    end

    should "return the file's md5 for video files" do
      assert_equal("34dd2489f7aaa9e57eda1b996ff26ff7", MediaFile.pixel_hash("test/files/webm/test-512x512.webm"))
      assert_equal("865c93102cad3e8a893d6aac6b51b0d2", MediaFile.pixel_hash("test/files/mp4/test-300x300.mp4"))
    end

    should "work for normal images" do
      assert_equal("01cb481ec7730b7cfced57ffa5abd196", MediaFile.pixel_hash("test/files/test.jpg"))
      assert_equal("69e64bd6e054757ac6ec67d1da3ad4fc", MediaFile.pixel_hash("test/files/test-cmyk-no-profile.jpg"))
      assert_equal("85e9fde0ba6cc7d4fedf24c71bb6277b", MediaFile.pixel_hash("test/files/test-grey-no-profile.jpg"))
      assert_equal("4d13f4b20edc9b238f760970105c6ce6", MediaFile.pixel_hash("test/files/test-grey-bad-profile.jpg"))
      assert_equal("7bc62a583c0eb07de4fb7fa0dc9e0851", MediaFile.pixel_hash("test/files/test-rotation-90cw.jpg"))
      assert_equal("510aa465afbba3d7d818038b7aa7bb6f", MediaFile.pixel_hash("test/files/test-rotation-180.jpg"))
      assert_equal("ac0220aea5683e3c4ffcb2c7b34078e8", MediaFile.pixel_hash("test/files/test-rotation-270cw.jpg"))
      assert_equal("0365fdfe0e905167c14c67e2bbdf8110", MediaFile.pixel_hash("test/files/test-weird-profile.jpg"))

      assert_equal("5daef1f4d42b97cc5cda14f93867b085", MediaFile.pixel_hash("test/files/alpha.png"))
      assert_equal("d351db38efb2697d355cf89853099539", MediaFile.pixel_hash("test/files/test.png"))
      assert_equal("723bce01fcc6b8444ae362467e8628af", MediaFile.pixel_hash("test/files/test-rotation-90cw.png"))

      assert_equal("446ddbb45f40265e565efbc8229d5eea", MediaFile.pixel_hash("test/files/test.gif"))
      assert_equal("d42cd8553aa008b4ef9bc253ff4f1239", MediaFile.pixel_hash("test/files/test-static-32x32.gif"))

      assert_equal("21e8133c81d6e30cec95127973a1793a", MediaFile.pixel_hash("test/files/avif/fox.profile0.8bpc.yuv420.monochrome.avif"))

      assert_equal("3d9213ea387706db93f0b39247d77573", MediaFile.pixel_hash("test/files/webp/test.webp"))
      assert_equal("fd52591b61fc34192d7c337fa024bf12", MediaFile.pixel_hash("test/files/webp/lossless1.webp"))
      assert_equal("c5c77aff5b4015d3416817d12c2c2377", MediaFile.pixel_hash("test/files/webp/lossy_alpha1.webp"))
      assert_equal("96d0f06ba512efea2de7bda8b5775106", MediaFile.pixel_hash("test/files/webp/Exif2.webp"))
      assert_equal("4811ad7d928dbf069ef991bb3051d7f6", MediaFile.pixel_hash("test/files/webp/Exif6.webp"))
    end

    should "compute the same pixel hash for images with different EXIF metadata" do
      assert_equal("1839af48fab8688cf72653d6ac4b52ab", MediaFile.md5("test/files/dupes/countergirl-baseline.jpg"))
      assert_equal("fa00b3cc4152933bf98692045fc59a6f", MediaFile.md5("test/files/dupes/countergirl-no-exif.jpg"))

      assert_equal("c135caa2229b6d43d06179503f70ed74", MediaFile.pixel_hash("test/files/dupes/countergirl-baseline.jpg"))
      assert_equal("c135caa2229b6d43d06179503f70ed74", MediaFile.pixel_hash("test/files/dupes/countergirl-no-exif.jpg"))
    end

    should "compute the same pixel hash for progressive and baseline encoded JPEGs" do
      assert_equal("1839af48fab8688cf72653d6ac4b52ab", MediaFile.md5("test/files/dupes/countergirl-baseline.jpg"))
      assert_equal("264cb22336ceaddf8bf2b1ba6d472bb0", MediaFile.md5("test/files/dupes/countergirl-progressive.jpg"))

      assert_equal("c135caa2229b6d43d06179503f70ed74", MediaFile.pixel_hash("test/files/dupes/countergirl-baseline.jpg"))
      assert_equal("c135caa2229b6d43d06179503f70ed74", MediaFile.pixel_hash("test/files/dupes/countergirl-progressive.jpg"))
    end

    should "compute the same pixel hash for greyscale and sRGB images" do
      assert_equal("1073acb0a8a59139a687360bf9031c7f", MediaFile.md5("test/files/dupes/countergirl-grey.png"))
      assert_equal("632766b7230cc2844cf36fa14d2bf765", MediaFile.md5("test/files/dupes/countergirl-grey-srgb.png"))

      assert_equal("d007f30f42cb7c5835fb3d0d9c24587e", MediaFile.pixel_hash("test/files/dupes/countergirl-grey.png"))
      assert_equal("d007f30f42cb7c5835fb3d0d9c24587e", MediaFile.pixel_hash("test/files/dupes/countergirl-grey-srgb.png"))
    end

    should "compute the same pixel hash for a color image with an incompatible greyscale color profile" do
      assert_equal("c135caa2229b6d43d06179503f70ed74", MediaFile.pixel_hash("test/files/dupes/countergirl-no-exif.jpg"))
      assert_equal("c135caa2229b6d43d06179503f70ed74", MediaFile.pixel_hash("test/files/dupes/countergirl-rgb-gray.jpg"))
    end

    should "compute the same pixel hash for images with a transparent alpha channel" do
      assert_equal("cc2e12de5c11afad72540c230e9dea37", MediaFile.md5("test/files/dupes/countergirl.gif"))
      assert_equal("af529aa2250b21fcb37b781a246937e5", MediaFile.md5("test/files/dupes/countergirl.png"))
      assert_equal("830eeb693d0f575ac76c92ed223dc3d8", MediaFile.md5("test/files/dupes/countergirl-no-exif.png"))

      assert_equal("2981edc81606af5552b9cd2db0a60a2c", MediaFile.pixel_hash("test/files/dupes/countergirl.gif"))
      assert_equal("2981edc81606af5552b9cd2db0a60a2c", MediaFile.pixel_hash("test/files/dupes/countergirl.png"))
      assert_equal("2981edc81606af5552b9cd2db0a60a2c", MediaFile.pixel_hash("test/files/dupes/countergirl-no-exif.png"))
    end

    should "compute the same pixel hash for images with an opaque alpha channel" do
      assert_equal("a353ab010901216b56a2be2d90fc8bfc", MediaFile.md5("test/files/dupes/countergirl-whitebg-alpha.png"))
      assert_equal("a4b5924967ace4045546def1609e9abc", MediaFile.md5("test/files/dupes/countergirl-whitebg-noalpha.gif"))
      assert_equal("058a5b03b4b22befe3813f4bc901fe1e", MediaFile.md5("test/files/dupes/countergirl-whitebg-noalpha.png"))

      assert_equal("5199b09cccde8a33c3d204413f5450d9", MediaFile.pixel_hash("test/files/dupes/countergirl-whitebg-alpha.png"))
      assert_equal("5199b09cccde8a33c3d204413f5450d9", MediaFile.pixel_hash("test/files/dupes/countergirl-whitebg-noalpha.gif"))
      assert_equal("5199b09cccde8a33c3d204413f5450d9", MediaFile.pixel_hash("test/files/dupes/countergirl-whitebg-noalpha.png"))
    end

    should "compute different pixel hashes for images with the same pixels but with different dimensions" do
      assert_equal("d7fccdb09eb17ed57ee2aaeff165e415", MediaFile.pixel_hash("test/files/dupes/black-100x200.png"))
      assert_equal("c1d32710ce71b7c02a9d943e1113b31f", MediaFile.pixel_hash("test/files/dupes/black-200x100.png"))
    end

    should "compute different pixel hashes for images with the same pixel values but with different embedded color profiles" do
      assert_equal("51b5c7fe125eca4048cd963617df5668", MediaFile.pixel_hash("test/files/dupes/countergirl-srgb.jpg"))
      assert_equal("56092d3fb1e5b803b4f89c039c4e46b4", MediaFile.pixel_hash("test/files/dupes/countergirl-p3.jpg"))
      assert_equal("ddd8706eb76f051d57bdbab45d7347d5", MediaFile.pixel_hash("test/files/dupes/countergirl-prophoto.jpg"))
      assert_equal("92df52d799527a96819e8aa52c16967f", MediaFile.pixel_hash("test/files/dupes/countergirl-adobergb.jpg"))
    end
  end

  context "for a ugoira" do
    setup do
      skip unless MediaFile::Ugoira.videos_enabled?
      frame_delays = JSON.parse(File.read("test/files/ugoira.json")).pluck("delay")
      @ugoira = MediaFile.open("test/files/ugoira.zip", frame_delays: frame_delays)
    end

    should "generate a preview" do
      assert_equal([60, 60], @ugoira.preview(150, 150).dimensions)
    end

    should "get the duration" do
      assert_equal(1.05, @ugoira.duration)
      assert_equal(4.76, @ugoira.frame_rate.round(2))
      assert_equal(5, @ugoira.frame_count)
    end

    should "convert to a webm" do
      webm = @ugoira.convert
      assert_equal(:webm, webm.file_ext)
      assert_equal([60, 60], webm.dimensions)
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
      assert_equal(10/1.002667, file.frame_rate)
      assert_equal(10, file.frame_count)
      assert_equal(10, file.metadata["FFmpeg:FrameCount"])
      assert_equal("mp42", file.metadata["FFmpeg:MajorBrand"])
      assert_equal("yuv420p", file.metadata["FFmpeg:PixFmt"])
      assert_equal("h264", file.metadata["FFmpeg:VideoCodec"])
      assert_equal("High", file.metadata["FFmpeg:VideoProfile"])
      assert_equal(291624, file.metadata["FFmpeg:VideoBitRate"])
      assert_equal("aac", file.metadata["FFmpeg:AudioCodec"])
      assert_equal("LC", file.metadata["FFmpeg:AudioProfile"])
      assert_equal("stereo", file.metadata["FFmpeg:AudioLayout"])
      assert_equal(128002, file.metadata["FFmpeg:AudioBitRate"])
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
      assert_equal(25003, file.metadata["FFmpeg:VideoBitRate"])
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
      assert_equal(25003, file.metadata["FFmpeg:VideoBitRate"])
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
        assert_equal(false, MediaFile.open(file).is_corrupt?)
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
      assert_equal(true, MediaFile.open("test/files/mp4/test-audio-vorbis.mp4").is_supported?)
      assert_equal(true, MediaFile.open("test/files/mp4/test-300x300-invalid-utf8-metadata.mp4").is_supported?)

      assert_equal(false, MediaFile.open("test/files/mp4/test-300x300-h265.mp4").is_supported?)
      assert_equal(false, MediaFile.open("test/files/mp4/test-300x300-av1.mp4").is_supported?)
      assert_equal(false, MediaFile.open("test/files/mp4/test-300x300-yuv444p-h264.mp4").is_supported?)
      assert_equal(false, MediaFile.open("test/files/mp4/test-yuv420p10le-av1.mp4").is_supported?)
      assert_equal(false, MediaFile.open("test/files/mp4/test-yuv420p10le-h264.mp4").is_supported?)
      assert_equal(false, MediaFile.open("test/files/mp4/test-yuv420p10le-vp9.mp4").is_supported?)

      assert_equal(false, MediaFile.open("test/files/mp4/test-audio-ac3.mp4").is_supported?)
      assert_equal(false, MediaFile.open("test/files/mp4/test-audio-mp2.mp4").is_supported?)
    end

    should "not fail during decoding if the video contains invalid UTF-8 characters in the file metadata" do
      assert_not_nil(MediaFile.open("test/files/mp4/test-300x300-invalid-utf8-metadata.mp4").attributes)
    end
  end

  context "for a webm file" do
    should "determine the metadata for a video with audio" do
      file = MediaFile.open("test/files/webm/test-audio.webm")

      assert_equal(1.01, file.duration) # 1.01
      assert_equal(10/1.01, file.frame_rate)
      assert_equal(10, file.frame_count)
      assert_equal(10, file.metadata["FFmpeg:FrameCount"])
      assert_equal("yuv420p", file.metadata["FFmpeg:PixFmt"])
      assert_equal("vp9", file.metadata["FFmpeg:VideoCodec"])
      assert_equal("Profile 0", file.metadata["FFmpeg:VideoProfile"])
      assert_equal(432546, file.metadata["FFmpeg:VideoBitRate"])
      assert_equal("opus", file.metadata["FFmpeg:AudioCodec"])
      assert_equal("stereo", file.metadata["FFmpeg:AudioLayout"])
      assert_equal(50661, file.metadata["FFmpeg:AudioBitRate"])
      assert_equal(0.1274, file.metadata["FFmpeg:AudioPeakLoudness"].round(4))
      assert_equal(0.0186, file.metadata["FFmpeg:AudioAverageLoudness"].round(4))
      assert_equal(0, file.metadata["FFmpeg:AudioLoudnessRange"])
      assert_equal(0.7506, file.metadata["FFmpeg:AudioSilencePercentage"].round(4))
    end

    should "determine the metadata for a video with silent audio" do
      file = MediaFile.open("test/files/webm/test-silent-audio.webm")

      assert_equal(0.501, file.duration)
      assert_equal(10/0.501, file.frame_rate) # 19.96
      assert_equal(10, file.frame_count)
      assert_equal(10, file.metadata["FFmpeg:FrameCount"])
      assert_equal("yuv420p", file.metadata["FFmpeg:PixFmt"])
      assert_equal("vp8", file.metadata["FFmpeg:VideoCodec"])
      assert_equal("0", file.metadata["FFmpeg:VideoProfile"])
      assert_equal(188407, file.metadata["FFmpeg:VideoBitRate"])
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
      assert_equal(10/0.48, file.frame_rate)
      assert_equal(10, file.frame_count)
      assert_equal(10, file.metadata["FFmpeg:FrameCount"])
      assert_equal("yuv420p", file.metadata["FFmpeg:PixFmt"])
      assert_equal("vp8", file.metadata["FFmpeg:VideoCodec"])
      assert_equal("0", file.metadata["FFmpeg:VideoProfile"])
      assert_equal(196650, file.metadata["FFmpeg:VideoBitRate"])
    end

    should "detect supported files" do
      assert_equal(true, MediaFile.open("test/files/webm/test-512x512.webm").is_supported?)
      assert_equal(true, MediaFile.open("test/files/webm/test-gbrp-vp9.webm").is_supported?)

      assert_equal(false, MediaFile.open("test/files/webm/test-512x512.mkv").is_supported?)
      assert_equal(false, MediaFile.open("test/files/webm/test-yuv420p10le-vp9.webm").is_supported?)
    end

    should "handle all supported video types" do
      Dir.glob("test/files/webm/*.{webm,mkv}").each do |file|
        assert_equal(false, MediaFile.open(file).is_corrupt?)
      end
    end
  end

  context "a compressed SWF file" do
    should "get all the metadata" do
      @metadata = MediaFile.open("test/files/compressed.swf").metadata

      assert_equal(true, @metadata["Flash:Compressed"])
      assert_not_equal("Install Compress::Zlib to extract compressed information", @metadata["ExifTool:Warning"])
      assert_equal(9, @metadata.count)
    end
  end

  context "an animated GIF file" do
    should "determine the duration of the animation" do
      file = MediaFile.open("test/files/test-animated-86x52.gif")
      assert_equal(0.4, file.duration)
      assert_equal(10, file.frame_rate)
      assert_equal(4, file.frame_count)
    end
  end

  context "a PNG file" do
    context "that is not animated" do
      should "not be detected as animated" do
        file = MediaFile.open("test/files/apng/not_apng.png")

        assert_equal(false, file.is_corrupt?)
        assert_equal(false, file.is_animated?)
        assert_nil(file.duration)
        assert_nil(file.frame_rate)
        assert_equal(1, file.frame_count)
      end
    end

    context "that is animated" do
      should "be detected as animated" do
        file = MediaFile.open("test/files/apng/normal_apng.png")

        assert_equal(false, file.is_corrupt?)
        assert_equal(true, file.is_animated?)
        assert_equal(2.0, file.duration)
        assert_equal(1.5, file.frame_rate)
        assert_equal(3, file.frame_count)
      end
    end

    context "that is animated but with only one frame" do
      should "not be detected as animated" do
        file = MediaFile.open("test/files/apng/single_frame.png")

        assert_equal(false, file.is_corrupt?)
        assert_equal(false, file.is_animated?)
        assert_nil(file.duration)
        assert_nil(file.frame_rate)
        assert_equal(1, file.frame_count)
      end
    end

    context "that is animated but with an unspecified frame rate" do
      should "have an assumed frame rate of ~6.66 FPS" do
        file = MediaFile.open("test/files/test-animated-inf-fps.png")

        assert_equal(false, file.is_corrupt?)
        assert_equal(true, file.is_animated?)
        assert_equal(0.3, file.duration)
        assert_equal(2, file.frame_count)
        assert_equal(2/0.3, file.frame_rate)
      end
    end

    context "that is animated but malformed" do
      should "be handled correctly" do
        file = MediaFile.open("test/files/apng/iend_missing.png")
        assert_equal(false, file.is_corrupt?)
        assert_equal(true, file.is_animated?)

        file = MediaFile.open("test/files/apng/misaligned_chunks.png")
        assert_equal(true, file.is_corrupt?)
        assert_equal(true, file.is_animated?)

        file = MediaFile.open("test/files/apng/broken.png")
        assert_equal(true, file.is_corrupt?)
        assert_equal(true, file.is_animated?)

        file = MediaFile.open("test/files/apng/actl_wronglen.png")
        assert_equal(false, file.is_corrupt?)
        assert_equal(true, file.is_animated?)

        file = MediaFile.open("test/files/apng/actl_zero_frames.png")
        assert_equal(false, file.is_corrupt?)
        assert_equal(false, file.is_animated?)
        assert_equal(0, file.frame_count)
      end
    end
  end

  context "a WebP file" do
    should "be able to read WebP files" do
      Dir["test/files/webp/*.webp"].each do |file|
        assert_nothing_raised { MediaFile.open(file).attributes }
      end
    end

    should "detect animated files" do
      assert_equal(true, MediaFile.open("test/files/webp/nyancat.webp").is_animated?)
      assert_equal(true, MediaFile.open("test/files/webp/nyancat.webp").is_animated_webp?)
      assert_equal(true, MediaFile.open("test/files/webp/nyancat.webp").metadata.is_animated?)
      assert_equal(false, MediaFile.open("test/files/webp/nyancat.webp").is_supported?)
      assert_equal(12, MediaFile.open("test/files/webp/nyancat.webp").frame_count)
      assert_equal(Float::INFINITY, MediaFile.open("test/files/webp/nyancat.webp").metadata.loop_count)

      # assert_equal(0.84, MediaFile.open("test/files/webp/nyancat.webp").duration)
    end

    should "be able to generate a preview" do
      assert_equal([128, 128], MediaFile.open("test/files/webp/test.webp").preview(180, 180).dimensions)
      assert_equal([176, 180], MediaFile.open("test/files/webp/2_webp_a.webp").preview(180, 180).dimensions)
      assert_equal([176, 180], MediaFile.open("test/files/webp/2_webp_ll.webp").preview(180, 180).dimensions)
      assert_equal([180, 120], MediaFile.open("test/files/webp/Exif2.webp").preview(180, 180).dimensions)
      assert_equal([180, 120], MediaFile.open("test/files/webp/fjord.webp").preview(180, 180).dimensions)
      assert_equal([180,  55], MediaFile.open("test/files/webp/lossless1.webp").preview(180, 180).dimensions)
      assert_equal([180,  55], MediaFile.open("test/files/webp/lossy_alpha1.webp").preview(180, 180).dimensions)
    end

    should "ignore EXIF orientation tags" do
      # XXX It's possible for .webp files to contain the IFD0:Orientation tag, but browsers currently ignore it, so we do too.
      assert_equal(false, MediaFile.open("test/files/webp/Exif2.webp").metadata.is_rotated?)
    end
  end

  context "an AVIF file" do
    should "be able to read AVIF files" do
      Dir["test/files/avif/*.avif"].each do |file|
        assert_nothing_raised { MediaFile.open(file).attributes }
      end
    end

    should "detect supported files" do
      assert_equal(true, MediaFile.open("test/files/avif/paris_icc_exif_xmp.avif").is_supported?)
      assert_equal(true, MediaFile.open("test/files/avif/hdr_cosmos01000_cicp9-16-9_yuv420_limited_qp40.avif").is_supported?)
      assert_equal(true, MediaFile.open("test/files/avif/hdr_cosmos01000_cicp9-16-9_yuv444_full_qp40.avif").is_supported?)
      assert_equal(true, MediaFile.open("test/files/avif/fox.profile0.8bpc.yuv420.monochrome.avif").is_supported?)
      assert_equal(true, MediaFile.open("test/files/avif/tiger_3layer_1res.avif").is_supported?)
    end

    should "detect unsupported files" do
      assert_equal(false, MediaFile.open("test/files/avif/Image grid example.avif").is_supported?)
      assert_equal(false, MediaFile.open("test/files/avif/kimono.crop.avif").is_supported?)
      assert_equal(false, MediaFile.open("test/files/avif/kimono.rotate90.avif").is_supported?)
      assert_equal(false, MediaFile.open("test/files/avif/sequence-with-pitm-avif-major.avif").is_supported?)
      assert_equal(false, MediaFile.open("test/files/avif/sequence-with-pitm.avif").is_supported?)
      assert_equal(false, MediaFile.open("test/files/avif/sequence-without-pitm.avif").is_supported?)
      assert_equal(false, MediaFile.open("test/files/avif/star-8bpc.avif").is_supported?)

      # XXX These should be unsupported, but aren't.
      # assert_equal(false, MediaFile.open("test/files/avif/alpha_video.avif").is_supported?)
      # assert_equal(false, MediaFile.open("test/files/avif/plum-blossom-small-profile0.8bpc.yuv420.alpha-full.avif").is_supported?)
      # assert_equal(false, MediaFile.open("test/files/avif/kimono.mirror-horizontal.avif").is_supported?)
    end

    should "detect animated files" do
      assert_equal(true, MediaFile.open("test/files/avif/sequence-with-pitm.avif").is_animated?)
      assert_equal(true, MediaFile.open("test/files/avif/sequence-without-pitm.avif").is_animated?)
      assert_equal(true, MediaFile.open("test/files/avif/alpha_video.avif").is_animated?)
      assert_equal(true, MediaFile.open("test/files/avif/star-8bpc.avif").is_animated?)

      assert_equal(48, MediaFile.open("test/files/avif/sequence-with-pitm.avif").frame_count)
      assert_equal(95, MediaFile.open("test/files/avif/sequence-without-pitm.avif").frame_count)
      assert_equal(48, MediaFile.open("test/files/avif/alpha_video.avif").frame_count)
      assert_equal(5, MediaFile.open("test/files/avif/star-8bpc.avif").frame_count)
    end

    should "detect static images with an auxiliary image sequence" do
      assert_equal(true, MediaFile.open("test/files/avif/sequence-with-pitm-avif-major.avif").metadata.is_animated_avif?)
      assert_equal(false, MediaFile.open("test/files/avif/sequence-with-pitm-avif-major.avif").is_animated?)
      assert_equal(1, MediaFile.open("test/files/avif/sequence-with-pitm-avif-major.avif").frame_count)
    end

    should "detect rotated images" do
      assert_equal(true, MediaFile.open("test/files/avif/kimono.rotate90.avif").metadata.is_rotated?)
    end

    should "detect monochrome images" do
      assert_equal(true, MediaFile.open("test/files/avif/fox.profile0.8bpc.yuv420.monochrome.avif").metadata.is_greyscale?)
    end

    should "be able to generate a preview" do
      assert_equal([180, 75], MediaFile.open("test/files/avif/hdr_cosmos01000_cicp9-16-9_yuv420_limited_qp40.avif").preview(180, 180).dimensions)
      assert_equal([180, 75], MediaFile.open("test/files/avif/hdr_cosmos01000_cicp9-16-9_yuv444_full_qp40.avif").preview(180, 180).dimensions)
      assert_equal([180, 135], MediaFile.open("test/files/avif/paris_icc_exif_xmp.avif").preview(180, 180).dimensions)
      assert_equal([180, 180], MediaFile.open("test/files/avif/Image grid example.avif").preview(180, 180).dimensions)
      assert_equal([180, 120], MediaFile.open("test/files/avif/fox.profile0.8bpc.yuv420.monochrome.avif").preview(180, 180).dimensions)
      assert_equal([180, 123], MediaFile.open("test/files/avif/tiger_3layer_1res.avif").preview(180, 180).dimensions)
    end
  end

  context "a corrupt GIF" do
    should "still read the metadata" do
      @file = MediaFile.open("test/files/test-corrupt.gif")
      @metadata = @file.metadata

      assert_equal(true, @file.is_corrupt?)
      assert_equal("libvips error", @file.error)
      assert_equal([475, 600], @file.dimensions)
      assert_equal("File format error", @metadata["ExifTool:Error"])
      assert_equal("89a", @metadata["GIF:GIFVersion"])
      assert_equal(10, @metadata.count)
    end

    should "not raise an exception when reading the frame count" do
      @file = MediaFile.open("test/files/gif/corrupt-static.gif")
      @metadata = @file.metadata

      assert_equal(true, @file.is_corrupt?)
      assert_equal("libvips error", @file.error)
      assert_equal(1, @file.frame_count)
      assert_equal([575, 800], @file.dimensions)
      assert_equal("File format error", @metadata["ExifTool:Error"])
      assert_equal("89a", @metadata["GIF:GIFVersion"])
      assert_equal(10, @metadata.count)
      assert_nothing_raised { @file.attributes }
    end
  end

  context "a corrupt PNG" do
    should "still read the metadata" do
      @file = MediaFile.open("test/files/test-corrupt.png")
      @metadata = @file.metadata

      assert_equal(true, @file.is_corrupt?)
      assert_equal("libvips error", @file.error)
      assert_equal("Grayscale", @metadata["PNG:ColorType"])
      assert_equal(10, @metadata.count)
    end
  end

  context "a corrupt JPEG" do
    should "still read the metadata" do
      @file = MediaFile.open("test/files/test-corrupt.jpg")
      @metadata = @file.metadata

      assert_equal(true, @file.is_corrupt?)
      assert_equal("libvips error", @file.error)
      assert_equal(1, @metadata["File:ColorComponents"])
      assert_equal(11, @metadata.count)
    end
  end

  context "a corrupt WEBP" do
    should "still read the metadata" do
      @file = MediaFile.open("test/files/webp/truncated.webp")
      @metadata = @file.metadata

      assert_equal(true, @file.is_corrupt?)
      assert_equal(:webp, @file.file_ext)
      assert_equal("libvips error", @file.error)
      assert_equal([800, 1067], @file.dimensions)
      assert_equal(29, @metadata.count)
    end
  end

  context "a greyscale image without an embedded color profile" do
    should "successfully generate a thumbnail" do
      @image = MediaFile.open("test/files/test-grey-no-profile.jpg")
      @preview = @image.preview(150, 150)

      assert_equal(1, @image.channels)
      assert_equal(:"b-w", @image.colorspace)
      assert_equal([535, 290], @image.dimensions)

      # XXX This will fail on libvips lower than 8.10. Before 8.10 it's 3
      # channel srgb, after 8.10 it's 1 channel greyscale.
      assert_equal(1, @preview.channels)
      assert_equal(:"b-w", @preview.colorspace)
      assert_equal([150, 81], @preview.dimensions)
    end
  end

  context "a CMYK image without an embedded color profile" do
    should "successfully generate a thumbnail" do
      @image = MediaFile.open("test/files/test-cmyk-no-profile.jpg")
      @preview = @image.preview(150, 150)

      assert_equal(4, @image.channels)
      assert_equal(:cmyk, @image.colorspace)
      assert_equal([197, 256], @image.dimensions)

      assert_equal(4, @preview.channels)
      assert_equal(:cmyk, @preview.colorspace)
      assert_equal([115, 150], @preview.dimensions)
    end
  end

  context "an image with a weird embedded color profile" do
    should "successfully generate a thumbnail" do
      @image = MediaFile.open("test/files/test-weird-profile.jpg")
      @preview = @image.preview(150, 150)

      assert_equal(3, @image.channels)
      assert_equal(:srgb, @image.colorspace)
      assert_equal([154, 192], @image.dimensions)

      assert_equal(3, @preview.channels)
      assert_equal(:srgb, @preview.colorspace)
      assert_equal([120, 150], @preview.dimensions)
    end
  end

  context "a large JPEG with an orientation flag" do
    should "read the whole image without `out of order read` errors" do
      @file = MediaFile.open("test/files/test-rotation-270cw-large.jpg")

      assert_equal([1104, 736], @file.dimensions)
      assert_equal([180, 120], @file.preview(180, 180).dimensions)
      assert_nil(@file.error)
      assert_equal("b9f80b26f56c1877b8a7f12b42e76909", @file.md5)
      assert_equal("f4602dd62706f8607b86cec90b51d498", @file.pixel_hash)
    end
  end

  context "a JPEG that is rotated 90 degrees clockwise" do
    should "rotate the image correctly" do
      @file = MediaFile.open("test/files/test-rotation-90cw.jpg")

      assert_equal([96, 128], @file.dimensions)
      assert_equal([48, 64], @file.preview(64, 64).dimensions)
      assert_equal("7bc62a583c0eb07de4fb7fa0dc9e0851", @file.pixel_hash)
    end
  end

  context "a JPEG that is rotated 270 degrees clockwise" do
    should "rotate the image correctly" do
      @file = MediaFile.open("test/files/test-rotation-270cw.jpg")

      assert_equal([100, 66], @file.dimensions)
      assert_equal([50, 33], @file.preview(50, 50).dimensions)
      assert_equal("ac0220aea5683e3c4ffcb2c7b34078e8", @file.pixel_hash)
    end
  end

  context "a JPEG that is rotated 180 degrees" do
    should "rotate the image correctly" do
      @file = MediaFile.open("test/files/test-rotation-180.jpg")

      assert_equal([66, 100], @file.dimensions)
      assert_equal([33, 50], @file.preview(50, 50).dimensions)
      assert_equal("510aa465afbba3d7d818038b7aa7bb6f", @file.pixel_hash)
    end
  end

  context "a PNG with an exif orientation flag" do
    should "not rotate the image" do
      @file = MediaFile.open("test/files/test-rotation-90cw.png")

      assert_equal([128, 96], @file.dimensions)
      assert_equal([64, 48], @file.preview(64, 64).dimensions)
      assert_equal("723bce01fcc6b8444ae362467e8628af", @file.pixel_hash)
    end
  end

  context "a WebP with an exif orientation flag" do
    should "not rotate the image" do
      @file = MediaFile.open("test/files/webp/Exif6.webp")

      assert_equal([427, 640], @file.dimensions)
      assert_equal([43, 64], @file.preview(64, 64).dimensions)
      assert_equal("4811ad7d928dbf069ef991bb3051d7f6", @file.pixel_hash)
    end
  end

  context "a AVIF with an exif orientation flag" do
    should "not rotate the image" do
      @file = MediaFile.open("test/files/avif/Exif6.avif")

      assert_equal([427, 640], @file.dimensions)
      assert_equal([43, 64], @file.preview(64, 64).dimensions)
      assert_equal("2cd7cd5f7f67a786c1b14d60ed7b6c25", @file.pixel_hash)
    end
  end
end
