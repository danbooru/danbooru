module Iqdb
  class Command
    attr_reader :database

    def initialize(database)
      @database = database
    end

    def process(&block)
      IO.popen("iqdb #{database}", "w", &block)
    end

    def add(post)
      hex = post.id.to_s(16)
      process do |io|
        io.puts "add 0 #{hex}:#{post.preview_file_path}"
        io.puts "quit"
      end
    end

    def remove(post_id)
      hex = post_id.to_s(16)
      process do |io|
        io.puts "remove 0 #{hex}"
        io.puts "quit"
      end
    end
  end
end
