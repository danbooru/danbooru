require "test_helper"

class SeccompTest < ActiveSupport::TestCase
  context "MediaFile::Seccomp.expand_syscall_names" do
    should "expand groups recursively" do
      assert_includes(MediaFile::Seccomp.expand_syscall_names("@exec"), "openat")
      assert_equal(%w[read write], MediaFile::Seccomp.expand_syscall_names("write read write"))
    end

    should "raise an error for unknown groups" do
      assert_raises(KeyError) { MediaFile::Seccomp.expand_syscall_names("@nonexistent") }
    end
  end

  context "MediaFile::Seccomp.expand_rules" do
    should "give plain syscalls the given action and keep the actions of rules" do
      rules = MediaFile::Seccomp.expand_rules(["read", ["clone3", MediaFile::Seccomp.errno(Errno::ENOSYS::Errno), []]], :allow)

      assert_equal([["read", :allow, []], ["clone3", MediaFile::Seccomp.errno(Errno::ENOSYS::Errno), []]], rules)
    end
  end

  context "MediaFile::Seccomp.allow" do
    should "raise an error for unknown syscalls" do
      assert_raises(Errno::EINVAL) { MediaFile::Seccomp.allow("nonexistent_syscall") }
    end

    should "build a filter that kills the process for other syscalls" do
      assert_match(/action KILL_PROCESS/, MediaFile::Seccomp.allow("@exec").to_pfc)
    end
  end

  context "MediaFile::Seccomp.killed?" do
    should "only be true for processes killed by SIGSYS" do
      _, killed = Process.wait2(Process.spawn("sh", "-c", "kill -SYS $$", rlimit_core: 0))
      _, exited = Process.wait2(Process.spawn("sh", "-c", "exit 159"))

      assert_equal(true, MediaFile::Seccomp.killed?(killed))
      assert_equal(false, MediaFile::Seccomp.killed?(exited))
    end
  end
end
