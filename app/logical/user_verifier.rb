# frozen_string_literal: true

# Checks whether a new account requires verification. An account requires
# verification if the IP is a proxy, or the IP is under a partial (signup) IP
# ban, or it was used to create another account recently.
class UserVerifier
  extend Memoist

  attr_reader :current_user, :request

  # Create a user verifier.
  # @param current_user [User] the user creating the new account, not the new account itself.
  # @param request the HTTP request
  def initialize(current_user, request)
    @current_user, @request = current_user, request
  end

  # Returns true if the new account should be restricted. Signups from local
  # IPs are unrestricted so that verification isn't required for development,
  # testing, or personal boorus.
  def requires_verification?
    return false if !Danbooru.config.new_user_verification?.to_s.truthy?
    return false if ip_address.is_local?

    # we check for IP bans first to make sure we bump the IP ban hit count
    is_ip_banned? || is_sockpuppet? || is_recently_used_ip? || is_proxy?
  end

  # @return [Integer] Returns whether the new account should be Restricted or a Member
  def initial_level
    if requires_verification?
      User::Levels::RESTRICTED
    else
      User::Levels::MEMBER
    end
  end

  private

  def ip_address
    @ip_address ||= Danbooru::IpAddress.new(request.remote_ip)
  end

  memoize def is_recently_used_ip?
    User.where(last_logged_in_at: 24.hours.ago..).exists?(["last_ip_addr <<= ?", ip_address.subnet.to_s]) ||
      UserEvent.authorized.where(created_at: 24.hours.ago..).exists?(["ip_addr <<= ?", ip_address.subnet.to_s])
  end

  memoize def is_sockpuppet?
    UserEvent.authorized.exists?(session_id: request.session[:session_id])
  end

  memoize def is_ip_banned?
    IpBan.hit!(:partial, ip_address.to_s)
  end

  memoize def is_proxy?
    ip_address.is_proxy?
  end
end
