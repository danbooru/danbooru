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
        @storage_manager.store(StringIO.new("data"), "test.txt")

        assert("data", File.read("#{@temp_dir}/test.txt"))
      end

      should "overwrite the file if it already exists" do
        @storage_manager.store(StringIO.new("foo"), "test.txt")
        @storage_manager.store(StringIO.new("bar"), "test.txt")

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
  end

  context "StorageManager::Mirror" do
    setup do
      @temp_dir1 = Dir.mktmpdir("danbooru-temp1-")
      @temp_dir2 = Dir.mktmpdir("danbooru-temp2-")

      @storage_manager = StorageManager::Mirror.new([
        StorageManager::Local.new(base_dir: @temp_dir1, base_url: "/data"),
        StorageManager::Local.new(base_dir: @temp_dir2, base_url: "/data")
      ])
    end

    teardown do
      FileUtils.rm_rf(@temp_dir1)
      FileUtils.rm_rf(@temp_dir2)
    end

    context "#store method" do
      should "store the file on both backends" do
        @storage_manager.store(StringIO.new("data"), "test.txt")

        assert("data", File.read("#{@temp_dir1}/test.txt"))
        assert("data", File.read("#{@temp_dir2}/test.txt"))
      end
    end

    context "#delete method" do
      should "delete the file from both backends" do
        @storage_manager.store(StringIO.new("data"), "test.txt")
        @storage_manager.delete("test.txt")

        assert_not(File.exist?("#{@temp_dir1}/test.txt"))
        assert_not(File.exist?("#{@temp_dir2}/test.txt"))
      end
    end

    context "#open method" do
      should "open the file from the first backend" do
        @storage_manager.store(StringIO.new("data"), "test.txt")

        assert_equal("data", @storage_manager.open("test.txt").read)
      end
    end
  end
end
