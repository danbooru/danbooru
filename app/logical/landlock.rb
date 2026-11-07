# frozen_string_literal: true

# Landlock, a Linux kernel feature that lets an unprivileged process restrict which files it can access. The
# restrictions apply to the process and all of its children, and they can't be undone. ExternalCommand uses it through
# setpriv(1) to sandbox external programs that process user-uploaded files.
#
# Landlock is available since Linux 5.13, but it must be enabled by the kernel, so it may not be available everywhere.
# Newer kernels support more restrictions (see `Landlock.abi_version`).
#
# @see https://docs.kernel.org/userspace-api/landlock.html
# @see https://man7.org/linux/man-pages/man7/landlock.7.html
# @see https://github.com/torvalds/linux/blob/master/include/uapi/linux/landlock.h
module Landlock
  # Filesystem access rights, and the ABI version that added them.
  ACCESS_FS = {
    execute: 1,
    write_file: 1,
    read_file: 1,
    read_dir: 1,
    remove_dir: 1,
    remove_file: 1,
    make_char: 1,
    make_dir: 1,
    make_reg: 1,
    make_sock: 1,
    make_fifo: 1,
    make_block: 1,
    make_sym: 1,
    refer: 2,
    truncate: 3,
    ioctl_dev: 5,
  }

  # The access rights that apply to files. The other rights only apply to directories.
  FILE_ACCESS = %i[execute write_file read_file truncate ioctl_dev]

  # The rights granted to paths that can be read.
  READ_ACCESS = %i[read_file read_dir]

  # The rights granted to paths that can be read and executed.
  EXECUTE_ACCESS = READ_ACCESS + %i[execute]

  # The rights granted to paths that can be written. Written files can't be executed.
  WRITE_ACCESS = READ_ACCESS + %i[write_file remove_dir remove_file make_dir make_reg make_sym truncate]

  module LibC
    extend FFI::Library

    ffi_lib FFI::Library::LIBC

    # The syscall number is the same on all architectures.
    SYS_LANDLOCK_CREATE_RULESET = 444
    LANDLOCK_CREATE_RULESET_VERSION = 1 << 0

    attach_function :syscall, [:long, :varargs], :long
  end

  # @return [Integer] The Landlock ABI version supported by the kernel, or 0 if Landlock isn't available.
  def self.abi_version
    @abi_version ||= [LibC.syscall(LibC::SYS_LANDLOCK_CREATE_RULESET, :pointer, nil, :size_t, 0, :uint32, LibC::LANDLOCK_CREATE_RULESET_VERSION), 0].max
  end

  # @return [Boolean] True if the kernel supports Landlock.
  def self.supported?
    abi_version >= 1
  end
end
