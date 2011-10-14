#!ruby
# encoding: US-ASCII

class ImageSize
  require "stringio"

# Image Type Constants
  module Type
    OTHER = "OTHER"
    GIF  = "GIF"
    PNG  = "PNG"
    JPEG = "JPEG"
    BMP  = "BMP"
    PPM  = "PPM" # PPM is like PBM, PGM, & XV
    PBM  = "PBM"
    PGM  = "PGM"
#   XV   = "XV"
    XBM  = "XBM"
    TIFF = "TIFF"
    XPM  = "XPM"
    PSD  = "PSD"
    SWF  = "SWF"
  end

  JpegCodeCheck = [
    "\xc0", "\xc1", "\xc2", "\xc3",
    "\xc5", "\xc6", "\xc7",
    "\xc9", "\xca", "\xcb",
    "\xcd", "\xce", "\xcf",
  ]

  # image type list
  def ImageSize.type_list
    Type.constants 
  end

  # receive image & make size
  # argument 1 is image String, StringIO or IO
  # argument 2 is type(ImageSize::Type::GIF and so on.) or nil
  def initialize(img_data, img_type = nil)
    @img_data = img_data.dup
    @img_width  = nil
    @img_height = nil
    @img_type   = nil

    if @img_data.is_a?(IO)
      img_top = @img_data.read(1024)
      img_io = def_read_o(@img_data)
    elsif @img_data.is_a?(StringIO)
      img_top = @img_data.read(1024)
      img_io = def_read_o(@img_data)
    elsif @img_data.is_a?(String)
      img_top = @img_data[0, 1024]
