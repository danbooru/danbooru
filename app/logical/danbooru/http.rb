module Danbooru
  class Http
    attr_writer :cache, :http

    class << self
      delegate :get, :post, :delete, :cache, :auth, :basic_auth, :headers, to: :new
    end

    def get(url, **options)
      request(:get, url, **options)
    end

    def post(url, **options)
      request(:post, url, **options)
    end

    def delete(url, **options)
      request(:delete, url, **options)
    end

    def cache(expiry)
      dup.tap { |o| o.cache = expiry.to_i }
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

    protected

    def request(method, url, **options)
      if @cache.present?
        cached_request(method, url, **options)
      else
        raw_request(method, url, **options)
      end
    end

    def cached_request(method, url, **options)
      key = Cache.hash({ method: method, url: url, headers: http.default_options.headers.to_h, **options }.to_json)

      cached_response = Cache.get(key, @cache) do
        response = raw_request(method, url, **options)
        { status: response.status, body: response.to_s, headers: response.headers.to_h, version: "1.1" }
      end

      ::HTTP::Response.new(**cached_response)
    end

    def raw_request(method, url, **options)
      http.send(method, url, **options)
    end

    def http
      @http ||= ::HTTP.use(:auto_inflate).headers(Danbooru.config.http_headers).headers("Accept-Encoding" => "gzip")
    end
  end
end
