# A wrapper around the IPAddress gem that adds some extra utility methods.
#
# https://github.com/ipaddress-gem/ipaddress

module Danbooru
  class IpAddress
    attr_reader :ip_address
    delegate_missing_to :ip_address

    def initialize(string)
      @ip_address = ::IPAddress.parse(string)
    end

    # "1.2.3.4/24" if the address is a subnet, "1.2.3.4" otherwise.
    def to_s
      ip_address.size > 1 ? ip_address.to_string : ip_address.to_s
    end

    def inspect
      "#<Danbooru::IpAddress #{to_s}>"
    end
  end
end
