require "test_helper"

class MediaFileWebpTest < ActiveSupport::TestCase
  context "#dimensions" do
    should "determine the correct dimensions for a WebP file" do
      assert_equal([550, 368], MediaFile.open("test/files/webp/fjord.webp").dimensions)
    end
  end

  context "#file_ext" do
    should "determine the correct extension for a WebP file" do
      Dir["test/files/webp/*.webp"].each do |file|
        assert_equal(:webp, MediaFile.open(file).file_ext)
      end
    end
  end

  context "#preview" do
    should "generate a preview image for a static image" do
      assert_equal([150, 100], MediaFile.open("test/files/webp/fjord.webp").preview(150, 150).dimensions)
    end

    # XXX Generating a preview for an animated WebP isn't supported by FFmpeg (https://trac.ffmpeg.org/ticket/4907).
    # assert_equal([150, 150], MediaFile.open("test/files/webp/nyancat.webp").preview(150, 150).dimensions)
  end

  context "#duration" do
    should "get the correct duration for animated files" do
      assert_equal(0.84, MediaFile.open("test/files/webp/nyancat.webp").duration)
      assert_equal(0.84, MediaFile.open("test/files/webp/nyancat.webp").vips_duration)
      assert_equal(0.04, MediaFile.open("test/files/webp/nyancat.webp").ffmpeg_duration) # XXX wrong in ffmpeg 7.1
    end
  end

  context "#pixel_hash" do
    should "return the file's md5 for corrupted files" do
      assert_equal(MediaFile.md5("test/files/webp/truncated.webp"), MediaFile.pixel_hash("test/files/webp/truncated.webp"))
    end

    should "return the file's md5 for animated files" do
      assert_equal("f9961d54b2290c36ad3e54995d9d2dcf", MediaFile.pixel_hash("test/files/webp/nyancat.webp"))
    end

    should "work for normal images" do
      assert_equal("3d9213ea387706db93f0b39247d77573", MediaFile.pixel_hash("test/files/webp/test.webp"))
      assert_equal("fd52591b61fc34192d7c337fa024bf12", MediaFile.pixel_hash("test/files/webp/lossless1.webp"))
      assert_equal("c5c77aff5b4015d3416817d12c2c2377", MediaFile.pixel_hash("test/files/webp/lossy_alpha1.webp"))
      assert_equal("96d0f06ba512efea2de7bda8b5775106", MediaFile.pixel_hash("test/files/webp/Exif2.webp"))
      assert_equal("4811ad7d928dbf069ef991bb3051d7f6", MediaFile.pixel_hash("test/files/webp/Exif6.webp"))
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

  context "a WebP with an exif orientation flag" do
    should "not rotate the image" do
      @file = MediaFile.open("test/files/webp/Exif6.webp")

      assert_equal([427, 640], @file.dimensions)
      assert_equal([43, 64], @file.preview(64, 64).dimensions)
      assert_equal("4811ad7d928dbf069ef991bb3051d7f6", @file.pixel_hash)
    end
  end
end
