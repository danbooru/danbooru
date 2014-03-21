module Iqdb
  class Importer
    def import!
      IO.popen("iqdb add #{Rails.root}/danbooru.db", "w") do |io|
        Post.find_each do |post|
          if File.exists?(post.preview_file_path)
            io.puts "#{post.id.to_s(16)}:#{post.preview_file_path}"
          end
        end
      end
    end
  end
end
