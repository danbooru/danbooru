require "test_helper"

class DanbooruTempfileTest < ActiveSupport::TestCase
  context "Danbooru::Tempfile" do
    should "delete the tempfile when it is garbage collected" do
      tempfile = Danbooru::Tempfile.new("test")
      path = tempfile.path
      assert(File.exist?(path))

      tempfile = nil
      GC.start
      GC.start

      assert_not(File.exist?(path))
    end
  end

  context "Danbooru::Tempdir" do
    should "delete the tempdir when the block is exited" do
      path = nil

      Danbooru::Tempdir.create(["danbooru-", ".zip"]) do |tempdir|
        path = tempdir.path
        assert(File.exist?(path))
      end

      assert_not(File.exist?(path))
    end

    should "delete the tempdir when it is garbage collected" do
      tempdir = Danbooru::Tempdir.create(["danbooru-", ".zip"])
      path = tempdir.path
      assert(File.exist?(path))

      tempdir = nil
      GC.start
      GC.start

      assert_not(File.exist?(path))
    end
  end
end
