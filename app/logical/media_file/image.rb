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
  rescue StandardError
    [0, 0]
  end

  def is_supported?
    case file_ext
    when :avif
      !metadata.is_rotated? && !metadata.is_mirrored? && !metadata.is_cropped? && !metadata.is_grid_image? && !metadata.has_auxiliary_image? && !metadata.is_animated_avif?
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
  rescue Vips::Error
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
    image.get("delay").map { |delay| (delay <= 10) ? 100 : delay }.sum / 1000.0
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

    output_file = Danbooru::Tempfile.new(["danbooru-image-preview-#{md5}-", ".#{format}"])
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
    # First we normalize the image to the same colorspace and add an alpha layer if missing,
    # so that pixel data stays the same even for different profiles
    img = open_image(fail: true)
    img = img.icc_transform("srgb") if img.get_typeof("icc-profile-data") != 0
    img = img.colourspace("srgb") if img.interpretation != :srgb
    img = img.add_alpha unless img.has_alpha?

    # Then we create a pam file: https://netpbm.sourceforge.net/doc/pam.html
    # It's basically a header followed by raw pixels, so that we strip everything
    # except the barebone necessary data for pixel hash computation
    pam_file = Danbooru::Tempfile.open(["danbooru-pixel-hash-#{md5}-", ".pam"])

    pam_file.binmode
    pam_file.puts "P7"
    pam_file.puts "WIDTH #{img.width}"
    pam_file.puts "HEIGHT #{img.height}"
    pam_file.puts "DEPTH #{img.bands}"
    pam_file.puts "MAXVAL 255"
    pam_file.puts "TUPLTYPE RGB_ALPHA"
    pam_file.puts "ENDHDR"

    # Finally, we write the raw pixel data to the pam file
    target = Vips::TargetCustom.new
    target.on_write do |chunk|
      pam_file.write(chunk)
      chunk.bytesize
    end

    img.rawsave_target(target)

    pam_file.flush
    MediaFile::Image.new(pam_file)
  ensure
    img&.release
  end

  private

  # @return [Vips::Image] the Vips image object for the file
  def image
    @image ||= open_image(fail: false)
  end

  def open_image(**options)
    case file_ext
    when :jpg
      Vips::Image.new_from_file(file.path, access: :sequential, autorotate: true, **options)
    when :png
      # pngload cannot rotate the image during load, so we do it after.
      open_png(**options)
    else
      # Browser support for WebP/AVIF is not widespread, and vips cannot read some of these flags, so we don't support it either.
      Vips::Image.new_from_file(file.path, access: :sequential, **options)
    end
  end

  # Open with sequential access when the image does not need rotation, otherwise use the default access mode.
  #
  # Sequential access uses much less memory than the default access mode but is not supported by `autorot`,
  # so we only reopen the picture in default mode if we actually need it.
  # This results in a higher memory usage for rotated pngs, but they are the rare case, so it's an overall gain.
  #
  # Note that only rotation specified before the IDAT chunk (actual image data) is considered valid.
  # Other types of rotation metadata are ignored by most browsers, so we ignore them too.
  def open_png(**options)
    image = Vips::Image.new_from_file(file.path, access: :sequential, **options)
    orientation = image.get("orientation") if image.get_typeof("orientation") != 0

    if orientation.present? && orientation != 1
      image.release
      image = Vips::Image.new_from_file(file.path, **options)
      image = image.autorot
    end

    image
  end

  def video
    FFmpeg.new(self)
  end

  def preview_frame
    if is_animated?
      @preview_frame ||= video.smart_video_preview || self
    else
      @preview_frame ||= self
    end
  end

  memoize :video, :dimensions, :error, :metadata, :is_corrupt?, :is_animated_gif?, :is_animated_png?
end
