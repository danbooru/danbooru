# frozen_string_literal: true

# A Danbooru::Domain represents a DNS domain name. It has methods for parsing, resolving, and validating domain names.
module Danbooru
  class Domain
    extend Memoist

    class Error < StandardError; end

    # @return [String] The original unnormalized domain name.
    attr_reader :original_domain

    # Parse a string into a Domain, or raise an exception if the string is not a valid domain.
    #
    # @param domain [String, Danbooru::Domain]
    # @return [Danbooru::Domain]
    # @raise [Error] If the domain is invalid
    def self.parse!(domain, **options)
      return domain.dup if domain.is_a?(Domain)
      new(domain, **options)
    end

    # Parse a string into a Domain, or return nil if the string is not a valid domain.
    #
    # @param domain [String, Danbooru::Domain]
    # @return [Danbooru::Domain, nil]
    def self.parse(domain, **options)
      parse!(domain, **options)
    rescue Error
      nil
    end

    # Parse a string into a Domain, or raise an exception if the string is not a valid domain.
    #
    # @param domain [String] The domain name.
    # @param resolver [Resolv::DNS] The DNS resolver to use when looking up DNS records.
    # @raise [Error] If the domain is invalid.
    def initialize(domain, resolver: nil)
      @original_domain = domain.to_s.freeze
      @resolver = resolver
      raise Error, "#{domain} is not a valid domain name" unless valid? && registerable?
    end

    # True if the domain name is syntactically valid.
    #
    # A valid domain name consists of a sequence of labels separated by dots. Each label must be less than 64 bytes long
    # and the total length must be less than 254 bytes. A label can be any binary string.
    #
    # In practice, a name can be syntactically valid but not still not allowed by ICANN or registrar rules.
    #
    # @see https://datatracker.ietf.org/doc/html/rfc2181#section-11 (Name syntax)
    def valid?
      return false if original_domain.blank?
      return false if original_domain.delete_suffix(".").bytesize > 253
      return false if original_domain.include?("..")
      return false if original_domain.start_with?(".")
      return false if original_domain.split(".").any? { |label| label.bytesize > 63 }

      true
    end

    # True if the domain name is both syntactically valid and allowed by registry rules. Some domain names are
    # technically allowed by the DNS protocol, but not allowed by ICANN or registry rules.
    #
    # @see https://datatracker.ietf.org/doc/html/rfc3696#section-2 (Restrictions on domain names)
    def registerable?
      return false unless valid?

      # The root domain (".") is technically a valid domain, but usually we don't want to allow it in URLs (e.g. "http://./").
      return false if root?

      # TLDs can only contain letters, Unicode, or Punycode, and must be at least two characters long.
      # https://data.iana.org/TLD/tlds-alpha-by-domain.txt
      return false unless tld.nil? || tld.match?(/\A[[^[:ascii:]]a-z]{2,}|xn--[a-z0-9-]{2,}\z/i)

      # Labels can only contain letters, digits, and hyphens, and can't start or end with a hyphen (the "LDH rule").
      domain.split(".").each do |label|
        # XXX Should only allow valid Unicode characters, not all of them.
        return false if !label.match?(/\A[[^[:ascii:]]a-zA-Z0-9-]+\z/)
        return false if label.start_with?("-") || label.end_with?("-")
      end

      # Subdomains technically have no rules because the domain owner can do whatever they want. In practice, they
      # usually obey the same rules as base domains, except some sites allow subdomains to contain underscores.
      subdomain.to_s.split(".").each do |label|
        return false if !label.match?(/\A[[^[:ascii:]]a-zA-Z0-9_-]+\z/)
        return false if label.start_with?("-") || label.end_with?("-")
      end

      true
    end

    # @return [String] The domain in normalized form (lowercase, with extraneous whitespace and dots removed).
    memoize def normalized_domain
      original_domain.downcase.strip.delete_prefix(".").delete_suffix(".")
    end

    alias_method :to_s, :normalized_domain

    # @return [Array<String>] The domain parsed into labels (the dot-separated pieces of the domain).
    memoize def labels
      normalized_domain.split(".")
    end

    alias_method :to_a, :labels
    alias_method :deconstruct, :labels

    # Return the subdomain. For example, for "senpenbankashiki.hp.infoseek.co.jp" the subdomain is "senpenbankashiki.hp".
    #
    # @return [String, nil] The subdomain, or nil if the domain doesn't have one (e.g. "twitter.com", "localhost").
    def subdomain
      public_suffix&.trd
    end

    # Return the base-level domain, also known as the eTLD+1. For example, for "senpenbankashiki.hp.infoseek.co.jp" the
    # base domain is "infoseek.co.jp". For dotless domains or top-level domains (e.g. "localhost", "co.jp"), it's the
    # full domain ("localhost", "co.jp").
    #
    # @return [String] The base domain.
    def domain
      public_suffix&.domain || normalized_domain
    end

    # Return the second-level domain (SLD). For example, for "senpenbankashiki.hp.infoseek.co.jp" the SLD is "infoseek".
    #
    # @return [String] The second-level domain, or the domain itself if it doesn't have one (e.g. "localhost").
    def sld
      return normalized_domain if dotless?
      public_suffix&.sld || labels[-2]
    end

    # Return the effective top-level domain. For example, for "senpenbankashiki.hp.infoseek.co.jp" the eTLD is "co.jp".
    #
    # @return [String, nil] The eTLD, or nil if the domain doesn't have one (e.g. "localhost").
    def etld
      public_suffix&.tld || tld
    end

    # Return the top-level domain. For example, for "senpenbankashiki.hp.infoseek.co.jp" the TLD is "jp".
    #
    # @return [String, nil] The TLD, or nil if the domain doesn't have one (e.g. "localhost").
    def tld
      labels.last unless dotless?
    end

    # A dotless domain is one like "localhost", "com", or "ai". It has only one label and no dots.
    #
    # Some ccTLDs like "ai" are actually resolvable to an IP (see http://ai./). gTLDs like "com" and "org" are not resolvable.
    #
    # @see https://en.wikipedia.org/wiki/Top-level_domain#Dotless_domains
    # @see https://lab.avl.la/dotless/
    def dotless?
      labels.size <= 1
    end

    # The root domain is the special domain ".". It's the top-most domain in the DNS hierarchy.
    def root?
      labels.empty?
    end

    # @return [PublicSuffix::Domain, nil] The parsed domain, or nil if it couldn't be parsed.
    memoize def public_suffix
      PublicSuffix.parse(normalized_domain, ignore_private: true) if tld.present?
    rescue PublicSuffix::Error
      nil
    end

    # @return [Resolv::DNS] The default DNS resolver to use for looking up DNS records.
    def resolver
      @resolver ||= Resolv::DNS.new.tap { |r| r.timeouts = [3, 3, 3] }
    end

    # Resolve a domain to an IP address, or raise an error if it can't be resolved.
    #
    # @return [Danbooru::IpAddress] The domain's IP address.
    def resolve!
      address = resolver.getaddress(to_s)
      Danbooru::IpAddress.new(address)
    rescue Resolv::ResolvError => e
      raise Error, e
    end

    # Resolve a domain to an IP address, or return nil if it can't be resolved.
    #
    # @return [Danbooru::IpAddress] The domain's IP address.
    def resolve
      resolve!
    rescue Error
      nil
    end

    # Look up DNS records of the given type.
    #
    # @param type [:any, :a, :aaaa, :cname, :mx, :ns, :ptr, :txt] The type of DNS record to return.
    # @return [Array<Resolv::DNS::Resource>] The list of DNS records, or an empty array if there was a DNS error.
    def records(type = :any)
      typeclass = Resolv::DNS::Resource::IN.const_get(type.upcase)
      resolver.getresources(to_s, typeclass)
    rescue Resolv::ResolvError
      []
    end

    # Equality on unnormalized domains. `Domain.new("foo.com") == Domain.new("FOO.com")` is false.
    def ==(other)
      self.class == other.class && original_domain == other.original_domain
    end

    # Case equality on normalized domains. Allows comparisons with strings or regexps. `Domain.new("foo.com") === " FOO.com. "` is true.
    def ===(other)
      if other.is_a?(Regexp)
        normalized_domain.match?(other)
      elsif other.is_a?(Domain)
        normalized_domain == other.normalized_domain
      else
        normalized_domain == Domain.parse(other)&.normalized_domain
      end
    end

    # Hash key equality.
    alias_method :eql?, :==

    # Hash the domain for when it's used as a hash key.
    def hash
      [self.class, original_domain].hash
    end

    # Sort domains by domain first, then by subdomain.
    def <=>(other)
      return nil unless other.is_a?(Domain)

      [domain, subdomain.to_s] <=> [other.domain, other.subdomain.to_s]
    end

    def inspect
      "#<#{self.class} #{to_s}>"
    end
  end
end
