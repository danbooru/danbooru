# frozen_string_literal: true

module Danbooru
  class Http
    class JsonAdapter < HTTP::MimeType::Adapter
      HTTP::MimeType.register_adapter "application/json", self
      HTTP::MimeType.register_adapter "application/ld+json", self

      def decode(str)
        json = JSON.parse(str)
        json = json.with_indifferent_access if json.is_a?(Hash)
        json
      rescue JSON::ParserError
        {}
      end
    end
  end
end
