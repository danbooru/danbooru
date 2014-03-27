module Iqdb
  class Importer
    def import!
      Post.find_each do |post|
        IO.popen("iqdb command #{Danbooru.config.iqdb_file}", "w") do |io|
          if File.exists?(post.preview_file_path)
            puts post.id
            hex = post.id.to_s(16)
            io.puts "add 0 #{hex}:#{post.preview_file_path}"
          end
          io.puts "quit"
        end
      end
    end
  end
end
