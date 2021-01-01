# Checks whether a new account seems suspicious and should require email verification.

class UserVerifier
  attr_reader :current_user, :request

  # current_user is the user creating the new account, not the new account itself.
  def initialize(current_user, request)
    @current_user, @request = current_user, request
  end

  def requires_verification?
    return false if !Danbooru.config.new_user_verification?
    return false if is_local_ip?

    # we check for IP bans first to make sure we bump the IP ban hit count
    is_ip_banned? || is_logged_in? || is_recent_signup? || is_proxy?
  end

  private

  def ip_address
    @ip_address ||= IPAddress.parse(request.remote_ip)
  end

  def is_local_ip?
    if ip_address.ipv4?
      ip_address.loopback? || ip_address.link_local? || ip_address.private?
    elsif ip_address.ipv6?
      ip_address.loopback? || ip_address.link_local? || ip_address.unique_local?
    end
  end

  def is_logged_in?
    !current_user.is_anonymous?
  end

  def is_recent_signup?(age: 24.hours)
    subnet_len = ip_address.ipv4? ? 24 : 64
    subnet = "#{ip_address}/#{subnet_len}"

    User.where("last_ip_addr <<= ?", subnet).where("created_at > ?", age.ago).exists?
  end

  def is_ip_banned?
    IpBan.hit!(:partial, ip_address.to_s)
  end

  def is_proxy?
    IpLookup.new(ip_address).is_proxy?
  end
end
