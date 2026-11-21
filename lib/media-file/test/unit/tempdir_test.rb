require "test_helper"

class MediaFileTempdirTest < ActiveSupport::TestCase
  context "MediaFile::Tempdir" do
    should "delete the directory when it's closed" do
      dir = MediaFile::Tempdir.create
      dir.close

      assert_equal(false, File.exist?(dir.path))
    end

    should "only be deleted by the finalizer in the process that created it" do
      dir = MediaFile::Tempdir.create
      finalizer = MediaFile::Tempdir.finalizer(dir.path)

      # A forked process doesn't have the other threads that may still be using the directory.
      other_pid = Process.pid + 1
      Process.stubs(:pid).returns(other_pid)
      finalizer.call
      assert_equal(true, File.exist?(dir.path))

      Process.unstub(:pid)
      finalizer.call
      assert_equal(false, File.exist?(dir.path))
    ensure
      dir&.close
    end
  end
end
