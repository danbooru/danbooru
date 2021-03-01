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
    ip = Danbooru::IpAddress.new(::Resolv.getaddress(hostname))
    raise ProhibitedIpError, "Connection to #{hostname} failed; #{ip} is a prohibited IP" if ip.is_local?
    ip.to_s
  end
end
