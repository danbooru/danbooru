# A MediaFile represents an image, video, or flash file. It contains methods for
# detecting the file type, for generating a preview image, for getting metadata,
# and for resizing images.
#
# A MediaFile is a wrapper around a File object, and supports all methods
# supported by a File.
class MediaFile
  extend Memoist
  attr_accessor :file

  # delegate all File methods to `file`.
  delegate *(File.instance_methods - MediaFile.instance_methods), to: :file

  # Open a file or filename and return a MediaFile object.
  #
  # @param file [File, String] a filename or an open File object
  # @param options [Hash] extra options for the MediaFile subclass.
  # @return [MediaFile] the media file
  def self.open(file, **options)
    file = Kernel.open(file, "r", binmode: true) unless file.respond_to?(:read)

    case file_ext(file)
    when :jpg, :gif, :png
      MediaFile::Image.new(file, **options)
    when :swf
      MediaFile::Flash.new(file, **options)
    when :webm, :mp4
      MediaFile::Video.new(file, **options)
    when :zip
      MediaFile::Ugoira.new(file, **options)
    else
      MediaFile.new(file, **options)
    end
  end

  # Detect a file's type based on the magic bytes in the header.
  # @param [File] an open file
  # @return [Symbol] the file's type
  def self.file_ext(file)
    header = file.pread(16, 0)

    case header
    when /\A\xff\xd8/n
      :jpg
    when /\AGIF87a/, /\AGIF89a/
      :gif
    when /\A\x89PNG\r\n\x1a\n/n
      :png
    when /\ACWS/, /\AFWS/, /\AZWS/
      :swf
    when /\x1a\x45\xdf\xa3/n
      :webm
    when /\A....ftyp(?:isom|3gp5|mp42|MSNV|avc1)/
      :mp4
    when /\APK\x03\x04/
      :zip
    else
      :bin
    end
  rescue EOFError
    :bin
  end

  # @return [Boolean] true if we can generate video previews.
  def self.videos_enabled?
    system("ffmpeg -version > /dev/null") && system("mkvmerge --version > /dev/null")
  end

  # Initialize a MediaFile from a regular File.
  # @param file [File] the image file
  def initialize(file, **options)
    @file = file
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

  # @return [String] the MD5 hash of the file, as a hex string.
  def md5
    Digest::MD5.file(file.path).hexdigest
  end

  # @return [Symbol] the detected file extension
  def file_ext
    MediaFile.file_ext(file)
  end

  # @return [Integer] the size of the file in bytes
  def file_size
    file.size
  end

  def metadata
    ExifTool.new(file).metadata
  end

  # @return [Boolean] true if the file is an image
  def is_image?
    file_ext.in?([:jpg, :png, :gif])
  end

  # @return [Boolean] true if the file is a video
  def is_video?
    file_ext.in?([:webm, :mp4])
  end

  # @return [Boolean] true if the file is a Pixiv ugoira
  def is_ugoira?
    file_ext == :zip
  end

  # @return [Boolean] true if the file is a Flash file
  def is_flash?
    file_ext == :swf
  end

  # @return [Boolean] true if the file is corrupted in some way
  def is_corrupt?
    false
  end

  # @return [Boolean] true if the file is animated. Note that GIFs and PNGs may be animated.
  def is_animated?
    is_video?
  end

  # @return [Boolean] true if the file has an audio track. The track may not be audible.
  def has_audio?
    false
  end

  # @return [Float] the duration of the video or animation, in seconds.
  def duration
    0.0
  end

  # Return a preview of the file, sized to fit within the given width and
  # height (preserving the aspect ratio).
  #
  # @param width [Integer] the max width of the image
  # @param height [Integer] the max height of the image
  # @param options [Hash] extra options when generating the preview
  # @return [MediaFile] a preview file
  def preview(width, height, **options)
    nil
  end

  # Return a cropped preview version of the file, sized to fit exactly within
  # the given width and height.
  #
  # @param width [Integer] the width of the cropped image
  # @param height [Integer] the height of the cropped image
  # @param options [Hash] extra options when generating the preview
  # @return [MediaFile] a cropped preview file
  def crop(width, height, **options)
    nil
  end

  memoize :file_ext, :file_size, :md5, :metadata
end
