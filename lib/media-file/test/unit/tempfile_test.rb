require "test_helper"

class MediaFileTempfileTest < ActiveSupport::TestCase
  context "MediaFile::Tempfile" do
    should "delete the tempfile when it is garbage collected" do
      tempfile = MediaFile::Tempfile.new("test")
      path = tempfile.path
      assert(File.exist?(path))

      tempfile = nil
      GC.start
      GC.start

      assert_not(File.exist?(path))
    end
  end

  context "MediaFile::Tempdir" do
    should "delete the tempdir when the block is exited" do
      path = nil

      MediaFile::Tempdir.create(["danbooru-", ".zip"]) do |tempdir|
        path = tempdir.path
        assert(File.exist?(path))
      end

      assert_not(File.exist?(path))
    end

    should "delete the tempdir when it is garbage collected" do
      tempdir = MediaFile::Tempdir.create(["danbooru-", ".zip"])
      path = tempdir.path
      assert(File.exist?(path))

      tempdir = nil
      GC.start
      GC.start

      assert_not(File.exist?(path))
    end
  end
end
