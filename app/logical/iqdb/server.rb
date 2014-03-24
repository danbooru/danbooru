module Iqdb
  class Server
    FLAG_SKETCH = 0x01
    FLAG_GRAYSCALE = 0x02
    FLAG_WIDTH_AS_SET = 0x08
    FLAG_DISCARD_COMMON_COEFFS = 0x16

    attr_reader :hostname, :port

    def self.import(database)
      IO.popen("iqdb #{database}", "w") do |io|
        Post.find_each do |post|
          puts "Adding #{post.id}"
          io.puts "#{post.id.to_s(16)} :#{post.preview_file_path}"
        end
      end
    end

    def self.add(database, image_id, filename)
      image_id_hex = image_id.to_s(16)
      `iqdb add #{database} #{image_id_hex} :#{filename}`
    end

    def self.remove(database, image_id)
      image_id_hex = image_id.to_s(16)
      `iqdb remove 0 #{image_id_hex} #{database}`
    end

    def initialize(hostname, port)
      @hostname = hostname
      @port = port
    end

    def open
      @socket = TCPSocket.new(hostname, port)
    end

    def close
      @socket.close
    end

    def request
      open
      yield
    ensure
      close
    end

    def query(dbid, results, filename, flags = FLAG_DISCARD_COMMON_COEFFS)
      request do
        @socket.puts "query #{dbid} #{flags} #{results} #{filename}"
        responses = Responses::Collection.new(@socket.read)
      end
    end
  end
end
