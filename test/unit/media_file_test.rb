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

    should "determine the correct dimensions for a webm file" do
      skip unless MediaFile.videos_enabled?
      assert_equal([512, 512], MediaFile.open("test/files/test-512x512.webm").dimensions)
    end

    should "determine the correct dimensions for a mp4 file" do
      skip unless MediaFile.videos_enabled?
      assert_equal([300, 300], MediaFile.open("test/files/test-300x300.mp4").dimensions)
    end

    should "determine the correct dimensions for a ugoira file" do
      skip unless MediaFile.videos_enabled?
      frame_data = JSON.parse(File.read("test/files/ugoira.json"))
      assert_equal([60, 60], MediaFile.open("test/files/ugoira.zip", frame_data: frame_data).dimensions)
    end

    should "determine the correct dimensions for a flash file" do
      assert_equal([607, 756], MediaFile.open("test/files/compressed.swf").dimensions)
    end

    should "work if called twice" do
      mf = MediaFile.open("test/files/test.jpg")
      assert_equal([500, 335], mf.dimensions)
      assert_equal([500, 335], mf.dimensions)

      mf = MediaFile.open("test/files/compressed.swf")
      assert_equal([607, 756], mf.dimensions)
      assert_equal([607, 756], mf.dimensions)
    end

    should "work for a video if called twice" do
      skip unless MediaFile.videos_enabled?

      mf = MediaFile.open("test/files/test-512x512.webm")
      assert_equal([512, 512], mf.dimensions)
      assert_equal([512, 512], mf.dimensions)

      frame_data = JSON.parse(File.read("test/files/ugoira.json"))
      mf = MediaFile.open("test/files/ugoira.zip", frame_data: frame_data)
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

    should "determine the correct extension for a webm file" do
      assert_equal(:webm, MediaFile.open("test/files/test-512x512.webm").file_ext)
    end

    should "determine the correct extension for a mp4 file" do
      assert_equal(:mp4, MediaFile.open("test/files/test-300x300.mp4").file_ext)
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
    end

    should "generate a preview image for an animated image" do
      skip unless MediaFile.videos_enabled?
      assert_equal([86, 52], MediaFile.open("test/files/test-animated-86x52.gif").preview(150, 150).dimensions)
      assert_equal([150, 105], MediaFile.open("test/files/test-animated-400x281.gif").preview(150, 150).dimensions)
      assert_equal([150, 150], MediaFile.open("test/files/test-animated-256x256.png").preview(150, 150).dimensions)
      assert_equal([150, 150], MediaFile.open("test/files/apng/normal_apng.png").preview(150, 150).dimensions)
    end

    should "generate a preview image for a video" do
      skip unless MediaFile.videos_enabled?
      assert_equal([150, 150], MediaFile.open("test/files/test-512x512.webm").preview(150, 150).dimensions)
      assert_equal([150, 150], MediaFile.open("test/files/test-300x300.mp4").preview(150, 150).dimensions)
    end

    should "be able to fit to width only" do
      assert_equal([400, 268], MediaFile.open("test/files/test.jpg").preview(400, nil).dimensions)
    end
  end

  context "#crop" do
    should "generate a cropped preview image" do
      assert_equal([150, 150], MediaFile.open("test/files/test.jpg").crop(150, 150).dimensions)
      assert_equal([150, 150], MediaFile.open("test/files/test.png").crop(150, 150).dimensions)
      assert_equal([150, 150], MediaFile.open("test/files/test.gif").crop(150, 150).dimensions)
    end

    should "generate a cropped preview image for a video" do
      skip unless MediaFile.videos_enabled?
      assert_equal([150, 150], MediaFile.open("test/files/test-512x512.webm").crop(150, 150).dimensions)
      assert_equal([150, 150], MediaFile.open("test/files/test-300x300.mp4").crop(150, 150).dimensions)
    end
  end

  context "for a ugoira" do
    setup do
      skip unless MediaFile::Ugoira.videos_enabled?
      frame_data = JSON.parse(File.read("test/files/ugoira.json"))
      @ugoira = MediaFile.open("test/files/ugoira.zip", frame_data: frame_data)
    end

    should "generate a preview" do
      assert_equal([60, 60], @ugoira.preview(150, 150).dimensions)
      assert_equal([150, 150], @ugoira.crop(150, 150).dimensions)
    end

    should "convert to a webm" do
      webm = @ugoira.convert
      assert_equal(:webm, webm.file_ext)
      assert_equal([60, 60], webm.dimensions)
    end
  end

  context "for a video" do
    should "detect videos with audio" do
      assert_equal(true, MediaFile.open("test/files/test-audio.mp4").has_audio?)
      assert_equal(false, MediaFile.open("test/files/test-300x300.mp4").has_audio?)
    end
  end

  context "a compressed SWF file" do
    should "get all the metadata" do
      @metadata = MediaFile.open("test/files/compressed.swf").metadata

      assert_equal(true, @metadata["Flash:Compressed"])
      assert_not_equal("Install Compress::Zlib to extract compressed information", @metadata["ExifTool:Warning"])
      assert_equal(6, @metadata.count)
    end
  end

  context "a corrupt GIF" do
    should "still read the metadata" do
      @file = MediaFile.open("test/files/test-corrupt.gif")
      @metadata = @file.metadata

      assert_equal(true, @file.is_corrupt?)
      assert_equal("File format error", @metadata["ExifTool:Error"])
      assert_equal("89a", @metadata["GIF:GIFVersion"])
      assert_equal(6, @metadata.count)
    end
  end

  context "a corrupt PNG" do
    should "still read the metadata" do
      @file = MediaFile.open("test/files/test-corrupt.png")
      @metadata = @file.metadata

      assert_equal(true, @file.is_corrupt?)
      assert_equal("Grayscale", @metadata["PNG:ColorType"])
      assert_equal(6, @metadata.count)
    end
  end

  context "a corrupt JPEG" do
    should "still read the metadata" do
      @file = MediaFile.open("test/files/test-corrupt.jpg")
      @metadata = @file.metadata

      assert_equal(true, @file.is_corrupt?)
      assert_equal(1, @metadata["File:ColorComponents"])
      assert_equal(7, @metadata.count)
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

      assert_equal(3, @preview.channels)
      assert_equal(:srgb, @preview.colorspace)
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
end
