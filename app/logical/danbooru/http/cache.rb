module Danbooru
  class Http
    class Cache < HTTP::Feature
      HTTP::Options.register_feature :cache, self

      attr_reader :expires_in

      def initialize(expires_in:)
        @expires_in = expires_in
      end

      def perform(request, &block)
        ::Cache.get(cache_key(request), expires_in) do
          response = yield request

          # XXX hack to remove connection state from response body so we can serialize it for caching.
          response.flush
          response.body.instance_variable_set(:@connection, nil)
          response.body.instance_variable_set(:@stream, nil)

          response
        end
      end

      def cache_key(request)
        "http:" + ::Cache.hash({ method: request.verb, url: request.uri.to_s, headers: request.headers.sort }.to_json)
      end
    end
  end
end
