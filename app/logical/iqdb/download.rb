module Iqdb
  class Download
    attr_reader :source, :download, :matches

    def initialize(source)
      @source = source
    end

    def download_and_find_similar
      tempfile = Tempfile.new("iqdb-#{$PROCESS_ID}")
      @download = Downloads::File.new(source, tempfile.path, :get_thumbnail => true)
      @download.download!

      if Danbooru.config.iqdb_hostname_and_port
        @matches = Iqdb::Server.default.query(3, @download.file_path).matches
      end
    ensure
      tempfile.close
      tempfile.unlink
    end
  end
end
