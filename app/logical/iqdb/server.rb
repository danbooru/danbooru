module Iqdb
  class Server
    FLAG_SKETCH = 0x01
    FLAG_GRAYSCALE = 0x02
    FLAG_WIDTH_AS_SET = 0x08
    FLAG_DISCARD_COMMON_COEFFS = 0x16

    attr_reader :hostname, :port, :socket

    def initialize(hostname, port)
      @hostname = hostname
      @port = port
    end

    def open
      @socket = TCPSocket.new(hostname, port)
    end

    def close
      socket.close
    end

    def request
      open
      yield
    ensure
      close
    end

    def add(post)
      request do
        hex = post.id.to_s(16)
        socket.puts "add 0 #{hex}:#{post.preview_file_path}"
      end
    end

    def remove(post_id)
      request do
        hext = post_id.to_s(16)
        socket.puts "remove 0 #{hex}"
      end
    end

    def query(results, filename, flags = FLAG_DISCARD_COMMON_COEFFS)
      request do
        socket.puts "query 0 #{flags} #{results} #{filename}"
        responses = Responses::Collection.new(@socket.read)
      end
    end
  end
end
