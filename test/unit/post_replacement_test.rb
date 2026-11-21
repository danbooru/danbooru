require "test_helper"

class PostReplacementTest < ActiveSupport::TestCase
  context "PostReplacement" do
    context "during validation" do
      should "not allow files with filenames that aren't valid UTF-8" do
        file = Rack::Test::UploadedFile.new("lib/media-file/test/files/jpg/test.jpg", original_filename: "a\xFF.jpg".b)
        replacement = build(:post_replacement, replacement_file: file)

        assert_equal(false, replacement.valid?)
        assert_equal(["'a�.jpg' isn't a valid filename (filenames must be UTF-8)"], replacement.errors[:base])
      end

      should "not allow files with filenames that contain NUL bytes" do
        file = Rack::Test::UploadedFile.new("lib/media-file/test/files/jpg/test.jpg")
        file.stubs(:original_filename).returns("a\0b.jpg")
        replacement = build(:post_replacement, replacement_file: file)

        assert_equal(false, replacement.valid?)
        assert_equal(["'a�b.jpg' isn't a valid filename (filenames can't contain NUL bytes)"], replacement.errors[:base])
      end

      should "allow replacements without a file" do
        replacement = build(:post_replacement, replacement_file: nil, replacement_url: "https://example.com/image.jpg")

        assert_equal(true, replacement.valid?)
      end
    end
  end
end
