# frozen_string_literal: true

require "io/nonblock"

# Runs the external programs that we use on untrusted files (ffmpeg, ffprobe, mkvmerge, exiftool, bin/archive for
# archives and ugoiras, and bin/image for images) in a sandbox, with time, memory, and output limits, so that a
# malicious file can't make them run forever, use all the memory, or do anything else if it manages to exploit a bug in
# the program.
#
# The sandbox uses Landlock to limit which files the command can access, and seccomp to limit which system calls it can
# make. Both work without root and without any special support from Docker or Kubernetes. Both are turned off by
# `Danbooru.config.disable_upload_sandbox?`.
#
# Commands are started with setpriv(1), which applies the sandbox and then runs the command. This is much faster than
# forking the Rails process to apply the sandbox, because forking a large process is slow.
class ExternalCommand
  class Error < StandardError; end
  class TimeoutError < Error; end
  class OutputLimitError < Error; end

  class SyscallError < Error
    # @return [SyscallError, nil] The error if it's a SyscallError or wraps one, like the errors raised by `parallel_each`.
    def self.find_in(error)
      [error, *(error.errors if error.is_a?(Concurrent::MultipleErrors))].find { it.is_a?(SyscallError) }
    end
  end

  TIMEOUT = 1.minute
  MEMORY_LIMIT = 4.gigabytes

  # The most output a command can print before it's killed.
  OUTPUT_LIMIT = 16.megabytes

  # The environment variables passed to commands, plus the `environment` of their profile. Commands use jemalloc (see the
  # Dockerfile) to stay under the memory limit.
  ENVIRONMENT = %w[PATH LD_PRELOAD MALLOC_CONF].freeze

  # What every command can do: load shared libraries, and use basic syscalls for memory, files, threads, and signals.
  # This leaves out syscalls for starting processes, opening network sockets, creating namespaces, tracing processes,
  # signalling any process, and other things these programs don't need. Commands are killed if they use any other syscall.
  BASE_PROFILE = {
    # /usr/lib has the dynamic linker, which has to be executable, and the coreutils programs (cat, echo, env...) that
    # /usr/bin links to.
    execute: %w[/usr/lib],
    read: %w[/etc/ld.so.cache /etc/ld.so.preload /etc/malloc.conf],
    write: %w[/dev/null],
    # socketpair and recvfrom are only for local sockets, since the syscalls for opening network sockets aren't allowed.
    syscalls: %w[
      @exec @exit @memory @process-info @process-self @setpriv @signals @stdio @threads @time @tty
      poll recvfrom socketpair
    ],
  }.freeze

  # What the Ruby helper scripts (bin/archive and bin/image) need on top of the base profile. They're run with this exact
  # Ruby. Ruby's timer thread waits on an eventfd with epoll, and Ruby turns off transparent huge pages.
  RUBY_PROFILE = {
    execute: [RbConfig.ruby],
    read: [RbConfig::CONFIG["rubylibprefix"], File.join(RbConfig::CONFIG["libdir"], RbConfig::CONFIG["LIBRUBY_SO"])],
    syscalls: ["eventfd2", "epoll_create1", "epoll_ctl", "epoll_wait", "epoll_pwait", ["prctl", :allow, [[0, :eq, Seccomp::PR_SET_THP_DISABLE]]]],
  }.freeze

  # What each program can do on top of the base profile. Programs not listed here only get the base profile. The Ruby
  # helper scripts are looked up by the `profile_name:` they're run with instead, because they all run the same Ruby.
  PROFILES = {
    "ffmpeg" => {
      execute: %w[/usr/local/bin/ffmpeg],
      read: %w[/usr/local/lib],
      # ffmpeg checks stdin for keypresses with pselect6.
      syscalls: %w[getrusage pselect6],
    },
    "ffprobe" => {
      execute: %w[/usr/local/bin/ffprobe],
      read: %w[/usr/local/lib],
    },
    "mkvmerge" => {
      execute: %w[/usr/bin/mkvmerge],
      read: %w[/usr/share/locale],
      syscalls: %w[uname],
    },
    "exiftool" => {
      execute: %w[/usr/local/bin/exiftool /usr/bin/perl],
      read: %w[/usr/local/share/perl /usr/share/perl /usr/share/perl5 /etc/perl /dev/urandom],
      # Perl calls symlink("", "") to check if symlinks are supported. Landlock stops it from creating any.
      syscalls: %w[symlink],
    },
    # Extracting archives creates directories and sets the umask, libarchive truncates a file when it fails partway
    # through extracting it (for example, when it runs out of memory), and writing zips renames temp files into place.
    # Landlock only lets them write in the given directories.
    "bin/archive" => RUBY_PROFILE.merge(
      syscalls: RUBY_PROFILE[:syscalls] + %w[umask mkdir mkdirat rename renameat renameat2 unlink unlinkat ftruncate],
    ),
    # bin/image only writes the output files it's given, which it creates by opening them. It reads libvips, its
    # modules, and mozjpeg from /usr/local/lib (see the Dockerfile). jemalloc keeps the address space of freed memory by
    # default, which counts against the memory limit, so the largest WebPs would run out of address space while hashing
    # their pixels.
    "bin/image" => RUBY_PROFILE.merge(
      read: RUBY_PROFILE[:read] + %w[/usr/local/lib],
      environment: { "MALLOC_CONF" => [ENV.fetch("MALLOC_CONF", nil), "retain:false"].compact_blank.join(",") },
    ),
  }.freeze

  attr_reader :argv, :program, :profile, :read, :write, :timeout, :memory_limit, :output_limit, :file_size_limit

  # Run a command and return its output. The command is killed if it runs longer than the timeout or prints more than
  # the output limit.
  #
  # The command isn't run through a shell, and it only gets the variables in ENVIRONMENT, so it can't see secrets like
  # database passwords or API keys.
  #
  # @param command [String] The command to run. Arguments must already be shell-escaped.
  # @param read [Array<String>] The files and directories the command can read, besides the system directories.
  # @param write [Array<String>] The files and directories the command can read and write.
  # @param timeout [Integer] The maximum number of seconds the command can run.
  # @param memory_limit [Integer] The maximum number of bytes of memory the command can use.
  # @param output_limit [Integer] The maximum number of bytes the command can print to stdout and stderr.
  # @param file_size_limit [Integer, nil] The maximum size in bytes of any file the command writes, or nil for no limit.
  # @param profile_name [String, nil] The name of the sandbox profile in PROFILES to use, if it isn't the program's name.
  # @return [Array<(String, Process::Status)>] The combined stdout and stderr of the command, and its exit status.
  # @raise [TimeoutError] If the command ran longer than the timeout.
  # @raise [OutputLimitError] If the command printed more than the output limit.
  # @raise [SyscallError] If the command was killed for using a blocked system call.
  # @raise [Error] If the command couldn't be started, or if Landlock isn't supported and the sandbox isn't disabled.
  def self.run(...)
    new(...).run
  end

  # Run one of our Ruby helper scripts, like bin/archive or bin/image, with the sandbox profile of the same name. It's
  # run with this exact Ruby, without Bundler, so it starts quickly. The gems it uses are passed with `-I`.
  #
  # @param script [String] The script, relative to the Rails root, like "bin/image".
  # @param args [Array] The arguments to the script.
  # @param gems [Array<String>] The names of the bundled gems the script uses.
  # @param read [Array<String>] The files and directories the script can read.
  # @param options [Hash] The other options for `ExternalCommand.run`.
  # @return [Hash, nil] The JSON object the script printed on the last line of its output, or nil if it crashed. The
  #   script parses untrusted files, so the caller must check the result.
  # @raise (see ExternalCommand.run)
  def self.run_script(script, *args, gems:, read: [], **options)
    path = Rails.root.join(script).to_s
    gem_paths = gems.flat_map { Gem.loaded_specs.fetch(it).full_require_paths }
    command = [RbConfig.ruby, "--disable-gems", "-W0", *gem_paths.map { "-I#{it}" }, path, *args].map { it.to_s.shellescape }.join(" ")
    output, _status = run(command, read: [path, *gem_paths, *read], profile_name: script, **options)

    # The result is on the last line, in case a library printed a warning before it. If it crashed, the output is a
    # backtrace. It's logged, but not shown to the user. It's escaped, because it can include text from the file, which
    # could add fake lines to the log.
    result = output.lines.last.to_s.parse_json
    return result if result.is_a?(Hash)

    DanbooruLogger.info("#{script} crashed: #{output.truncate(2000).inspect}")
    nil
  end

  # @see ExternalCommand.run
  def initialize(command, read: [], write: [], timeout: TIMEOUT, memory_limit: MEMORY_LIMIT, output_limit: OUTPUT_LIMIT, file_size_limit: nil, profile_name: nil) # rubocop:disable Metrics/ParameterLists
    @argv = command.shellsplit
    @program = argv.first
    raise ArgumentError, "can't run an empty command" if program.nil?

    @profile = PROFILES.fetch(profile_name || program, {})
    @read = read
    @write = write
    @timeout = timeout
    @memory_limit = memory_limit
    @output_limit = output_limit
    @file_size_limit = file_size_limit
  end

  # @see ExternalCommand.run
  def run
    sandbox = sandbox?
    # Commands are killed if the Rails process dies, because only the Rails process enforces the timeout.
    command = ["setpriv", "--pdeathsig", "KILL", *(sandbox ? sandbox_args : []), "--", *argv]
    filter = Seccomp.allow(BASE_PROFILE[:syscalls] + profile.fetch(:syscalls, [])).to_bpf if sandbox
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
    output = output_writer = stdin = stdin_writer = pid = exited = status = nil

    begin
      output, output_writer = IO.pipe
      # setpriv reads the seccomp filter from stdin. The command gets an empty stdin after setpriv has read it.
      stdin, stdin_writer = IO.pipe
      stdin_writer.write(filter) if sandbox
      stdin_writer.close

      # Ruby makes pipes non-blocking, which would make the command's writes fail when the pipe is full, so it would lose output.
      output_writer.nonblock = false

      # Errors raised in this thread from outside, like Rack::Timeout's, are held off until we have the pid and the
      # status, so we always know whether the command is still running and needs to be killed.
      Thread.handle_interrupt(Object => :never) do
        pid = Process.spawn(
          ENV.slice(*ENVIRONMENT).merge(profile.fetch(:environment, {})), *command,
          in: stdin, out: output_writer, err: output_writer, unsetenv_others: true, close_others: true,
          # Disable core dumps, otherwise a command that crashes when it hits the memory limit can fill the disk.
          rlimit_as: memory_limit.to_i, rlimit_core: 0, **(file_size_limit ? { rlimit_fsize: file_size_limit.to_i } : {}),
        )
      end

      output_writer.close
      stdin.close
      exited = IO.for_fd(LibC.pidfd_open!(pid))
      result = read_output!(output, deadline)

      # The command may have closed its output but kept running. The pidfd is readable once the command exits.
      timed_out! unless exited.wait_readable(remaining(deadline))
      Thread.handle_interrupt(Object => :never) { status = Process.wait2(pid).last }
    ensure
      Thread.handle_interrupt(Object => :never) do
        # Kill the command if we stopped before it exited, because of a timeout, the output limit, or an error from
        # outside. In the sandbox the command can't start other processes, so this stops everything it started. Its
        # pid can't have been reused yet, because we haven't waited on it.
        if pid && status.nil?
          Process.kill(:KILL, pid)
          Process.wait(pid)
        end

        [output, output_writer, stdin, stdin_writer, exited].compact.each(&:close)
      end
    end

    if Seccomp.killed?(status)
      # Log it, because a file that makes a program call a blocked syscall may be an attempt to exploit the program.
      Rails.logger.error("ExternalCommand: #{program} called a blocked syscall (command: #{argv.join(" ").truncate(1000)})")
      raise SyscallError, "#{program} called a blocked syscall"
    end

    raise Error, "can't run #{program}: #{result.lines.first.chomp.delete_prefix("setpriv: ").delete_prefix("failed to execute #{program}: ")}" if !status.success? && result.start_with?("setpriv: ")

    [result.force_encoding(Encoding.default_external), status]
  end

  private

  # @return [Boolean] True if the command should be run with Landlock and seccomp.
  # @raise [Error] If Landlock isn't supported. Running without it must be explicitly allowed, so that a kernel without
  #   Landlock doesn't silently turn it off.
  def sandbox?
    return false if Danbooru.config.disable_upload_sandbox?.to_s.truthy?
    raise Error, "can't run #{program}: Landlock isn't supported by this kernel (set DANBOORU_DISABLE_UPLOAD_SANDBOX=true to disable sandboxing)" unless Landlock.supported?

    true
  end

  # @return [Array<String>] The setpriv options for running the command with Landlock and the seccomp filter from stdin.
  def sandbox_args
    # setpriv doesn't support ioctl_dev. Seccomp only allows ioctls that check for a terminal anyway.
    supported_access = Landlock::ACCESS_FS.filter_map { |name, abi| name if abi <= Landlock.abi_version } - [:ioctl_dev]
    setpriv_access = ->(access) { (access & supported_access).map { it.to_s.tr("_", "-") }.join(",") }

    rules = [
      [BASE_PROFILE[:read] + profile.fetch(:read, []) + read, Landlock::READ_ACCESS],
      [BASE_PROFILE[:execute] + profile.fetch(:execute, []), Landlock::EXECUTE_ACCESS],
      [BASE_PROFILE[:write] + write, Landlock::WRITE_ACCESS],
    ]

    # Paths that don't exist are skipped. Paths that are symlinks aren't allowed, because the rule would give access to
    # whatever the symlink points to instead.
    landlock_rules = rules.flat_map do |paths, access|
      paths.select { File.exist?(it) }.flat_map do |path|
        raise Error, "can't run #{program}: #{path} can't be sandboxed because it's a symlink" if File.symlink?(path)

        path_access = File.directory?(path) ? access : access & Landlock::FILE_ACCESS
        ["--landlock-rule", "path-beneath:#{setpriv_access.call(path_access)}:#{path}"]
      end
    end

    ["--nnp", "--landlock-access", "fs:#{setpriv_access.call(supported_access)}", *landlock_rules, "--seccomp-filter", "/dev/stdin"]
  end

  # Read the command's output until it closes it.
  #
  # @return [String] The output, as binary.
  # @raise [TimeoutError] If the command runs past the deadline.
  # @raise [OutputLimitError] If the command prints too much.
  def read_output!(output, deadline)
    buffer = "".b

    loop do
      timed_out! unless output.wait_readable(remaining(deadline))

      chunk = output.read_nonblock(64.kilobytes, exception: false)
      return buffer if chunk.nil?
      next if chunk == :wait_readable

      buffer << chunk
      raise OutputLimitError, "#{program} printed more than #{output_limit} bytes" if buffer.bytesize > output_limit
    end
  end

  def timed_out!
    raise TimeoutError, "#{program} timed out after #{timeout.to_i} seconds"
  end

  # @return [Float] The number of seconds left until the deadline, or 0 if it has passed.
  def remaining(deadline)
    [deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC), 0].max
  end

  module LibC
    extend FFI::Library

    ffi_lib FFI::Library::LIBC

    # The syscall number is the same on all architectures.
    SYS_PIDFD_OPEN = 434

    attach_function :syscall, [:long, :varargs], :long

    # @return [Integer] A file descriptor that becomes readable when the process exits.
    def self.pidfd_open!(pid)
      ret = syscall(SYS_PIDFD_OPEN, :int, pid, :uint, 0)
      raise SystemCallError.new("pidfd_open", FFI.errno) if ret < 0
      ret
    end
  end
end
