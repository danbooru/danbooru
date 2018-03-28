module DanbooruImageResizer
  # Taken from ArgyllCMS 2.0.0 (see also: https://ninedegreesbelow.com/photography/srgb-profile-comparison.html)
  SRGB_PROFILE = "#{Rails.root}/config/sRGB.icm"
  # http://jcupitt.github.io/libvips/API/current/libvips-resample.html#vips-thumbnail
  THUMBNAIL_OPTIONS = { size: :down, linear: false, auto_rotate: false, export_profile: SRGB_PROFILE }
  # http://jcupitt.github.io/libvips/API/current/VipsForeignSave.html#vips-jpegsave
  JPEG_OPTIONS = { background: 255, strip: true, interlace: true, optimize_coding: true }

  # https://github.com/jcupitt/libvips/wiki/HOWTO----Image-shrinking
  # http://jcupitt.github.io/libvips/API/current/Using-vipsthumbnail.md.html
  def self.resize(file, width, height, resize_quality = 90)
    output_file = Tempfile.new
    resized_image = Vips::Image.thumbnail(file.path, width, height: height, **THUMBNAIL_OPTIONS)
    resized_image.jpegsave(output_file.path, Q: resize_quality, **JPEG_OPTIONS)

    output_file
  end
end
