# frozen_string_literal: true

# Mark the Rails process as non-dumpable. This stops other processes running as the same user, such as ffmpeg or
# exiftool exploited by a malicious file, from reading our secrets from /proc/<pid>/environ or /proc/<pid>/mem, or
# attaching to us with ptrace. It also disables core dumps. Forked Puma and GoodJob workers inherit this.
#
# @see https://man7.org/linux/man-pages/man2/PR_SET_DUMPABLE.2const.html
module Prctl
  extend FFI::Library

  ffi_lib FFI::Library::LIBC

  PR_SET_DUMPABLE = 4

  attach_function :prctl, [:int, :ulong, :ulong, :ulong, :ulong], :int
end

raise SystemCallError.new("prctl(PR_SET_DUMPABLE, 0) failed", FFI.errno) if Prctl.prctl(Prctl::PR_SET_DUMPABLE, 0, 0, 0, 0) < 0
