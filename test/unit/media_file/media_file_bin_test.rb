require "test_helper"

class MediaFileBinTest < ActiveSupport::TestCase
  context "an empty file" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/bin/test-empty.bin")

      assert_equal(0, file.width)
      assert_equal(0, file.height)
      assert_equal(0, file.file_size)
      assert_equal(:bin, file.file_ext)
      assert_equal("application/octet-stream", file.mime_type)
      assert_equal("d41d8cd98f00b204e9800998ecf8427e", file.md5)
      assert_equal("d41d8cd98f00b204e9800998ecf8427e", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "ExifTool:Error" => "File is empty",
      }, file.metadata.to_h)
    end
  end
end
