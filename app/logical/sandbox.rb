# frozen_string_literal: true

# Run a program inside an isolated sandbox, much like a Docker container. Inside the sandbox,
# the program doesn't have network access, can't see other programs, and can only see read-only
# OS directories like /usr and /lib. It can only communicate by reading from stdin and printing
# output to stdout.
#
# This is based on a combination of Linux namespaces, to isolate the process in a container,
# and Seccomp, to restrict system calls.
#
# @example
#   # Run a command in a sandbox and return the result as a string.
#   output = Sandbox.new(stdin: File.open("image.jpg")).run!("exiftool -json -")
#
#   # Open a shell inside the sandbox.
#   Sandbox.new.shell
#
#   # Doesn't work - no network access.
#   Sandbox.new.system("ping 127.0.0.1")
#
#   # Doesn't work - no access to /home.
#   Sandbox.new.system("cat ~/.ssh/id_rsa")
#
#   # Doesn't work - no access to test.txt.
#   FileUtils.touch("test.txt")
#   Sandbox.new.system("rm test.txt")
#
# Documentation:
#
# @see https://en.wikipedia.org/wiki/Linux_namespaces
# @see https://blog.lizzie.io/linux-containers-in-500-loc.html
# @see https://jvns.ca/blog/2020/04/27/new-zine-how-containers-work/
# @see https://zserge.com/posts/containers/
# @see https://man7.org/linux/man-pages/man7/namespaces.7.html
# @see https://www.youtube.com/watch?v=8fi7uSYlOdc
#
# Utilities:
#
# @see https://github.com/netblue30/firejail
# @see https://github.com/google/nsjail
# @see https://man7.org/linux/man-pages/man1/setpriv.1.html
# @see https://man7.org/linux/man-pages/man1/unshare.1.html
class Sandbox
  class Error < StandardError; end

  attr_accessor :stdin, :stdout, :stderr, :root, :process, :network, :hostname, :tmp, :ro, :rw, :env, :seccomp

  # Configure a new sandbox. Call `#confine!` afterward to run code in the sandbox.
  #
  # @param stdin [File, nil] The stdin use inside the sandbox. If nil, redirect stdin to /dev/null.
  # @param stdout [File, nil] The stdout to use inside the sandbox. If nil, redirect stdout to /dev/null.
  # @param stderr [File, nil] The stderr to use inside the sandbox. If nil, redirect stderr to /dev/null.
  # @param process [Boolean] If true, allow sandboxed processes to see processes outside the sandbox. Default: false.
  # @param network [Boolean] If true, allow network access inside the sandbox. Default: false.
  # @param hostname [Boolean] If true, allow sandboxed processes to see the system hostname.
  #   If false, generate a random hostname inside the sandbox. Default: false.
  # @param root [Boolean] If true, run the sandboxed process with root privileges. Note: this
  #   doesn't give root privileges outside the sandbox. Default: false.
  # @param tmp [Boolean] If true, mount /tmp, /run, and /dev/shm in the sandbox. Default: false.
  # @param ro [Array<String>] The list of directories to allow read-only access to inside the sandbox.
  # @param rw [Array<String>] The list of directories to allow read-write access to inside the sandbox.
  # @param env [Array<String>] The list of environment variables to keep inside the sandbox. Default: none.
  # @param seccomp [Seccomp::Filter, nil] If present, a system call filter to apply inside the sandbox.
  def initialize(stdin: $stdin, stdout: $stdout, stderr: $stderr, root: false, process: false,
                 network: false, hostname: false, tmp: false, seccomp: Seccomp.allow("@common"),
                 ro: %w[/usr /lib /lib64 /bin /sbin], rw: [], env: [])
    @stdin  = stdin.nil?  ? File.open("/dev/null", "r") : stdin
    @stdout = stdout.nil? ? File.open("/dev/null", "w") : stdout
    @stderr = stderr.nil? ? File.open("/dev/null", "w") : stderr
    @root = root
    @network = network
    @process = process
    @hostname = hostname
    @tmp = tmp
    @ro = ro
    @rw = rw
    @env = env
    @seccomp = seccomp
  end

  # Run a block of code in a sandboxed subprocess.
  # @return [Integer] the process ID of the subprocess
  def confine!(&block)
    clear_env!
    redirect_stdio!
    close_fds!
    no_new_privs!

    new_user_namespace!
    new_pid_namespace! do
      new_hostname_namespace!
      new_network_namespace!
      new_cgroup_namespace!
      new_ipc_namespace!
      new_mount_namespace!
      filter_syscalls!

      yield
    end
  end

  # Run a program in the sandbox and return immediately.
  # @return [Integer] the process ID of the command
  def spawn(*args)
    Process.fork do
      pid = confine! do
        Process.exec(*args)
      end

      status = waitpid!(pid)
      exit status.exitstatus
    end
  end

  # Run a program in the sandbox and return its output. Raise an error if it fails.
  # @return [String] The stdout of the command.
  def run!(*args)
    IO.pipe do |reader, writer|
      sandbox = dup.tap { |o| o.stdout = writer }
      pid = sandbox.spawn(*args)
      writer.close

      ret = reader.read
      status = waitpid!(pid)
      raise Error, "run!(#{args.map(&:inspect).join}) failed (exit #{status.exitstatus})" if !status.success?

      ret
    end
  end

  # Run a program in the sandbox and return its output. Return nil if it fails.
  # @return [String, nil] The stdout of the command, or nil if it failed.
  def run(*args)
    run!(*args)
  rescue Error
    nil
  end

  # Run a program in the sandbox and wait for it to finish.
  # @return [Process::Status] the exit status of the program
  def system(command, *args)
    pid = spawn(command, *args)
    waitpid!(pid)
  end

  # Run an interactive shell in the sandbox.
  def shell(shell = "/bin/sh")
    system(shell)
  end

  protected

  # Wait on a subprocess to exit. Raise an error if it is killed because it called an
  # unauthorized syscall blocked by the seccomp filter.
  def waitpid!(pid)
    pid, status = Process.wait2(pid)

    if status.signaled? && Signal.signame(status.termsig) == "SYS"
      raise Error, "Command failed: called unauthorized syscall (see dmesg for details)"
    else
      status
    end
  end

  # Move our process to a new user namespace. Inside the namespace, our process runs under a
  # different UID/GID than outside the namespace.
  #
  # Creating a user namespace grants us root privileges inside the namespace. This lets us set
  # up other namespaces. We later drop these privileges after setting up the other namespaces.
  #
  # @see https://man7.org/linux/man-pages/man7/user_namespaces.7.html
  def new_user_namespace!
    outer_uid, outer_gid = Process.uid, Process.gid
    uid = root ? 0 : outer_uid
    gid = root ? 0 : outer_gid

    raise Error, "multi-threaded processes can't be sandboxed (hint: set DANBOORU_DEBUG_MODE=1)" if Thread.list.count > 1
    Linux.unshare!([:clone_newuser])

    # Tell the kernel how to map our UID and GID outside the namespace to new
    # (potentially different) IDs inside the namespace. See user_namespaces(7).
    File.write("/proc/self/setgroups", "deny")
    File.write("/proc/self/uid_map", "#{uid} #{outer_uid} 1\n")
    File.write("/proc/self/gid_map", "#{gid} #{outer_gid} 1\n")
  end

  # Move our process to a new hostname namespace. Inside the namespace, we set a new random hostname.
  def new_hostname_namespace!
    return if hostname

    Linux.unshare!([:clone_newuts])
    sethostname!(SecureRandom.uuid)
  end

  # Move our process to a new PID namespace. Inside the namespace, we run as PID 1 and we can't
  # see any processes outside the namespace. This requires a fork to spawn a new child in the namespace.
  def new_pid_namespace!(&block)
    return yield if process

    Linux.unshare!([:clone_newpid])
    Process.fork(&block)
  end

  # Move our process to a new network namespace. Inside the namespace, all we have is a
  # disabled localhost interface, so we have no network access.
  def new_network_namespace!
    return if network
    Linux.unshare!([:clone_newnet])
  end

  # Move our process to a new Cgroup namespace.
  def new_cgroup_namespace!
    Linux.unshare!([:clone_newcgroup])
  end

  # Move our process to a new IPC namespace.
  def new_ipc_namespace!
    Linux.unshare!([:clone_newipc])
  end

  # Move our process to a new mount namespace. Inside the namespace, our process has its own
  # unique view of the filesystem.
  def new_mount_namespace!
    Linux.unshare!([:clone_newns])
    mount!("tmpfs", "/tmp", fstype: "tmpfs")

    ro.each do |path|
      # XXX bug: submounts don't get mounted readonly.
      bind_mount!(path, File.join("/tmp", path), flags: %i[rdonly nodev nosuid])
    end
    rw.each do |path|
      bind_mount!(path, File.join("/tmp", path), flags: %i[nodev nosuid])
    end

    if process
      bind_mount!("/proc", "/tmp/proc")
    else
      mount!("proc", "/tmp/proc", fstype: "proc", flags: %i[rdonly])
    end

    if tmp
      mount!("tmpfs", "/tmp/tmp", fstype: "tmpfs")
      mount!("tmpfs", "/tmp/run", fstype: "tmpfs")
      mount!("tmpfs", "/tmp/dev/shm", fstype: "tmpfs")
    end

    remount!("/tmp", flags: %i[rdonly nodev nosuid noexec noatime])
    pivot_root!("/tmp")
  end

  # @return [Array<Integer>] The list of currently open file descriptors for the process.
  def open_fds
    Dir.open("/proc/self/fd") do |dir|
      # Don't include "/proc/self/fd" itself in the list of open files
      dir.children.map(&:to_i) - [dir.fileno]
    end
  end

  # Close all open files for the process, except stdin, stdout, and stderr.
  #
  # @param keep [Array<Integer>] The list of open files to keep.
  # @return [void]
  def close_fds!(keep: [0, 1, 2])
    fds = open_fds - keep

    fds.each do |fd|
      IO.new(fd).close
    rescue ArgumentError
      # Trying to close FDs 3 and 4 will raise an ArgumentError because these
      # FDs are used internally by the Ruby VM. Ignore the error.
    end
  end

  # Redirect stdin, stdout, and stderr for our process.
  def redirect_stdio!
    IO.new(0).reopen(stdin)
    IO.new(1).reopen(stdout)
    IO.new(2).reopen(stderr)
  end

  def clear_env!
    ENV.delete_if do |name, value|
      !env.include?(name)
    end
  end

  # Activate seccomp(2) filtering.
  def filter_syscalls!
    seccomp&.apply!
  end

  # Call prctl(PR_SET_NO_NEW_PRIVS, 1). This makes it so setuid binaries have
  # no effect, so we can't elevate privileges by running things like sudo(1).
  # This is required by seccomp(2).
  #
  # @see https://www.kernel.org/doc/html/latest/userspace-api/no_new_privs.html
  def no_new_privs!
    Linux.prctl!(:set_no_new_privs, 1, 0, 0, 0)
  end

  # Mount the `source` filesystem on the `target` directory.
  def mount!(source, target, fstype: nil, flags: [])
    FileUtils.mkdir_p(target, mode: 0755)
    Linux.mount!(source, target, fstype, flags, nil)
  end

  # Remount an existing mountpoint with the new `flags`.
  def remount!(target, flags: [])
    mount!(nil, target, flags: flags + [:remount])
  end

  # Bind mount a directory to a new mountpoint. Bind mounting `/usr` to
  # `/tmp/usr` means `/tmp/usr` refers to the same directory as `/usr`.
  def bind_mount!(source, target, flags: [])
    mount!(source, target, flags: [:bind, :rec, :private])
    remount!(target, flags: [:bind, *flags])
  end

  # Change the root (`/`) directory to the given directory.
  def pivot_root!(newroot)
    Linux.pivot_root!(newroot, newroot)
    Dir.chdir("/")

    # The new root was mounted on top of the old root. This unmounts the old root.
    Linux.umount2!(".", :detach)
  end

  # Change the system hostname.
  def sethostname!(hostname)
    Linux.sethostname!(hostname, hostname.size)
  end

  # Create Ruby bindings for various Linux kernel syscalls.
  # https://github.com/ffi/ffi/wiki
  module Linux
    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    # Create a Ruby method that calls the given system call, and define a bang version that
    # raises an error if the syscall fails.
    def self.attach_function(name, *args)
      define_singleton_method("#{name}!") do |*args|
        ret = send(name, *args)

        if ret < 0
          message = "#{name}(#{args.map(&:inspect).join(", ")})"
          raise SystemCallError.new(message, FFI.errno)
        else
          ret
        end
      end

      super(name, *args)
    end

    # https://www.kernel.org/doc/html/latest/userspace-api/no_new_privs.html
    # https://github.com/torvalds/linux/blob/master/include/uapi/linux/prctl.h
    enum :prctl_command, [
      :set_no_new_privs, 38
    ]

    # https://github.com/torvalds/linux/blob/master/include/uapi/linux/sched.h
    bitmask :unshare_flags, [
      :clone_time,      7,  # 0x00000080, New time namespace
      :clone_newns,     17, # 0x00020000, New mount (filesystem) namespace
      :clone_newcgroup, 25, # 0x02000000, New cgroup namespace
      :clone_newuts,    26, # 0x04000000, New utsname (hostname) namespace
      :clone_newipc,    27, # 0x08000000, New ipc namespace
      :clone_newuser,   28, # 0x10000000, New user namespace
      :clone_newpid,    29, # 0x20000000, New pid namespace
      :clone_newnet,    30, # 0x40000000, New network namespace
    ]

    # https://github.com/torvalds/linux/blob/master/include/uapi/linux/mount.h
    bitmask :mount_flags, [
      :rdonly,  0,
      :nosuid,  1,
      :nodev,   2,
      :noexec,  3,
      :remount, 5,
      :noatime, 10,
      :bind,    12,
      :rec,     14,
      :private, 18,
      :slave,   19,
    ]

    # https://github.com/torvalds/linux/blob/master/include/linux/fs.h#L1425
    bitmask :umount_flags, [
      :detach, 1 # 0x2
    ]

    # prctl - operations on a process or thread
    # https://man7.org/linux/man-pages/man2/prctl.2.html
    # int prctl(int option, unsigned long arg2, unsigned long arg3, unsigned long arg4, unsigned long arg5);
    attach_function :prctl, [:prctl_command, :long, :long, :long, :long], :int

    # unshare - disassociate parts of the process execution context
    # https://man7.org/linux/man-pages/man2/unshare.2.html
    # https://man7.org/linux/man-pages/man7/namespaces.7.html
    # int unshare(int flags);
    attach_function :unshare, [:unshare_flags], :int

    # mount - mount filesystem
    # https://man7.org/linux/man-pages/man2/mount.2.html
    # int mount(const char *source, const char *target, const char *filesystemtype, unsigned long mountflags, const void *data);
    attach_function :mount, [:string, :string, :string, :mount_flags, :pointer], :int

    # umount, umount2 - unmount filesystem
    # https://man7.org/linux/man-pages/man2/umount2.2.html
    # int umount2(const char *target, int flags);
    attach_function :umount2, [:string, :umount_flags], :int

    # pivot_root - change the root mount
    # https://man7.org/linux/man-pages/man2/pivot_root.2.html
    # int pivot_root(const char *new_root, const char *put_old);
    attach_function :pivot_root, [:string, :string], :int

    # sethostname - set system hostname
    # https://man7.org/linux/man-pages/man2/sethostname.2.html
    # int sethostname(const char *name, size_t len);
    attach_function :sethostname, [:string, :size_t], :int
  end
end
