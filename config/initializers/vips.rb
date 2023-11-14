# Make libvips use the Rails logger.
#
# XXX Vips warning messages in background threads don't use this logger because of a ruby-vips limitation, so they won't
# be hidden even if the log level is set to `error` or above. You have to set the VIPS_WARNING environment variable
# before the program starts to hide these warnings.
GLib.logger = Rails.logger

Vips.attach_function :vips_tracked_get_mem, [], :int
Vips.attach_function :vips_tracked_get_allocs, [], :int
Vips.attach_function :vips_tracked_get_files, [], :int

# Disable the vips operation cache unless the VIPS_MAX_CACHE environment variable is set.
#
# Normally Vips caches the last 100 operations so that, for example, if the same image is thumbnailed twice in a row,
# the thumbnail will only be generated once. We don't usually perform the same operation more than once, so this cache
# increases memory usage without increasing performance.
#
# https://www.libvips.org/API/current/VipsOperation.html#id-1.3.6.9.10
Vips.vips_cache_set_max(ENV.fetch("VIPS_MAX_CACHE", 0).to_i)

# Disable multithreading unless the VIPS_CONCURRENCY environment variable is set. Enabling multithreading usually
# increases memory usage without increasing performance.
#
# https://www.libvips.org/API/current/VipsOperation.html#vips-concurrency-set
Vips.concurrency_set(ENV.fetch("VIPS_CONCURRENCY", 1).to_i)

class Vips::Image
  # Release the memory used by this image.
  def release
    # XXX Deep hack to manually free the underlying VipsImage object.
    @struct.pointer.autorelease = false
    GObject.g_object_unref(@ptr)

    @ptr = nil
    @struct = nil
    @references = nil

    # Perform a minor GC. This isn't strictly necessary, but it barely affects performance and it helps keep memory usage low.
    GC.start(full_mark: false)
  end
end
