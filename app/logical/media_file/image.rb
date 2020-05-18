class MediaFile::Image < MediaFile
  # Taken from ArgyllCMS 2.0.0 (see also: https://ninedegreesbelow.com/photography/srgb-profile-comparison.html)
  SRGB_PROFILE = "#{Rails.root}/config/sRGB.icm"

  # http://jcupitt.github.io/libvips/API/current/VipsForeignSave.html#vips-jpegsave
  JPEG_OPTIONS = { Q: 90, background: 255, strip: true, interlace: true, optimize_coding: true }

  # http://jcupitt.github.io/libvips/API/current/libvips-resample.html#vips-thumbnail
  if Vips.at_least_libvips?(8, 8)
    THUMBNAIL_OPTIONS = { size: :down, linear: false, no_rotate: true, export_profile: SRGB_PROFILE, import_profile: SRGB_PROFILE }
    CROP_OPTIONS = { crop: :attention, linear: false, no_rotate: true, export_profile: SRGB_PROFILE, import_profile: SRGB_PROFILE }
  else
    THUMBNAIL_OPTIONS = { size: :down, linear: false, auto_rotate: false, export_profile: SRGB_PROFILE, import_profile: SRGB_PROFILE }
    CROP_OPTIONS = { crop: :attention, linear: false, auto_rotate: false, export_profile: SRGB_PROFILE, import_profile: SRGB_PROFILE }
  end

  def dimensions
    image.size
  rescue Vips::Error
    [0, 0]
  end

  # https://github.com/jcupitt/libvips/wiki/HOWTO----Image-shrinking
  # http://jcupitt.github.io/libvips/API/current/Using-vipsthumbnail.md.html
  def preview(width, height)
    output_file = Tempfile.new(["image-preview", ".jpg"])
    resized_image = image.thumbnail_image(width, height: height, **THUMBNAIL_OPTIONS)
    resized_image.jpegsave(output_file.path, **JPEG_OPTIONS)

    MediaFile::Image.new(output_file)
  end

  def crop(width, height)
    output_file = Tempfile.new(["image-crop", ".jpg"])
    resized_image = image.thumbnail_image(width, height: height, **CROP_OPTIONS)
    resized_image.jpegsave(output_file.path, **JPEG_OPTIONS)

    MediaFile::Image.new(output_file)
  end

  private

  def image
    @image ||= Vips::Image.new_from_file(file.path, fail: true)
  end
end
