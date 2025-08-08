# frozen_string_literal: true

module Danbooru
  class Http
    class JSONAdapter < HTTP::MimeType::Adapter
      def self.register
        HTTP::MimeType.register_adapter "application/json", self
        HTTP::MimeType.register_adapter "application/ld+json", self
        HTTP::MimeType.register_adapter "application/vnd.api+json", self
      end

      def encode(obj)
        return obj.to_json if obj.respond_to?(:to_json)

        ::JSON.dump(obj)
      end

      def decode(str)
        Danbooru::JSON.parse(str) || {}
      end
    end
  end
end
