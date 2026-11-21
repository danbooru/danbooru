# frozen_string_literal: true

require "active_support"
require "active_support/core_ext"
require "concurrent"
require "digest/md5"
require "etc"
require "ffi"
require "fileutils"
require "json"
require "logger"
require "memoist"
require "shellwords"
require "tempfile"
require "tmpdir"

# A MediaFile represents an image, video, or flash file. It contains methods for
# detecting the file type, for generating a preview image, for getting metadata,
# and for resizing images.
#
# A MediaFile is a wrapper around a File object, and supports all methods
# supported by a File.
class MediaFile
  extend Memoist

  # The base class of every error raised by the library. Its message may include internal details, like file paths or
  # the output of ffmpeg, so it isn't shown to users.
  class Error < StandardError
    # @return [String] The message to show users.
    def user_message
      "The file couldn't be processed"
    end
  end

  # An error caused by the file itself, like a corrupt or invalid file. Its message is written for users.
  class InvalidFileError < Error
    def user_message
      message
    end
  end

  # A file that took too long to process, usually because it's very large or made to be slow to decode. The message
  # says which program timed out, for logs. Users only see that the file took too long.
  class TimeoutError < InvalidFileError
    def initialize(message = "File took too long to process")
      super
    end

    def user_message
      "File took too long to process"
    end
  end

  # The MIME types of the file types we detect. Other files are "application/octet-stream".
  MIME_TYPES = {
    jpg: "image/jpeg",
    png: "image/png",
    gif: "image/gif",
    webp: "image/webp",
    avif: "image/avif",
    mp4: "video/mp4",
    webm: "video/webm",
    swf: "application/x-shockwave-flash",
    zip: "application/zip",
    ugoira: "video/x-ugoira",
  }.freeze

  # The settings for the library. Apps using the library set these with `MediaFile.configure`.
  #
  # @!attribute logger [Logger] Where to log errors from the external programs, like a helper script crashing.
  # @!attribute sandbox [Boolean] If false, run the external programs without Landlock and seccomp. Only turn this off
  #   when the kernel doesn't support Landlock, like in some development environments. Defaults to true, unless the
  #   MEDIA_FILE_DISABLE_SANDBOX environment variable is "true".
  # @!attribute max_file_size [Integer] The largest file the external programs can write, in bytes.
  # @!attribute max_image_resolution [Integer] The largest image that will be decoded, in pixels.
  # @!attribute max_image_width [Integer] The widest image that will be decoded, in pixels.
  # @!attribute max_image_height [Integer] The tallest image that will be decoded, in pixels.
  # @!attribute max_concurrency [Integer] The number of threads ffmpeg can use to encode videos.
  Config = Struct.new(:logger, :sandbox, :max_file_size, :max_image_resolution, :max_image_width, :max_image_height, :max_concurrency, keyword_init: true)

  # @return [Config] The library's settings.
  def self.config
    @config ||= Config.new(
      logger: Logger.new($stderr, level: :info),
      sandbox: ENV["MEDIA_FILE_DISABLE_SANDBOX"] != "true",
      max_file_size: 100.megabytes,
      max_image_resolution: 21_000 * 21_000,
      max_image_width: 40_000,
      max_image_height: 40_000,
      max_concurrency: Concurrent.available_processor_count.to_i.clamp(1..),
    )
  end

  # Change the library's settings.
  #
  # @yieldparam config [Config] The settings.
  def self.configure
    yield config
  end

  # @return [Logger] The logger set in `MediaFile.config`.
  def self.logger
    config.logger
  end

  # Like JSON.parse, but returns nil instead of raising an error if the input is nil, blank, or contains a syntax error.
  # Hashes have indifferent access.
  #
  # @param string [String, nil] The JSON.
  # @return [Object, nil] The parsed JSON, or nil if it's invalid.
  def self.parse_json(string)
    return nil if string.blank?

    json = JSON.parse(string)
    json.is_a?(Hash) ? json.with_indifferent_access : json
  rescue JSON::ParserError
    nil
  end

  attr_accessor :file

  # Delegate all File methods to `file`, except `close`, which is defined below.
  delegate(*(File.instance_methods - MediaFile.instance_methods - [:close]), to: :file)

  # Open a file or filename and return a MediaFile object. If a block is given,
  # pass the file to the block and return the result after closing the file.
  #
  # @param file [File, MediaFile, String] A filename or an open File object.
  # @param options [Hash] extra options for the MediaFile subclass.
  # @yieldparam media_file [MediaFile] The opened media file.
  # @return [MediaFile] The media file.
  def self.open(file, **options, &block)
    if file.is_a?(MediaFile)
      media_file = file
    else
      file = File.open(file, "r", binmode: true) unless file.respond_to?(:read) # rubocop:disable Style/FileOpen
      media_file = new_from_file(file, **options)
    end

    return media_file unless block_given?

    begin
      yield media_file
    ensure
      media_file.close
    end
  end

  # Return a new MediaFile from an open File object.
  #
  # @param file [File] The File object.
  # @param file_ext [Symbol] The file extension.
  # @param options [Hash] Extra options for the MediaFile subclass.
  # @return [MediaFile] The media file.
  def self.new_from_file(file, file_ext = MediaFile.file_ext(file), frame_delays: nil, **options)
    case file_ext
    in :jpg | :gif | :png | :webp | :avif
      MediaFile::Image.new(file, **options)
    in :swf
      MediaFile::Flash.new(file, **options)
    in :webm | :mp4
      MediaFile::Video.new(file, **options)
    in :ugoira
      MediaFile::Ugoira.new(file, **options)
    in :zip if frame_delays.present?
      MediaFile::Ugoira.new(file, frame_delays:, **options)
    else
      MediaFile.new(file, **options)
    end
  end

  # Detect a file's type based on the magic bytes in the header.
  # @param [File] an open file
  # @return [Symbol] the file's type
  def self.file_ext(file)
    MediaFile::FileTypeDetector.new(file).file_ext
  end

  # @return [Boolean] true if we can generate video previews.
  def self.videos_enabled?
    dependency_versions.values_at(:ffmpeg, :mkvmerge).all?
  end

  # The versions of the programs the library runs. They're only checked once, because they don't change while the
  # program is running.
  #
  # @return [Hash{Symbol => String, nil}] The version of each program, or nil if it isn't installed.
  def self.dependency_versions
    @dependency_versions ||= {
      vips: program_output("vips", "--version").to_s[/vips-([0-9.]+)/, 1], # "vips-8.18.7"
      ffmpeg: program_output("ffmpeg", "-version").to_s[/ffmpeg version ([0-9.]+)/, 1], # "ffmpeg version 9.0.2 Copyright..."
      mkvmerge: program_output("mkvmerge", "--version").to_s.chomp.presence, # "mkvmerge v97.0 ('You Don't Have A Clue') 64-bit"
      exiftool: program_output("exiftool", "-ver").to_s.chomp.presence, # "13.55"
    }
  end

  # @return [String, nil] The output of a program, or nil if it isn't installed or fails.
  private_class_method def self.program_output(*command)
    output = IO.popen(command, err: File::NULL, &:read)
    output if $?.success?
  rescue SystemCallError
    nil
  end

  # Initialize a MediaFile from a regular File.
  #
  # @param file [File] The image file.
  def initialize(file, **options)
    @file = file
    @exif_lock = Mutex.new
  end

  # Close the file if it is open.
  def close
    @file&.close
    @file = nil
  end

  # @return [Array<(Integer, Integer)>] the width and height of the file
  def dimensions
    [0, 0]
  end

  # @return [Integer] the width of the file
  def width
    dimensions.first
  end

  # @return [Integer] the height of the file
  def height
    dimensions.second
  end

  # @return [Integer] the resolution of the file
  def resolution
    width.to_i * height.to_i
  end

  # @return [String] The MD5 hash of the file, as a hex string.
  def self.md5(filename, **options)
    MediaFile.open(filename, **options, &:md5)
  end

  # @return [String] the MD5 hash of the file, as a hex string.
  def md5
    Digest::MD5.file(file.path).hexdigest
  end

  # @return [String] The MD5 hash of the image's pixel data, or just the file's MD5 if we can't compute a hash of the image data.
  def self.pixel_hash(filename, **options)
    MediaFile.open(filename, **options, &:pixel_hash)
  end

  # @return [String] The MD5 hash of the image's pixel data, or just the file's MD5 if we can't compute a hash of the image data.
  def pixel_hash
    md5
  end

  # @return [Integer] The size in bytes of the decoded file if it's decoded all at once, or 0 if it isn't (see
  #   `MediaFile::Image::MAX_IN_MEMORY_SIZE`).
  def in_memory_size
    0
  end

  # @return [Symbol] the detected file extension
  def file_ext
    MediaFile.file_ext(file)
  end

  # @return [Integer] the size of the file in bytes
  def file_size
    file.size
  end

  # @return [MediaFile::ExifTool::Metadata] The metadata for the file. Subclasses may override this to add
  #   extra non-ExifTool metadata, such as error messages, Ugoira frame delays, or ffprobe metadata.
  #   This metadata may be slower to calculate than the raw `exif_metadata`.
  def metadata
    exif_metadata
  end

  # @return [MediaFile::ExifTool::Metadata] The metadata for the file, as returned by MediaFile::ExifTool. It's locked so that ExifTool only
  #   runs once when it's read from several threads, like during upload validation.
  def exif_metadata
    @exif_lock.synchronize do
      @exif_metadata ||= MediaFile::ExifTool.new(file).metadata
    end
  end

  # @return [String] The MIME type of the file, or "application/octet-stream" if unknown.
  def mime_type
    MIME_TYPES.fetch(file_ext, "application/octet-stream")
  end

  # @return [Boolean] True if the file is over the upload limits (see `MediaFile::Image::MAX_IN_MEMORY_SIZE`).
  def is_too_large?
    false
  end

  # Check that the file can be processed safely, using the limits in `MediaFile.config`. The checks are ordered so that
  # a file that's too large is rejected before it's decoded, so it can't use too much time or memory first.
  #
  # @param max_duration [Numeric, nil] The longest a video or animation can be in seconds, or nil for no limit.
  # @raise [InvalidFileError] If the file is too large, unsupported, or corrupt. The message is written for users.
  def validate!(max_duration: nil)
    config = MediaFile.config

    # Check the file size before reading the file. Reading the dimensions only decodes images that are within the
    # limits checked below (see `MediaFile::Image.read!`).
    if file_size > config.max_file_size
      raise InvalidFileError, "File size too large (size: #{file_size.to_fs(:human_size)}; max size: #{config.max_file_size.to_fs(:human_size)})"
    # Check the frame count before the dimensions, because getting a video's dimensions requires reading every frame.
    elsif is_video? && packet_count > MediaFile::FFmpeg::MAX_PACKET_COUNT
      raise InvalidFileError, "Video has too many frames (max: #{MediaFile::FFmpeg::MAX_PACKET_COUNT})"
    end

    # Read the file and its metadata at the same time, because both start an external program. Wait for both before
    # checking them, so neither is still running if a check fails.
    reads = [Concurrent::Promises.future_on(:io) { dimensions }, Concurrent::Promises.future_on(:io) { exif_metadata }]
    reads.each(&:wait)
    reads.each(&:value!)

    # These are the same limits `libexec/image` checks before decoding an image (see `within_limits?`). Change both together.
    if resolution > config.max_image_resolution
      raise InvalidFileError, "Image resolution is too large (resolution: #{(resolution / 1_000_000.0).round(1)} megapixels (#{width}x#{height}); max: #{config.max_image_resolution / 1_000_000} megapixels)"
    elsif width.to_i > config.max_image_width
      raise InvalidFileError, "Image width is too large (width: #{width}; max width: #{config.max_image_width})"
    elsif height.to_i > config.max_image_height
      raise InvalidFileError, "Image height is too large (height: #{height}; max height: #{config.max_image_height})"
    elsif in_memory_size > MediaFile::Image::MAX_IN_MEMORY_SIZE
      raise InvalidFileError, "Image is too large to decode (size: #{in_memory_size.to_fs(:human_size)}; max size: #{MediaFile::Image::MAX_IN_MEMORY_SIZE.to_fs(:human_size)})"
    elsif file_ext == :webp && resolution > MediaFile::Image::MAX_WEBP_RESOLUTION
      raise InvalidFileError, "WebP image is too large to decode (resolution: #{(resolution / 1_000_000.0).round(1)} megapixels (#{width}x#{height}); max: #{MediaFile::Image::MAX_WEBP_RESOLUTION / 1_000_000} megapixels)"
    # Check the metadata before `is_supported?`, which needs the metadata to check AVIFs.
    elsif exif_metadata["Danbooru:ExifToolError"].present?
      raise InvalidFileError, "File has too much metadata"
    elsif !is_supported?
      raise InvalidFileError, "File type is not supported"
    elsif is_corrupt?
      raise InvalidFileError, "File is corrupt"
    # Checked after `is_corrupt?`, because corrupt files often have no dimensions, and "corrupt" is the better error.
    elsif width.to_i <= 0 || height.to_i <= 0
      raise InvalidFileError, "Couldn't read the file's dimensions"
    elsif max_duration && duration.to_i > max_duration
      raise InvalidFileError, "Duration must be less than #{max_duration} seconds"
    end
  end

  # @return [Boolean] True if the file is supported by Danbooru. Certain files may be unsupported because they use features we don't support.
  def is_supported?
    true
  end

  # @return [Boolean] true if the file is an image
  def is_image?
    file_ext.in?(%i[jpg png gif webp avif])
  end

  # @return [Boolean] true if the file is a video
  def is_video?
    file_ext.in?([:webm, :mp4])
  end

  # @return [Boolean] True if the file is a MP4.
  def is_mp4?
    file_ext == :mp4
  end

  # @return [Boolean] True if the file is a WebM.
  def is_webm?
    file_ext == :webm
  end

  # @return [Boolean] true if the file is a Pixiv ugoira
  def is_ugoira?
    file_ext == :zip
  end

  # @return [Boolean] true if the file is a Flash file
  def is_flash?
    file_ext == :swf
  end

  # @return [Boolean] True if the file is too corrupted to read or generate thumbnails without error.
  def is_corrupt?
    error.present?
  end

  # @return [String, nil] The error message when reading the file, or nil if there are no errors.
  def error
    nil
  end

  # @return [Boolean] true if the file is animated. Note that GIFs and PNGs may be animated.
  def is_animated?
    is_video? || frame_count.to_i > 1
  end

  # @return [Float, nil] the duration of the video or animation in seconds, or
  #   nil if not a video or animation, or the duration is unknown.
  def duration
    nil
  end

  # @return [Float, nil] the number of frames in the video or animation, or nil
  #   if not a video or animation.
  def frame_count
    nil
  end

  # @return [Float, nil] the average frame rate of the video or animation, or
  #   nil if not a video or animation. Note that GIFs and PNGs can have a
  #   variable frame rate.
  def frame_rate
    nil
  end

  # @return [Boolean] true if the file has an audio track. The track may not be audible.
  def has_audio?
    false
  end

  # Return a preview of the file, sized to fit within the given width and height (preserving the aspect ratio).
  #
  # @param width [Integer] the max width of the image
  # @param height [Integer] the max height of the image
  # @param options [Hash] extra options when generating the preview
  # @return [MediaFile, nil] a preview file, or nil if we can't generate a preview for this file type (e.g. Flash files)
  def preview(width, height, **options)
    preview!(width, height, **options)
  rescue StandardError
    nil
  end

  # Like `preview`, but raises an exception if generating the preview fails for any reason. Videos and ugoiras resize
  # their preview frame, a single frame made by ffmpeg. It's resized directly, without checking if it's animated.
  def preview!(max_width, max_height, **options)
    w, h = MediaFile.scale_dimensions(*preview_frame.dimensions, max_width, max_height)
    preview_frame.resize!(w, h, **options)
  end

  def attributes
    {
      path: path,
      width: width,
      height: height,
      file_size: file_size,
      file_ext: file_ext,
      mime_type: mime_type,
      md5: md5,
      pixel_hash: pixel_hash,
      is_corrupt?: is_corrupt?,
      is_supported?: is_supported?,
      is_animated?: is_animated?,
      duration: duration,
      frame_count: frame_count,
      frame_rate: frame_rate,
      metadata: metadata,
    }.stringify_keys
  end

  def as_json(options = nil)
    attributes.as_json(options)
  end

  memoize def test_case
    template = Erubi::Engine.new <<~TEST.chomp
      should "be parsed correctly" do
        file = MediaFile.open(<%= path.inspect %>)

      <% attributes.except("path").each do |key, value| -%>
      <% if value.is_a?(MediaFile::ExifTool::Metadata) -%>
      <% entries = value.to_h.map { |k, v| "    \#{k.inspect} => \#{v.inspect}," }.join("\n") -%>
        assert_equal({
      <%= entries %>
        }, file.<%= key %>.to_h)
      <% elsif value.nil? -%>
        assert_nil(file.<%= key %>)
      <% else -%>
        assert_equal(<%= value.inspect %>, file.<%= key %>)
      <% end -%>
      <% end -%>
      end
    TEST

    eval(template.src)
  end

  # Scale `width` and `height` to fit within `max_width` and `max_height`.
  def self.scale_dimensions(width, height, max_width, max_height)
    max_width ||= Float::INFINITY
    max_height ||= Float::INFINITY

    if width <= max_width && height <= max_height
      [width, height]
    else
      scale = [max_width.to_f / width.to_f, max_height.to_f / height.to_f].min
      [(width * scale).round.to_i, (height * scale).round.to_i]
    end
  end

  private

  # @return [MediaFile::Image] The frame that previews are made from.
  def preview_frame
    raise NotImplementedError
  end

  memoize :file_ext, :file_size, :md5, :mime_type
end

require_relative "media_file/version"
require_relative "media_file/tempfile"
require_relative "media_file/tempdir"
require_relative "media_file/landlock"
require_relative "media_file/seccomp"
require_relative "media_file/external_command"
require_relative "media_file/file_type_detector"
require_relative "media_file/exif_tool"
require_relative "media_file/ffmpeg"
require_relative "media_file/archive"
require_relative "media_file/image"
require_relative "media_file/video"
require_relative "media_file/flash"
require_relative "media_file/ugoira"
require_relative "media_file/cli"
