module DanbooruImageResizer
  # Taken from ArgyllCMS 2.0.0 (see also: https://ninedegreesbelow.com/photography/srgb-profile-comparison.html)
  SRGB_PROFILE = "#{Rails.root}/config/sRGB.icm"
  # http://jcupitt.github.io/libvips/API/current/libvips-resample.html#vips-thumbnail
  THUMBNAIL_OPTIONS = { size: :down, linear: false, auto_rotate: false, export_profile: SRGB_PROFILE }
  # http://jcupitt.github.io/libvips/API/current/VipsForeignSave.html#vips-jpegsave
  JPEG_OPTIONS = { background: 255, strip: true, interlace: true, optimize_coding: true }
  CROP_OPTIONS = { linear: false, auto_rotate: false, export_profile: SRGB_PROFILE, crop: :attention }

  # XXX libvips-8.4 on Debian doesn't support the `Vips::Image.thumbnail` method.
  # On 8.4 we have to shell out to vipsthumbnail instead. Remove when Debian supports 8.5.
  def self.resize(file, width, height, quality = 90)
    if Vips.at_least_libvips?(8, 5)
      resize_ruby(file, width, height, quality)
    else
      resize_shell(file, width, height, quality)
    end
  end

  def self.crop(file, width, height, quality = 90)
    if Vips.at_least_libvips?(8, 5)
      crop_ruby(file, width, height, quality)
    else
      crop_shell(file, width, height, quality)
    end    
  end

  # https://github.com/jcupitt/libvips/wiki/HOWTO----Image-shrinking
  # http://jcupitt.github.io/libvips/API/current/Using-vipsthumbnail.md.html
  def self.resize_ruby(file, width, height, resize_quality)
    output_file = Tempfile.new
    resized_image = Vips::Image.thumbnail(file.path, width, height: height, **THUMBNAIL_OPTIONS)
    resized_image.jpegsave(output_file.path, Q: resize_quality, **JPEG_OPTIONS)

    output_file
  end

  def self.crop_ruby(file, width, height, resize_quality)
    return nil unless Danbooru.config.enable_image_cropping

    output_file = Tempfile.new
    resized_image = Vips::Image.thumbnail(file.path, width, height: height, **CROP_OPTIONS)
    resized_image.jpegsave(output_file.path, Q: resize_quality, **JPEG_OPTIONS)

    output_file
  end

  def self.resize_shell(file, width, height, quality)
    output_file = Tempfile.new(["resize", ".jpg"])

    # --size=WxH will upscale if the image is smaller than the target size.
    # Fix the target size so that it's not bigger than the image.
    image = Vips::Image.new_from_file(file.path)
    target_width  = [image.width, width].min
    target_height = [image.height, height].min

    arguments = [
      file.path,
      "--eprofile=#{SRGB_PROFILE}",
      "--size=#{target_width}x#{target_height}",
      "--format=#{output_file.path}[Q=#{quality},background=255,strip,interlace,optimize_coding]"
    ]

    success = system("vipsthumbnail", *arguments)
    raise RuntimeError, "vipsthumbnail failed (exit status: #{$?.exitstatus})" if !success

    output_file
  end

  def self.crop_shell(file, width, height, quality)
    return nil unless Danbooru.config.enable_image_cropping

    output_file = Tempfile.new(["crop", ".jpg"])

    # --size=WxH will upscale if the image is smaller than the target size.
    # Fix the target size so that it's not bigger than the image.
    image = Vips::Image.new_from_file(file.path)

    arguments = [
      file.path,
      "--eprofile=#{SRGB_PROFILE}",
      "--smartcrop=attention",
      "--size=#{width}x#{height}",
      "--format=#{output_file.path}[Q=#{quality},background=255,strip,interlace,optimize_coding]"
    ]

    success = system("vipsthumbnail", *arguments)
    raise RuntimeError, "vipsthumbnail failed (exit status: #{$?.exitstatus})" if !success

    output_file
  end
end
