require "danbooru/http/html_adapter"
require "danbooru/http/xml_adapter"
require "danbooru/http/cache"
require "danbooru/http/logger"
require "danbooru/http/redirector"
require "danbooru/http/retriable"
require "danbooru/http/session"
require "danbooru/http/spoof_referrer"
require "danbooru/http/unpolish_cloudflare"

module Danbooru
  class Http
    class DownloadError < StandardError; end
    class FileTooLargeError < StandardError; end

    DEFAULT_TIMEOUT = 10
    MAX_REDIRECTS = 5

    attr_accessor :max_size, :http

    class << self
      delegate :get, :head, :put, :post, :delete, :cache, :follow, :max_size, :timeout, :auth, :basic_auth, :headers, :cookies, :use, :public_only, :download_media, to: :new
    end

    def initialize
      @http ||=
        ::Danbooru::Http::ApplicationClient.new
        .timeout(DEFAULT_TIMEOUT)
        .headers("Accept-Encoding" => "gzip")
        .headers("User-Agent": "#{Danbooru.config.canonical_app_name}/#{Rails.application.config.x.git_hash}")
        .use(:auto_inflate)
        .use(redirector: { max_redirects: MAX_REDIRECTS })
        .use(:session)
    end

    def get(url, **options)
      request(:get, url, **options)
    end

    def head(url, **options)
      request(:head, url, **options)
    end

    def put(url, **options)
      request(:get, url, **options)
    end

    def post(url, **options)
      request(:post, url, **options)
    end

    def delete(url, **options)
      request(:delete, url, **options)
    end

    def follow(*args)
      dup.tap { |o| o.http = o.http.follow(*args) }
    end

    def max_size(size)
      dup.tap { |o| o.max_size = size }
    end

    def timeout(*args)
      dup.tap { |o| o.http = o.http.timeout(*args) }
    end

    def auth(*args)
      dup.tap { |o| o.http = o.http.auth(*args) }
    end

    def basic_auth(*args)
      dup.tap { |o| o.http = o.http.basic_auth(*args) }
    end

    def headers(*args)
      dup.tap { |o| o.http = o.http.headers(*args) }
    end

    def cookies(*args)
      dup.tap { |o| o.http = o.http.cookies(*args) }
    end

    def use(*args)
      dup.tap { |o| o.http = o.http.use(*args) }
    end

    def cache(expires_in)
      use(cache: { expires_in: expires_in })
    end

    # allow requests only to public IPs, not to local or private networks.
    def public_only
      dup.tap do |o|
        o.http = o.http.dup.tap do |http|
          http.default_options = http.default_options.with_socket_class(ValidatingSocket)
        end
      end
    end

    concerning :DownloadMethods do
      def download_media(url, file: Tempfile.new("danbooru-download-", binmode: true))
        response = get(url)

        raise DownloadError, "Downloading #{response.uri} failed with code #{response.status}" if response.status != 200
        raise FileTooLargeError, response if @max_size && response.content_length.to_i > @max_size

        size = 0
        response.body.each do |chunk|
          size += chunk.size
          raise FileTooLargeError if @max_size && size > @max_size
          file.write(chunk)
        end

        file.rewind
        [response, MediaFile.open(file)]
      end
    end

    protected

    def request(method, url, **options)
      http.send(method, url, **options)
    rescue OpenSSL::SSL::SSLError
      fake_response(590, "")
    rescue ValidatingSocket::ProhibitedIpError
      fake_response(591, "")
    rescue HTTP::Redirector::TooManyRedirectsError
      fake_response(596, "")
    rescue HTTP::TimeoutError
      fake_response(597, "")
    rescue HTTP::ConnectionError
      fake_response(598, "")
    rescue HTTP::Error
      fake_response(599, "")
    end

    def fake_response(status, body)
      ::HTTP::Response.new(status: status, version: "1.1", body: ::HTTP::Response::Body.new(body))
    end
  end
end
