module Iqdb
  class Download
    attr_reader :source, :download, :matches

    def initialize(source)
      @source = source
    end

    def download_from_source
      tempfile = Tempfile.new("iqdb-#{$PROCESS_ID}")
      @download = Downloads::File.new(source, tempfile.path)
      @download.download!
    ensure
      tempfile.close
      tempfile.unlink
    end

    def find_similar
      if Danbooru.config.iqdb_hostname_and_port
        @matches = Iqdb::Server.default.query(3, @download.file_path).matches
      end
    end
  end
end
