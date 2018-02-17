module Downloads
  class File
    class Error < Exception ; end

    attr_reader :data, :options
    attr_accessor :source, :original_source, :downloaded_source, :file_path

    def initialize(source, file_path, options = {})
      # source can potentially get rewritten in the course
      # of downloading a file, so check it again
      @source = source
      @original_source = source

      # the URL actually downloaded after rewriting the original source.
      @downloaded_source = nil

      # where to save the download
      @file_path = file_path

      # we sometimes need to capture data from the source page
      @data = {}

      @options = options

      @data[:get_thumbnail] = options[:get_thumbnail]
    end

    def size
      url, headers, _ = before_download(@source, @data)
      options = { timeout: 3, headers: headers }.deep_merge(Danbooru.config.httparty_options)
      res = HTTParty.head(url, options)
      res.content_length
    end

    def download!
      url, headers, @data = before_download(@source, @data)

      ::File.open(@file_path, "wb") do |out|
        http_get_streaming(uncached_url(url, headers), out, headers)
      end

      @downloaded_source = url
      @source = after_download(url)
    end

    def before_download(url, datums)
      headers = Danbooru.config.http_headers

      RewriteStrategies::Base.strategies.each do |strategy|
        url, headers, datums = strategy.new(url).rewrite(url, headers, datums)
      end

      return [url, headers, datums]
    end

    def after_download(src)
      src = fix_twitter_sources(src)
      if options[:referer_url].present?
        src = set_source_to_referer(src, options[:referer_url])
      end
      src
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
            return
          else
            raise Error.new("HTTP error code: #{res.code} #{res.message}")
          end
        rescue Errno::ECONNRESET, Errno::ETIMEDOUT, Errno::EIO, Errno::EHOSTUNREACH, Errno::ECONNREFUSED, IOError => x
          tries += 1
          if tries < 3
            retry
          else
            raise
          end
        end
      end # while
    end # def

    def fix_twitter_sources(src)
      if src =~ %r!^https?://(?:video|pbs)\.twimg\.com/! && original_source =~ %r!^https?://twitter\.com/!
        original_source
      elsif src =~ %r!^https?://img\.pawoo\.net/! && original_source =~ %r!^https?://pawoo\.net/!
        original_source
      else
        src
      end
    end

    def set_source_to_referer(src, referer)
      if Sources::Strategies::Nijie.url_match?(src) ||
         Sources::Strategies::Twitter.url_match?(src) || Sources::Strategies::Twitter.url_match?(referer) ||
         Sources::Strategies::Pawoo.url_match?(src) ||
         Sources::Strategies::Tumblr.url_match?(src) || Sources::Strategies::Tumblr.url_match?(referer) ||
         Sources::Strategies::ArtStation.url_match?(src) || Sources::Strategies::ArtStation.url_match?(referer)
        strategy = Sources::Site.new(src, :referer_url => referer)
        strategy.referer_url
      else
        src
      end
    end

    private

    # Prevent Cloudflare from potentially mangling the image. See issue #3528.
    def uncached_url(url, headers = {})
      url = Addressable::URI.parse(url)

      if is_cloudflare?(url, headers)
        url.query_values = (url.query_values || {}).merge(danbooru_no_cache: SecureRandom.uuid)
      end

      url
    end

    def is_cloudflare?(url, headers = {})
      Cache.get("is_cloudflare:#{url.origin}", 4.hours) do
        res = HTTParty.head(url, { headers: headers }.deep_merge(Danbooru.config.httparty_options))
        raise Error.new("HTTP error code: #{res.code} #{res.message}") unless res.success?

        res.key?("CF-Ray")
      end
    end
  end
end