#      img_io = StringIO.open(@img_data){|sio| io = def_read_o(sio); io }
      img_io = StringIO.open(@img_data)
      img_io = def_read_o(img_io)
    else
      raise "argument class error!! #{img_data.type}"
    end
    
    if @img_type.nil?
      @img_type = check_type(img_top)
    else
      type = Type.constants.find{|t| img_type == t }
      raise("type is failed. #{img_type}\n") if !type
      @img_type = img_type
    end

    if @img_type != Type::OTHER
      @img_width, @img_height = self.__send__("measure_#{@img_type}", img_io)
    else
      @img_width, @img_height = [nil, nil]
    end
    
    if @img_data.is_a?(String)
      img_io.close
    end
  end

  # get image type
  # ex. "GIF", "PNG", "JPEG"
  def get_type; @img_type; end
  
  # get image height
  def get_height
    if @img_type == Type::OTHER then nil else @img_height end
  end
  
  # get image width
  def get_width
    if @img_type == Type::OTHER then nil else @img_width end
  end
  
  # get image width and height(Array)
  def get_size
    [self.get_width, self.get_height]
  end
  
  alias :height :get_height
  alias :h :get_height
  
  alias :width :get_width
  alias :w :get_width
  
  alias :size :get_size
  
  
  private
  
  # define read_o
  def def_read_o(io)
    io.seek(0, 0)
    # define Singleton-method definition to IO (byte, offset)
    def io.read_o(length = 1, offset = nil)
      self.seek(offset, 0) if offset
      ret = self.read(length)
      raise "cannot read!!" unless ret
      ret
    end
    io
  end

  def check_type(img_top)
    if img_top =~ /^GIF8[7,9]a/                      then Type::GIF
    elsif img_top[0, 8] == "\x89PNG\x0d\x0a\x1a\x0a" then Type::PNG
    elsif img_top[0, 2] == "\xFF\xD8"                then Type::JPEG
    elsif img_top[0, 2] == 'BM'                      then Type::BMP
    elsif img_top =~ /^P[1-7]/                       then Type::PPM
    elsif img_top =~ /\#define\s+\S+\s+\d+/          then Type::XBM
    elsif img_top[0, 4] == "MM\x00\x2a"              then Type::TIFF
    elsif img_top[0, 4] == "II\x2a\x00"              then Type::TIFF
    elsif img_top =~ /\/\* XPM \*\//                 then Type::XPM
    elsif img_top[0, 4] == "8BPS"                    then Type::PSD
    elsif img_top[1, 2] == "WS"                      then Type::SWF
    else Type::OTHER
    end
  end

  def measure_GIF(img_io)
    img_io.read_o(6)
    img_io.read_o(4).unpack('vv')
  end

  def measure_PNG(img_io)
    img_io.read_o(12)
    raise "This file is not PNG." unless img_io.read_o(4) == "IHDR"
    img_io.read_o(8).unpack('NN')
  end

  def measure_JPEG(img_io)
    c_marker = "\xFF"   # Section marker.
    img_io.read_o(2)
    while(true)
      marker, code, length = img_io.read_o(4).unpack('aan')
      raise "JPEG marker not found!" if marker != c_marker

      if JpegCodeCheck.include?(code)
        height, width = img_io.read_o(5).unpack('xnn')
        return([width, height])
      end
      img_io.read_o(length - 2)
    end
  end

  def measure_BMP(img_io)
    img_io.read_o(26).unpack("x18VV");
  end

  def measure_PPM(img_io)
    header = img_io.read_o(1024)
    header.gsub!(/^\#[^\n\r]*/m, "")
    header =~ /^(P[1-6])\s+?(\d+)\s+?(\d+)/m
    width = $2.to_i; height = $3.to_i
    case $1
      when "P1", "P4" then @img_type = "PBM"
      when "P2", "P5" then @img_type = "PGM"
      when "P3", "P6" then @img_type = "PPM"
#     when "P7"
#       @img_type = "XV"
#       header =~ /IMGINFO:(\d+)x(\d+)/m
#       width = $1.to_i; height = $2.to_i
    end
    [width, height]
  end

  alias :measure_PGM :measure_PPM
  alias :measure_PBM :measure_PPM
  
  def measure_XBM(img_io)
    img_io.read_o(1024) =~ /^\#define\s*\S*\s*(\d+)\s*\n\#define\s*\S*\s*(\d+)/mi
    [$1.to_i, $2.to_i]
  end

  def measure_XPM(img_io)
    width = height = nil
    while(line = img_io.read_o(1024))
      if line =~ /"\s*(\d+)\s+(\d+)(\s+\d+\s+\d+){1,2}\s*"/m
        width = $1.to_i; height = $2.to_i
        break
      end
    end
    [width, height]
  end

  def measure_PSD(img_io)
    img_io.read_o(26).unpack("x14NN")
  end

  def measure_TIFF(img_io)
    endian = if (img_io.read_o(4) =~ /II\x2a\x00/o) then 'v' else 'n' end
# 'v' little-endian   'n' default to big-endian

    packspec = [
      nil,           # nothing (shouldn't happen)
      'C',           # BYTE (8-bit unsigned integer)
      nil,           # ASCII
      endian,        # SHORT (16-bit unsigned integer)
      endian.upcase, # LONG (32-bit unsigned integer)
      nil,           # RATIONAL
      'c',           # SBYTE (8-bit signed integer)
      nil,           # UNDEFINED
      endian,        # SSHORT (16-bit unsigned integer)
      endian.upcase, # SLONG (32-bit unsigned integer)
    ]

    offset = img_io.read_o(4).unpack(endian.upcase)[0] # Get offset to IFD

    ifd = img_io.read_o(2, offset)
    num_dirent = ifd.unpack(endian)[0]                   # Make it useful
    offset += 2
    num_dirent = offset + (num_dirent * 12);             # Calc. maximum offset of IFD

    ifd = width = height = nil
    while(width.nil? || height.nil?)
      ifd = img_io.read_o(12, offset)                 # Get first directory entry
      break if (ifd.nil? || (offset > num_dirent))
      offset += 12
      tag = ifd.unpack(endian)[0]                       # ...and decode its tag
      type = ifd[2, 2].unpack(endian)[0]                # ...and the data type

     # Check the type for sanity.
      next if (type > packspec.size + 0) || (packspec[type].nil?)
      if tag == 0x0100                                  # Decode the value
        width = ifd[8, 4].unpack(packspec[type])[0]
      elsif tag == 0x0101                               # Decode the value
        height = ifd[8, 4].unpack(packspec[type])[0]
      end
    end

    raise "#{if width.nil? then 'width not defined.' end} #{if height.nil? then 'height not defined.' end}" if width.nil? || height.nil?
    [width, height]
  end

  def measure_SWF(img_io)
    header = img_io.read_o(9)
    
    sig1 = header[0,1]
    sig2 = header[1,1]
    sig3 = header[2,1]

    if !((sig1 == 'F' || sig1 == 'C') && sig2 == 'W' && sig3 == 'S')
      raise("This file is not SWF.")
    end

    bit_length = Integer("0b#{header.unpack('@8B5')[0]}")
    header << img_io.read_o(bit_length*4/8+1)
    str = header.unpack("@8B#{5+bit_length*4}")[0]
    last = 5
    x_min = Integer("0b#{str[last,bit_length]}")
    x_max = Integer("0b#{str[(last += bit_length),bit_length]}")
    y_min = Integer("0b#{str[(last += bit_length),bit_length]}")
    y_max = Integer("0b#{str[(last += bit_length),bit_length]}")
    width = (x_max - x_min)/20
    height = (y_max - y_min)/20
    [width, height]
  end
end


if __FILE__ == $0
  print "TypeList: #{ImageSize.type.inspect}\n"

  Dir.glob("*").each do |file|
    print "#{file} (string)\n"
    open(file, "rb") do |fh|
      img = ImageSize.new(fh.read)
      print <<-EOF
type:   #{img.get_type.inspect}
width:  #{img.get_width.inspect}
height: #{img.get_height.inspect}
      EOF
    end
  end
end

