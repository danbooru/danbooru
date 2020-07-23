class APNGInspector
  attr_reader :frames

  PNG_MAGIC_NUMBER = ["89504E470D0A1A0A"].pack('H*')

  def initialize(file_path)
    @file_path = file_path
    @corrupted = false
    @animated = false
  end

  # PNG file consists of 8-byte magic number, followed by arbitrary number of chunks
  # Each chunk has the following structure:
  # 4-byte length (unsigned int, can be zero)
  # 4-byte name (ASCII string consisting of letters A-z)
  # (length)-byte data
  # 4-byte CRC
  #
  # Any data after chunk named IEND is irrelevant
  # APNG frame count is inside a chunk named acTL, in first 4 bytes of data.

  # This function calls associated block for each PNG chunk
  # parameters passed are |chunk_name, chunk_length, file_descriptor|
  # returns true if file is read succesfully from start to IEND,
  # or if 100 000 chunks are read; returns false otherwise.
  def each_chunk
    iend_reached = false
    File.open(@file_path, 'rb') do |file|
      # check if file is not PNG at all
      return false if file.read(8) != PNG_MAGIC_NUMBER

      chunks = 0

      # We could be dealing with large number of chunks,
      # so the code should be optimized to create as few objects as possible.
      # All literal strings are frozen and read() function uses string buffer.
      chunkheader = ''
      while file.read(8, chunkheader)
        # ensure that first 8 bytes from chunk were read properly
        if chunkheader.nil? || chunkheader.length < 8
          return false
        end

        current_pos = file.tell

        chunk_len, chunk_name = chunkheader.unpack("Na4".freeze)
        return false if chunk_name =~ /[^A-Za-z]/
        yield chunk_name, chunk_len, file

        # no need to read further if IEND is reached
        if chunk_name == "IEND".freeze
          iend_reached = true
          break
        end

        # check if we processed too many chunks already
        # if we did, file is probably maliciously formed
        # fail gracefully without marking the file as corrupt
        chunks += 1
        if chunks > 100_000
          iend_reached = true
          break
        end

        # jump to the next chunk - go forward by chunk length + 4 bytes CRC
        file.seek(current_pos + chunk_len + 4, IO::SEEK_SET)
      end
    end

    iend_reached
  end

  def inspect!
    actl_corrupted = false

    read_success = each_chunk do |name, len, file|
      if name == 'acTL'.freeze
        framecount = parse_actl(len, file)
        if framecount < 1
          actl_corrupted = true
        else
          @animated = true
          @frames = framecount
        end
      end
    end

    @corrupted = !read_success || actl_corrupted
    self
  end

  def corrupted?
    @corrupted
  end

  def animated?
    !@corrupted && @animated
  end

  private

  # return number of frames in acTL or -1 on failure
  def parse_actl(len, file)
    return -1 if len != 8
    framedata = file.read(4)
    if framedata.nil? || framedata.length != 4
      return -1
    end

    framedata.unpack1("N".freeze)
  end
end
