# frozen_string_literal: true

# A MediaFile for a JPEG, PNG, GIF, WebP, or AVIF file. Uses libvips for reading and resizing images.
#
# The images are read by `libexec/image` in a separate process inside the ExternalCommand sandbox, so a bug in libvips or
# the image libraries it uses can't be exploited by a malicious file to take over the Rails process.
#
# @see libexec/image
# @see https://github.com/libvips/ruby-vips
# @see https://libvips.github.io/libvips/API/current
class MediaFile::Image < MediaFile
  # An image that libvips couldn't resize. libvips' own error messages aren't shown to users.
  class ResizeError < MediaFile::InvalidFileError
    def initialize(message = "libvips error")
      super
    end
  end

  # Images are decoded by libexec/image, which can use at most 4 GB of memory (`MediaFile::ExternalCommand::MEMORY_LIMIT`). An
  # image that needs more fails partway through decoding, which looks the same as a corrupt file. The two limits below
  # reject images that would need too much memory before they're decoded, so they're reported as too large instead.
  #
  # Most JPEGs and PNGs are decoded a few rows at a time, so their size in memory is 0 and only the size limits in
  # `MediaFile.config` apply. Progressive JPEGs, interlaced PNGs, rotated JPEGs and PNGs, GIFs, WebPs, and AVIFs are
  # decoded all at once, so the whole decoded image has to fit in memory. This is the max size of that decoded image
  # (see `#in_memory_size`).
  #
  # Measured with libvips 8.18 at this limit, PNGs need about 1.8 GB and progressive JPEGs under 3 GB. The largest GIF
  # (46 MP) and AVIF (36 MP) on Danbooru need 1 GB and 2.3 GB.
  MAX_IN_MEMORY_SIZE = 1.gigabyte

  # The max resolution of WebPs. libvips' WebP loader keeps about five copies of the image in memory while decoding it,
  # so WebPs run out of memory long before they reach MAX_IN_MEMORY_SIZE. Measured with libvips 8.18, 12803x12803 is the
  # largest WebP that fits, and 12900x12900 runs out of memory.
  MAX_WEBP_RESOLUTION = 12_800 * 12_800

  # Set by `.read!`, which reads several images at once.
  attr_writer :info

  # Run a libexec/image command in the sandbox, with the default 4 GB memory limit (see `MAX_IN_MEMORY_SIZE`).
  #
  # @return [Hash, nil] The JSON output of the command, with symbol keys, or nil if it crashed or printed too much.
  # @raise [MediaFile::TimeoutError] If the command timed out.
  # @raise [MediaFile::ExternalCommand::SyscallError] If the command was killed by the sandbox. It isn't wrapped, so the file can
  #   be quarantined.
  def self.run!(*args, read:, write: [], timeout: MediaFile::ExternalCommand::TIMEOUT)
    result = MediaFile::ExternalCommand.run_script("libexec/image", *args, gems: %w[ffi ruby-vips logger], read:, write:, timeout:)
    result&.deep_symbolize_keys
  rescue MediaFile::ExternalCommand::OutputLimitError
    MediaFile.logger.warn("libexec/image printed too much output: #{args.first}")
    nil
  end

  # Read and decode several images with one call to libexec/image, like the frames of a ugoira. Images over the upload
  # limits aren't decoded.
  #
  # @return [void]
  def self.read!(images, timeout: MediaFile::ExternalCommand::TIMEOUT)
    images = images.grep(MediaFile::Image)
    return if images.empty?

    limits = {
      max_resolution: MediaFile.config.max_image_resolution,
      max_width: MediaFile.config.max_image_width,
      max_height: MediaFile.config.max_image_height,
      max_in_memory_size: MAX_IN_MEMORY_SIZE,
      max_webp_resolution: MAX_WEBP_RESOLUTION,
    }
    output = run!("read", limits.to_json, *images.flat_map { [it.file_ext, it.path] }, read: images.map(&:path), timeout:)
    results = output&.dig(:images)

    unless results.is_a?(Array) && results.size == images.size
      MediaFile.logger.warn("libexec/image returned an invalid result: #{output.inspect.truncate(1000)}") unless output.nil?
      results = []
    end

    images.each_with_index { |image, i| image.info = parse_info(results[i]) }
  end

  # libexec/image parses untrusted files, so a compromised libexec/image could print anything. Anything that isn't a number is
  # treated as 0, and anything that isn't an MD5 hash isn't used as the pixel hash.
  #
  # @param result [Hash, nil] The result for one image from `libexec/image read`, or nil if libexec/image crashed.
  # @return [Hash] The image's width, height, frame count, frame delays, size in memory, whether it's over the upload
  #   limits, the error to show users, and pixel hash. The width and height are 0 if the image's header couldn't be read.
  def self.parse_info(result)
    result = {} unless result.is_a?(Hash)
    width = Integer(result[:width], exception: false).to_i
    height = Integer(result[:height], exception: false).to_i

    # libvips' own error isn't shown to users.
    error = "libvips error" if result[:error] || width <= 0 || height <= 0

    {
      width:,
      height:,
      n_pages: Integer(result[:n_pages], exception: false),
      delay: Array(result[:delay]).map { Integer(it, exception: false).to_i },
      in_memory_size: Integer(result[:in_memory_size], exception: false).to_i,
      too_large: result[:too_large] == true,
      error:,
      pixel_hash: result[:pixel_hash].to_s[/\A\h{32}\z/],
    }
  end
  private_class_method :parse_info

  def close
    super
    @preview_frame&.close unless @preview_frame == self
    @preview_frame = nil
  end

  def dimensions
    if info[:width] > 0 && info[:height] > 0
      [info[:width], info[:height]]
    else
      [metadata.width, metadata.height]
    end
  end

  # @return [Boolean] True if the image is over the upload limits (see `MAX_IN_MEMORY_SIZE`). It isn't
  #   decoded, so it's too large instead of corrupt.
  def is_too_large?
    info[:too_large]
  end

  # Images that are too large aren't supported.
  def is_supported?
    return false if is_too_large?

    case file_ext
    when :avif
      !metadata.is_rotated? && !metadata.is_mirrored? && !metadata.is_cropped? && !metadata.is_grid_image? && !metadata.has_auxiliary_image? && !metadata.is_animated_avif?
    else
      true
    end
  end

  # XXX we should check if animated gifs can be successfully decoded, but ffmpeg sometimes returns errors for
  # seemingly good gifs, and no errors for known corrupted gifs.
  def is_corrupt?
    error.present?
  end

  # @return [String, nil] The error to show users if the image is corrupt.
  def error
    info[:error]
  end

  # @return [Integer] The size in bytes of the decoded image if it's decoded all at once, or 0 if it's decoded a few rows
  #   at a time (see `MAX_IN_MEMORY_SIZE`).
  def in_memory_size
    info[:in_memory_size]
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
      info[:n_pages]
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
    return nil if info[:delay].empty?

    info[:delay].sum { |delay| (delay <= 10) ? 100 : delay } / 1000.0
  end

  # @return [Integer, nil] The duration of the animation as calculated by ffmpeg, or possibly nil if the file
  #   isn't animated or is corrupt. Note that libvips and ffmpeg may disagree on the duration.
  def ffmpeg_duration
    video.duration
  end

  def frame_rate
    return nil if !is_animated? || frame_count.nil? || duration.nil? || duration == 0
    frame_count / duration
  end

  # @return [MediaFile::Image] The image resized to the exact width and height.
  # @raise [ResizeError] If the image couldn't be resized.
  def resize!(width, height, format: :jpeg, quality: 85)
    output_file = MediaFile::Tempfile.new(["media-file-image-preview-#{md5}-", ".#{format}"])
    result = MediaFile::Image.run!("resize", file_ext, path, width, height, format, quality, output_file.path, read: [path], write: [output_file.path])

    # libvips' own error isn't shown to users, like in `.parse_info`. libexec/image could write anything if it were
    # compromised, so check that it wrote an image of the right type.
    unless result && result[:error].nil? && MediaFile.file_ext(output_file) == { jpeg: :jpg, webp: :webp }.fetch(format.to_sym)
      MediaFile.logger.warn("libexec/image resize failed: #{result.inspect.truncate(1000)}") unless result.nil?
      raise ResizeError
    end

    MediaFile::Image.new(output_file)
  rescue StandardError
    output_file&.close
    raise
  end

  def preview!(max_width, max_height, **options)
    w, h = MediaFile.scale_dimensions(width, height, max_width, max_height)
    preview_frame.resize!(w, h, **options)
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

  # @return [String] The MD5 hash of the image's pixels, as a PAM file (https://netpbm.sourceforge.net/doc/pam.html), or
  #   the file's MD5 if the image is animated or can't be decoded. A PAM file is a header followed by the raw pixels, so
  #   the hash only depends on the pixels, not the file format or metadata. See `libexec/image`.
  def pixel_hash
    return md5 if is_animated?

    info[:pixel_hash] || md5
  end

  private

  # @return [Hash] The image's properties, read by libexec/image (see `.parse_info`). It's locked so that libexec/image only
  #   runs once when it's read from several threads, like when generating previews in parallel.
  def info
    synchronize(:info) do
      MediaFile::Image.read!([self]) if @info.nil?
      @info
    end
  end

  # @return [MediaFile::FFmpeg] The FFmpeg instance for this file. It's cached, because it caches what ffmpeg returns.
  def video
    synchronize(:video) { @video ||= MediaFile::FFmpeg.new(self) }
  end

  def preview_frame
    synchronize(:preview_frame) do
      @preview_frame ||= is_animated? ? (video.smart_video_preview || self) : self
    end
  end
end
