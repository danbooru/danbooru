# frozen_string_literal: true

# This is a wrapper around seccomp, a Linux kernel feature used to limit the
# system calls the current process is allowed to make. This is used for
# sandboxing code when processing user-uploaded files.
#
# @example
#   # Allow only the read(2), write(2), close(2), and exit_group(2) syscalls to be used
#   # for the remainder of the program; kill the process if any other syscalls are called.
#   Seccomp.allow!("read write close exit_group")
#
#   # Kill the process if sync(2) is called; allow all other syscalls.
#   Seccomp.deny!("sync")
#
#   # Run exiftool in a sandboxed subprocess, allowing it to only use syscalls
#   # from the @exec, @signals, and @tty syscall groups.
#   Seccomp.allow!("@exec @signals @tty") do
#     exec "exiftool -json image.jpg"
#   end
#
#   # Run a shell inside a seccomp sandbox.
#   Seccomp.allow!("@common") { exec "dash" }
#
#   # Print a human-readable dump of the seccomp filter.
#   puts Seccomp.allow("@exec @signals @tty").to_pfc
#
#   # Show all available syscalls.
#   puts Seccomp.syscalls
#
# Documentation:
#
# @see https://en.wikipedia.org/wiki/Seccomp
# @see https://lwn.net/Articles/656307/ A seccomp overview
# @see https://lwn.net/Articles/494252/ A library for seccomp filters
# @see https://www.kernel.org/doc/html/latest/userspace-api/seccomp_filter.html
# @see https://man7.org/linux/man-pages/man2/seccomp.2.html
# @see https://github.com/seccomp/libseccomp
# @see https://blog.cloudflare.com/sandboxing-in-linux-with-zero-lines-of-code/
# @see https://docs.docker.com/engine/security/seccomp/
# @see https://kubernetes.io/docs/tutorials/clusters/seccomp/
# @see https://www.freedesktop.org/software/systemd/man/systemd.exec.html#System%20Call%20Filtering
#
# Related projects:
#
# @see https://github.com/cloudflare/sandbox
# @see https://github.com/david942j/seccomp-tools
# @see https://man.openbsd.org/pledge.2
# @see https://dev.exherbo.org/~alip/sydbox/
#
# Syscall lists:
#
# @see https://github.com/seccomp/libseccomp/blob/main/src/syscalls.csv
# @see https://github.com/systemd/systemd/blob/main/src/shared/seccomp-util.c#L281
# @see https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_64.tbl
# @see https://marcin.juszkiewicz.com.pl/download/tables/syscalls.html
# @see https://filippo.io/linux-syscall-table/
module Seccomp
  class Error < StandardError; end

  # Symbolic groups of syscalls that can be used in filters.
  SYSCALL_GROUPS = {
    # A broad set of common syscalls sufficient to run most programs.
    "@common" => %w[
      @exec @exit @fs @memory @network @process-control @process-info @signals
      @stdio @system-info @threads @time @tty
    ],
    # Syscalls needed to cleanly exit a Ruby program.
    "@exit" => %w[
      exit exit_group getpid munmap rt_sigaction timer_delete
    ],
    # Syscalls needed to allocate and manage memory.
    "@memory" => %w[
      brk mmap mmap2 munmap mprotect mremap
    ],
    # Syscalls needed by multi-threaded Ruby programs.
    "@threads" => %w[
      futex getpid mmap ppoll read write sched_yield
    ],
    # Syscalls commonly needed to execute external programs.
    "@exec" => %w[
      @memory
      @stdio
      @fs-read
      @process-info
      @exit
      arch_prctl
      execve execveat
      futex
      set_robust_list
      set_tid_address
      prlimit64
      timer_settime
    ],
    # Syscalls for reading and writing open files.
    "@stdio" => %w[
      close
      dup dup2 dup3
      getdents getdents64
      fadvise64
      fcntl
      fgetxattr
      fstat
      lseek
      pipe pipe2
      read pread64 readv preadv preadv2
      write pwrite64 writev pwritev pwritev2
    ],
    # Syscalls for opening files.
    "@fs-open" => %w[
      open openat openat2
    ],
    # Syscalls that read information from the filesystem.
    "@fs-read" => %w[
      @fs-open
      access faccessat faccessat2
      chdir fchdir
      getcwd
      getxattr lgetxattr fgetxattr
      readlink readlinkat
      stat fstat newfstatat lstat
      statfs fstatfs
    ],
    # Syscalls that modify data on the filesystem.
    "@fs-write" => %w[
      @fs-read
      creat
      fallocate
      link linkat
      mkdir mkdirat
      rename renameat renameat2
      rmdir
      symlink symlinkat
      truncate ftruncate
      umask
      unlink unlinkat
    ],
    # Syscalls that modify metadata on the filesystem.
    "@fs-attr" => %w[
      @fs-write
      chmod fchmod fchmodat
      chown fchown fchownat lchown
      setxattr lsetxattr fsetxattr
      utime utimes utimensat futimesat
    ],
    # Syscalls for reading or writing to the filesystem.
    "@fs" => %w[
      @stdio @fs-attr
    ],
    "@evented-io" => %w[
      epoll_create epoll_create1 epoll_ctl epoll_wait epoll_pwait
      eventfd eventfd2
      poll ppoll
      select pselect6
    ],
    "@network" => %w[
      socket socketpair
      accept accept4
      bind
      connect
      listen
      shutdown

      recv recvfrom recvmsg recvmmsg recvmmsg_time64
      send sendto sendmsg sendmmsg
      getpeername
      getsockname
      getsockopt setsockopt
    ],
    "@process-info" => %w[
      capget
      getpid getppid
      getpgid getpgrp
      getsid gettid
      getuid geteuid getresuid
      getgid getegid getresgid getgroups
      sched_getaffinity
      times
    ],
    "@process-control" => %w[
      clone clone3 fork vfork
      getpriority setpriority
      kill tkill tgkill rt_sigqueueinfo rt_tgsigqueueinfo
      nice
      pidfd_open pidfd_send_signal
      prlimit64
      setpgid
      wait4 waitid waitpid
    ],
    "@signals" => %w[
      alarm
      rt_sigaction sigaction
      rt_sigpending sigpending
      rt_sigprocmask sigprocmask
      rt_sigsuspend sigsuspend
      rt_sigtimedwait rt_sigtimedwait_time64
      rt_sigreturn
      signalfd signalfd4
      sigaltstack
      signal
      pause
    ],
    "@system-info" => %w[
      sysinfo
      uname
    ],
    "@time" => %w[
      nanosleep clock_nanosleep
      clock_getres
      clock_gettime
      gettimeofday
      time
    ],
    "@tty" => %w[
      ioctl
    ],
  }

  # A lowlevel wrapper around libseccomp using the Ruby FFI.
  #
  # https://github.com/ffi/ffi/wiki
  # https://github.com/seccomp/libseccomp
  module LibSeccomp
    extend FFI::Library
    ffi_lib "libseccomp"

    # https://github.com/seccomp/libseccomp/blob/main/include/seccomp.h.in#L121
    enum :arch, [:native, 0]

    # https://github.com/seccomp/libseccomp/blob/main/include/seccomp.h.in#L332
    enum FFI::Type::UINT32, :action, [
      :kill,         0x80000000,
      :kill_process, 0x80000000,
      :kill_thread,  0x00000000,
      :log,          0x7ffc0000,
      :allow,        0x7fff0000,
    ]

    # https://github.com/seccomp/libseccomp/blob/main/include/seccomp.h.in#L64
    enum :attr, [
      :tsync,    4,
      :optimize, 8,
    ]

    typedef :pointer, :scmp_filter_ctx

    # seccomp_init - Initialize the seccomp filter state
    # https://man7.org/linux/man-pages/man3/seccomp_init.3.html
    # scmp_filter_ctx seccomp_init(uint32_t def_action);
    attach_function :seccomp_init, [:action], :scmp_filter_ctx

    # seccomp_load - Load the current seccomp filter into the kernel
    # https://man7.org/linux/man-pages/man3/seccomp_load.3.html
    # int seccomp_load(scmp_filter_ctx ctx);
    attach_function :seccomp_load, [:scmp_filter_ctx], :int

    # seccomp_release - Release the seccomp filter state
    # https://man7.org/linux/man-pages/man3/seccomp_release.3.html
    # void seccomp_release(scmp_filter_ctx ctx);
    attach_function :seccomp_release, [:scmp_filter_ctx], :void

    # seccomp_rule_add - Add a seccomp filter rule
    # https://man7.org/linux/man-pages/man3/seccomp_rule_add.3.html
    # int seccomp_rule_add(scmp_filter_ctx ctx, uint32_t action, int syscall, unsigned int arg_cnt, ...);
    attach_function :seccomp_rule_add, [:scmp_filter_ctx, :action, :int, :uint32], :int

    # seccomp_syscall_resolve_name - Resolve a syscall name to a number
    # https://man7.org/linux/man-pages/man3/seccomp_syscall_resolve_name.3.html
    # int seccomp_syscall_resolve_name(const char *name);
    attach_function :seccomp_syscall_resolve_name, [:string], :int

    # seccomp_syscall_resolve_name - Resolve a syscall number to a name
    # https://man7.org/linux/man-pages/man3/seccomp_syscall_resolve_num_arch.3.html
    # char* seccomp_syscall_resolve_num_arch(uint32_t arch_token, int num)
    attach_function :seccomp_syscall_resolve_num_arch, [:arch, :int], :strptr

    # seccomp_attr_set - Manage the seccomp filter attributes
    # https://man7.org/linux/man-pages/man3/seccomp_attr_set.3.html
    # int seccomp_attr_set(scmp_filter_ctx ctx, enum scmp_filter_attr attr, uint32_t value);
    attach_function :seccomp_attr_set, [:scmp_filter_ctx, :attr, :uint32], :int

    # seccomp_export_bpf - Export the seccomp filter as BPF
    # int seccomp_export_bpf(const scmp_filter_ctx ctx, int fd);
    # https://man7.org/linux/man-pages/man3/seccomp_export_bpf.3.html
    attach_function :seccomp_export_bpf, [:scmp_filter_ctx, :int], :int

    # seccomp_export_pfc - Export the seccomp filter as PFC
    # int seccomp_export_pfc(const scmp_filter_ctx ctx, int fd);
    # https://man7.org/linux/man-pages/man3/seccomp_export_pfc.3.html
    attach_function :seccomp_export_pfc, [:scmp_filter_ctx, :int], :int
  end

  module LibC
    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    attach_function :free, [:pointer], :void
  end

  # A Seccomp::Filter represents a single seccomp filter, containing a set of
  # syscall filtering rules and a default action.
  class Filter
    attr_reader :context, :tsync, :optimize

    # Create a new syscall filter. Use `add_rule` to add rules to the filter.
    # Use `apply!` to activate the filter after all rules have been added.
    #
    # If a block is given, run the block with the new filter.
    #
    # @param default_action [Symbol] The default action to take when a syscall
    #   doesn't match a rule.
    # @param tsync [Boolean] True to apply the filter to all threads in the
    #   current process. False to apply it just to the current thread.
    # @param optimize [Boolean] True to generate the filter as a binary tree,
    #   false as a sequential list.
    def initialize(default_action = :kill, tsync: true, optimize: false)
      @context = init!(default_action)
      self.tsync = tsync
      self.optimize = optimize

      yield self if block_given?
    end

    # Add a syscall rule to the filter. If the syscall doesn't exist, raise an error.
    #
    # @param syscall_name [String] The name of the syscall
    # @param action [Symbol] The action to take when the syscall is called (:allow, :log, :kill)
    # @return [self]
    # @raise [SystemCallError] If the rule couldn't be added
    def add_rule(syscall_name, action)
      syscall_number = Seccomp.resolve_syscall_name(syscall_name)
      ret = LibSeccomp.seccomp_rule_add(context, action, syscall_number, 0)
      raise SystemCallError.new("seccomp_rule_add(#{action}, #{syscall_name}) failed", -ret) if ret < 0

      self
    end

    # Activate the syscall filter by loading it into the kernel. All code after
    # this point must obey the syscall filter.
    #
    # If a block is given, apply the filter to the given block of code. The
    # block is run in a forked subprocess, which means the filter only applies
    # to the block of code.
    #
    # @return [self]
    def apply!(&block)
      return apply_to!(&block) if block_given?

      ret = LibSeccomp.seccomp_load(context)
      raise SystemCallError.new("seccomp_load(#{context}) failed", -ret) if ret < 0
      self
    end

    # Apply the filter to a block of code in a forked subprocess.
    def apply_to!(&block)
      raise ArgumentError, "Seccomp::Filter#apply_block!: block required" unless block_given?

      pid = Process.fork do
        apply!
        yield self
      end

      pid, status = Process.wait2(pid)
      if status.signaled? && Signal.signame(status.termsig) == "SYS"
        raise Error, "Subprocess called unauthorized syscall (see dmesg for details)"
      end

      self
    end

    # Return a string representing the filter in BPF (Berkeley Packet Filter) format.
    #
    # @return [String]
    def to_bpf
      IO.pipe do |reader, writer|
        ret = LibSeccomp.seccomp_export_bpf(context, writer.fileno)
        raise SystemCallError.new("seccomp_export_bpf() failed", -ret) if ret < 0
        writer.close
        reader.read
      end
    end

    # Return a string representing the filter in PFC (Pseudo Filter Code) format.
    #
    # @return [String]
    def to_pfc
      IO.pipe do |reader, writer|
        ret = LibSeccomp.seccomp_export_pfc(context, writer.fileno)
        raise SystemCallError.new("seccomp_export_pfc() failed", -ret) if ret < 0
        writer.close
        reader.read
      end
    end

    protected

    # Create a new libseccomp context.
    #
    # @param default_action [Symbol] The default_action for the context
    # @return [FFI::AutoPointer] The libseccomp context
    def init!(default_action)
      context = LibSeccomp.seccomp_init(default_action)
      raise Errno::ENOMEM, "seccomp_init(#{default_action}) failed" if context == nil

      FFI::AutoPointer.new(context, LibSeccomp.method(:seccomp_release))
    end

    # Set an attribute on the filter.
    #
    # @see https://man7.org/linux/man-pages/man3/seccomp_attr_set.3.html
    # @param [Symbol] the attribute name
    # @param [Integer] the attribute value
    def set_attr(attr, value)
      ret = LibSeccomp.seccomp_attr_set(context, attr, value)
      raise SystemCallError.new("seccomp_attr_set(context, #{attr.inspect}, #{value}) failed", -ret) if ret < 0
    end

    # If true, apply the filter to all threads in the process. If false,
    # apply it only to the current thread.
    #
    # @param value [Boolean]
    # @return [void]
    def tsync=(value)
      set_attr(:tsync, value ? 1 : 0)
      @tsync = value
    end

    # If true, generate the BPF code as a binary tree of if-else statements.
    # May be faster for large rule sets. If false, generate the BPF code as a
    # sequential list of if-else statements.
    #
    # @param value [Boolean]
    # @return [void]
    def optimize=(value)
      set_attr(:optimize, value ? 2 : 1)
      @optimize = value
    end
  end

  # Create a filter allowing only the given set of syscalls. Deny all other
  # syscalls by default. Calling a denied syscall will kill the process by default.
  def self.allow(syscalls, default_action: :kill)
    filter(syscalls, :allow, default_action: default_action)
  end

  # Create a filter denying the given set of syscalls. Allow all other
  # syscalls by default. Calling a denied syscall will kill the process by default.
  def self.deny(syscalls, default_action: :allow)
    filter(syscalls, :kill, default_action: default_action)
  end

  # Create and immediately apply a filter allowing only the given set of syscalls.
  def self.allow!(syscalls, default_action: :kill, &block)
    allow(syscalls, default_action: default_action).apply!(&block)
  end

  # Create and immediately apply a filter denying the given set of syscalls.
  def self.deny!(syscalls, default_action: :allow, &block)
    deny(syscalls, default_action: default_action).apply!(&block)
  end

  # Create a syscall filter for the current process that performs `action` when
  # any of the given syscalls are called, or `default_action` when any other
  # syscall is called.
  #
  # Call `apply!` on the result to activate the filter.
  #
  # @param syscalls [Array<String>] The set of syscalls
  # @param action [Symbol] The action to take when any of the given syscalls are called (:allow, :log, :kill)
  # @param default_action [Symbol] The action to take when any other syscall is called (:allow, :log, :kill)
  # @param options [Hash] Options to pass to Seccomp::Filter#initialize
  # @return [Seccomp::Filter] the seccomp filter
  def self.filter(syscalls, action, default_action: :kill, **options)
    Filter.new(default_action, **options) do |filter|
      expand_syscall_names(syscalls).each do |syscall|
        filter.add_rule(syscall, action)
      end
    end
  end

  # Return the list of syscalls available on the current system. This list may
  # vary depending on the CPU architecture and kernel version.
  #
  # @return [Hash<Integer, String>] a hash of syscall numbers to syscall names
  def self.syscalls
    @syscalls ||= 0.upto(8192).map do |n|
      [n, resolve_syscall_number(n) ]
    end.to_h.compact
  end

  # Recursively expand a list of syscall names, that may contain a mixture of regular
  # names and syscall group names (e.g. `@stdio`), to a flat list of syscall names.
  #
  # @param syscall_names [Array<String>] A list of syscall names. May include syscall
  #   groups (e.g `@stdio`). May be a space-separated string, or a list of strings.
  # @return [Array<String>] A list of syscall names
  def self.expand_syscall_names(*syscall_names)
    syscall_names.flatten.flat_map(&:split).flat_map do |syscall|
      if syscall.start_with?("@")
        group = SYSCALL_GROUPS.fetch(syscall)
        expand_syscall_names(group)
      else
        syscall
      end
    end.sort.uniq
  end

  # Resolve a syscall name to a syscall number.
  #
  # May return a negative number if the syscall exists on another architecture,
  # but not on this architecture. For example, `arch_prctl` exists on x86 but
  # not on ARM or other architectures.
  #
  # Raises an error if the syscall doesn't exist on any architecture.
  #
  # @param [String] the syscall name
  # @return [Integer] the syscall number
  # @raise [Errno::EINVAL] if the syscall doesn't exist
  def self.resolve_syscall_name(syscall_name)
    syscall_number = LibSeccomp.seccomp_syscall_resolve_name(syscall_name.to_s)
    raise Errno::EINVAL, "Syscall '#{syscall_name}' doesn't exist" if syscall_number == -1
    syscall_number
  end

  # Resolve a syscall number to a syscall name.
  #
  # @param syscall_number [Integer] The syscall number
  # @param arch [Symbol] The CPU architecture (x86_64, aarch64, etc)
  # @return [String, nil] The syscall name, or nil if a syscall by that number doesn't exist
  def self.resolve_syscall_number(syscall_number, arch = :native)
    name, ptr = LibSeccomp.seccomp_syscall_resolve_num_arch(arch, syscall_number)
    name
  ensure
    LibC.free(ptr)
  end
end
