require 'test_helper'

class StorageManagerTest < ActiveSupport::TestCase
  def tempfile(data, &block)
    file = Danbooru::Tempfile.new
    file.write(data)
    file.flush

    if block_given?
      yield file
      file.close
    else
      file
    end
  end

  def sftp
    host = ENV["DANBOORU_SFTP_HOST"]
    port = ENV["DANBOORU_SFTP_PORT"]
    user = ENV["DANBOORU_SFTP_USER"]
    pass = ENV["DANBOORU_SFTP_PASS"]
    dir  = ENV["DANBOORU_SFTP_DIR"]

    if host.present? && port.present? && user.present? && pass.present? && dir.present?
      StorageManager::SFTP.new(host, base_dir: dir, ssh_options: { port: port, user: user, password: pass })
    else
      nil
    end
  end

  context "StorageManager::Local" do
    setup do
      @storage_manager = StorageManager::Local.new(base_dir: @temp_dir, base_url: "/data")
    end

    context "#store method" do
      should "store the file" do
        @storage_manager.store(tempfile("data"), "test.txt")

        assert_equal("data", File.read("#{@temp_dir}/test.txt"))
      end

      should "overwrite the file if it already exists" do
        @storage_manager.store(tempfile("foo"), "test.txt")
        @storage_manager.store(tempfile("bar"), "test.txt")

        assert_equal("bar", File.read("#{@temp_dir}/test.txt"))
      end
    end

    context "#delete method" do
      should "delete the file" do
        @storage_manager.store(tempfile("data"), "test.txt")
        @storage_manager.delete("test.txt")

        assert_not(File.exist?("#{@temp_dir}/test.txt"))
      end

      should "not fail if the file doesn't exist" do
        assert_nothing_raised { @storage_manager.delete("dne.txt") }
      end
    end
  end

  context "StorageManager::SFTP" do
    setup do
      @storage_manager = sftp
      skip "SFTP server not configured" if @storage_manager.nil?
    end

    context "#store method" do
      should "store the file" do
        tempfile("blah") do |file|
          @storage_manager.store(file, "blah.txt")
        end

        file = @storage_manager.open("blah.txt")
        assert_equal("blah", file.read)
        file.close
      end

      should "create parent directories if they don't already exist" do
        tempfile("blah") do |file|
          @storage_manager.store(file, "a/b/c/d/blah.txt")
        end

        file = @storage_manager.open("a/b/c/d/blah.txt")
        assert_equal("blah", file.read)
        file.close
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
        @storage_manager.store(tempfile("data"), "test.txt")

        assert_equal("data", File.read("#{@temp_dir1}/test.txt"))
        assert_equal("data", File.read("#{@temp_dir2}/test.txt"))
      end
    end

    context "#delete method" do
      should "delete the file from both backends" do
        @storage_manager.store(tempfile("data"), "test.txt")
        @storage_manager.delete("test.txt")

        assert_not(File.exist?("#{@temp_dir1}/test.txt"))
        assert_not(File.exist?("#{@temp_dir2}/test.txt"))
      end
    end

    context "#open method" do
      should "open the file from the first backend" do
        @storage_manager.store(tempfile("data"), "test.txt")

        assert_equal("data", @storage_manager.open("test.txt").read)
      end
    end
  end
end
