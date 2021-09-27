# A MediaFile for a JPEG, PNG, or GIF file. Uses libvips for resizing images.
#
# @see https://github.com/libvips/ruby-vips
# @see https://libvips.github.io/libvips/API/current
class MediaFile::Image < MediaFile
  # http://jcupitt.github.io/libvips/API/current/VipsForeignSave.html#vips-jpegsave
  JPEG_OPTIONS = { Q: 90, background: 255, strip: true, interlace: true, optimize_coding: true }

  # http://jcupitt.github.io/libvips/API/current/libvips-resample.html#vips-thumbnail
  THUMBNAIL_OPTIONS = { size: :down, linear: false }
  CROP_OPTIONS = { crop: :attention, linear: false }

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
    if is_animated_gif?
      if metadata.has_key?("GIF:Duration")
        # GIF:Duration => "9.03 s"
        metadata["GIF:Duration"].to_f
      else
        # If GIF:Duration is absent then it means the GIF has an unlimited
        # framerate. In this situation we assume the browser will play the GIF
        # at 10 FPS; this is browser dependent.
        #
        # A GIF consists of a series of frames, each frame having a separate frame
        # delay. The duration of the GIF is the sum of each frame delay. If the frame
        # delay of each frame is zero, then it means the GIF has an unlimited framerate
        # and should be played as fast as possible. In reality, browsers cap the
        # framerate to around 10FPS.
        (frame_count * (1.0/10.0)).round(2)
      end
    elsif is_animated_png?
      frame_count.to_f / frame_rate
    else
      nil
    end
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
    if is_animated_gif?
      frame_count / duration
    elsif is_animated_png?
      # XXX we have to resort to ffprobe to get the frame rate because libvips and exiftool can't get it.
      video.frame_rate
    else
      nil
    end
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
    file_ext == :gif && is_animated?
  end

  def is_animated_png?
    file_ext == :png && is_animated?
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
