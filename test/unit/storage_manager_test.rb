require "test_helper"
require "testcontainers"

class StorageManagerTest < ActiveSupport::TestCase
  def tempfile(data, &_block)
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
      # Work around testcontainers producing `'IO#read': closed stream` warnings when it tries to detect the host's gateway IP.
      ENV["TC_HOST"] = `ip -4 route show default`.split[2] unless ENV["CI"].present?

      @sftp_container =
        Testcontainers::DockerContainer.new("atmoz/sftp")
        .with_command("testuser:testpass:::upload")
        .with_exposed_ports("22/tcp")
        .with_wait_for(:tcp_port, "22")

      @sftp_container.start

      @storage_manager = StorageManager::SFTP.new(@sftp_container.host, base_dir: "/upload", ssh_options: {
        port: @sftp_container.mapped_port(22),
        user: "testuser",
        password: "testpass",
        verify_host_key: :never,
        auth_methods: %w[password],
      })
    rescue Testcontainers::Error => e
      skip "Docker not available: #{e.message}"
    end

    teardown do
      @sftp_container&.stop
      @sftp_container&.remove
    rescue Testcontainers::Error
      nil
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

      should "overwrite the file if it already exists" do
        tempfile("foo") { |f| @storage_manager.store(f, "test.txt") }
        tempfile("bar") { |f| @storage_manager.store(f, "test.txt") }

        file = @storage_manager.open("test.txt")
        assert_equal("bar", file.read)
        file.close
      end

      should "restore the original file if overwriting it fails" do
        tempfile("original") { |f| @storage_manager.store(f, "test.txt") }

        # Close the pool so the next store creates a fresh connection we can instrument.
        @storage_manager.close_pool!

        # Wrap the SFTPConnection so that the second mv_f! call (temp → dest) fails; the first (backup) and third
        # (restore) calls succeed, so we can verify that the original file is restored if the move fails
        real_open = StorageManager::SFTP::SFTPConnection.method(:open)
        StorageManager::SFTP::SFTPConnection.define_singleton_method(:open) do |host, **ssh_options|
          conn = real_open.call(host, **ssh_options)
          mv_f_count = 0
          real_mv_f = conn.method(:mv_f!)

          conn.define_singleton_method(:mv_f!) do |src, dest|
            mv_f_count += 1

            raise "injected failure" if mv_f_count == 2
            real_mv_f.call(src, dest)
          end

          conn
        end

        assert_raises(RuntimeError) { tempfile("new") { |f| @storage_manager.store(f, "test.txt") } }

        file = @storage_manager.open("test.txt")
        assert_equal("original", file.read)
        file.close
      ensure
        StorageManager::SFTP::SFTPConnection.define_singleton_method(:open, real_open) if defined?(real_open) && real_open
      end

      should "create parent directories if they don't already exist" do
        tempfile("blah") do |file|
          @storage_manager.store(file, "a/b/c/d/blah.txt")
        end

        file = @storage_manager.open("a/b/c/d/blah.txt")
        assert_equal("blah", file.read)
        file.close
      end

      should "raise an error if a file exists where a parent directory is expected" do
        tempfile("data") { |f| @storage_manager.store(f, "conflict.txt") }

        assert_raises(RuntimeError) do
          tempfile("data") { |f| @storage_manager.store(f, "conflict.txt/nested.txt") }
        end
      end

      should "raise an error if the destination directory can't be written" do
        @sftp_container.exec(["sh", "-lc", "mkdir -p /home/testuser/upload/no_write && chmod 555 /home/testuser/upload/no_write"])

        assert_raises(Net::SFTP::StatusException) do
          tempfile("data") { |f| @storage_manager.store(f, "no_write/test.txt") }
        end
      end
    end

    context "#delete method" do
      should "delete the file" do
        tempfile("blah") { |f| @storage_manager.store(f, "blah.txt") }
        @storage_manager.delete("blah.txt")

        assert_raises(RuntimeError) { @storage_manager.open("blah.txt") }
      end

      should "not fail if the file doesn't exist" do
        assert_nothing_raised { @storage_manager.delete("dne.txt") }
      end

      should "raise an error if the file can't be deleted due to permissions" do
        @sftp_container.exec(["sh", "-lc", "mkdir -p /home/testuser/upload/no_delete && echo secret > /home/testuser/upload/no_delete/file.txt && chmod 555 /home/testuser/upload/no_delete"])

        assert_raises(Net::SFTP::StatusException) { @storage_manager.delete("no_delete/file.txt") }
      end
    end

    context "#open method" do
      should "open and read the file" do
        tempfile("hello") { |f| @storage_manager.store(f, "hello.txt") }

        file = @storage_manager.open("hello.txt")
        assert_equal("hello", file.read)
        file.close
      end

      should "raise an error if the file doesn't exist" do
        assert_raises(RuntimeError) { @storage_manager.open("missing.txt") }
      end

      should "raise an error if the file can't be opened due to permissions" do
        @sftp_container.exec(["sh", "-lc", "echo secret > /home/testuser/upload/no_read.txt && chmod 000 /home/testuser/upload/no_read.txt"])

        assert_raises(Net::SFTP::StatusException) { @storage_manager.open("no_read.txt") }
      end
    end
  end

  context "StorageManager::Mirror" do
    setup do
      @temp_dir1 = Dir.mktmpdir("danbooru-temp1-")
      @temp_dir2 = Dir.mktmpdir("danbooru-temp2-")

      @storage_manager = StorageManager::Mirror.new([
        StorageManager::Local.new(base_dir: @temp_dir1, base_url: "/data"),
        StorageManager::Local.new(base_dir: @temp_dir2, base_url: "/data"),
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
