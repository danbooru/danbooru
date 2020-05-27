# Adapted from https://github.com/dim/ruby-imagespec/blob/f2f3ce8bb5b1b411f8658e66a891a095261d94c0/lib/image_spec/parser/swf.rb
# License: https://github.com/dim/ruby-imagespec/blob/master/LICENSE

class MediaFile::Flash < MediaFile
  def dimensions
    # Read the entire stream into memory because the
    # dimensions aren't stored in a standard location
    contents = File.read(file.path, binmode: true).force_encoding("ASCII-8BIT")

    # Our 'signature' is the first 3 bytes
    # Either FWS or CWS.  CWS indicates compression
    signature = contents[0..2]

    # SWF version
    version = contents[3].unpack('C').join.to_i

    # Determine the length of the uncompressed stream
    length = contents[4..7].unpack('V').join.to_i

    # If we do, in fact, have compression
    if signature == 'CWS'
      # Decompress the body of the SWF
      body = Zlib::Inflate.inflate( contents[8..length] )

      # And reconstruct the stream contents to the first 8 bytes (header)
      # Plus our decompressed body
      contents = contents[0..7] + body
    end

    # Determine the nbits of our dimensions rectangle
    nbits = contents.unpack('C'*contents.length)[8] >> 3

    # Determine how many bits long this entire RECT structure is
    rectbits = 5 + nbits * 4    # 5 bits for nbits, as well as nbits * number of fields (4)

    # Determine how many bytes rectbits composes (ceil(rectbits/8))
    rectbytes = (rectbits.to_f / 8).ceil

    # Unpack the RECT structure from the stream in little-endian bit order, then join it into a string
    rect = contents[8..(8 + rectbytes)].unpack("#{'B8' * rectbytes}").join

    # Read in nbits incremenets starting from 5
    dimensions = Array.new
    4.times do |n|
      s = 5 + (n * nbits)     # Calculate our start index
      e = s + (nbits - 1)     # Calculate our end index
      dimensions[n] = rect[s..e].to_i(2)    # Read that range (binary) and convert it to an integer
    end

    # The values we have here are in "twips"
    # 20 twips to a pixel (that's why SWFs are fuzzy sometimes!)
    width = (dimensions[1] - dimensions[0]) / 20
    height = (dimensions[3] - dimensions[2]) / 20

    [width, height]
  end

  memoize :dimensions
end
