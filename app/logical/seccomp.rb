# frozen_string_literal: true

# This is a wrapper around libseccomp for building seccomp filters, which limit the system calls a process is allowed
# to make. ExternalCommand exports the filters as BPF and loads them with setpriv(1) to sandbox programs that process
# user-uploaded files.
#
# @example
#   # Build a filter that only allows the @exec, @signals, and @tty syscall groups, as BPF for `setpriv --seccomp-filter`.
#   bpf = Seccomp.allow("@exec @signals @tty").to_bpf
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
  # The clone(2) flags for creating namespaces. Namespaces expose a lot of the kernel to attacks.
  CLONE_NAMESPACE_FLAGS = 0x7E020000

  # The clone(2) flag for creating a thread instead of a process.
  CLONE_THREAD = 0x00010000

  # The ioctl(2) requests that check whether a file is a terminal (TCGETS and TCGETS2).
  TERMINAL_IOCTLS = [0x5401, 0x802C542A]

  # The prctl(2) options for naming threads (PR_SET_NAME) and memory mappings (PR_SET_VMA).
  PR_SET_NAME = 15
  PR_SET_VMA = 0x53564D41

  # The prctl(2) options that setpriv(1) uses after loading the filter.
  PR_SET_PDEATHSIG = 1
  PR_SET_KEEPCAPS = 8
  PR_SET_NO_NEW_PRIVS = 38

  # The fcntl(2) commands for duplicating file descriptors, getting or setting their flags, and getting or setting the
  # size of pipes (F_DUPFD, F_GETFD, F_SETFD, F_GETFL, F_SETFL, F_DUPFD_CLOEXEC, F_SETPIPE_SZ, F_GETPIPE_SZ). This leaves
  # out F_SETOWN and F_SETSIG, which make the kernel send signals to other processes.
  FCNTL_FLAG_COMMANDS = [0, 1, 2, 3, 4, 1030, 1031, 1032]

  # The action that makes a syscall fail with the given errno, without running it.
  #
  # @param errno [Integer] The error number (e.g. `Errno::ENOSYS::Errno`)
  # @return [Integer] The action
  def self.errno(errno)
    0x00050000 | (errno & 0xffff)
  end

  # Symbolic groups of syscalls that can be used in filters. Each entry is a syscall name, a group name, or a rule
  # `[syscall_name, action, comparisons]` that only applies when the syscall's arguments match (see `Filter#add_rule`).
  # Calls that match none of a syscall's rules get the filter's default action.
  SYSCALL_GROUPS = {
    # Syscalls needed to cleanly exit a Ruby program.
    "@exit" => %w[
      exit exit_group getpid munmap rt_sigaction timer_delete
    ],
    # Syscalls needed to allocate and manage memory, and to name memory mappings.
    "@memory" => [
      "brk", "get_mempolicy", "madvise", "mmap", "mmap2", "munmap", "mprotect", "mremap",
      ["prctl", :allow, [[0, :masked_eq, 0xFFFFFFFF, PR_SET_VMA]]],
    ],
    # Syscalls needed by multi-threaded programs. Threads can be created and named, but not processes or namespaces.
    # clone3 fails because its flags are in memory that seccomp can't check, which makes glibc fall back to clone.
    "@threads" => [
      "futex", "getpid", "mmap", "ppoll", "read", "rseq", "write", "sched_yield",
      ["clone", :allow, [[0, :masked_eq, CLONE_NAMESPACE_FLAGS | CLONE_THREAD, CLONE_THREAD]]],
      ["clone3", errno(Errno::ENOSYS::Errno), []],
      ["prctl", :allow, [[0, :masked_eq, 0xFFFFFFFF, PR_SET_NAME]]],
    ],
    # Syscalls for changing the limits and CPU affinity of the current process, but not of other processes. Setting the
    # affinity of other processes fails instead of being killed, because some programs set it for their own threads by
    # thread ID, which can't be told apart from other processes.
    "@process-self" => [
      ["prlimit64", :allow, [[0, :eq, 0]]],
      ["sched_setaffinity", :allow, [[0, :eq, 0]]],
      ["sched_setaffinity", errno(Errno::EPERM::Errno), [[0, :ne, 0]]],
    ],
    # Syscalls commonly needed to execute external programs.
    "@exec" => %w[
      @memory
      @stdio
      @fs-read
      @process-info
      @exit
      arch_prctl
      execve
      futex
      getrandom
      set_robust_list
      set_tid_address
      timer_settime
    ],
    # Syscalls for reading and writing open files.
    "@stdio" => %w[
      close close_range
      dup dup2 dup3
      getdents getdents64
      fadvise64
      fstat
      lseek
      pipe pipe2
      read pread64 readv preadv preadv2
      splice
      write pwrite64 writev pwritev pwritev2
    ] + FCNTL_FLAG_COMMANDS.map { ["fcntl", :allow, [[1, :masked_eq, 0xFFFFFFFF, it]]] },
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
      readlink readlinkat
      stat fstat newfstatat lstat statx
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
    "@process-control" => [
      ["clone", :allow, [[0, :masked_eq, CLONE_NAMESPACE_FLAGS, 0]]],
    ] + %w[
      @threads @process-self
      fork vfork
      getpriority setpriority
      kill tkill tgkill rt_sigqueueinfo rt_tgsigqueueinfo
      nice
      pidfd_open pidfd_send_signal
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
      restart_syscall
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
      timer_create
    ],
    # Syscalls that setpriv(1) makes after it loads the filter, to drop capabilities, apply Landlock, and set the parent
    # death signal. These can only take away privileges. The death signal can only be set to SIGKILL, so a program
    # can't turn it off.
    "@setpriv" => [
      "capset", "landlock_create_ruleset", "landlock_add_rule", "landlock_restrict_self",
      ["prctl", :allow, [[0, :eq, PR_SET_PDEATHSIG], [1, :eq, Signal.list["KILL"]]]],
      ["prctl", :allow, [[0, :eq, PR_SET_KEEPCAPS]]],
      ["prctl", :allow, [[0, :eq, PR_SET_NO_NEW_PRIVS]]],
    ],
    # Syscalls for checking whether a file is a terminal. Other ioctls aren't allowed, because they expose a lot of the kernel.
    "@tty" => TERMINAL_IOCTLS.map { ["ioctl", :allow, [[1, :masked_eq, 0xFFFFFFFF, it]]] },
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
      :act_badarch, 2,
    ]

    typedef :pointer, :scmp_filter_ctx

    # seccomp_init - Initialize the seccomp filter state
    # https://man7.org/linux/man-pages/man3/seccomp_init.3.html
    # scmp_filter_ctx seccomp_init(uint32_t def_action);
    attach_function :seccomp_init, [:action], :scmp_filter_ctx

    # seccomp_release - Release the seccomp filter state
    # https://man7.org/linux/man-pages/man3/seccomp_release.3.html
    # void seccomp_release(scmp_filter_ctx ctx);
    attach_function :seccomp_release, [:scmp_filter_ctx], :void

    # https://github.com/seccomp/libseccomp/blob/main/include/seccomp.h.in#L88
    enum :compare, [
      :ne,        1,
      :lt,        2,
      :le,        3,
      :eq,        4,
      :ge,        5,
      :gt,        6,
      :masked_eq, 7,
    ]

    # struct scmp_arg_cmp
    class ArgCmp < FFI::Struct
      layout :arg, :uint, :op, :compare, :datum_a, :uint64, :datum_b, :uint64
    end

    # seccomp_rule_add_array - Add a seccomp filter rule, optionally only matching certain syscall arguments
    # https://man7.org/linux/man-pages/man3/seccomp_rule_add.3.html
    # int seccomp_rule_add_array(scmp_filter_ctx ctx, uint32_t action, int syscall, unsigned int arg_cnt, const struct scmp_arg_cmp *arg_array);
    attach_function :seccomp_rule_add_array, [:scmp_filter_ctx, :action, :int, :uint32, :pointer], :int

    # seccomp_syscall_resolve_name - Resolve a syscall name to a number
    # https://man7.org/linux/man-pages/man3/seccomp_syscall_resolve_name.3.html
    # int seccomp_syscall_resolve_name(const char *name);
    attach_function :seccomp_syscall_resolve_name, [:string], :int

    # seccomp_syscall_resolve_name - Resolve a syscall number to a name
    # https://man7.org/linux/man-pages/man3/seccomp_syscall_resolve_num_arch.3.html
    # char* seccomp_syscall_resolve_num_arch(uint32_t arch_token, int num)
    attach_function :seccomp_syscall_resolve_num_arch, [:arch, :int], :strptr

    # seccomp_attr_set - Set a seccomp filter attribute
    # https://man7.org/linux/man-pages/man3/seccomp_attr_set.3.html
    # int seccomp_attr_set(scmp_filter_ctx ctx, enum scmp_filter_attr attr, uint32_t value);
    attach_function :seccomp_attr_set, [:scmp_filter_ctx, :attr, :action], :int

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

    # Look up `free` in the whole process instead of in libc, so it uses the same allocator as libseccomp. Otherwise,
    # with jemalloc preloaded (see the Dockerfile), we'd free jemalloc's memory with glibc's `free` and crash.
    ffi_lib FFI::CURRENT_PROCESS

    attach_function :free, [:pointer], :void
  end

  # A Seccomp::Filter represents a single seccomp filter, containing a set of
  # syscall filtering rules and a default action.
  class Filter
    attr_reader :context

    # Create a new syscall filter. Use `add_rule` to add rules to the filter.
    # Use `to_bpf` to export the filter after all rules have been added.
    #
    # If a block is given, run the block with the new filter.
    #
    # @param default_action [Symbol] The default action to take when a syscall
    #   doesn't match a rule.
    def initialize(default_action = :kill)
      @context = init!(default_action)

      # Syscalls for other architectures, like 32-bit or x32 syscalls on x86_64, get the default action too. Otherwise
      # libseccomp only kills the thread that made them, and the rest of the process keeps running.
      ret = LibSeccomp.seccomp_attr_set(context, :act_badarch, default_action)
      raise SystemCallError.new("seccomp_attr_set(act_badarch) failed", -ret) if ret < 0

      yield self if block_given?
    end

    # Add a syscall rule to the filter. If the syscall doesn't exist, raise an error.
    #
    # @example
    #   # Allow prlimit64(2) only if its first argument (the pid) is 0.
    #   filter.add_rule("prlimit64", :allow, [[0, :eq, 0]])
    #
    #   # Allow clone(2) only if none of the bits in `mask` are set in its first argument (the flags).
    #   filter.add_rule("clone", :allow, [[0, :masked_eq, mask, 0]])
    #
    #   # Make clone3(2) fail with ENOSYS.
    #   filter.add_rule("clone3", Seccomp.errno(Errno::ENOSYS::Errno))
    #
    # @param syscall_name [String] The name of the syscall
    # @param action [Symbol, Integer] The action to take when the syscall is called (:allow, :log, :kill, or `Seccomp.errno`)
    # @param comparisons [Array<Array>] The conditions the syscall's arguments must match for the rule to apply, as
    #   `[arg_index, op, value]`, or `[arg_index, :masked_eq, mask, value]`. All conditions must match.
    # @return [self]
    # @raise [SystemCallError] If the rule couldn't be added
    def add_rule(syscall_name, action, comparisons = [])
      syscall_number = Seccomp.resolve_syscall_name(syscall_name)
      array = FFI::MemoryPointer.new(LibSeccomp::ArgCmp, [comparisons.size, 1].max)
      comparisons.each_with_index do |(arg, op, datum_a, datum_b), i|
        cmp = LibSeccomp::ArgCmp.new(array + (i * LibSeccomp::ArgCmp.size))
        cmp[:arg] = arg
        cmp[:op] = op
        cmp[:datum_a] = datum_a
        cmp[:datum_b] = datum_b || 0
      end

      ret = LibSeccomp.seccomp_rule_add_array(context, action, syscall_number, comparisons.size, array)
      raise SystemCallError.new("seccomp_rule_add(#{action}, #{syscall_name}) failed", -ret) if ret < 0

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
      raise Errno::ENOMEM, "seccomp_init(#{default_action}) failed" if context.nil?

      FFI::AutoPointer.new(context, LibSeccomp.method(:seccomp_release))
    end
  end

  # Create a filter allowing only the given set of syscalls. Deny all other
  # syscalls by default. Calling a denied syscall will kill the process by default.
  def self.allow(syscalls, default_action: :kill)
    filter(syscalls, :allow, default_action: default_action)
  end

  # Create a syscall filter that performs `action` when any of the given syscalls
  # are called, or `default_action` when any other syscall is called.
  #
  # @param syscalls [Array<String>] The set of syscalls. May include syscall groups (e.g `@stdio`). Rules in groups
  #   that only match certain arguments keep their own action.
  # @param action [Symbol] The action to take when any of the given syscalls are called (:allow, :log, :kill)
  # @param default_action [Symbol] The action to take when any other syscall is called (:allow, :log, :kill)
  # @return [Seccomp::Filter] the seccomp filter
  def self.filter(syscalls, action, default_action: :kill)
    Filter.new(default_action) do |filter|
      expand_rules(syscalls, action).each do |syscall, rule_action, comparisons|
        filter.add_rule(syscall, rule_action, comparisons)
      end
    end
  end

  # @return [Boolean] True if the process was killed for calling a blocked syscall.
  def self.killed?(status)
    status.termsig == Signal.list["SYS"]
  end

  # Return the list of syscalls available on the current system. This list may
  # vary depending on the CPU architecture and kernel version.
  #
  # @return [Hash<Integer, String>] a hash of syscall numbers to syscall names
  def self.syscalls
    @syscalls ||= 0.upto(8192).index_with do |n|
      resolve_syscall_number(n)
    end.compact
  end

  # Recursively expand a list of syscall names and syscall groups (e.g. `@stdio`) to a flat list of syscall names.
  #
  # @param syscalls [String, Array<String>] A list of syscalls and groups, or a space-separated string.
  # @return [Array<String>] A list of syscall names
  def self.expand_syscall_names(syscalls)
    expand_rules(syscalls, :allow).map(&:first).sort.uniq
  end

  # Recursively expand a list of syscall names and syscall groups to a list of `[syscall_name, action, comparisons]`
  # rules. Plain syscall names get the given action.
  #
  # @param syscalls [String, Array<String, Array>] A list of syscalls, groups, and rules, or a space-separated string.
  # @param action [Symbol, Integer] The action for plain syscall names.
  # @return [Array<Array>] The rules
  def self.expand_rules(syscalls, action)
    Array(syscalls).flat_map { it.is_a?(String) ? it.split : [it] }.flat_map do |entry|
      case entry
      in Array then [entry]
      in /\A@/ then expand_rules(SYSCALL_GROUPS.fetch(entry), action)
      in String then [[entry, action, []]]
      end
    end.uniq
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
