# A MediaFile for a JPEG, PNG, or GIF file. Uses libvips for resizing images.
#
# @see https://github.com/libvips/ruby-vips
# @see https://libvips.github.io/libvips/API/current
class MediaFile::Image < MediaFile
  # Taken from ArgyllCMS 2.0.0 (see also: https://ninedegreesbelow.com/photography/srgb-profile-comparison.html)
  SRGB_PROFILE = "#{Rails.root}/config/sRGB.icm"

  # http://jcupitt.github.io/libvips/API/current/VipsForeignSave.html#vips-jpegsave
  JPEG_OPTIONS = { Q: 90, background: 255, strip: true, interlace: true, optimize_coding: true }

  # http://jcupitt.github.io/libvips/API/current/libvips-resample.html#vips-thumbnail
  if Vips.at_least_libvips?(8, 10)
    THUMBNAIL_OPTIONS = { size: :down, linear: false, no_rotate: true }
    CROP_OPTIONS = { crop: :attention, linear: false, no_rotate: true }
  elsif Vips.at_least_libvips?(8, 8)
    THUMBNAIL_OPTIONS = { size: :down, linear: false, no_rotate: true, export_profile: "srgb" }
    CROP_OPTIONS = { crop: :attention, linear: false, no_rotate: true, export_profile: "srgb" }
  else
    THUMBNAIL_OPTIONS = { size: :down, linear: false, auto_rotate: false, export_profile: SRGB_PROFILE, import_profile: SRGB_PROFILE }
    CROP_OPTIONS = { crop: :attention, linear: false, auto_rotate: false, export_profile: SRGB_PROFILE, import_profile: SRGB_PROFILE }
  end

  def dimensions
    image.size
  rescue Vips::Error
    [0, 0]
  end

  def is_corrupt?
    image.stats
    false
  rescue Vips::Error
    true
  end

  def is_animated?
    is_animated_gif? || is_animated_png?
  end

  def channels
    image.bands
  end

  def colorspace
    image.interpretation
  end

  # @see https://github.com/jcupitt/libvips/wiki/HOWTO----Image-shrinking
  # @see http://jcupitt.github.io/libvips/API/current/Using-vipsthumbnail.md.html
  def preview(width, height)
    output_file = Tempfile.new(["image-preview", ".jpg"])
    resized_image = preview_frame.image.thumbnail_image(width, height: height, **THUMBNAIL_OPTIONS)
    resized_image.jpegsave(output_file.path, **JPEG_OPTIONS)

    MediaFile::Image.new(output_file)
  end

  def crop(width, height)
    output_file = Tempfile.new(["image-crop", ".jpg"])
    resized_image = preview_frame.image.thumbnail_image(width, height: height, **CROP_OPTIONS)
    resized_image.jpegsave(output_file.path, **JPEG_OPTIONS)

    MediaFile::Image.new(output_file)
  end

  def preview_frame
    if is_animated?
      FFmpeg.new(file).smart_video_preview
    else
      self
    end
  end

  def is_animated_gif?
    file_ext == :gif && image.get("n-pages") > 1
  # older versions of libvips that don't support n-pages will raise an error
  rescue Vips::Error
    false
  end

  def is_animated_png?
    file_ext == :png && APNGInspector.new(file.path).inspect!.animated?
  end

  # @return [Vips::Image] the Vips image object for the file
  def image
    Vips::Image.new_from_file(file.path, fail: true)
  end

  memoize :image, :dimensions, :is_corrupt?, :is_animated_gif?, :is_animated_png?
end
