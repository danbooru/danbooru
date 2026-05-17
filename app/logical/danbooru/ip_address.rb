# frozen_string_literal: true

# A wrapper around the IPAddress gem that adds some extra utility methods.
#
# @see https://github.com/ipaddress-gem/ipaddress
module Danbooru
  class IpAddress
    attr_reader :ip_address

    delegate :ipv4?, :ipv6?, :loopback?, :link_local?, :unique_local?, :private?, :to_string, :network, :prefix, :unspecified?, to: :ip_address
    delegate :ip_info, :is_proxy?, to: :ip_lookup

    def self.parse(string)
      new(string)
    rescue
      nil
    end

    # @param ip_addr [String, IPAddress] The IP address.
    def initialize(ip_addr)
      if ip_addr.is_a?(::IPAddress)
        @ip_address = ip_addr
      elsif ip_addr.is_a?(Danbooru::IpAddress)
        @ip_address = ip_addr.ip_address
      else
        @ip_address = ::IPAddress.parse(ip_addr.to_s.strip)
      end
    end

    def ip_lookup
      @ip_lookup ||= IpLookup.new(self)
    end

    # @return [Boolean] True if this is a non-publicly routable IP address.
    def is_local?
      if ipv4?
        loopback? || link_local? || multicast? || reserved? || private?
      elsif ipv6?
        loopback? || link_local? || multicast? || reserved? || unique_local? || unspecified? || ipv4_mapped?
      end
    end

    # @return [Boolean] True if this is a multicast address.
    def multicast?
      (ipv4? && ip_address.multicast?) || (ipv6? && in?(%w[ff00::/8]))
    end

    # @return [Boolean] True if this is a reserved address.
    # @see https://en.wikipedia.org/wiki/List_of_reserved_IP_addresses
    def reserved?
      # 0.0.0.0/8, ::/128 - Reserved; on Linux, these are treated as loopback addresses and route to localhost.
      # 100.64.0.0/10 - CGNAT
      # 240.0.0.0/4 - Reserved for future use
      # 255.255.255.255 - Reserved for the broadcast address on the local network segment
      in?(%w[0.0.0.0/8 ::/128 100.64.0.0/10 240.0.0.0/4 255.255.255.255])
    end

    # @return [Boolean] True if this is an IPv4-mapped IPv6 address.
    # @see https://en.wikipedia.org/wiki/IPv6_address#Transition_from_IPv4
    def ipv4_mapped?
      # ::ffff:0:0/96 - IPv4-in-IPv6 mappings (e.g. ::ffff:169.254.169.254, ::ffff:a9fe:a9fe in hex)
      # 2001::/32 - Teredo tunneling
      # 2002::/16 - 6to4, deprecated (e.g. 2002:a9fe:a9fe::/48 = 169.254.169.254).
      # 64:ff9b::/96 - NAT64 translation (e.g. 64:ff9b::169.254.169.254)
      # 64:ff9b:1::/48 - NAT64 local-use
      in?(%w[::ffff:0:0/96 2002::/16 64:ff9b::/96 64:ff9b:1::/48])
    end

    # If we're being reverse proxied behind Cloudflare, then Tor connections
    # will appear to originate from 2405:8100:8000::/48.
    # @see https://blog.cloudflare.com/cloudflare-onion-service/
    def is_tor?
      Danbooru::IpAddress.new("2405:8100:8000::/48").include?(ip_address)
    end

    # Convert the IP to a subnet.
    def supernet(prefix)
      self.class.new(ip_address.supernet(prefix))
    end

    # Convert the IP to a /24 or /64 subnet, unless it's a local IP, a Tor IP, or already a subnet.
    def subnet
      if is_local? || is_tor? || ip_address.size > 1
        self
      elsif ipv4?
        supernet(24)
      elsif ipv6?
        supernet(64)
      end
    end

    # @param ip_addresses [Array<String, IPAddress>] An array of IP addresses or subnets.
    # @return [Boolean] True if this IP is contained within any of the given IPs or subnets.
    def in?(ip_addresses)
      ip_addresses.any? { |ip| IpAddress.parse(ip).include?(self) }
    end

    # @param other [String, IPAddress] An IP address or subnet.
    # @return [Boolean] True if this subnet contains the given IP or subnet.
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
      (ip_address.size > 1) ? "#{network}/#{prefix}" : ip_address.to_s
    end

    def inspect
      "#<Danbooru::IpAddress #{to_s}>"
    end

    # @param other [String, IPAddress] An IP address or subnet.
    # @return [Boolean] True if this IP is contained within the given subnet.
    def ===(other)
      in?([other])
    end

    def ==(other)
      self.class == other.class && to_s == other.to_s
    end

    def <=>(other)
      return nil unless other.is_a?(IpAddress)

      [-prefix.to_i, network.to_s] <=> [-other.prefix.to_i, other.network.to_s]
    end

    # This is needed to be able to correctly treat IpAddresses as hash keys,
    # which Rails does internally when preloading associations.
    def hash
      to_s.hash
    end

    alias_method :eql?, :==
  end
end
