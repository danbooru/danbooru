module Downloads
  class File
    class Error < Exception ; end

    attr_reader :data
    attr_accessor :source, :content_type, :file_path

    def initialize(source, file_path, options = {})
      # source can potentially get rewritten in the course
      # of downloading a file, so check it again
      @source = source

      # where to save the download
      @file_path = file_path

      # we sometimes need to capture data from the source page
      @data = {:is_ugoira => options[:is_ugoira]}
    end

    def download!
      @source, @data = http_get_streaming(@source, @data) do |response|
        self.content_type = response["Content-Type"]
        ::File.open(@file_path, "wb") do |out|
          response.read_body(out)
        end
      end
      @source = after_download(@source)
    end

    def before_download(url, headers, datums)
      RewriteStrategies::Base.strategies.each do |strategy|
        url, headers, datums = strategy.new.rewrite(url, headers, datums)
      end

      return [url, headers, datums]
    end

    def after_download(src)
      fix_image_board_sources(src)
    end

    def http_get_streaming(src, datums = {}, options = {})
      max_size = options[:max_size] || Danbooru.config.max_file_size
      max_size = nil if max_size == 0 # unlimited
      limit = 4
      tries = 0
      url = URI.parse(src)

      while true
        unless url.is_a?(URI::HTTP) || url.is_a?(URI::HTTPS)
          raise Error.new("URL must be HTTP or HTTPS")
        end

        headers = {
          "User-Agent" => "#{Danbooru.config.safe_app_name}/#{Danbooru.config.version}"
        }
        src, headers, datums = before_download(src, headers, datums)
        url = URI.parse(src)

        begin
          Net::HTTP.start(url.host, url.port, :use_ssl => url.is_a?(URI::HTTPS)) do |http|
            http.read_timeout = 10
            http.request_get(url.request_uri, headers) do |res|
              case res
              when Net::HTTPSuccess then
                if max_size
                  len = res["Content-Length"]
                  raise Error.new("File is too large (#{len} bytes)") if len && len.to_i > max_size
                end
                yield(res)
                return [src, datums]

              when Net::HTTPRedirection then
                if limit == 0 then
                  raise Error.new("Too many redirects")
                end
                src = res["location"]
                limit -= 1

              else
                raise Error.new("HTTP error code: #{res.code} #{res.message}")
              end
            end # http.request_get
          end # http.start
        rescue Errno::ECONNRESET, Errno::ETIMEDOUT, Errno::EIO, Errno::EHOSTUNREACH, Errno::ECONNREFUSED, IOError => x
          tries += 1
          if tries < 3
            retry
          else
            raise
          end
        end
      end # while

      [src, datums]
    end # def

    def fix_image_board_sources(src)
      if src =~ /i\.4cdn\.org|\/src\/\d{12,}|urnc\.yi\.org|yui\.cynthia\.bne\.jp/
        "Image board"
      else
        src
      end
    end
  end
end
