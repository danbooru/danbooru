class MediaFile
  extend Memoist
  attr_accessor :file

  # delegate all File methods to `file`.
  delegate *(File.instance_methods - MediaFile.instance_methods), to: :file

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

  def self.videos_enabled?
    system("ffmpeg -version > /dev/null") && system("mkvmerge --version > /dev/null")
  end

  def initialize(file, **options)
    @file = file
  end

  def dimensions
    [0, 0]
  end

  def width
    dimensions.first
  end

  def height
    dimensions.second
  end

  def md5
    Digest::MD5.file(file.path).hexdigest
  end

  def file_ext
    MediaFile.file_ext(file)
  end

  def file_size
    file.size
  end

  def is_image?
    file_ext.in?([:jpg, :png, :gif])
  end

  def is_video?
    file_ext.in?([:webm, :mp4])
  end

  def is_ugoira?
    file_ext == :zip
  end

  def is_flash?
    file_ext == :swf
  end

  def is_corrupt?
    false
  end

  def is_animated?
    is_video?
  end

  def has_audio?
    false
  end

  def duration
    0.0
  end

  def preview(width, height, **options)
    nil
  end

  def crop(width, height, **options)
    nil
  end

  memoize :file_ext, :file_size, :md5
end
