# frozen_string_literal: true

# This class handles the creation of new accounts. It checks whether the account should be restricted because the signup
# was from a proxy or a sockpuppet account.
class UserSignup
  extend Memoist

  attr_reader :request, :params

  # @param request the HTTP request
  def initialize(request)
    @request = request
    @params = request.params
  end

  # @return [User] The user that will be created.
  memoize def user
    User.new(
      request: request,
      last_ip_addr: request.remote_ip,
      last_logged_in_at: Time.zone.now,
      requires_verification: requires_verification?,
      level: initial_level,
      name: params[:user][:name],
      password: params[:user][:password],
      password_confirmation: params[:user][:password_confirmation],
      email_address_attributes: { address: params.dig(:user, :email_address, :address) },
    )
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
