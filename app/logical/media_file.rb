# frozen_string_literal: true

# A MediaFile represents an image, video, or flash file. It contains methods for
# detecting the file type, for generating a preview image, for getting metadata,
# and for resizing images.
#
# A MediaFile is a wrapper around a File object, and supports all methods
# supported by a File.
class MediaFile
  extend Memoist
  include ActiveModel::Serializers::JSON

  attr_accessor :file

  # delegate all File methods to `file`.
  delegate *(File.instance_methods - MediaFile.instance_methods), to: :file

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
      file = Kernel.open(file, "r", binmode: true) unless file.respond_to?(:read)
      media_file = new_from_file(file, **options)
    end

    if block_given?
      result = yield media_file
      media_file.close
      result
    else
      media_file
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
    FileTypeDetector.new(file).file_ext
  end

  # @return [Boolean] true if we can generate video previews.
  def self.videos_enabled?
    system("ffmpeg -version > /dev/null") && system("mkvmerge --version > /dev/null")
  end

  # Initialize a MediaFile from a regular File.
  #
  # @param file [File] The image file.
  def initialize(file, **options)
    @file = file
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
    width * height
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

  # @return [Symbol] the detected file extension
  def file_ext
    MediaFile.file_ext(file)
  end

  # @return [Integer] the size of the file in bytes
  def file_size
    file.size
  end

  # @return [ExifTool::Metadata] The metadata for the file. Subclasses may override this to add
  #   extra non-ExifTool metadata, such as error messages, Ugoira frame delays, or ffprobe metadata.
  #   This metadata may be slower to calculate than the raw `exif_metadata`.
  def metadata
    exif_metadata
  end

  # @return [ExifTool::Metadata] The metadata for the file, as returned by ExifTool.
  def exif_metadata
    ExifTool.new(file).metadata
  end

  # @return [Mime::Type] The MIME type of the file, or "application/octet-stream" if unknown.
  def mime_type
    Mime::Type.lookup_by_extension(file_ext) || Mime::Type.lookup("application/octet-stream")
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
  rescue
    nil
  end

  # Like `preview`, but raises an exception if generating the preview fails for any reason.
  def preview!(width, height, **options)
    raise NotImplementedError
  end

  # Return a set of AI-inferred tags for this image. Performs an API call to
  # the Autotagger service. The Autotagger service must be running, otherwise
  # it will return an empty list of tags.
  #
  # @return [Array<AITag>] The list of AI tags.
  def ai_tags(autotagger: AutotaggerClient.new)
    autotagger.evaluate!(self)
  end

  def attributes
    {
      path: path,
      width: width,
      height: height,
      file_size: file_size,
      file_ext: file_ext,
      mime_type: mime_type.to_s,
      md5: md5,
      pixel_hash: pixel_hash,
      is_corrupt?: is_corrupt?,
      is_supported?: is_supported?,
      duration: duration,
      frame_count: frame_count,
      frame_rate: frame_rate,
      metadata: metadata
    }.stringify_keys
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

  memoize :file_ext, :file_size, :md5, :mime_type, :exif_metadata
end
