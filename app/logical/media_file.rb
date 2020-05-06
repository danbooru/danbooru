class MediaFile
  extend Memoist
  attr_accessor :file

  # delegate all File methods to `file`.
  delegate *(File.instance_methods - MediaFile.instance_methods), to: :file

  def self.open(file)
    file = Kernel.open(file, "r", binmode: true) unless file.respond_to?(:read)

    case file_ext(file)
    when :jpg, :gif, :png
      MediaFile::Image.new(file)
    when :swf
      MediaFile::Flash.new(file)
    when :webm, :mp4
      MediaFile::Video.new(file)
    when :zip
      MediaFile::Ugoira.new(file)
    else
      MediaFile.new(file)
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
  end

  def initialize(file)
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

  memoize :dimensions, :file_ext, :file_size, :md5
end
