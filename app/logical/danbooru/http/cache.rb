# frozen_string_literal: true

module Danbooru
  class Http
    class Cache < HTTP::Feature
      attr_reader :expires_in, :key

      def initialize(expires_in:, key: nil)
        super
        @expires_in = expires_in
        @key = key
      end

      def self.register
        HTTP::Options.register_feature :cache, self
      end

      def perform(request, &block)
        ::Cache.get(cache_key(request), expires_in) do
          response = yield request

          # XXX hack to remove connection state from response body so we can serialize it for caching.
          response.flush
          response.body.instance_variable_set(:@connection, nil)
          response.body.instance_variable_set(:@stream, nil)
          response.instance_exec { @request = request.dup }
          response.request.instance_exec { @uri_normalizer = nil }
          response.request.body.instance_exec { @source = nil }

          response
        end
      end

      def cache_key(request)
        if key.present? && key.is_a?(Proc)
          "http:#{key.call(request)}"
        elsif key.present?
          "http:#{key}"
        else
          "http:#{::Cache.hash({ method: request.verb, url: request.uri.to_s, headers: request.headers.sort }.to_json)}"
        end
      end
    end
  end
end
