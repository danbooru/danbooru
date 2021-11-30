# A MediaFile for a JPEG, PNG, or GIF file. Uses libvips for resizing images.
#
# @see https://github.com/libvips/ruby-vips
# @see https://libvips.github.io/libvips/API/current
class MediaFile::Image < MediaFile
  # http://jcupitt.github.io/libvips/API/current/VipsForeignSave.html#vips-jpegsave
  JPEG_OPTIONS = { Q: 90, background: 255, strip: true, interlace: true, optimize_coding: true }

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

  def duration
    return nil if !is_animated?
    video.duration
  end

  def frame_count
    if file_ext == :gif
      image.get("n-pages")
    elsif file_ext == :png
      metadata.fetch("PNG:AnimationFrames", 1)
    else
      nil
    end
  end

  def frame_rate
    return nil if !is_animated? || frame_count.nil? || duration.nil? || duration == 0
    frame_count / duration
  end

  def channels
    image.bands
  end

  def colorspace
    image.interpretation
  end

  def resize(max_width, max_height, format: :jpeg, **options)
    # @see https://www.libvips.org/API/current/Using-vipsthumbnail.md.html
    # @see https://www.libvips.org/API/current/libvips-resample.html#vips-thumbnail
    if colorspace == :srgb
      resized_image = preview_frame.image.thumbnail_image(max_width, height: max_height, import_profile: "srgb", export_profile: "srgb", **options)
    elsif colorspace == :cmyk
      # Leave CMYK as CMYK for better color accuracy than sRGB.
      resized_image = preview_frame.image.thumbnail_image(max_width, height: max_height, import_profile: "cmyk", export_profile: "cmyk", intent: :relative, **options)
    elsif colorspace == :"b-w" && has_embedded_profile?
      # Convert greyscale to sRGB so that the color profile is properly applied before we strip it.
      resized_image = preview_frame.image.thumbnail_image(max_width, height: max_height, export_profile: "srgb", **options)
    elsif colorspace == :"b-w"
      # Otherwise, leave greyscale without a profile as greyscale because
      # converting it to sRGB would change it from 1 channel to 3 channels.
      resized_image = preview_frame.image.thumbnail_image(max_width, height: max_height, **options)
    else
      raise NotImplementedError
    end

    output_file = Tempfile.new(["image-preview", ".jpg"])
    resized_image.jpegsave(output_file.path, **JPEG_OPTIONS)

    MediaFile::Image.new(output_file)
  end

  def preview(max_width, max_height)
    resize(max_width, max_height, size: :down)
  end

  def crop(max_width, max_height)
    resize(max_width, max_height, crop: :attention)
  end

  def preview_frame
    if is_animated?
      FFmpeg.new(file).smart_video_preview
    else
      self
    end
  end

  def is_animated?
    frame_count.to_i > 1
  end

  def is_animated_gif?
    file_ext == :gif && is_animated?
  end

  def is_animated_png?
    file_ext == :png && is_animated?
  end

  # Return true if the image has an embedded ICC color profile.
  def has_embedded_profile?
    image.icc_import(embedded: true)
    true
  rescue Vips::Error
    false
  end

  # @return [Vips::Image] the Vips image object for the file
  def image
    Vips::Image.new_from_file(file.path, fail: true).autorot
  end

  def video
    FFmpeg.new(file)
  end

  memoize :image, :video, :dimensions, :is_corrupt?, :is_animated_gif?, :is_animated_png?
end
