# frozen_string_literal: true

# The library's declarations: what it can read, and the settings apps can change. There's no logic here.
class MediaFile
  # The image types the library can read, with libvips (see `MediaFile::Image`). libexec/image has its own copy of this
  # list, because it doesn't load the library.
  SUPPORTED_IMAGE_TYPES = %i[jpg png gif webp avif].freeze

  # The video types the library can read, with ffmpeg (see `MediaFile::Video`).
  SUPPORTED_VIDEO_TYPES = %i[mp4 webm].freeze

  # The archive types the library can read, with libexec/archive (see `MediaFile::Archive`). Ugoiras are .zip files too,
  # but they're read by `MediaFile::Ugoira`.
  SUPPORTED_ARCHIVE_TYPES = %i[zip rar 7z].freeze

  # The MIME types of the file types the library detects. Other files are "application/octet-stream".
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

  # The settings apps can change with `MediaFile.configure`, like Danbooru does in config/initializers/media_file.rb.
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
end
