module Downloads
  class File
    class Error < Exception ; end

    attr_reader :data, :options
    attr_accessor :source, :original_source, :content_type, :file_path

    def initialize(source, file_path, options = {})
      # source can potentially get rewritten in the course
      # of downloading a file, so check it again
      @source = source
      @original_source = source

      # where to save the download
      @file_path = file_path

      # we sometimes need to capture data from the source page
      @data = {}

      @options = options

      @data[:get_thumbnail] = options[:get_thumbnail]
    end

    def size
      headers = {
        "User-Agent" => "#{Danbooru.config.safe_app_name}/#{Danbooru.config.version}"
      }
      @source, headers, @data = before_download(@source, headers, @data)
      url = URI.parse(@source)
      Net::HTTP.start(url.host, url.port, :use_ssl => url.is_a?(URI::HTTPS)) do |http|
        http.read_timeout = 3
        http.request_head(url.request_uri, headers) do |res|
          return res.content_length
        end
      end
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
        url, headers, datums = strategy.new(url).rewrite(url, headers, datums)
      end

      return [url, headers, datums]
    end

    def after_download(src)
      src = fix_twitter_sources(src)
      if options[:referer_url].present?
        src = set_source_to_referer(src)
      end
      src
    end

    def validate_local_hosts(url)
      ip_addr = IPAddr.new(Resolv.getaddress(url.hostname))
      if Danbooru.config.banned_ip_for_download?(ip_addr)
        raise Error.new("Banned server for download")
      end
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

        validate_local_hosts(url)

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

    def fix_twitter_sources(src)
      if src =~ %r!^https?://pbs\.twimg\.com/! && original_source =~ %r!^https?://twitter\.com/!
        original_source
      elsif src =~ %r!^https?://img\.pawoo\.net/! && original_source =~ %r!^https?://pawoo\.net/!
        original_source
      else
        src
      end
    end

    def set_source_to_referer(src)
      if Sources::Strategies::Nijie.url_match?(src) ||
         Sources::Strategies::Twitter.url_match?(src) ||
         Sources::Strategies::Tumblr.url_match?(src) ||
         Sources::Strategies::Pawoo.url_match?(src)
        strategy = Sources::Site.new(src, :referer_url => options[:referer_url])
        strategy.referer_url
      else
        src
      end
    end
  end
end
