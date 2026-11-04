# Make libvips use the Rails logger.
#
# XXX Vips warning messages in background threads don't use this logger because of a ruby-vips limitation, so they won't
# be hidden even if the log level is set to `error` or above. You have to set the VIPS_WARNING environment variable
# before the program starts to hide these warnings.
GLib.logger = Rails.logger

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

# Only allow libvips to load the image formats we support (see `MediaFile.new_from_file`), so that if a file of another
# type is ever passed to libvips, it won't be parsed by a loader we don't use. This blocks all loaders, then unblocks the
# file loaders we use. The loaders are looked up by nickname because their class names depend on how libvips was built
# (e.g. the GIF loader may use libnsgif or giflib).
#
# @see `vips_operation_block_set` in vips/operation.h (libvips 8.13+)
Vips.attach_function :vips_operation_block_set, [:string, :int], :void
Vips.vips_operation_block_set("VipsForeignLoad", 1)
%w[jpegload pngload gifload webpload heifload].filter_map { GObject.g_type_name(Vips.type_find("VipsForeignLoad", it)) }.each do |loader|
  Vips.vips_operation_block_set(loader, 0)
end

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
