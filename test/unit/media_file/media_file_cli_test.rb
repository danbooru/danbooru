require "test_helper"

class MediaFileCliTest < ActiveSupport::TestCase
  context "CLI" do
    should "work when called with bin/media-ls" do
      assert_equal(true, system(Rails.root.join("bin/media-ls --help > /dev/null 2>&1").to_s))
    end

    should "work" do
      stdout = StringIO.new
      assert_equal(true, MediaFile::CLI.run!("--help", stdout:))
      assert_equal(false, MediaFile::CLI.run!("--invalid-option", stdout:, stderr: stdout))

      assert_equal(true, MediaFile::CLI.run!(*%w[test/files], stdout:))
      assert_equal(true, MediaFile::CLI.run!(*%w[test/files -lh -u si -p 3], stdout:))
      assert_equal(true, MediaFile::CLI.run!(*%w[test/files -lR], stdout:))
      assert_equal(true, MediaFile::CLI.run!(*%w[test/files/test.jpg], stdout:))
      assert_equal(true, MediaFile::CLI.run!(*%w[test/files/test.jpg -d], stdout:))
      assert_equal(true, MediaFile::CLI.run!(*%w[test/files/test.jpg -j], stdout:))
      assert_equal(true, MediaFile::CLI.run!(*%w[test/files/ -c mpixels,name -g type,dimensions -s user,size], stdout:))
    end

    should "produce json output" do
      stdout = StringIO.new
      assert_equal(true, MediaFile::CLI.run!(*%w[test/files/test.jpg -j -c name,size], stdout:))
      assert_equal([{ "name" => "test.jpg", "size" => 28_086 }], stdout.tap(&:rewind).read.parse_json)
    end
  end
end
