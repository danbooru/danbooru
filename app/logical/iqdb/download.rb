module Iqdb
  class Download
    attr_reader :source, :download, :matches

    def initialize(source)
      @source = source
    end

    def find_similar
      if Danbooru.config.iqdbs_server
        params = {
          "key" => Danbooru.config.iqdbs_auth_key,
          "url" => source
        }
        uri = URI.parse("#{Danbooru.config.iqdbs_server}/similar")
        uri.query = URI.encode_www_form(params)

        Net::HTTP.start(uri.host, uri.port) do |http|
          resp = http.request_get(uri.request_uri)
          if resp.is_a?(Net::HTTPSuccess)
            JSON.parse(resp.body)
          else
            raise "HTTP error code: #{resp.code} #{resp.message}"
          end
        end
      else
        begin
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
  end
end
