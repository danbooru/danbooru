# frozen_string_literal: true

module Danbooru
  class URL
    class Error < StandardError; end

    # @return [String] The original URL as a string.
    attr_reader :original_url, :url

    # @return [Addressable:URI] The parsed and normalized URL.
    attr_reader :url

    delegate :domain, :host, :site, :path, to: :url

    # Parse a string into a URL, or raise an exception if the string is not a valid HTTPS or HTTPS URL.
    #
    # @param url [String, Danbooru::URL]
    def initialize(url)
      @original_url = url.to_s
      @url = Addressable::URI.heuristic_parse(original_url).display_uri
      @url.path = nil if @url.path == "/"

      raise Error, "#{original_url} is not an http:// URL" if !@url.normalized_scheme.in?(["http", "https"])
    rescue Addressable::URI::InvalidURIError => e
      raise Error, e
    end

    # Parse a string into a URL, or raise an exception if the string is not a valid HTTPS or HTTPS URL.
    #
    # @param url [String, Danbooru::URL]
    # @return [Danbooru::URL]
    def self.parse!(url)
      new(url)
    end

    # Parse a string into a URL, or return nil if the string is not a valid HTTP or HTTPS URL.
    #
    # @param url [String, Danbooru::URL]
    # @return [Danbooru::URL]
    def self.parse(url)
      parse!(url)
    rescue Error
      nil
    end

    # @return [String] the URL in unnormalized form
    def to_s
      original_url
    end

    # @return [String] the URL in normalized form
    def to_normalized_s
      url.to_str
    end

    # @return [Array<String>] the URL's path split into segments
    def path_segments
      path.split("/").compact_blank
    end

    # @return [Hash] the URL's query parameters
    def params
      url.query_values.to_h.with_indifferent_access
    end
  end
end
