# frozen_string_literal: true

# A MediaFile for a JPEG, PNG, or GIF file. Uses libvips for resizing images.
#
# @see https://github.com/libvips/ruby-vips
# @see https://libvips.github.io/libvips/API/current
class MediaFile::Image < MediaFile
  delegate :thumbnail_image, to: :image

  def close
    super
    @preview_frame&.close unless @preview_frame == self
    @preview_frame = nil
    @image&.release
    @image = nil
  end

  def dimensions
    image.size
  rescue Vips::Error
    [metadata.width, metadata.height]
  rescue
    [0, 0]
  end

  def is_supported?
    case file_ext
    when :avif
      # XXX Mirrored AVIFs should be unsupported too, but we currently can't detect the mirrored flag using exiftool or ffprobe.
      !metadata.is_rotated? && !metadata.is_cropped? && !metadata.is_grid_image? && !metadata.is_animated_avif?
    when :webp
      !is_animated?
    else
      true
    end
  end

  def is_corrupt?
    error.present?
  end

  def error
    image = open_image(fail: true)
    stats = image.stats
    stats.release
    image.release

    # XXX we should check if animated gifs can be successfully decoded, but ffmpeg sometimes returns errors for
    # seemingly good gifs, and no errors for known corrupted gifs.
    # return video.error if is_animated? && video.error.present?

    nil
  rescue Vips::Error => e
    # XXX Vips has a single global error buffer that is shared between threads and that isn't cleared between operations.
    # We can't reliably use `e.message` here because it may pick up errors from other threads, or from previous
    # operations in the same thread.
    "libvips error"
  end

  def metadata
    super.merge({ "Vips:Error" => error }.compact_blank)
  end

  def duration
    return nil if !is_animated?

    # XXX ffmpeg 7.1 calculates duration incorrectly for some gif and webp files.
    case file_ext
    when :gif, :webp
      vips_duration
    else
      ffmpeg_duration
    end
  end

  def frame_count
    case file_ext
    when :gif, :webp
      n_pages
    when :png
      exif_metadata.fetch("PNG:AnimationFrames", 1)
    when :avif
      video.frame_count
    else
      nil
    end
  end

  # @return [Integer, nil] The duration of the animation as calculated by libvips, or possibly nil if the file
  #   isn't animated or is corrupt. Note that libvips and ffmpeg may disagree on the duration.
  def vips_duration
    # XXX Browsers typically raise the frame time to 0.1s if it's less than or equal to 0.01s.
    image.get("delay").map { |delay| delay <= 10 ? 100 : delay }.sum / 1000.0
  rescue Vips::Error
    nil
  end

  # @return [Integer, nil] The duration of the animation as calculated by ffmpeg, or possibly nil if the file
  #   isn't animated or is corrupt. Note that libvips and ffmpeg may disagree on the duration.
  def ffmpeg_duration
    video.duration
  end

  # @return [Integer, nil] The frame count for gif and webp images, or possibly nil if the file doesn't have a frame count or is corrupt.
  def n_pages
    image.get("n-pages")
  rescue Vips::Error
    nil
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

  def resize!(max_width, max_height, format: :jpeg, quality: 85, **options)
    # @see https://www.libvips.org/API/current/Using-vipsthumbnail.md.html
    # @see https://www.libvips.org/API/current/libvips-resample.html#vips-thumbnail
    if colorspace.in?(%i[srgb rgb16])
      resized_image = thumbnail_image(max_width, height: max_height, size: :force, import_profile: "srgb", export_profile: "srgb", **options)
    elsif colorspace == :cmyk && has_embedded_profile?
      resized_image = thumbnail_image(max_width, height: max_height, size: :force, import_profile: "cmyk", export_profile: "srgb", **options)
    elsif colorspace == :cmyk && !has_embedded_profile?
      # Leave CMYK without a profile as CMYK to avoid distorting the colors by converting it to sRGB
      hscale = max_width / width.to_f
      vscale = max_height / height.to_f
      resized_image = image.resize(hscale, vscale: vscale, **options)
    elsif colorspace.in?(%i[b-w grey16]) && has_embedded_profile?
      # Convert greyscale to sRGB so that the color profile is properly applied before we strip it.
      resized_image = thumbnail_image(max_width, height: max_height, size: :force, export_profile: "srgb", **options)
    elsif colorspace.in?(%i[b-w grey16])
      # Otherwise, leave greyscale without a profile as greyscale because
      # converting it to sRGB would change it from 1 channel to 3 channels.
      resized_image = thumbnail_image(max_width, height: max_height, size: :force, **options)
    else
      raise NotImplementedError
    end

    if resized_image.has_alpha?
      flattened_image = resized_image.flatten(background: 255)
      resized_image.release
      resized_image = flattened_image
    end

    output_file = Danbooru::Tempfile.new(["danbooru-image-preview-#{md5}-", ".#{format.to_s}"])
    case format.to_sym
    when :jpeg
      # https://www.libvips.org/API/current/VipsForeignSave.html#vips-jpegsave
      resized_image.jpegsave(output_file.path, Q: quality, strip: true, interlace: true, optimize_coding: true, optimize_scans: true, trellis_quant: true, overshoot_deringing: true, quant_table: 3)
    when :webp
      # https://www.libvips.org/API/current/VipsForeignSave.html#vips-webpsave
      resized_image.webpsave(output_file.path, Q: quality, preset: :drawing, smart_subsample: false, effort: 4, strip: true)
    when :avif
      # https://www.libvips.org/API/current/VipsForeignSave.html#vips-heifsave
      resized_image.heifsave(output_file.path, Q: quality, compression: :av1, effort: 4, strip: true)
    else
      raise NotImplementedError
    end

    resized_image.release
    MediaFile::Image.new(output_file)
  end

  def preview!(max_width, max_height, **options)
    w, h = MediaFile.scale_dimensions(width, height, max_width, max_height)
    MediaFile::Image.new(preview_frame.file).resize!(w, h, **options)
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

  def is_animated_webp?
    file_ext == :webp && is_animated?
  end

  def is_animated_avif?
    file_ext == :avif && is_animated?
  end

  # Return true if the image has an embedded ICC color profile.
  def has_embedded_profile?
    image.get_typeof("icc-profile-data") != 0
  end

  def pixel_hash
    return md5 if is_animated?

    file = pixel_hash_file
    file.md5
  rescue Vips::Error
    md5
  ensure
    file&.close
  end

  # @return [MediaFile::Image] The raw image used for computing the pixel hash.
  def pixel_hash_file
    image = open_image(fail: true)
    image = image.icc_transform("srgb") if image.get_typeof("icc-profile-data") != 0
    image = image.colourspace("srgb") if image.interpretation != :srgb
    image = image.add_alpha unless image.has_alpha?

    # PAM file format: https://netpbm.sourceforge.net/doc/pam.html
    output_file = Danbooru::Tempfile.open(["danbooru-pixel-hash-#{md5}-", ".pam"])
    output_file.puts "P7"
    output_file.puts "WIDTH #{image.width}"
    output_file.puts "HEIGHT #{image.height}"
    output_file.puts "DEPTH #{image.bands}"
    output_file.puts "MAXVAL 255"
    output_file.puts "TUPLTYPE RGB_ALPHA"
    output_file.puts "ENDHDR"
    output_file.flush
    image.rawsave_fd(output_file.fileno)

    MediaFile::Image.new(output_file)
  ensure
    image&.release
  end

  private

  # @return [Vips::Image] the Vips image object for the file
  def image
    @image ||= open_image(fail: false)
  end

  def open_image(**options)
    case file_ext
    when :jpg
      # Only JPEG supports the EXIF orientation flag. It may technically be present in other formats, but web browsers
      # ignore it, so we do too. XXX AVIF also has `irot` and `imir` flags, which browsers support, but libvips doesn't.
      # https://zpl.fi/exif-orientation-in-different-formats/
      Vips::Image.new_from_file(file.path, access: :sequential, autorotate: true, **options)
    else
      Vips::Image.new_from_file(file.path, access: :sequential, **options)
    end
  end

  def video
    FFmpeg.new(self)
  end

  def preview_frame
    @preview_frame ||= begin
      if is_animated?
        video.smart_video_preview || self
      else
        self
      end
    end
  end

  memoize :video, :dimensions, :error, :metadata, :is_corrupt?, :is_animated_gif?, :is_animated_png?
end
