# Make libvips use the Rails logger.
#
# XXX Vips warning messages in background threads don't use this logger because of a ruby-vips limitation, so they won't
# be hidden even if the log level is set to `error` or above. You have to set the VIPS_WARNING environment variable
# before the program starts to hide these warnings.
GLib.logger = Rails.logger

Vips.attach_function :vips_image_invalidate_all, [:pointer], :void
