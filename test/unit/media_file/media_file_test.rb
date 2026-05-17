require "test_helper"

class MediaFileTest < ActiveSupport::TestCase
  context "#dimensions" do
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

      frame_delays = JSON.parse(File.read("test/files/ugoira/animation.json")).pluck("delay")
      mf = MediaFile.open("test/files/ugoira/ugoira.zip", frame_delays: frame_delays)
      assert_equal([60, 60], mf.dimensions)
      assert_equal([60, 60], mf.dimensions)
    end
  end

  context "#file_ext" do
    should "not fail for empty files" do
      assert_equal(:bin, MediaFile.open("test/files/test-empty.bin").file_ext)
    end
  end
end
