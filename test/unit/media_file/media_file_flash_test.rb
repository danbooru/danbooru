require "test_helper"

class MediaFileFlashTest < ActiveSupport::TestCase
  context "#dimensions" do
    should "determine the correct dimensions for a flash file" do
      assert_equal([608, 757], MediaFile.open("test/files/compressed.swf").dimensions)
    end
  end

  context "#file_ext" do
    should "determine the correct extension for a flash file" do
      assert_equal(:swf, MediaFile.open("test/files/compressed.swf").file_ext)
    end
  end

  context "#pixel_hash" do
    should "return the file's md5 for Flash files" do
      assert_equal("1f9a43dbebb2195a8f7d9e0eede51e4b", MediaFile.pixel_hash("test/files/compressed.swf"))
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
end
