module Linux
  module_function

  module LibC
    module_function

    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    # https://www.kernel.org/doc/html/latest/userspace-api/no_new_privs.html
    # https://github.com/torvalds/linux/blob/master/include/uapi/linux/prctl.h
    PR_SET_NO_NEW_PRIVS = 38

    # https://github.com/torvalds/linux/blob/master/include/uapi/linux/sched.h
    CLONE_FS      = 0x00000200
    CLONE_NEWUSER = 0x10000000
    CLONE_NEWNS	  = 0x00020000

    # https://github.com/torvalds/linux/blob/master/include/uapi/linux/mount.h
    MS_RDONLY  = 1<<0
    MS_NOSUID  = 1<<1
    MS_NODEV   = 1<<2
    MS_REMOUNT = 1<<5
    MS_BIND    = 1<<12
    MS_REC     = 1<<14
    MS_PRIVATE = 1<<18
    MS_SLAVE   = 1<<19

    MNT_DETACH = 2

    def attach_function(name, *args)
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

    # https://man7.org/linux/man-pages/man2/prctl.2.html
    # int prctl(int option, unsigned long arg2, unsigned long arg3, unsigned long arg4, unsigned long arg5);
    attach_function :prctl, [:int, :long, :long, :long, :long], :int
    attach_function :unshare, [:int], :int
    attach_function :mount, [:string, :string, :string, :ulong, :pointer], :int
    attach_function :umount2, [:string, :int], :int
    attach_function :pivot_root, [:string, :string], :int
    attach_function :dup2, [:int, :int], :int
  end

  def set_no_new_privs!
    LibC.prctl!(LibC::PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0)
  end

  def mount!(source, target, fstype: nil, flags: LibC::MS_NOSUID|LibC::MS_NODEV)
    LibC.mount!(source, target, fstype, flags, nil)
  end

  def bind_mount!(old_dir, new_dir, mode: 0755, flags: LibC::MS_RDONLY|LibC::MS_NOSUID|LibC::MS_NODEV|LibC::MS_PRIVATE)
    FileUtils.mkdir_p(new_dir, mode: mode)
    mount!(old_dir, new_dir, flags: LibC::MS_BIND|LibC::MS_REC|flags)
  end

  def pivot_root!(newroot)
    LibC.pivot_root!(newroot, newroot)
    Dir.chdir("/")
    LibC.umount2!(".", LibC::MNT_DETACH)
  end
end
