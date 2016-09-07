class APNGInspector
  attr_reader :frames
  
  PNG_MAGIC_NUMBER = ["89504E470D0A1A0A"].pack('H*')
  
  def initialize(file_path)
    @file_path = file_path
    @corrupted = false
    @animated = false
  end
  
  #Calls associated block for each PNG chunk
  #parameters passed are |chunk_name, chunk_length, file_descriptor|
  #returns true if file is read succesfully from start to IEND, false otherwise. 
  def each_chunk
    iend_reached = false
    File.open(@file_path, 'rb') do |file|
      return false if file.read(8) != PNG_MAGIC_NUMBER
      
      while chunkheader = file.read(8)
        return false if chunkheader.to_s.length != 8

        chunk_len, chunk_name = chunkheader.unpack("Na4")
        current_pos = file.tell
        yield chunk_name, chunk_len, file
        if chunk_name == "IEND"
          iend_reached = true
          break
        end
        file.seek(current_pos+chunk_len+4, IO::SEEK_SET)
      end
    end
    return iend_reached
  end
  
  def inspect!
    actl_corrupted = false
    
    read_success = each_chunk do |name, len, file|
      if name == 'acTL'
        if len != 8 then
          actl_corrupted = true
        else
          framedata = file.read(4)
          if framedata.to_s.length != 4
            actl_corrupted = true
          else
            framecount = framedata.unpack("N")[0]
            if framecount < 1 
              actl_corrupted = true
            else
              @animated = true
              @frames = framecount
            end
          end
        end
      end
    end
    @corrupted = !read_success || actl_corrupted 
    return !@corrupted
  end
  
  def corrupted?
    @corrupted
  end
  
  def animated?
    !@corrupted && @animated && @frames > 1
  end
end