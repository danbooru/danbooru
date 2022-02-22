# frozen_string_literal: true

module Danbooru
  class URL
    class Error < StandardError; end

    attr_reader :original_url, :url
    delegate_missing_to :url

    # Parse a string into an URL, or raise an exception if the string is not a valid HTTPS or HTTPS URL.
    #
    # @param string [String]
    # @return [Danbooru::URL]
    def initialize(string)
      @original_url = string
      @url = Addressable::URI.heuristic_parse(string).display_uri
      @url.path = nil if @url.path == "/"
      raise Error, "#{string} is not an http:// URL" if !@url.normalized_scheme.in?(["http", "https"])
    rescue Addressable::URI::InvalidURIError => e
      raise Error, e
    end

    # Parse a string into an URL, or return nil if the string is not a valid HTTP or HTTPS URL.
    #
    # @param string [String]
    # @return [Danbooru::URL]
    def self.parse(string)
      new(string)
    rescue StandardError => e
      nil
    end

    # @return [String] the URL in normalized form
    def to_s
      url.to_str
    end

    # @return [Array<String>] the URL's path split into segments
    def path_segments
      path.split("/").compact_blank
    end

    # @return [Hash] the URL's query parameters
    def params
      url.query_values.with_indifferent_access
    end
  end
end
