# frozen_string_literal: true

require "danbooru/http/application_client"
require "danbooru/http/html_adapter"
require "danbooru/http/xml_adapter"
require "danbooru/http/cache"
require "danbooru/http/logger"
require "danbooru/http/redirector"
require "danbooru/http/retriable"
require "danbooru/http/session"
require "danbooru/http/spoof_referrer"
require "danbooru/http/unpolish_cloudflare"

# The HTTP client used by Danbooru for all outgoing HTTP requests. A wrapper
# around the http.rb gem that adds some helper methods and custom behavior:
#
# * Redirects are automatically followed
# * Referers are automatically spoofed
# * Cookies are automatically remembered
# * Requests can be cached
# * Rate limited requests can be automatically retried
# * HTML and XML responses are automatically parsed
# * Sites using Cloudflare Polish are automatically bypassed
# * SSRF attempts are blocked
#
# @example
#   http = Danbooru::Http.new
#   response = http.get("https://danbooru.donmai.us/posts.json")
#   json = response.parse
#
module Danbooru
  class Http
    class Error < StandardError; end
    class DownloadError < Error; end
    class FileTooLargeError < Error; end

    DEFAULT_TIMEOUT = 10
    MAX_REDIRECTS = 5

    attr_accessor :max_size, :http

    class << self
      delegate :get, :head, :put, :post, :delete, :cache, :follow, :max_size, :timeout, :auth, :basic_auth, :headers, :cookies, :use, :public_only, :with_legacy_ssl, :download_media, to: :new
    end

    def initialize
      @http ||=
        ::Danbooru::Http::ApplicationClient.new
        .timeout(DEFAULT_TIMEOUT)
        .headers("Accept-Encoding" => "gzip")
        .headers("User-Agent": "#{Danbooru.config.canonical_app_name}/#{Rails.application.config.x.git_hash}")
        #.headers("User-Agent": Danbooru.config.canonical_app_name)
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
      request(:put, url, **options)
    end

    def post(url, **options)
      request(:post, url, **options)
    end

    def delete(url, **options)
      request(:delete, url, **options)
    end

    def get!(url, **options)
      request!(:get, url, **options)
    end

    def post!(url, **options)
      request!(:post, url, **options)
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

    def proxy(host: Danbooru.config.http_proxy_host, port: Danbooru.config.http_proxy_port.to_i, username: Danbooru.config.http_proxy_username, password: Danbooru.config.http_proxy_password)
      return self if host.blank?

      dup.tap do |o|
        o.http = o.http.via(host, port, username, password)
      end
    end

    # allow requests only to public IPs, not to local or private networks.
    def public_only
      dup.tap do |o|
        o.http = o.http.dup.tap do |http|
          http.default_options = http.default_options.with_socket_class(ValidatingSocket)
        end
      end
    end

    # allow requests to sites using unsafe legacy renegotiations (such as dic.nicovideo.jp)
    # see https://github.com/openssl/openssl/commit/72d2670bd21becfa6a64bb03fa55ad82d6d0c0f3
    def with_legacy_ssl
      dup.tap do |o|
        o.http = o.http.dup.tap do |http|
          ctx = OpenSSL::SSL::SSLContext.new
          ctx.options |= OpenSSL::SSL::OP_LEGACY_SERVER_CONNECT
          http.default_options = http.default_options.with_ssl_context(ctx)
        end
      end
    end

    concerning :DownloadMethods do
      # Download a file from `url` and return a {MediaFile}.
      #
      # @param url [String] the URL to download
      # @param file [Tempfile] the file to download the URL to
      # @raise [DownloadError] if the server returns a non-200 OK response
      # @raise [FileTooLargeError] if the file exceeds Danbooru's maximum download size.
      # @return [Array<(HTTP::Response, MediaFile)>] the HTTP response and the downloaded file
      def download_media(url, file: Tempfile.new("danbooru-download-", binmode: true))
        response = get(url)

        raise DownloadError, "#{url} failed with code #{response.status}" if response.status != 200
        raise FileTooLargeError, "File size too large (size: #{response.content_length.to_i.to_formatted_s(:human_size)}; max size: #{@max_size.to_formatted_s(:human_size)})" if @max_size && response.content_length.to_i > @max_size

        size = 0
        response.body.each do |chunk|
          size += chunk.size
          raise FileTooLargeError, "File size too large (max size: #{@max_size.to_formatted_s(:human_size)})" if @max_size && size > @max_size
          file.write(chunk)
        end

        file.rewind
        [response, MediaFile.open(file)]
      end
    end

    protected

    # Perform a HTTP request for the given URL. On error, return a fake 5xx
    # response so the caller doesn't have to deal with exceptions.
    #
    # @param method [String] the HTTP method
    # @param url [String] the URL to request
    # @param options [Hash] the URL parameters
    # @return [HTTP::Response] the HTTP response
    def request(method, url, **options)
      http.send(method, url, **options)
    rescue OpenSSL::SSL::SSLError
      fake_response(590)
    rescue ValidatingSocket::ProhibitedIpError
      fake_response(591)
    rescue HTTP::Redirector::TooManyRedirectsError
      fake_response(596)
    rescue HTTP::TimeoutError
      fake_response(597)
    rescue HTTP::ConnectionError
      fake_response(598)
    rescue HTTP::Error
      fake_response(599)
    end

    # Perform a HTTP request for the given URL, raising an error on 4xx or 5xx
    # responses.
    #
    # @param method [String] the HTTP method
    # @param url [String] the URL to request
    # @param options [Hash] the URL parameters
    # @raise [Danbooru::Http::Error] if the response was a 4xx or 5xx error
    # @return [HTTP::Response] the HTTP response
    def request!(method, url, **options)
      response = request(method, url, **options)

      if response.status.in?(200..399)
        response
      else
        raise Error, "#{method.upcase} #{url} failed (HTTP #{response.status})"
      end
    end

    def fake_response(status)
      ::HTTP::Response.new(status: status, version: "1.1", body: "", request: nil)
    end
  end
end
