module Iqdb
  class Download
    attr_reader :source, :download, :similar_posts

    def initialize(source)
      @source = source
    end

    def download_from_source
      tempfile = Tempfile.new("iqdb-#{$PROCESS_ID}")
      @download = Downloads::File.new(source, tempfile.path)
      @download.download!
    end

    def find_similar
      if Danbooru.config.iqdb_hostname_and_port
        @similar_posts = Iqdb::Server.new(*Danbooru.config.iqdb_hostname_and_port).query(0, 3, @download.file_path)
      end
    end
  end
end
