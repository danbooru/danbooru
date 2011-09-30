module Downloads
  class File
    class Error < Exception ; end
  
    attr_accessor :source, :content_type, :file_path
  
    def initialize(source, file_path)
      @source = source
      @file_path = file_path
    end
  
    def download!
      http_get_streaming do |response|
        self.content_type = response["Content-Type"]
        ::File.open(file_path, "wb") do |out|
          response.read_body(out)
        end
      end
      after_download
    end
  
    def before_download(url, headers)
      Strategies::Base.strategies.each do |strategy|
        url, headers = strategy.new.rewrite(url, headers)
      end
      
      return [url, headers]
    end
  
    def after_download
      fix_image_board_sources
    end
  
    def http_get_streaming(options = {})
      max_size = options[:max_size] || Danbooru.config.max_file_size
      max_size = nil if max_size == 0 # unlimited
      limit = 4

      while true
        url = URI.parse(source)

        unless url.is_a?(URI::HTTP)
          raise Error.new("URL must be HTTP")
        end

        Net::HTTP.start(url.host, url.port) do |http|
          http.read_timeout = 10
          headers = {
            "User-Agent" => "#{Danbooru.config.safe_app_name}/#{Danbooru.config.version}"
          }
          @source, headers = before_download(@source, headers)
          url = URI.parse(source)
          http.request_get(url.request_uri, headers) do |res|
            case res
            when Net::HTTPSuccess then
              if max_size
                len = res["Content-Length"]
                raise Error.new("File is too large (#{len} bytes)") if len && len.to_i > max_size
              end
              yield(res)
              return

            when Net::HTTPRedirection then
              if limit == 0 then
                raise Error.new("Too many redirects")
              end
              source = res["location"]
              limit -= 1

            else
              raise Error.new("HTTP error code: #{res.code} #{res.message}")
            end
          end # http.request_get
        end # http.start
      end # while
    end # def
  
    def fix_image_board_sources
      if source =~ /\/src\/\d{12,}|urnc\.yi\.org|yui\.cynthia\.bne\.jp/
        @source = "Image board"
      end
    end
  end
end
