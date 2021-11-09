# This is a wrapper around seccomp, a Linux kernel feature used to limit the
# system calls the current process is allowed to make. This is used for
# sandboxing code when processing user-uploaded files.
#
# @example
#   # Allow only the read(2), write(2), close(2), and exit_group(2) syscalls;
#   # kill the process if any other syscalls are used.
#   Seccomp.allow!(["read", "write", "close", "exit_group"])
#
#   # Kill the process if setuid(2) or seteuid(2) are used; allow all other syscalls.
#   Seccomp.deny!(["setuid", "seteuid"])
#
# Documentation:
#
# @see https://en.wikipedia.org/wiki/Seccomp
# @see https://lwn.net/Articles/656307/ - A seccomp overview
# @see https://lwn.net/Articles/494252/ - A library for seccomp filters
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
# @see https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_64.tbl
# @see https://github.com/systemd/systemd/blob/main/src/shared/seccomp-util.c
# @see https://marcin.juszkiewicz.com.pl/download/tables/syscalls.html
# @see https://filippo.io/linux-syscall-table/
# @see https://linux.die.net/man/8/ausyscall
module Seccomp
  # Symbolic groups of syscalls that can be used in filter lists.
  SYSCALL_GROUPS = {
    "@common" => %w[
      @exec @fs-write @process-info @tty

      futex
      prlimit64
      rt_sigaction rt_sigprocmask rt_sigreturn
      timer_delete
    ],
    "@memory" => %w[
      brk mmap munmap mprotect mremap
    ],
    "@exec" => %w[
      @memory
      @stdio
      @fs-read
      arch_prctl
      execve execveat
      set_robust_list
      set_tid_address
    ],
    "@stdio" => %w[
      close
      dup dup2 dup3
      getdents getdents64
      exit exit_group
      fadvise64
      fcntl
      fstat
      lseek
      pipe pipe2
      read pread64 readv preadv preadv2
      write pwrite64 writev pwritev pwritev2
    ],
    "@fs-open" => %w[
      open openat openat2
    ],
    "@fs-read" => %w[
      @fs-open
      access faccessat faccessat2
      chdir fchdir
      getcwd
      readlink readlinkat
      stat fstat newfstatat lstat
      statfs fstatfs
    ],
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
      unlink unlinkat
    ],
    "@fs-attr" => %w[
      @fs-write
      chmod fchmod fchmodat
      chown fchown fchownat lchown
      utime utimes utimensat futimesat
    ],
    "@io-event" => %w[
      epoll_create epoll_create1 epoll_ctl epoll_wait epoll_pwait
      eventfd eventfd2
      poll ppoll
      select pselect
    ],
    "@process-info" => %w[
      getpid getppid
      getpgid getpgrp
      getsid gettid
      getuid geteuid
      getgid getegid getgroups
      sched_getaffinity
      times
    ],
    "@process-control" => %w[
      clone clone3 fork vfork
      kill tkill tgkill rt_sigqueueinfo rt_tgsigqueueinfo
      pidfd_open pidfd_send_signal
      prlimit64
      setpgid setpgrp
      wait4 waitid waitpid
    ],
    "@signal" => %w[
      rt_sigaction sigaction
      rt_sigpending sigpending
      rt_sigprocmask sigprocmask
      rt_sigsuspend sigsuspend
      rt_sigtimedwait sigtimedwait sigwaitinfo
      rt_sigreturn
      signalfd signalfd4
      sigaltstack
      signal
      pause
    ],
    "@tty" => %w[
      ioctl
    ],
    "@privileged" => %w[
      prctl
      setns
      unshare
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

    # Create a new syscall filter. Use `add_rule!` to add rules to the filter
    # then `load!` to install it.
    #
    # If a block is given, run the block then automatically load the new filter.
    #
    # @param default_action [Symbol] the default action to take for any syscall
    #   that doesn't match a rule.
    # @param tsync [Boolean] whether to apply the filter to all threads in the
    #   current process, or just the current thread.
    # @param optimize [Boolean] whether to generate the filter as a binary tree
    #   or a sequential list
    def initialize(default_action = :kill_process, tsync: true, optimize: true)
      @context = init!(default_action)
      self.tsync = tsync
      self.optimize = optimize

      if block_given?
        yield self
        load!
      end
    end

    # Add a new rule to the filter.
    #
    # @param syscall_name [String] the syscall name
    # @param action [Symbol] the action to take when the syscall is called (:allow, :log, :kill_process, or :kill_thread)
    def add_rule!(syscall_name, action = :allow)
      syscall_number = Seccomp.resolve_syscall_name(syscall_name)
      raise Errno::EINVAL, "Seccomp::Filter.add_rule!(#{syscall_name.inspect}) failed; syscall '#{syscall_name}' doesn't exist" if syscall_number.nil?

      ret = LibSeccomp.seccomp_rule_add(context, action, syscall_number, 0)

      if ret < 0
        message = "LibSeccomp.seccomp_rule_add(#{context}, #{action}, #{syscall_number}, 0) failed"
        raise SystemCallError.new(message, -ret)
      end
    end

    # Activate the syscall filter by loading it into the kernel.
    def load!
      ret = LibSeccomp.seccomp_load(context)
      raise SystemCallError.new("seccomp_load(#{context}) failed", -ret) if ret < 0
    end

    # Set an attribute on the filter.
    #
    # @see https://man7.org/linux/man-pages/man3/seccomp_attr_set.3.html
    # @param [Symbol] the attribute name
    # @param [Integer] the attribute value
    def set_attr!(attr, value)
      ret = LibSeccomp.seccomp_attr_set(context, attr, value)
      raise SystemCallError.new("LibSeccomp.seccomp_attr_set(context, #{attr.inspect}, #{value}) failed", -ret) if ret < 0
    end

    # If true, add the filter to all threads in the process. If false,
    # add it only to the current thread.
    #
    # @param value [Boolean]
    def tsync=(value)
      set_attr!(:tsync, value ? 1 : 0)
      @tsync = value
    end

    # If true, generate the BPF code as a binary tree of if-else statements.
    # Good for large rule sets. If false, generate the BPF code as a sequential
    # list of if-else statements.
    #
    # @param value [Boolean]
    def optimize=(value)
      set_attr!(:optimize, value ? 2 : 1)
      @optimize = value
    end

    # Return a string representing the filter in BPF (Berkeley Packet Filter) format.
    #
    # @return [String]
    def to_bpf
      IO.pipe do |reader, writer|
        ret = LibSeccomp.seccomp_export_bpf(context, writer.fileno)
        raise SystemCallError.new("LibSeccomp.seccomp_export_bpf() failed", -ret) if ret < 0
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
        raise SystemCallError.new("LibSeccomp.seccomp_export_pfc() failed", -ret) if ret < 0
        writer.close
        reader.read
      end
    end

    protected

    # Create a new libseccomp context.
    #
    # @param default_action [Symbol] the default_action for the context
    # @return [FFI::Pointer] the libseccomp context
    def init!(default_action)
      context = LibSeccomp.seccomp_init(default_action)
      raise Errno::ENOMEM, "seccomp_init(#{default_action}) failed" if context == nil

      FFI::AutoPointer.new(context, LibSeccomp.method(:seccomp_release))
    end
  end

  # Allow only the given set of syscalls. Deny all other syscalls by default.
  # Calling a denied syscall will kill the process.
  def self.allow!(syscalls, default_action: :kill_process)
    filter!(syscalls, :allow, default_action: default_action)
  end

  # Deny the given set of syscalls. Allow all other syscalls by default.
  # Calling a denied syscall will kill the process.
  def self.deny!(syscalls, default_action: :allow)
    filter!(syscalls, :kill_process, default_action: default_action)
  end

  # Add a set of syscall filtering rules to the current process. Perform
  # `action` when any of the given syscalls are called, or `default_action`
  # when any other syscall is called.
  #
  # @param syscalls [Array<String>] The set of syscalls to act on
  # @param action [Symbol] the action to take when one of the given syscalls is called
  # @param [Symbol] The action to take when any other syscall is called
  def self.filter!(syscalls, action, default_action: :kill_process)
    Filter.new(default_action) do |filter|
      expand_syscall_names(syscalls).each do |syscall|
        filter.add_rule!(syscall, action)
      end
    end
  end

  # Return the list of syscalls available on the current system. This list may
  # vary depending on the CPU architecture and kernel version.
  #
  # @return [Hash<Integer, String>] a hash of syscall numbers to syscall names
  def self.syscalls
    0.upto(8192).map do |n|
      [n, resolve_syscall_number(n) ]
    end.to_h.compact
  end

  # Recursively expand a list of syscall names, that may contain a mixture of regular
  # names and syscall group names (e.g. `@common`), to a flat list of syscall names.
  #
  # @param syscall_names [Array<String>] a list of syscall names, including syscall groups
  # @return [Array<String>] a list of syscall names
  def self.expand_syscall_names(syscall_names)
    syscall_names.flat_map do |syscall|
      if syscall.starts_with?("@")
        group = SYSCALL_GROUPS.fetch(syscall)
        expand_syscall_names(group)
      else
        syscall
      end
    end.sort.uniq
  end

  # Resolve a syscall name to a syscall number.
  #
  # @param [String] the syscall name
  # @return [Integer, nil] the syscall number, or nil if a syscall by that name doesn't exist
  def self.resolve_syscall_name(syscall_name)
    syscall_number = LibSeccomp.seccomp_syscall_resolve_name(syscall_name.to_s)
    return nil if syscall_number < 0
    syscall_number
  end

  # Resolve a syscall number to a syscall name.
  #
  # @param [Integer] the syscall number
  # @return [String, nil] the syscall name, or nil if a syscall by that number doesn't exist
  def self.resolve_syscall_number(syscall_number, arch = :native)
    name, ptr = LibSeccomp.seccomp_syscall_resolve_num_arch(arch, syscall_number)
    name
  ensure
    LibC.free(ptr)
  end
end
