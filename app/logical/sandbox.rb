# @see https://blog.lizzie.io/linux-containers-in-500-loc.html
# @see https://jvns.ca/blog/2020/04/27/new-zine-how-containers-work/
# @see https://zserge.com/posts/containers/
# @see https://github.com/netblue30/firejail
# @see https://github.com/google/nsjail
# @see https://www.youtube.com/watch?v=8fi7uSYlOdc
class Sandbox
  class Error < StandardError; end

  attr_reader :syscalls

  def initialize(syscalls: ["@common"])
    @syscalls = syscalls
  end

  def sandbox!
    raise Error, "multi-threaded processes can't be sandboxed (hint: set DANBOORU_DEBUG_MODE=1)" if Thread.list.count > 1

    Linux.set_no_new_privs!
    Linux::LibC.unshare!(Linux::LibC::CLONE_NEWUSER|Linux::LibC::CLONE_NEWNS)

    File.write("/proc/self/setgroups", "deny")
    File.write("/proc/self/uid_map", "1000 1000 1\n")
    File.write("/proc/self/gid_map", "1000 1000 1\n")

    Linux.mount!("tmpfs", "/tmp", fstype: "tmpfs", flags: Linux::LibC::MS_NOSUID|Linux::LibC::MS_NODEV)
    Linux.bind_mount!("/usr",  "/tmp/usr")
    Linux.bind_mount!("/proc", "/tmp/proc")
    File.symlink("usr/lib64",  "/tmp/lib64")
    File.symlink("usr/lib",    "/tmp/lib")
    File.symlink("usr/bin",    "/tmp/bin")
    Linux.mount!(nil, "/tmp", flags: Linux::LibC::MS_NOSUID|Linux::LibC::MS_NODEV|Linux::LibC::MS_RDONLY|Linux::LibC::MS_REMOUNT)
    Zeitwerk::Loader.eager_load_all if !Rails.env.production?
    Linux.pivot_root!("/tmp")

    ENV.clear
    close_fds!

    Seccomp.allow!(syscalls)
  end

  def spawn(command, *args, stdin: nil, stdout: nil, stderr: nil)
    pid = Process.fork

    if pid == nil
      redirect_io!(stdin, stdout, stderr)
      sandbox!
      Process.exec(command, *args)
    end

    pid
  end

  def run(command, *args, stdin: nil, stderr: nil)
    IO.pipe do |reader, writer|
      pid = spawn(command, *args, stdin: stdin, stdout: writer, stderr: stderr)
      writer.close

      ret = reader.read
      waitpid!(pid)

      ret
    end
  end

  def system(command, *args, **options)
    pid = spawn(command, *args, **options)
    waitpid!(pid)
  end

  def shell(command = "sh")
    system("sh", "-c", command, stdin: $stdin, stdout: $stdout, stderr: $stderr)
  end

  def waitpid!(pid)
    pid, status = Process.wait2(pid)

    if status.success?
      status
    elsif status.signaled? && Signal.signame(status.termsig) == "SYS"
      raise Error, "Command failed: called unauthorized syscall (see dmesg for details)"
    #else
    #  raise Error, "Command failed (exit #{status.exitstatus})"
    end
  end

  def open_fds
    Dir.open("/proc/self/fd") do |dir|
      dir.children.map(&:to_i) - [dir.fileno]
    end
  end

  def close_fds!
    fds = open_fds - [0, 1, 2]
    fds.each do |fd|
      IO.new(fd).close
    rescue ArgumentError
      # Trying to close FDs 3 and 4 will raise an ArgumentError because these
      # FDs are used internally by the Ruby VM. Ignore the error.
    end
  end

  def redirect_io!(stdin, stdout, stderr)
    stdin  = File.open("/dev/null", "r") if stdin.nil?
    stdout = File.open("/dev/null", "w") if stdout.nil?
    stderr = File.open("/dev/null", "w") if stderr.nil?
    IO.new(0).reopen(stdin)
    IO.new(1).reopen(stdout)
    IO.new(2).reopen(stderr)
  end
end
