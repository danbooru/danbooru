# frozen_string_literal: true

# A utility class representing a HTTP URL. A wrapper around Addressable::URI that adds
# extra utility methods. Anything dealing with URLs inside Danbooru should use this class
# instead of using `Addressable::URI` or the Ruby `URI` class directly,
#
# Source::URL is a subclass that adds further methods for parsing URLs from source sites,
# such as Twitter, Pixiv, etc.
#
# @example
#   url = Danbooru::URL.parse("https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg")
#   url.path          # => "/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg"
#   url.path_segments # => ["original", "d3", "43", "d34e4cf0a437a5d65f8e82b7bcd02606.jpg"]
#   url.basename      # => "d34e4cf0a437a5d65f8e82b7bcd02606.jpg"
#   url.filename      # => "d34e4cf0a437a5d65f8e82b7bcd02606"
#   url.file_ext      # => "jpg"
#   url.host          # => "cdn.donmai.us"
#   url.domain        # => "donmai.us"
#   url.subdomain     # => "cdn"
#   url.site          # => "https://cdn.donmai.us"
#
#   url = Danbooru::URL.parse("https://danbooru.donmai.us/posts?tags=touhou")
#   url.params        # => { tags: "touhou" }
#   url.query         # => "tags=touhou"
#
# @see Source::URL
module Danbooru
  class URL
    class Error < StandardError; end

    # @return [String] The original URL as a string.
    attr_reader :original_url, :url

    # @return [Addressable:URI] The parsed and normalized URL.
    attr_reader :url

    delegate :domain, :host, :port, :site, :path, :query, :fragment, :password, to: :url

    # Parse a string into a URL, or raise an exception if the string is not a valid HTTP or HTTPS URL.
    #
    # @param url [String, Danbooru::URL]
    def initialize(url)
      @original_url = url.to_s
      @url = Addressable::URI.heuristic_parse(original_url)

      @url.authority = @url.normalized_authority
      @url.path = Addressable::URI.unencode_component(@url.path, String, "/%")
      raise Error, "invalid byte sequence in UTF-8" if !@url.path.valid_encoding?
      @url.path = @url.path.gsub(/[^[:graph:]]/) { |c| "%%%02X" % c.ord }
      @url.path = nil if @url.path == "/"

      raise Error, "#{original_url} is not an http:// URL" if !@url.normalized_scheme.in?(["http", "https"])
      raise Error, "#{original_url} is not a valid hostname" if parsed_domain.nil?
    rescue Addressable::URI::InvalidURIError => e
      raise Error, e
    end

    # Parse a string into a URL, or raise an exception if the string is not a valid HTTP or HTTPS URL.
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

    # Escape a string for use in an URL path or query parameter. Like `CGI.escape`, but leaves Unicode characters as Unicode.
    #
    # @example
    #   Danbooru::URL.escape("fate/stay_night") # => "fate%2Fstay_night"
    #   Danbooru::URL.escape("大丈夫?おっぱい揉む?") # => "大丈夫%3Fおっぱい揉む%3F"
    #
    # @return [String] The escaped string
    def self.escape(string)
      Addressable::URI.encode_component(string, /[\/?#&+%]/).force_encoding("UTF-8")
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

    # @return [String, nil] The name of the file with the file extension, or nil if not present.
    def basename
      path_segments.last
    end
    #
    # @return [String, nil] The name of the file without the file extension, or nil if not present.
    def filename
      basename&.slice(/^(.*)\./, 1)
    end

    # @return [String, nil] The file extension (without the dot), or nil if not present.
    def file_ext
      basename&.slice(/\.([[:alnum:]]+)$/, 1)
    end

    # The subdomain of the URL, or nil if absent. For example, for "http://senpenbankashiki.hp.infoseek.co.jp", the
    # subdomain is "senpenbankashiki.hp", the domain is "infoseek.co.jp", the SLD is "infoseek", and the TLD is "co.jp".
    #
    # @return [String, nil]
    def subdomain
      parsed_domain&.trd
    end

    # @return [String, nil] The username in a `http://username:password@example.com` URL.
    def http_user
      url.user
    end

    # @return [PublicSuffix::Domain, nil]
    def parsed_domain
      @parsed_domain ||= PublicSuffix.parse(host)
    rescue # PublicSuffix::DomainInvalid, PublicSuffix::DomainNotAllowed
      nil
    end
  end
end
