require 'test_helper'

class StorageManagerTest < ActiveSupport::TestCase
  setup do
    CurrentUser.ip_addr = "127.0.0.1"
  end

  context "StorageManager::Match" do
    setup do
      @storage_manager = StorageManager::Match.new do |matcher|
        matcher.add_manager(type: :crop) do
          "crop"
        end

        matcher.add_manager(type: [:large, :original]) do
          "large or original"
        end

        matcher.add_manager(id: 1..100) do
          "first"
        end

        matcher.add_manager(id: 101..200, type: :preview) do
          "preview"
        end

        matcher.add_manager({}) do
          "default"
        end
      end
    end

    should "find the different matches" do
      assert_equal("large or original", @storage_manager.find(type: :original))
      assert_equal("crop", @storage_manager.find(type: :crop))
      assert_equal("large or original", @storage_manager.find(type: :large))
      assert_equal("preview", @storage_manager.find(type: :preview, id: 150))
      assert_equal("default", @storage_manager.find(type: :preview, id: 1000))
      assert_equal("crop", @storage_manager.find(type: :crop, id: 1_000))
      assert_equal("large or original", @storage_manager.find(type: :large, id: 1_000))
    end
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

        @file_path = "#{@temp_dir}/preview/#{@post.md5}.jpg"
        @large_file_path = "#{@temp_dir}/sample/sample-#{@post.md5}.jpg"
        @preview_file_path = "#{@temp_dir}/#{@post.md5}.#{@post.file_ext}"
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

    context "when the original_subdir option is used" do
      should "store original files at the correct path" do
        @post = FactoryBot.create(:post, file_ext: "png")
        @storage_manager = StorageManager::Local.new(base_dir: @temp_dir, base_url: "/data", original_subdir: "original/")

        assert_equal("#{@temp_dir}/original/#{@post.md5}.png", @storage_manager.file_path(@post, @post.file_ext, :original))

        @storage_manager.store_file(StringIO.new("data"), @post, :original)
        assert_equal(true, File.exist?("#{@temp_dir}/original/#{@post.md5}.png"))
      end
    end
  end

  context "StorageManager::Hybrid" do
    setup do
      @post1 = FactoryBot.build(:post, id: 1, file_ext: "png")
      @post2 = FactoryBot.build(:post, id: 2, file_ext: "png")

      @storage_manager = StorageManager::Hybrid.new do |id, md5, file_ext, type|
        if id.odd?
          StorageManager::Local.new(base_dir: "#{@temp_dir}/i1", base_url: "/i1")
        else
          StorageManager::Local.new(base_dir: "#{@temp_dir}/i2", base_url: "/i2")
        end
      end
    end

    context "#store_file method" do
      should "store odd-numbered posts under /i1 and even-numbered posts under /i2" do
        @storage_manager.store_file(StringIO.new("post1"), @post1, :original)
        @storage_manager.store_file(StringIO.new("post2"), @post2, :original)

        assert(File.exist?("#{@temp_dir}/i1/#{@post1.md5}.png"))
        assert(File.exist?("#{@temp_dir}/i2/#{@post2.md5}.png"))
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
