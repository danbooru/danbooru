module Iqdb
  class Server
    FLAG_SKETCH = 0x01
    FLAG_GRAYSCALE = 0x02
    FLAG_WIDTH_AS_SET = 0x08
    FLAG_DISCARD_COMMON_COEFFS = 0x10

    attr_reader :hostname, :port, :socket

    def self.default
      new(*Danbooru.config.iqdb_hostname_and_port)
    end

    def initialize(hostname, port)
      @hostname = hostname
      @port = port
    end

    def open
      @socket = TCPSocket.open(hostname, port)
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
        socket.puts "done"
        socket.read
      end
    end

    def remove(post_id)
      request do
        hex = post_id.to_s(16)
        socket.puts "remove 0 #{hex}"
        socket.puts "done"
        socket.read
      end
    end

    def similar(post_id, results, flags = FLAG_DISCARD_COMMON_COEFFS)
      request do
        hex_id = post_id.to_s(16)
        socket.puts "sim 0 #{flags} #{results} #{hex_id}"
        socket.puts "done"
        responses = Responses::Collection.new(@socket.read)
      end
    end

    def query(results, filename, flags = FLAG_DISCARD_COMMON_COEFFS)
      request do
        socket.puts "query 0 #{flags} #{results} #{filename}"
        socket.puts "done"
        responses = Responses::Collection.new(@socket.read)
      end
    end
  end
end
