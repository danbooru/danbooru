# frozen_string_literal: true

# A wrapper around Ruby's IPAddr class that adds some extra utility methods.
#
# @see https://docs.ruby-lang.org/en/master/IPAddr.html
module Danbooru
  class IpAddress
    attr_reader :ip_address

    delegate :ipv4?, :ipv6?, :loopback?, :link_local?, :private?, :prefix, to: :ip_address
    delegate :ip_info, :is_proxy?, to: :ip_lookup

    def self.parse(string)
      new(string)
    rescue
      nil
    end

    # @param ip_addr [String, IPAddr, Danbooru::IpAddress] The IP address.
    def initialize(ip_addr)
      if ip_addr.is_a?(::IPAddr)
        @ip_address = ip_addr
      elsif ip_addr.is_a?(Danbooru::IpAddress)
        @ip_address = ip_addr.ip_address
      else
        @ip_address = ::IPAddr.new(ip_addr.to_s.strip)
        raise ArgumentError, "IPv6 zone IDs aren't supported" if ipv6? && @ip_address.zone_id.present?
      end
    end

    def ip_lookup
      @ip_lookup ||= IpLookup.new(self)
    end

    # @return [Boolean] True if this is a non-publicly routable IP address. For IPv6, `private?` includes fc00::/7
    #   (unique local addresses) and `reserved?` includes :: (the unspecified address).
    def is_local?
      loopback? || link_local? || multicast? || reserved? || private? || ipv4_mapped?
    end

    # @return [Boolean] True if this is a multicast address.
    def multicast?
      in?(%w[224.0.0.0/4 ff00::/8])
    end

    # @return [Boolean] True if this is a reserved address.
    # @see https://en.wikipedia.org/wiki/List_of_reserved_IP_addresses
    def reserved?
      # 0.0.0.0/8, ::/128 - Reserved; on Linux, these are treated as loopback addresses and route to localhost.
      # 100.64.0.0/10 - CGNAT
      # 192.0.0.0/24 - IETF protocol assignments (includes Oracle Cloud's metadata server at 192.0.0.192)
      # 198.18.0.0/15 - Benchmarking; sometimes used for internal networks
      # 240.0.0.0/4 - Reserved for future use
      # 255.255.255.255 - Reserved for the broadcast address on the local network segment
      # fec0::/10 - Deprecated IPv6 site-local addresses
      in?(%w[0.0.0.0/8 ::/128 100.64.0.0/10 192.0.0.0/24 198.18.0.0/15 240.0.0.0/4 255.255.255.255 fec0::/10])
    end

    # @return [Boolean] True if this is an IPv4-mapped IPv6 address.
    # @see https://en.wikipedia.org/wiki/IPv6_address#Transition_from_IPv4
    def ipv4_mapped?
      # ::ffff:0:0/96 - IPv4-in-IPv6 mappings (e.g. ::ffff:169.254.169.254, ::ffff:a9fe:a9fe in hex)
      # ::/96 - IPv4-compatible addresses, deprecated (e.g. ::7f00:1 = 127.0.0.1)
      in?(%w[::ffff:0:0/96 ::/96])
    end

    # @return [Boolean] True if this is a public IPv6 address that tunnels or translates to an IPv4 address. These are
    #   real client addresses, but connecting to them may reach a local IPv4 address.
    # @see https://en.wikipedia.org/wiki/IPv6_address#Transition_from_IPv4
    def ipv4_tunneled?
      # 2001::/32 - Teredo tunneling
      # 2002::/16 - 6to4, deprecated (e.g. 2002:a9fe:a9fe::/48 = 169.254.169.254).
      # 64:ff9b::/96 - NAT64 translation (e.g. 64:ff9b::169.254.169.254)
      # 64:ff9b:1::/48 - NAT64 local-use
      in?(%w[2001::/32 2002::/16 64:ff9b::/96 64:ff9b:1::/48])
    end

    # @return [Boolean] True if outgoing connections to this address should be blocked to prevent SSRF attacks.
    def prohibited_for_outgoing?
      is_local? || ipv4_tunneled?
    end

    # If we're being reverse proxied behind Cloudflare, then Tor connections
    # will appear to originate from 2405:8100:8000::/48.
    # @see https://blog.cloudflare.com/cloudflare-onion-service/
    def is_tor?
      Danbooru::IpAddress.new("2405:8100:8000::/48").include?(ip_address)
    end

    # Convert the IP to a subnet.
    def supernet(prefix)
      self.class.new(ip_address.mask(prefix))
    end

    # @return [Integer] The number of addresses in the subnet (1 for a single address).
    def size
      2**((ipv4? ? 32 : 128) - prefix)
    end

    # Convert the IP to a /24 or /64 subnet, unless it's a local IP, a Tor IP, or already a subnet.
    def subnet
      if is_local? || is_tor? || size > 1
        self
      elsif ipv4?
        supernet(24)
      elsif ipv6?
        supernet(64)
      end
    end

    # @param ip_addresses [Array<String, IpAddress>] An array of IP addresses or subnets.
    # @return [Boolean] True if this IP is contained within any of the given IPs or subnets.
    def in?(ip_addresses)
      ip_addresses.any? { |ip| IpAddress.parse(ip).include?(self) }
    end

    # @param other [String, IpAddress] An IP address or subnet.
    # @return [Boolean] True if this subnet contains the given IP or subnet.
    def include?(other)
      other = Danbooru::IpAddress.new(other)
      return false if (ipv4? && other.ipv6?) || (ipv6? && other.ipv4?)

      ip_address.include?(other.ip_address)
    end

    def as_json
      to_s
    end

    # "1.2.3.0/24" if the address is a subnet, "1.2.3.4" otherwise.
    def to_s
      (size > 1) ? "#{ip_address}/#{prefix}" : ip_address.to_s
    end

    def inspect
      "#<Danbooru::IpAddress #{to_s}>"
    end

    # @param other [String, IpAddress] An IP address or subnet.
    # @return [Boolean] True if this IP is contained within the given subnet.
    def ===(other)
      in?([other])
    end

    def ==(other)
      self.class == other.class && to_s == other.to_s
    end

    def <=>(other)
      return nil unless other.is_a?(IpAddress)

      [-prefix, ip_address.to_s] <=> [-other.prefix, other.ip_address.to_s]
    end

    # This is needed to be able to correctly treat IpAddresses as hash keys,
    # which Rails does internally when preloading associations.
    def hash
      to_s.hash
    end

    alias_method :eql?, :==
  end
end
