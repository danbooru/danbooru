require "test_helper"

class MediaFileAvifTest < ActiveSupport::TestCase
  context "#dimensions" do
    should "determine the correct dimensions for an AVIF file" do
      assert_equal([2048, 858], MediaFile.open("test/files/avif/hdr_cosmos01000_cicp9-16-9_yuv420_limited_qp40.avif").dimensions)
    end
  end

  context "#file_ext" do
    should "determine the correct extension for an AVIF file" do
      Dir["test/files/avif/*.avif"].each do |file|
        assert_equal(:avif, MediaFile.open(file).file_ext)
      end
    end
  end

  context "#preview" do
    should "generate a preview image for a static image" do
      assert_equal([150, 63], MediaFile.open("test/files/avif/hdr_cosmos01000_cicp9-16-9_yuv420_limited_qp40.avif").preview(150, 150).dimensions)
    end

    should "generate a preview image for an animated image" do
      skip unless MediaFile.videos_enabled?
      assert_equal([150, 113], MediaFile.open("test/files/avif/sequence-with-pitm.avif").preview(150, 150).dimensions)
      assert_equal([150, 84], MediaFile.open("test/files/avif/sequence-without-pitm.avif").preview(150, 150).dimensions)
      assert_equal([150, 150], MediaFile.open("test/files/avif/star-8bpc.avif").preview(150, 150).dimensions)
      assert_equal([150, 113], MediaFile.open("test/files/avif/alpha_video.avif").preview(150, 150).dimensions)
    end
  end

  context "#duration" do
    should "get the correct duration for animated files" do
      assert_equal(1.92, MediaFile.open("test/files/avif/sequence-with-pitm.avif").duration)
      assert_equal(3.962292, MediaFile.open("test/files/avif/sequence-without-pitm.avif").duration)
      assert_equal(0.5,  MediaFile.open("test/files/avif/star-8bpc.avif").duration)
      assert_equal(1.92, MediaFile.open("test/files/avif/alpha_video.avif").duration)

      assert_nil(MediaFile.open("test/files/avif/sequence-with-pitm.avif").vips_duration)
      assert_nil(MediaFile.open("test/files/avif/sequence-without-pitm.avif").vips_duration)
      assert_nil(MediaFile.open("test/files/avif/star-8bpc.avif").vips_duration)
      assert_nil(MediaFile.open("test/files/avif/alpha_video.avif").vips_duration)

      assert_equal(1.92, MediaFile.open("test/files/avif/sequence-with-pitm.avif").ffmpeg_duration)
      assert_equal(3.962292, MediaFile.open("test/files/avif/sequence-without-pitm.avif").ffmpeg_duration)
      assert_equal(0.5,  MediaFile.open("test/files/avif/star-8bpc.avif").ffmpeg_duration)
      assert_equal(1.92, MediaFile.open("test/files/avif/alpha_video.avif").ffmpeg_duration)
    end
  end

  context "#pixel_hash" do
    should "return the file's md5 for animated files" do
      assert_equal("5ad19202d4cd9b0e90587f56ff648c28", MediaFile.pixel_hash("test/files/avif/alpha_video.avif"))
    end

    should "work for normal images" do
      assert_equal("21e8133c81d6e30cec95127973a1793a", MediaFile.pixel_hash("test/files/avif/fox.profile0.8bpc.yuv420.monochrome.avif"))
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
      assert_equal(false, MediaFile.open("test/files/avif/alpha_video.avif").is_supported?)
      assert_equal(false, MediaFile.open("test/files/avif/plum-blossom-small.profile0.8bpc.yuv420.alpha-full.avif").is_supported?)
      assert_equal(false, MediaFile.open("test/files/avif/kimono.mirror-horizontal.avif").is_supported?)
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
      assert_equal(true, MediaFile.open("test/files/avif/sequence-with-pitm-avif-major.avif").is_animated?)
      assert_equal(48, MediaFile.open("test/files/avif/sequence-with-pitm-avif-major.avif").frame_count)
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

  context "a AVIF with an exif orientation flag" do
    should "not rotate the image" do
      @file = MediaFile.open("test/files/avif/Exif6.avif")

      assert_equal([427, 640], @file.dimensions)
      assert_equal([43, 64], @file.preview(64, 64).dimensions)
      assert_equal("2cd7cd5f7f67a786c1b14d60ed7b6c25", @file.pixel_hash)
    end
  end
end
