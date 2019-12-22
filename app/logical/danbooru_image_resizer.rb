module DanbooruImageResizer
  module_function

  # Taken from ArgyllCMS 2.0.0 (see also: https://ninedegreesbelow.com/photography/srgb-profile-comparison.html)
  SRGB_PROFILE = "#{Rails.root}/config/sRGB.icm"

  # http://jcupitt.github.io/libvips/API/current/libvips-resample.html#vips-thumbnail
  if Vips.at_least_libvips?(8, 8)
    THUMBNAIL_OPTIONS = { size: :down, linear: false, no_rotate: true, export_profile: SRGB_PROFILE, import_profile: SRGB_PROFILE }
    CROP_OPTIONS = { linear: false, no_rotate: true, export_profile: SRGB_PROFILE, import_profile: SRGB_PROFILE, crop: :attention }
  else
    THUMBNAIL_OPTIONS = { size: :down, linear: false, auto_rotate: false, export_profile: SRGB_PROFILE, import_profile: SRGB_PROFILE }
    CROP_OPTIONS = { linear: false, auto_rotate: false, export_profile: SRGB_PROFILE, import_profile: SRGB_PROFILE, crop: :attention }
  end

  # http://jcupitt.github.io/libvips/API/current/VipsForeignSave.html#vips-jpegsave
  JPEG_OPTIONS = { background: 255, strip: true, interlace: true, optimize_coding: true }

  # https://github.com/jcupitt/libvips/wiki/HOWTO----Image-shrinking
  # http://jcupitt.github.io/libvips/API/current/Using-vipsthumbnail.md.html
  def resize(file, width, height, resize_quality = 90)
    output_file = Tempfile.new
    resized_image = Vips::Image.thumbnail(file.path, width, height: height, **THUMBNAIL_OPTIONS)
    resized_image.jpegsave(output_file.path, Q: resize_quality, **JPEG_OPTIONS)

    output_file
  end

  def crop(file, width, height, resize_quality = 90)
    return nil unless Danbooru.config.enable_image_cropping

    output_file = Tempfile.new
    resized_image = Vips::Image.thumbnail(file.path, width, height: height, **CROP_OPTIONS)
    resized_image.jpegsave(output_file.path, Q: resize_quality, **JPEG_OPTIONS)

    output_file
  end

  def validate_shell(file)
    temp = Tempfile.new("validate")
    output, status = Open3.capture2e("vips stats #{file.path} #{temp.path}.v")

    # png | jpeg | gif
    if output =~ /Read Error|Premature end of JPEG file|Failed to read from given file/m
      return false
    end

    return true
  ensure
    temp.close
    temp.unlink
  end
end
