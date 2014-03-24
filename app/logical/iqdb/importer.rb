module Iqdb
  class Importer
    def import!
      IO.popen("iqdb command #{Danbooru.config.iqdb_file}", "w") do |io|
        Post.find_each do |post|
          if File.exists?(post.preview_file_path)
            puts post.id
            hex = post.id.to_s(16)
            io.puts "add 0 #{hex} :#{post.preview_file_path}"
          end
        end
        io.puts "quit"
      end
    end
  end
end
