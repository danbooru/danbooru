# frozen_string_literal: true

# A wrapper around the IPAddress gem that adds some extra utility methods.
#
# @see https://github.com/ipaddress-gem/ipaddress
module Danbooru
  class IpAddress
    attr_reader :ip_address
    delegate :ipv4?, :ipv6?, :loopback?, :link_local?, :unique_local?, :private?, :to_string, :network, :prefix, :multicast?, :unspecified?, to: :ip_address
    delegate :ip_info, :is_proxy?, to: :ip_lookup

    def self.parse(string)
      new(string)
    rescue
      nil
    end

    def initialize(string)
      @ip_address = ::IPAddress.parse(string.to_s.strip)
    end

    def ip_lookup
      @ip_lookup ||= IpLookup.new(self)
    end

    def is_local?
      if ipv4?
        loopback? || link_local? || multicast? || private?
      elsif ipv6?
        loopback? || link_local? || unique_local? || unspecified?
      end
    end

    # If we're being reverse proxied behind Cloudflare, then Tor connections
    # will appear to originate from 2405:8100:8000::/48.
    # @see https://blog.cloudflare.com/cloudflare-onion-service/
    def is_tor?
      Danbooru::IpAddress.new("2405:8100:8000::/48").include?(ip_address)
    end

    def include?(other)
      other = Danbooru::IpAddress.new(other)
      return false if (ipv4? && other.ipv6?) || (ipv6? && other.ipv4?)

      ip_address.include?(other.ip_address)
    end

    def as_json
      to_s
    end

    # "1.2.3.4/24" if the address is a subnet, "1.2.3.4" otherwise.
    def to_s
      ip_address.size > 1 ? "#{network}/#{prefix}" : ip_address.to_s
    end

    def inspect
      "#<Danbooru::IpAddress #{to_s}>"
    end

    def ==(other)
      self.class == other.class && to_s == other.to_s
    end

    # This is needed to be able to correctly treat IpAddresses as hash keys,
    # which Rails does internally when preloading associations.
    def hash
      to_s.hash
    end

    alias_method :eql?, :==
  end
end
