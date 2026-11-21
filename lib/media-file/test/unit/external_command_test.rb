require "test_helper"

class ExternalCommandTest < ActiveSupport::TestCase
  # Profiles for the programs that only the tests run.
  PROFILES = MediaFile::ExternalCommand::PROFILES.merge(
    # Ruby uses epoll and eventfd for its timer thread, and turns off transparent huge pages (PR_SET_THP_DISABLE).
    "ruby" => { execute: %w[/usr/local/bin/ruby], read: %w[/usr/local/lib], syscalls: ["epoll_create1", "epoll_ctl", "epoll_wait", "eventfd2", ["prctl", :allow, [[0, :eq, 41]]]] },
    "sh" => { execute: %w[/usr/bin/dash] },
    "unshare" => { execute: %w[/usr/bin/unshare] },
  ).freeze

  # Runs a Ruby script in the sandbox that makes a syscall and prints its return value and errno.
  def syscall!(name, *args)
    args = [MediaFile::Seccomp.resolve_syscall_name(name), *args].fill(0, args.size + 1, 6 - args.size)
    script = %{f = Fiddle::Function.new(Fiddle::Handle::DEFAULT["syscall"], [Fiddle::TYPE_LONG] * 7, Fiddle::TYPE_LONG); puts [f.call(#{args.join(", ")}), Fiddle.last_error].inspect}

    stub_const(MediaFile::ExternalCommand, :PROFILES, PROFILES) do
      MediaFile::ExternalCommand.run("ruby -rfiddle -e #{script.shellescape}").first
    end
  end

  context "MediaFile::ExternalCommand.run" do
    should "return the output and status of the command" do
      output, status = MediaFile::ExternalCommand.run("echo hello")

      assert_equal("hello\n", output)
      assert_equal(true, status.success?)
    end

    should "return the output in the default external encoding" do
      output, _status = MediaFile::ExternalCommand.run("echo ünïcödé")

      assert_equal("ünïcödé\n", output)
      assert_equal(Encoding.default_external, output.encoding)
    end

    should "return stderr in the output" do
      output, status = MediaFile::ExternalCommand.run("cat /nonexistent")

      assert_equal(1, status.exitstatus)
      assert_match(/No such file or directory/, output)
    end

    should "return the status of commands that fail without raising an error" do
      _output, status = MediaFile::ExternalCommand.run("false")

      assert_equal(1, status.exitstatus)
    end

    should "not allow empty commands" do
      assert_raises(ArgumentError) { MediaFile::ExternalCommand.run("") }
      assert_raises(ArgumentError) { MediaFile::ExternalCommand.run("   ") }
    end

    should "raise an error if the program doesn't exist" do
      error = assert_raises(MediaFile::ExternalCommand::Error) { MediaFile::ExternalCommand.run("nosuchprogram") }

      assert_equal("can't run nosuchprogram: No such file or directory", error.message)
    end

    should "allow paths in directories that are symlinks" do
      Dir.mktmpdir do |dir|
        FileUtils.mkdir("#{dir}/real")
        File.write("#{dir}/real/file", "hello")
        File.symlink("#{dir}/real", "#{dir}/link")

        output, status = MediaFile::ExternalCommand.run("cat #{dir}/link/file", read: ["#{dir}/link/file"])
        assert_equal(true, status.success?)
        assert_equal("hello", output)
      end
    end

    should "skip read and write paths that don't exist" do
      output, status = MediaFile::ExternalCommand.run("echo hello", read: ["/nonexistent"], write: ["/nonexistent"])

      assert_equal(true, status.success?)
      assert_equal("hello\n", output)
    end

    should "work when $stdout and $stderr aren't the real stdout and stderr" do
      stdout, stderr = $stdout, $stderr
      $stdout, $stderr = StringIO.new, StringIO.new
      output, _status = MediaFile::ExternalCommand.run("echo hello")

      assert_equal("hello\n", output)
    ensure
      $stdout, $stderr = stdout, stderr
    end

    should "work when called from several threads at once" do
      outputs = 10.times.map { |i| Thread.new { MediaFile::ExternalCommand.run("echo #{i}").first } }.map(&:value)

      assert_equal(10.times.map { "#{it}\n" }, outputs)
    end

    should "allow output up to the output limit" do
      output, _status = MediaFile::ExternalCommand.run("head -c 100 /dev/zero", read: ["/dev/zero"], output_limit: 100)
      assert_equal(100, output.bytesize)

      assert_raises(MediaFile::ExternalCommand::OutputLimitError) { MediaFile::ExternalCommand.run("head -c 101 /dev/zero", read: ["/dev/zero"], output_limit: 100) }
    end

    should "not report commands that call abort() as calling a blocked syscall" do
      stub_const(MediaFile::ExternalCommand, :PROFILES, PROFILES) do
        _output, status = MediaFile::ExternalCommand.run(%{ruby -rfiddle -e 'Fiddle::Function.new(Fiddle::Handle::DEFAULT["abort"], [], Fiddle::TYPE_VOID).call'})

        assert_equal(true, status.signaled?)
        assert_equal(false, MediaFile::Seccomp.killed?(status))
      end
    end

    should "not fork the Rails process to run commands" do
      Process.expects(:fork).never
      output, _status = MediaFile::ExternalCommand.run("echo hello")

      assert_equal("hello\n", output)
    end

    should "raise an error if a path is a symlink" do
      Dir.mktmpdir do |dir|
        File.symlink("/etc/hostname", "#{dir}/link")
        error = assert_raises(MediaFile::ExternalCommand::Error) { MediaFile::ExternalCommand.run("cat #{dir}/link", read: ["#{dir}/link"]) }

        assert_equal("can't run cat: #{dir}/link can't be sandboxed because it's a symlink", error.message)
      end
    end

    should "not let commands gain privileges" do
      output, _status = MediaFile::ExternalCommand.run("cat /proc/self/status", read: ["/proc"])
      assert_match(/^NoNewPrivs:\s+1$/, output)
      assert_match(/^Seccomp:\s+2$/, output)
    end

    should "not leak files" do
      MediaFile::ExternalCommand.run("echo hello")
      GC.start
      open_files = Dir.children("/proc/self/fd").size

      10.times { MediaFile::ExternalCommand.run("echo hello") }
      10.times do
        MediaFile::ExternalCommand.run("nosuchprogram")
      rescue StandardError
        nil
      end
      10.times do
        Timeout.timeout(0.05) { MediaFile::ExternalCommand.run("sleep 5") }
      rescue StandardError
        nil
      end

      # Other files can be closed while this runs, for example when temp files from other tests are garbage collected.
      GC.start
      assert_operator(Dir.children("/proc/self/fd").size, :<=, open_files)
    end

    should "kill the command and not leak files if it can't wait for the command" do
      MediaFile::ExternalCommand::LibC.stubs(:pidfd_open!).raises(Errno::EPERM)
      open_files = Dir.children("/proc/self/fd").size

      assert_raises(Errno::EPERM) { MediaFile::ExternalCommand.run("sleep 32") }
      assert_equal(open_files, Dir.children("/proc/self/fd").size)
      assert_empty(`ps -eo args`.lines.map(&:strip).grep(/\Asleep 32\z/))
    end

    should "kill commands if the parent process dies" do
      # Run the command from a new process instead of a fork, because forking this multithreaded process can hang the child.
      pid = Process.spawn({ "BUNDLE_GEMFILE" => File.expand_path("Gemfile") }, RbConfig.ruby, "-rbundler/setup", "-e", %{require_relative "lib/media_file"; MediaFile::ExternalCommand.run("sleep 33")}, out: File::NULL)
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 60

      until `ps -eo args`.lines.map(&:strip).include?("sleep 33")
        _, status = Process.waitpid2(pid, Process::WNOHANG)
        flunk("the parent process exited before running the command: #{status.inspect}") if status

        if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline
          Process.kill(:KILL, pid)
          Process.wait(pid)
          flunk("the parent process didn't run the command after 60 seconds")
        end

        sleep 0.1
      end

      Process.kill(:KILL, pid)
      Process.wait(pid)
      sleep 0.5

      assert_empty(`ps -eo args`.lines.map(&:strip).grep(/\Asleep 33\z/))
    end

    should "not leak files if the sandbox can't be built" do
      open_files = Dir.children("/proc/self/fd").size
      MediaFile::Seccomp.stubs(:allow).raises(Errno::EINVAL)

      assert_raises(Errno::EINVAL) { MediaFile::ExternalCommand.run("echo hello") }
      assert_equal(open_files, Dir.children("/proc/self/fd").size)
    end

    should "kill commands that are interrupted by another timeout" do
      assert_raises(Timeout::Error) { Timeout.timeout(1) { MediaFile::ExternalCommand.run("sleep 31") } }

      assert_empty(`ps -eo args`.lines.map(&:strip).grep(/\Asleep 31\z/))
    end

    should "kill commands that close their output and keep running" do
      stub_const(MediaFile::ExternalCommand, :PROFILES, PROFILES) do
        started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        error = assert_raises(MediaFile::ExternalCommand::TimeoutError) { MediaFile::ExternalCommand.run(%{ruby -e '$stdout.close; $stderr.close; sleep 30'}, timeout: 1) }

        assert_equal("ruby timed out after 1 seconds", error.message)
        assert_operator(Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at, :<, 10)
      end
    end

    should "return all the output of commands that print a lot" do
      output, status = MediaFile::ExternalCommand.run("head -c 5000000 /dev/zero", read: ["/dev/zero"])

      assert_equal(true, status.success?)
      assert_equal(5_000_000, output.bytesize)
    end

    should "kill commands that print more than the output limit" do
      gemfile = File.expand_path("media_file.gemspec")
      error = assert_raises(MediaFile::ExternalCommand::OutputLimitError) { MediaFile::ExternalCommand.run("cat #{gemfile}", read: [gemfile], output_limit: 100) }
      assert_equal("cat printed more than 100 bytes", error.message)

      stub_const(MediaFile::ExternalCommand, :OUTPUT_LIMIT, 100) do
        assert_raises(MediaFile::ExternalCommand::OutputLimitError) { MediaFile::ExternalCommand.run("cat #{gemfile}", read: [gemfile]) }
      end
    end

    should "not let commands run files they can only read" do
      Dir.mktmpdir do |dir|
        FileUtils.cp(File.realpath("/usr/bin/true"), "#{dir}/true")
        FileUtils.chmod(0o755, "#{dir}/true")
        error = assert_raises(MediaFile::ExternalCommand::Error) { MediaFile::ExternalCommand.run("#{dir}/true", read: [dir]) }

        assert_match(%r{\Acan't run #{dir}/true: Permission denied}, error.message)
      end
    end

    should "kill commands that run longer than the timeout" do
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      error = assert_raises(MediaFile::ExternalCommand::TimeoutError) { MediaFile::ExternalCommand.run("sleep 30", timeout: 1) }

      assert_equal("sleep timed out after 1 seconds", error.message)
      assert_operator(Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at, :<, 10)
    end

    should "not let commands write core dumps" do
      stub_const(MediaFile::ExternalCommand, :PROFILES, PROFILES) do
        output, _status = MediaFile::ExternalCommand.run("sh -c 'ulimit -c'")
        assert_equal("0\n", output)
      end
    end

    should "not let commands use more memory than the memory limit" do
      stub_const(MediaFile::ExternalCommand, :PROFILES, PROFILES) do
        _output, status = MediaFile::ExternalCommand.run(%{ruby --disable=jit -e 'puts 1'}, memory_limit: 500.megabytes)
        assert_equal(true, status.success?)

        output, status = MediaFile::ExternalCommand.run(%{ruby --disable=jit -e 'puts ("a" * 1_000_000_000).size'}, memory_limit: 500.megabytes)
        assert_equal(false, status.success?)
        assert_match(/NoMemoryError/, output)
      end
    end

    should "not run commands through a shell" do
      output, _status = MediaFile::ExternalCommand.run("echo hello; echo world")

      assert_equal("hello; echo world\n", output)
    end

    should "not pass the environment to commands" do
      ENV["DANBOORU_EXTERNAL_COMMAND_TEST_SECRET"] = "secret"
      output, _status = MediaFile::ExternalCommand.run("env")

      assert_equal(ENV.slice(*MediaFile::ExternalCommand::ENVIRONMENT).keys.sort, output.lines.map { it.split("=").first }.sort)
    ensure
      ENV.delete("DANBOORU_EXTERNAL_COMMAND_TEST_SECRET")
    end

    should "not let commands read the environment of the Rails process" do
      output, status = MediaFile::ExternalCommand.run("cat /proc/#{Process.pid}/environ")

      assert_equal(false, status.success?)
      assert_match(/Permission denied/, output)
    end

    should "only let commands read the given files" do
      output, status = MediaFile::ExternalCommand.run("cat #{File.expand_path("media_file.gemspec")}")
      assert_equal(false, status.success?)
      assert_match(/Permission denied/, output)

      output, status = MediaFile::ExternalCommand.run("cat #{File.expand_path("media_file.gemspec")}", read: [File.expand_path("media_file.gemspec")])
      assert_equal(true, status.success?)
      assert_match(/media_file/, output)
    end

    should "not let programs read the files of other programs" do
      output, status = MediaFile::ExternalCommand.run("ffprobe -v error -i /usr/local/bin/exiftool")

      assert_equal(false, status.success?)
      assert_match(/Permission denied/, output)
    end

    should "only let commands write to the given directories" do
      Dir.mktmpdir do |dir|
        _output, status = MediaFile::ExternalCommand.run("touch #{dir}/file")
        assert_equal(false, status.success?)
        assert_equal(false, File.exist?("#{dir}/file"))

        _output, status = MediaFile::ExternalCommand.run("touch #{dir}/file", write: [dir])
        assert_equal(true, status.success?)
        assert_equal(true, File.exist?("#{dir}/file"))
      end
    end

    should "not let commands use the network" do
      stub_const(MediaFile::ExternalCommand, :PROFILES, PROFILES) do
        error = assert_raises(MediaFile::ExternalCommand::SyscallError) { MediaFile::ExternalCommand.run(%{ruby -rsocket -e 'TCPSocket.new("127.0.0.1", 80)'}) }
        assert_equal("ruby called a blocked syscall", error.message)
      end
    end

    should "not run commands if Landlock isn't supported" do
      MediaFile::Landlock.stubs(:abi_version).returns(0)
      error = assert_raises(MediaFile::ExternalCommand::Error) { MediaFile::ExternalCommand.run("echo hello") }

      assert_equal("can't run echo: Landlock isn't supported by this kernel (set `MediaFile.config.sandbox = false` to disable sandboxing)", error.message)
    end

    should "run commands without Landlock if the sandbox is disabled and Landlock isn't supported" do
      MediaFile::Landlock.stubs(:abi_version).returns(0)
      MediaFile.config.stubs(:sandbox).returns(false)
      output, status = MediaFile::ExternalCommand.run("cat #{File.expand_path("media_file.gemspec")}")

      assert_equal(true, status.success?)
      assert_match(/media_file/, output)
    end

    should "run commands without Landlock or seccomp if the sandbox is disabled" do
      MediaFile.config.stubs(:sandbox).returns(false)
      output, status = MediaFile::ExternalCommand.run("cat /proc/self/status #{File.expand_path("media_file.gemspec")}")

      # Docker may apply its own seccomp filter, so the command should have the same filters as the Rails process.
      rails_filters = File.read("/proc/self/status")[/^Seccomp_filters:\s+(\d+)$/, 1]
      assert_equal(true, status.success?)
      assert_equal(rails_filters, output[/^Seccomp_filters:\s+(\d+)$/, 1])
      assert_match(/media_file/, output)
    end

    should "not allow syscalls for networking, executing file descriptors, or reading extended attributes" do
      syscalls = MediaFile::Seccomp.expand_syscall_names(MediaFile::ExternalCommand::BASE_PROFILE[:syscalls] + MediaFile::ExternalCommand::PROFILES.values.flat_map { it.fetch(:syscalls, []) })

      assert_equal([], syscalls & %w[socket connect bind listen accept accept4 execveat getxattr lgetxattr fgetxattr])
    end

    should "use the profile given for the command, instead of the profile for the program" do
      Dir.mktmpdir do |dir|
        command = "#{RbConfig.ruby.shellescape} --disable-gems -e 'Dir.mkdir(ARGV[0])' #{File.join(dir, "new").shellescape}"

        # bin/image runs the same Ruby as bin/archive, but it doesn't write files, so it can't create directories.
        assert_raises(MediaFile::ExternalCommand::SyscallError) { MediaFile::ExternalCommand.run(command, write: [dir], profile_name: "bin/image") }
        assert_equal(true, MediaFile::ExternalCommand.run(command, write: [dir], profile_name: "bin/archive").last.success?)
        assert_equal(true, Dir.exist?(File.join(dir, "new")))
      end
    end

    should "raise an error if the command calls a blocked syscall" do
      stub_const(MediaFile::ExternalCommand, :PROFILES, PROFILES) do
        error = assert_raises(MediaFile::ExternalCommand::SyscallError) { MediaFile::ExternalCommand.run("unshare --user true") }
        assert_equal("unshare called a blocked syscall", error.message)
      end
    end

    should "log commands that call a blocked syscall" do
      MediaFile.logger.expects(:error).with("ExternalCommand: unshare called a blocked syscall (command: unshare --user true)")

      stub_const(MediaFile::ExternalCommand, :PROFILES, PROFILES) do
        assert_raises(MediaFile::ExternalCommand::SyscallError) { MediaFile::ExternalCommand.run("unshare --user true") }
      end
    end

    should "shorten long commands when logging them" do
      MediaFile.logger.expects(:error).with { |message| message.size < 1100 && message.include?("(command: unshare --user true aaa") }

      stub_const(MediaFile::ExternalCommand, :PROFILES, PROFILES) do
        assert_raises(MediaFile::ExternalCommand::SyscallError) { MediaFile::ExternalCommand.run("unshare --user true #{"a" * 5000}") }
      end
    end

    should "not let commands use files opened by the Rails process" do
      File.open(File.expand_path("media_file.gemspec")) do |file|
        file.close_on_exec = false
        output, _status = MediaFile::ExternalCommand.run("ls /proc/self/fd", read: ["/proc"])

        assert_not_includes(output.split, file.fileno.to_s)
      end
    end

    context "calling raw syscalls" do
      should "not let commands create namespaces with clone" do
        clone_newuser = 0x10000000
        error = assert_raises(MediaFile::ExternalCommand::SyscallError) { syscall!("clone", clone_newuser | Signal.list["CHLD"]) }

        assert_equal("ruby called a blocked syscall", error.message)
      end

      should "not let commands start other processes" do
        error = assert_raises(MediaFile::ExternalCommand::SyscallError) { syscall!("clone", Signal.list["CHLD"]) }

        assert_equal("ruby called a blocked syscall", error.message)
      end

      should "only allow ioctls that check for a terminal" do
        assert_equal("[-1, #{Errno::ENOTTY::Errno}]\n", syscall!("ioctl", 1, 0x5401, 0)) # TCGETS on a pipe
        assert_raises(MediaFile::ExternalCommand::SyscallError) { syscall!("ioctl", 1, 0x541B, 0) } # FIONREAD
      end

      should "only allow prctls for naming threads and memory" do
        assert_raises(MediaFile::ExternalCommand::SyscallError) { syscall!("prctl", 4, 1) } # PR_SET_DUMPABLE
      end

      should "not let commands turn off their parent death signal" do
        assert_match(/\A\[0, /, syscall!("prctl", 1, Signal.list["KILL"])) # PR_SET_PDEATHSIG
        assert_raises(MediaFile::ExternalCommand::SyscallError) { syscall!("prctl", 1, 0) }
      end

      should "not let commands make the kernel signal other processes" do
        assert_raises(MediaFile::ExternalCommand::SyscallError) { syscall!("fcntl", 1, 8, Process.pid) } # F_SETOWN
      end

      should "not let commands signal other processes" do
        assert_raises(MediaFile::ExternalCommand::SyscallError) { syscall!("kill", Process.pid, 0) }
        assert_raises(MediaFile::ExternalCommand::SyscallError) { syscall!("tgkill", Process.pid, Process.pid, 0) }
        assert_equal("[-1, #{Errno::EPERM::Errno}]\n", syscall!("tgkill", Process.pid, Process.pid, Signal.list["ABRT"]))
        assert_equal("[-1, #{Errno::EPERM::Errno}]\n", syscall!("tkill", Process.pid, Signal.list["ABRT"]))
      end

      should "not let commands use dangerous syscalls" do
        %w[ptrace bpf io_uring_setup userfaultfd memfd_create mount setns unshare keyctl perf_event_open process_vm_readv].each do |name|
          assert_raises(MediaFile::ExternalCommand::SyscallError, name) { syscall!(name) }
        end
      end

      should "make clone3 fail with ENOSYS" do
        assert_equal("[-1, #{Errno::ENOSYS::Errno}]\n", syscall!("clone3"))
      end

      should "kill commands that make x32 syscalls" do
        x32_getpid = 0x40000000 | MediaFile::Seccomp.resolve_syscall_name("getpid")
        script = %{Fiddle::Function.new(Fiddle::Handle::DEFAULT["syscall"], [Fiddle::TYPE_LONG], Fiddle::TYPE_LONG).call(#{x32_getpid})}

        stub_const(MediaFile::ExternalCommand, :PROFILES, PROFILES) do
          assert_raises(MediaFile::ExternalCommand::SyscallError) { MediaFile::ExternalCommand.run("ruby -rfiddle -e #{script.shellescape}", timeout: 10) }
        end
      end

      should "not let commands change the limits of other processes" do
        error = assert_raises(MediaFile::ExternalCommand::SyscallError) { syscall!("prlimit64", Process.pid, 7, 0, 0) }

        assert_equal("ruby called a blocked syscall", error.message)
      end

      should "not let commands change the CPU affinity of other processes" do
        assert_equal("[-1, #{Errno::EPERM::Errno}]\n", syscall!("sched_setaffinity", Process.pid, 0, 0))
      end

      # SVT-AV1 tries to give its threads realtime priority when it runs as root.
      should "make changing the scheduling policy fail with EPERM" do
        assert_match(/\A\[\d+, /, syscall!("sched_get_priority_max", 1)) # SCHED_FIFO
        assert_match(/\A\[\d+, /, syscall!("sched_get_priority_min", 1))

        %w[sched_setscheduler sched_setparam sched_setattr].each do |name|
          assert_equal("[-1, #{Errno::EPERM::Errno}]\n", syscall!(name, 0, 0, 0), name)
        end
      end
    end

    should "raise an error if the sandbox can't be set up" do
      MediaFile::Seccomp.stubs(:allow).returns(stub(to_bpf: "invalid"))
      error = assert_raises(MediaFile::ExternalCommand::Error) { MediaFile::ExternalCommand.run("echo hello") }

      assert_equal("can't run echo: invalid filter", error.message)
    end

    should "raise an error if the program doesn't exist and the sandbox is disabled" do
      MediaFile.config.stubs(:sandbox).returns(false)
      error = assert_raises(MediaFile::ExternalCommand::Error) { MediaFile::ExternalCommand.run("nosuchprogram") }

      assert_equal("can't run nosuchprogram: No such file or directory", error.message)
    end
  end

  context "MediaFile::FFmpeg.shell!" do
    should "raise an FFmpeg error when the command times out" do
      video = "test/files/mp4/test-300x300-av1.mp4"
      error = assert_raises(MediaFile::FFmpeg::Error) { MediaFile::FFmpeg.shell!("ffmpeg -re -stream_loop -1 -i #{video} -f null /dev/null", read: [video], timeout: 1) }
      assert_equal("ffmpeg timed out after 1 seconds", error.message)
    end

    should "raise an FFmpeg error when the command prints too much output" do
      error = assert_raises(MediaFile::FFmpeg::Error) { MediaFile::FFmpeg.shell!("ffprobe -version", output_limit: 10) }
      assert_equal("ffprobe printed more than 10 bytes", error.message)
    end

    should "not hide errors from the sandbox" do
      MediaFile::Landlock.stubs(:abi_version).returns(0)

      assert_raises(MediaFile::ExternalCommand::Error) { MediaFile::FFmpeg.shell!("ffprobe -version") }
    end
  end

  context "FFmpeg" do
    should "not let a file disguised as a video read other local files" do
      Dir.mktmpdir do |dir|
        FileUtils.cp("test/files/mp4/test-300x300-av1.mp4", "#{dir}/video.mp4")
        File.write("#{dir}/playlist.mp4", "ffconcat version 1.0\nfile video.mp4\n")

        media_file = MediaFile.open("#{dir}/playlist.mp4")
        media_file.stubs(:file_ext).returns(:mp4)
        ffmpeg = MediaFile::FFmpeg.new(media_file)

        assert_equal(0, ffmpeg.packet_count)
        assert_nil(ffmpeg.metadata[:streams])
        assert_not_nil(ffmpeg.metadata[:error])
      end
    end

    should "not process files of unsupported types" do
      media_file = MediaFile.open("test/files/mp4/test-300x300-av1.mp4")
      media_file.stubs(:file_ext).returns(:bin)

      assert_match(/unsupported file type/, MediaFile::FFmpeg.new(media_file).metadata[:error])
    end
  end
end
