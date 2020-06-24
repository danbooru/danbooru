# A TCPSocket wrapper that disallows connections to local or private IPs. Used for SSRF protection.
# https://owasp.org/www-community/attacks/Server_Side_Request_Forgery

require "resolv"

class ValidatingSocket < TCPSocket
  class ProhibitedIpError < StandardError; end

  def initialize(hostname, port)
    ip = validate_hostname!(hostname)
    super(ip, port)
  end

  def validate_hostname!(hostname)
    ip = IPAddress.parse(::Resolv.getaddress(hostname))
    raise ProhibitedIpError, "Connection to #{hostname} failed; #{ip} is a prohibited IP" if prohibited_ip?(ip)
    ip.to_s
  end

  def prohibited_ip?(ip)
    if ip.ipv4?
      ip.loopback? || ip.link_local? || ip.multicast? || ip.private?
    elsif ip.ipv6?
      ip.loopback? || ip.link_local? || ip.unique_local? || ip.unspecified?
    end
  end
end
