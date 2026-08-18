require "test_helper"

class MediaFileFlashTest < ActiveSupport::TestCase
  context "Previews" do
    should "be generated properly" do
      should_generate_previews(
        "swf",
        failures: ["test/files/swf/compressed.swf"],
      )
    end
  end

  context "a SWF flash file" do
    should "be parsed correctly" do
      file = MediaFile.open("test/files/swf/compressed.swf")

      assert_equal(608, file.width)
      assert_equal(757, file.height)
      assert_equal(59_429, file.file_size)
      assert_equal(:swf, file.file_ext)
      assert_equal("application/x-shockwave-flash", file.mime_type)
      assert_equal("1f9a43dbebb2195a8f7d9e0eede51e4b", file.md5)
      assert_equal("1f9a43dbebb2195a8f7d9e0eede51e4b", file.pixel_hash)
      assert_equal(false, file.is_corrupt?)
      assert_equal(true, file.is_supported?)
      assert_equal(false, file.is_animated?)
      assert_nil(file.duration)
      assert_nil(file.frame_count)
      assert_nil(file.frame_rate)
      assert_equal({
        "File:FileType" => "SWF",
        "Flash:FlashVersion" => 8,
        "Flash:Compressed" => true,
        "Flash:ImageWidth" => 607.6,
        "Flash:ImageHeight" => 756.6,
        "Flash:FrameRate" => 25,
        "Flash:FrameCount" => 1,
        "Flash:Duration" => "0.04 s",
        "Flash:FlashAttributes" => "(none)",
      }, file.metadata.to_h)
    end
  end
end
