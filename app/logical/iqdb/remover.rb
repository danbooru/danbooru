module Iqdb
  class Remover
    def remove!
      post_ids = []

      IO.popen("iqdb list #{Danbooru.config.iqdb_file}", "w+") do |io|
        post_ids = io.read
      end

      post_ids = post_ids.split("\n").map { |id| id.hex }
      post_ids.each do |id|
        unless Post.exists?(id)
          Post.remove_iqdb(id)
        end
      end
    end
  end
end
