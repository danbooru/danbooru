require 'resolv'

module Downloads
  class File
    include ActiveModel::Validations
    class Error < Exception; end

    RETRIABLE_ERRORS = [Errno::ECONNRESET, Errno::ETIMEDOUT, Errno::EIO, Errno::EHOSTUNREACH, Errno::ECONNREFUSED, Timeout::Error, IOError]

    delegate :data, to: :strategy
    attr_reader :url, :referer

    validate :validate_url

    def initialize(url, referer = nil)
      @url = Addressable::URI.parse(url) rescue nil
      @referer = referer
      validate!
    end

    def size
      res = HTTParty.head(uncached_url, **httparty_options, timeout: 3)

      if res.success?
        res.content_length
      else
        raise HTTParty::ResponseError.new(res)
      end
    end

    def download!(url: uncached_url, tries: 3, **options)
      Retriable.retriable(on: RETRIABLE_ERRORS, tries: tries, base_interval: 0) do
        file = http_get_streaming(url, headers: strategy.headers, **options)
        return [file, strategy]
      end
    end

    def validate_url
      errors[:base] << "URL must not be blank" if url.blank?
      errors[:base] << "'#{url}' is not a valid url" if !url.host.present?
      errors[:base] << "'#{url}' is not a valid url. Did you mean 'http://#{url}'?" if !url.scheme.in?(%w[http https])
    end

    def http_get_streaming(url, file: Tempfile.new(binmode: true), headers: {}, max_size: Danbooru.config.max_file_size)
      size = 0

      res = HTTParty.get(url, httparty_options) do |chunk|
        next if chunk.code == 302

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
    end

    # Prevent Cloudflare from potentially mangling the image. See issue #3528.
    def uncached_url
      return file_url unless is_cloudflare?(file_url)

      url = file_url.dup
      url.query_values = url.query_values.to_h.merge(danbooru_no_cache: SecureRandom.uuid)
      url
    end

    def preview_url
      @preview_url ||= Addressable::URI.parse(strategy.preview_url)
    end

    def file_url
      @file_url ||= Addressable::URI.parse(strategy.image_url)
    end

    def strategy
      @strategy ||= Sources::Strategies.find(url.to_s, referer)
    end

    def httparty_options
      {
        timeout: 10,
        stream_body: true,
        headers: strategy.headers,
        connection_adapter: ValidatingConnectionAdapter
      }.deep_merge(Danbooru.config.httparty_options)
    end

    def is_cloudflare?(url)
      return false if ENV["SKIP_CLOUDFLARE_CHECK"]

      ip_addr = IPAddr.new(Resolv.getaddress(url.hostname))
      CloudflareService.new.ips.any? { |subnet| subnet.include?(ip_addr) }
    end
  end

  # Hook into HTTParty to validate the IP before following redirects.
  # https://www.rubydoc.info/github/jnunemaker/httparty/HTTParty/ConnectionAdapter
  class ValidatingConnectionAdapter < HTTParty::ConnectionAdapter
    def self.call(uri, options)
      ip_addr = IPAddr.new(::Resolv.getaddress(uri.hostname))

      if Danbooru.config.banned_ip_for_download?(ip_addr)
        raise Downloads::File::Error, "Downloads from #{ip_addr} are not allowed"
      end

      super(uri, options)
    end
  end
end
