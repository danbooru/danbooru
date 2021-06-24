# A TCPSocket wrapper that disallows connections to local or private IPs. Used
# by {Danbooru::Http} to prevent server-side request forgery (SSRF) attacks. For
# example, if we try to download an image from http://example.com/image.jpg, but
# example.com resolves to 127.0.0.1, then the request is prohibited.
#
# @see https://owasp.org/www-community/attacks/Server_Side_Request_Forgery
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
