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
      assert_equal([60, 60], MediaFile.open("test/files/valid_ugoira.zip").dimensions)
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

      mf = MediaFile.open("test/files/valid_ugoira.zip")
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
      assert_equal(:zip, MediaFile.open("test/files/valid_ugoira.zip").file_ext)
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
    should "generate a preview image" do
      assert_equal([150, 101], MediaFile.open("test/files/test.jpg").preview(150, 150).dimensions)
      assert_equal([113, 150], MediaFile.open("test/files/test.png").preview(150, 150).dimensions)
      assert_equal([150, 150], MediaFile.open("test/files/test.gif").preview(150, 150).dimensions)
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
end
