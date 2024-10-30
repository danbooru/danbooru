# frozen_string_literal: true

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

    Danbooru::Http::HtmlAdapter.register
    Danbooru::Http::JSONAdapter.register
    Danbooru::Http::XmlAdapter.register
    Danbooru::Http::Cache.register
    Danbooru::Http::Logger.register
    Danbooru::Http::Redirector.register
    Danbooru::Http::Retriable.register
    Danbooru::Http::Session.register
    Danbooru::Http::SpoofReferrer.register
    Danbooru::Http::UnpolishCloudflare.register

    DEFAULT_USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:108.0) Gecko/20100101 Firefox/108.0"

    DEFAULT_TIMEOUT = 20
    MAX_REDIRECTS = 5

    attr_accessor :max_size, :http

    class << self
      delegate :get, :head, :put, :post, :delete, :parsed_get, :parsed_post, :redirect_url, :cache, :follow, :max_size, :timeout, :auth, :basic_auth, :headers, :cookies, :use, :proxy, :public_only, :with_legacy_ssl, :download_media, to: :new
    end

    # The default HTTP client.
    def self.default
      Danbooru::Http::ApplicationClient.new
        .timeout(DEFAULT_TIMEOUT)
        .headers("Accept-Encoding": "gzip")
        .use(normalize_uri: { normalizer: method(:normalize_uri) })
        .use(:auto_inflate)
        .use(redirector: { max_redirects: MAX_REDIRECTS })
        .use(:session)
    end

    # The default HTTP client for requests to external websites. This includes API calls to external services, fetching source data, and downloading images.
    def self.external
      if Danbooru.config.http_proxy.present?
        # XXX The `proxy` option is incompatible with the `public_only` option. When using a proxy, the proxy itself
        # should be configured to block HTTP requests to IPs on the local network.
        new.proxy.headers("User-Agent": DEFAULT_USER_AGENT)
      else
        new.public_only.headers("User-Agent": DEFAULT_USER_AGENT)
      end
    end

    # The default HTTP client for API calls to internal services controlled by Danbooru.
    def self.internal
      new.headers("User-Agent": "#{Danbooru.config.canonical_app_name}/#{Rails.application.config.x.git_hash}")
    end

    # Normalizes the URI before performing a request. Percent-encodes special characters to avoid "URI must be ascii only"
    # and "bad URI(is not URI?)" errors.
    def self.normalize_uri(uri)
      parsed_uri = Addressable::URI.parse(uri)

      normalized_path = parsed_uri.path.split(%r{(/)}).map do |segment|
        next segment if segment == "/"
        segment = Addressable::URI.unencode_component(segment)
        segment = Addressable::URI.encode_component(segment, Addressable::URI::CharacterClasses::PATH.gsub(%r{\\/}, ""))
        segment
      end.join

      HTTP::URI.new(
        scheme: parsed_uri.scheme,
        authority: parsed_uri.authority,
        path: normalized_path,
        query: Addressable::URI.encode_component(parsed_uri.query, "[[:ascii:]&&[^ ]]"),
        fragment: parsed_uri.fragment
      )
    end

    def initialize
      @http ||= Danbooru::Http.default
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

    def parsed_get(url, **options)
      parsed_request(:get, url, **options)
    end

    def parsed_post(url, **options)
      parsed_request(:post, url, **options)
    end

    def follow(max_redirects: MAX_REDIRECTS)
      use(redirector: { max_redirects: })
    end

    def no_follow
      disable_feature(:redirector)
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

    def disable_feature(*features)
      dup.tap do |o|
        options = o.http.default_options.dup
        options.features = options.features.without(*features)
        o.http = o.http.branch(options)
      end
    end

    def cache(expires_in)
      use(cache: { expires_in: expires_in })
    end

    def proxy(url: Danbooru.config.http_proxy)
      return self if url.blank?
      parsed_url = Danbooru::URL.parse!(url)

      dup.tap do |o|
        o.http = o.http.via(parsed_url.host, parsed_url.port, parsed_url.http_user, parsed_url.password)
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

    # Return the URL that the given URL redirects to, or nil on error. This does not follow multiple redirects.
    #
    # @param method [String] The HTTP method to use, GET or HEAD. HEAD may be faster, but may fail for some sites.
    # @return [Danbooru::URL, nil] The URL this URL redirects to, or nil on error.
    def redirect_url(url, method: "HEAD")
      response = no_follow.request(method.downcase, url)
      return nil unless response.status.redirect?
      Danbooru::URL.parse(response.headers["Location"])
    end

    concerning :DownloadMethods do
      # Download a file from `url` and return a {MediaFile}.
      #
      # @param url [String] the URL to download
      # @param file [Danbooru::Tempfile] the file to download the URL to
      # @raise [DownloadError] if the server returns a non-200 OK response
      # @raise [FileTooLargeError] if the file exceeds Danbooru's maximum download size.
      # @return [Array<(HTTP::Response, MediaFile)>] the HTTP response and the downloaded file
      def download_media(url, file: Danbooru::Tempfile.new("danbooru-download-#{url.parameterize.truncate(96)}-", binmode: true))
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
    # @param format [Symbol] if present, override the response's content type to be this format (:json, :html, or :xml).
    # @param options [Hash] the URL parameters
    # @return [HTTP::Response] the HTTP response
    def request(method, url, format: nil, **options)
      url = url.to_s
      response = http.send(method, url, **options)

      if format
        mime_type = Mime::Type.lookup_by_extension(format).to_s
        content_type = HTTP::ContentType.parse(mime_type)
        response.instance_eval { @content_type = content_type }
      end

      response
    rescue OpenSSL::SSL::SSLError
      fake_response(590, method, url)
    rescue ValidatingSocket::ProhibitedIpError
      fake_response(591, method, url)
    rescue HTTP::Redirector::TooManyRedirectsError
      fake_response(596, method, url)
    rescue HTTP::TimeoutError
      fake_response(597, method, url)
    rescue HTTP::ConnectionError, Resolv::ResolvError
      fake_response(598, method, url)
    rescue HTTP::Error
      fake_response(599, method, url)
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

    # Perform a HTTP request for the given URL and return the parsed JSON, XML, or HTML response.
    # Return nil on error, or if the URL was blank.
    #
    # @param method [String] The HTTP method.
    # @param url [String] The URL to request.
    # @param options [Hash] The URL parameters.
    # @return [Hash, Array, Nokogiri::HTML::Document, nil] The parsed HTTP response body, or nil on error.
    def parsed_request(method, url, **options)
      return nil if url.blank?
      response = request(method, url, **options)
      return nil if response.code != 200
      response.parse
    end

    def fake_response(status, method, url)
      ::HTTP::Response.new(status: status, version: "1.1", body: "", request: ::HTTP::Request.new(verb: method, uri: url))
    end
  end
end
