require "test_helper"

class APNGInspectorTest < ActiveSupport::TestCase
  def inspect(filename)
    apng = APNGInspector.new("#{Rails.root}/test/files/apng/#{filename}")
    apng.inspect!
    apng
  end
  context "APNG inspector" do
    should "correctly parse normal APNG file" do
      apng = inspect('normal_apng.png')
      assert_equal(3, apng.frames)
      assert_equal(true, apng.animated?)
      assert_equal(false, apng.corrupted?)
    end

    should "recognize 1-frame APNG as animated" do
      apng = inspect('single_frame.png')
      assert_equal(1, apng.frames)
      assert_equal(true, apng.animated?)
      assert_equal(false, apng.corrupted?)
    end

    should "correctly parse normal PNG file" do
      apng = inspect('not_apng.png')
      assert_equal(false, apng.animated?)
      assert_equal(false, apng.corrupted?)
    end

    should "handle empty file" do
      apng = inspect('empty.png')
      assert_equal(false, apng.animated?)
      assert_equal(true, apng.corrupted?)
    end

    should "handle corrupted files" do
      apng = inspect('iend_missing.png')
      assert_equal(false, apng.animated?)
      assert_equal(true, apng.corrupted?)
      apng = inspect('misaligned_chunks.png')
      assert_equal(false, apng.animated?)
      assert_equal(true, apng.corrupted?)
      apng = inspect('broken.png')
      assert_equal(false, apng.animated?)
      assert_equal(true, apng.corrupted?)
    end

    should "handle incorrect acTL chunk" do
      apng = inspect('actl_wronglen.png')
      assert_equal(false, apng.animated?)
      assert_equal(true, apng.corrupted?)
      apng = inspect('actl_zero_frames.png')
      assert_equal(false, apng.animated?)
      assert_equal(true, apng.corrupted?)
    end

    should "handle non-png files" do
      apng = inspect('jpg.png')
      assert_equal(false, apng.animated?)
      assert_equal(true, apng.corrupted?)
    end
  end
end
