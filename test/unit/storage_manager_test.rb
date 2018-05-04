require 'test_helper'

class StorageManagerTest < ActiveSupport::TestCase
  BASE_DIR = "#{Rails.root}/tmp/test-storage"

  setup do
    CurrentUser.ip_addr = "127.0.0.1"
  end

  context "StorageManager::Local" do
    setup do
      @storage_manager = StorageManager::Local.new(base_dir: BASE_DIR, base_url: "/data")
    end

    teardown do
      FileUtils.rm_rf(BASE_DIR)
    end

    context "#store method" do
      should "store the file" do
        @storage_manager.store(StringIO.new("data"), "#{BASE_DIR}/test.txt")

        assert("data", File.read("#{BASE_DIR}/test.txt"))
      end

      should "overwrite the file if it already exists" do
        @storage_manager.store(StringIO.new("foo"), "#{BASE_DIR}/test.txt")
        @storage_manager.store(StringIO.new("bar"), "#{BASE_DIR}/test.txt")

        assert("bar", File.read("#{BASE_DIR}/test.txt"))
      end
    end

    context "#delete method" do
      should "delete the file" do
        @storage_manager.store(StringIO.new("data"), "test.txt")
        @storage_manager.delete("test.txt")

        assert_not(File.exist?("#{BASE_DIR}/test.txt"))
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

        @file_path = "#{BASE_DIR}/preview/#{@post.md5}.jpg"
        @large_file_path = "#{BASE_DIR}/sample/sample-#{@post.md5}.jpg"
        @preview_file_path = "#{BASE_DIR}/#{@post.md5}.#{@post.file_ext}"
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

        assert_equal("/data/#{@post.md5}.png", @storage_manager.file_url(@post, :original))
        assert_equal("/data/sample/sample-#{@post.md5}.jpg", @storage_manager.file_url(@post, :large))
        assert_equal("/data/preview/#{@post.md5}.jpg", @storage_manager.file_url(@post, :preview))
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

  context "StorageManager::Hybrid" do
    setup do
      @post1 = FactoryBot.build(:post, id: 1, file_ext: "png")
      @post2 = FactoryBot.build(:post, id: 2, file_ext: "png")

      @storage_manager = StorageManager::Hybrid.new do |id, md5, file_ext, type|
        if id.odd?
          StorageManager::Local.new(base_dir: "#{BASE_DIR}/i1", base_url: "/i1")
        else
          StorageManager::Local.new(base_dir: "#{BASE_DIR}/i2", base_url: "/i2")
        end
      end
    end

    teardown do
      FileUtils.rm_rf(BASE_DIR)
    end

    context "#store_file method" do
      should "store odd-numbered posts under /i1 and even-numbered posts under /i2" do
        @storage_manager.store_file(StringIO.new("post1"), @post1, :original)
        @storage_manager.store_file(StringIO.new("post2"), @post2, :original)

        assert(File.exist?("#{BASE_DIR}/i1/#{@post1.md5}.png"))
        assert(File.exist?("#{BASE_DIR}/i2/#{@post2.md5}.png"))
      end
    end

    context "#file_url method" do
      should "generate /i1 urls for odd posts and /i2 urls for even posts" do
        assert_equal("/i1/#{@post1.md5}.png", @storage_manager.file_url(@post1, :original))
        assert_equal("/i2/#{@post2.md5}.png", @storage_manager.file_url(@post2, :original))
      end
    end
  end
end
