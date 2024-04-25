# frozen_string_literal: true

module Danbooru
  class JSON
    # Like JSON.parse, but returns nil instead of raising an error if the input is nil, blank, or contains a syntax error.
    def self.parse(string)
      return nil if string.blank?

      json = ::JSON.parse(string)
      json = json.with_indifferent_access if json.is_a?(Hash)
      json
    rescue ::JSON::ParserError
      nil
    end
  end
end
