module Downloads
  class File
    class Error < Exception ; end

    attr_reader :data, :options
    attr_accessor :source, :referer

    # Prevent Cloudflare from potentially mangling the image. See issue #3528.
    def self.uncached_url(url, headers = {})
      url = Addressable::URI.parse(url)

      if is_cloudflare?(url, headers)
        url.query_values = (url.query_values || {}).merge(danbooru_no_cache: SecureRandom.uuid)
      end

      url
    end

    def self.is_cloudflare?(url, headers = {})
      Cache.get("is_cloudflare:#{url.origin}", 4.hours) do
        res = HTTParty.head(url, { headers: headers }.deep_merge(Danbooru.config.httparty_options))
        raise Error.new("HTTP error code: #{res.code} #{res.message}") unless res.success?

        res.key?("CF-Ray")
      end
    end

    def initialize(source, referer=nil, options = {})
      # source can potentially get rewritten in the course
      # of downloading a file, so check it again
      @source = source
      @referer = referer

      # we sometimes need to capture data from the source page
      @data = {}

      @options = options

      @data[:get_thumbnail] = options[:get_thumbnail]
    end

    def size
      strategy = Sources::Strategies.find(source, referer)
      options = { timeout: 3, headers: strategy.headers }.deep_merge(Danbooru.config.httparty_options)

      res = HTTParty.head(strategy.file_url, options)

      if res.success?
        res.content_length
      else
        raise HTTParty::ResponseError.new(res)
      end
    end

    def download!
      strategy = Sources::Strategies.find(source, referer)
      output_file = Tempfile.new(binmode: true)
      @data = strategy.data

      http_get_streaming(
        self.class.uncached_url(strategy.file_url, strategy.headers), 
        output_file, 
        strategy.headers
      )

      [output_file, strategy]
    end

    def validate_local_hosts(url)
      ip_addr = IPAddr.new(Resolv.getaddress(url.hostname))
      if Danbooru.config.banned_ip_for_download?(ip_addr)
        raise Error.new("Banned server for download")
      end
    end

    def http_get_streaming(src, file, headers = {}, max_size: Danbooru.config.max_file_size)
      tries = 0
      url = URI.parse(src)

      while true
        unless url.is_a?(URI::HTTP) || url.is_a?(URI::HTTPS)
          raise Error.new("URL must be HTTP or HTTPS")
        end

        validate_local_hosts(url)

        begin
          size = 0
          options = { stream_body: true, timeout: 10, headers: headers }

          res = HTTParty.get(url, options.deep_merge(Danbooru.config.httparty_options)) do |chunk|
            size += chunk.size
            raise Error.new("File is too large (max size: #{max_size})") if size > max_size && max_size > 0

            file.write(chunk)
          end

          if res.success?
            file.rewind
            return file
          else
            raise Error.new("HTTP error code: #{res.code} #{res.message}")
          end
        rescue Errno::ECONNRESET, Errno::ETIMEDOUT, Errno::EIO, Errno::EHOSTUNREACH, Errno::ECONNREFUSED, Timeout::Error, IOError => x
          tries += 1
          if tries < 3
            retry
          else
            raise
          end
        end
      end # while
    end # def
  end
end
