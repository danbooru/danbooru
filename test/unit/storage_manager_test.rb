require 'test_helper'

class StorageManagerTest < ActiveSupport::TestCase
  setup do
    CurrentUser.ip_addr = "127.0.0.1"
  end

  context "StorageManager::Local" do
    setup do
      @storage_manager = StorageManager::Local.new(base_dir: @temp_dir, base_url: "/data")
    end

    context "#store method" do
      should "store the file" do
        @storage_manager.store(StringIO.new("data"), "#{@temp_dir}/test.txt")

        assert("data", File.read("#{@temp_dir}/test.txt"))
      end

      should "overwrite the file if it already exists" do
        @storage_manager.store(StringIO.new("foo"), "#{@temp_dir}/test.txt")
        @storage_manager.store(StringIO.new("bar"), "#{@temp_dir}/test.txt")

        assert("bar", File.read("#{@temp_dir}/test.txt"))
      end
    end

    context "#delete method" do
      should "delete the file" do
        @storage_manager.store(StringIO.new("data"), "test.txt")
        @storage_manager.delete("test.txt")

        assert_not(File.exist?("#{@temp_dir}/test.txt"))
      end

      should "not fail if the file doesn't exist" do
        assert_nothing_raised { @storage_manager.delete("dne.txt") }
      end
    end

    context "#store_file and #delete_file methods" do
      setup do
        @post = FactoryBot.create(:post, file_ext: "png")

        @storage_manager.store_file(StringIO.new("data"), @post, :preview)
        @storage_manager.store_file(StringIO.new("data"), @post, :large)
        @storage_manager.store_file(StringIO.new("data"), @post, :original)
        subdir = "#{@post.md5[0..1]}/#{@post.md5[2..3]}"

        @file_path = "#{@temp_dir}/preview/#{subdir}/#{@post.md5}.jpg"
        @large_file_path = "#{@temp_dir}/sample/#{subdir}/sample-#{@post.md5}.jpg"
        @preview_file_path = "#{@temp_dir}/original/#{subdir}/#{@post.md5}.#{@post.file_ext}"
      end

      should "store the files at the correct path" do
        assert(File.exist?(@file_path))
        assert(File.exist?(@large_file_path))
        assert(File.exist?(@preview_file_path))
      end

      should "delete the files" do
        @storage_manager.delete_file(@post.id, @post.md5, @post.file_ext, :preview)
        @storage_manager.delete_file(@post.id, @post.md5, @post.file_ext, :large)
        @storage_manager.delete_file(@post.id, @post.md5, @post.file_ext, :original)

        assert_not(File.exist?(@file_path))
        assert_not(File.exist?(@large_file_path))
        assert_not(File.exist?(@preview_file_path))
      end
    end

    context "#file_url method" do
      should "return the correct urls" do
        @post = FactoryBot.create(:post, file_ext: "png")
        @storage_manager.stubs(:tagged_filenames).returns(false)
        subdir = "#{@post.md5[0..1]}/#{@post.md5[2..3]}"

        assert_equal("/data/original/#{subdir}/#{@post.md5}.png", @storage_manager.file_url(@post, :original))
        assert_equal("/data/sample/#{subdir}/sample-#{@post.md5}.jpg", @storage_manager.file_url(@post, :large))
        assert_equal("/data/preview/#{subdir}/#{@post.md5}.jpg", @storage_manager.file_url(@post, :preview))
      end

      should "return the correct url for flash files" do
        @post = FactoryBot.create(:post, file_ext: "swf")

        @storage_manager.stubs(:base_url).returns("/data")
        assert_equal("/images/download-preview.png", @storage_manager.file_url(@post, :preview))

        @storage_manager.stubs(:base_url).returns("http://localhost/data")
        assert_equal("http://localhost/images/download-preview.png", @storage_manager.file_url(@post, :preview))
      end
    end
  end
end
