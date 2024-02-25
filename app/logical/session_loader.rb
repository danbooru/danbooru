# frozen_string_literal: true

# Loads the current user from their session cookies or API key. Used by the
# ApplicationController to set the CurrentUser global early during the HTTP
# request cycle.
#
# @see ApplicationController#set_current_user
# @see CurrentUser
class SessionLoader
  include ActiveModel::API

  class AuthenticationFailure < StandardError; end

  attr_reader :session, :request, :ip_address, :params

  # Initialize the session loader.
  # @param request the HTTP request
  def initialize(request)
    @request = request
    @session = request.session
    @ip_address = Danbooru::IpAddress.new(request.remote_ip)
    @params = request.query_parameters
  end

  # Attempt to log a user in with the given username and password. Records a
  # login attempt event and returns the user if successful.
  # @param name_or_email [String] The user's username or email address.
  # @param password [String] the user's password
  # @return [User, nil] the user if the password was correct, otherwise nil
  def login(name_or_email, password)
    user = User.find_by_name_or_email(name_or_email)

    if user.present? && user.authenticate_password(password)
      # Don't allow logins to privileged or inactive accounts from proxies, even if the password is correct
      if (user.is_approver? || user.last_logged_in_at < 6.months.ago) && ip_address.is_proxy?
        UserEvent.create_from_request!(user, :failed_login, request)
        return nil
      elsif user.totp.present?
        UserEvent.create_from_request!(user, :totp_login_pending_verification, request)
        return user
      end

      login_user(user, :login)
    elsif user.nil?
      errors.add(:base, "Incorrect username or password")
      nil
    else
      UserEvent.create_from_request!(user, :failed_login, request)
      errors.add(:base, "Incorrect username or password")
      nil
    end
  end

  # Verify whether a user's 2FA code is correct after they have logged in with their password.
  #
  # @param user [User] The user to authenticate.
  # @param code [String] The user's 6-digit 2FA code, or their 8-digit backup code.
  # @return [Boolean] True if the 2FA code is correct, or false if it's incorrect.
  def verify_totp!(user, code)
    if user.totp.verify(code)
      login_user(user, :totp_login)
      true
    elsif user.verify_backup_code!(code)
      login_user(user, :backup_code_login)
      true
    else
      UserEvent.create_from_request!(user, :totp_failed_login, request)
      false
    end
  end

  def login_user(user, event_category)
    session[:user_id] = user.id
    session[:last_authenticated_at] = Time.now.utc.to_s

    UserEvent.build_from_request(user, event_category, request)
    user.last_logged_in_at = Time.now
    user.last_ip_addr = request.remote_ip
    user.save!

    user
  end

  # Verify a user's password and 2FA code. Used to confirm a user's password before sensitive actions like adding API
  # keys or changing the user's email.
  #
  # @param user [User] The user to reauthenticate.
  # @param password [String] The user's password.
  # @param verification_code [String] The user's 6-digit 2FA code, or their 8-digit backup code (if they have 2FA enabled).
  def reauthenticate(user, password, verification_code = nil)
    if !user.authenticate_password(password) # wrong password
      UserEvent.create_from_request!(user, :failed_reauthenticate, request)
      errors.add(:password, "is incorrect")
      false
    elsif !user.totp.present? # right password and user doesn't have 2FA
      UserEvent.create_from_request!(user, :reauthenticate, request)
      session[:last_authenticated_at] = Time.now.utc.to_s
      true
    elsif user.totp.verify(verification_code) # right password and right 2FA code
      UserEvent.create_from_request!(user, :totp_reauthenticate, request)
      session[:last_authenticated_at] = Time.now.utc.to_s
      true
    elsif user.verify_backup_code!(verification_code) # right password and right backup code
      UserEvent.create_from_request!(user, :backup_code_reauthenticate, request)
      session[:last_authenticated_at] = Time.now.utc.to_s
      true
    else # right password and wrong 2FA code or wrong backup code
      UserEvent.create_from_request!(user, :totp_failed_reauthenticate, request)
      errors.add(:verification_code, "is incorrect")
      false
    end
  end

  # Logs the current user out. Deletes their session cookie and records a logout event.
  def logout(user = CurrentUser.user)
    session.delete(:user_id)
    session.delete(:last_authenticated_at)
    return if user.is_anonymous?
    UserEvent.create_from_request!(user, :logout, request)
  end

  # Sets the current user. Runs on each HTTP request. The user is set based on
  # their API key, their session cookie, or the signed user id param (used when
  # resetting a password from an magic email link)
  #
  # Also performs post-load actions, including updating the user's last login
  # timestamp, their last used IP, their timezone, their database timeout,
  # whether safe mode is enabled, their session cookie, and unbanning banned
  # users if their ban is expired.
  #
  # @see ApplicationController#set_current_user
  # @see CurrentUser
  def load
    CurrentUser.user = User.anonymous

    if has_api_authentication?
      load_session_for_api
    elsif session[:user_id]
      load_session_user
    end

    set_statement_timeout
    update_last_logged_in_at
    update_last_ip_addr
    set_time_zone
    set_country
    set_safe_mode
    set_save_data_mode
    initialize_session_cookies
    CurrentUser.user.unban! if CurrentUser.user.ban_expired?
  ensure
    DanbooruLogger.add_session_attributes(request, session, CurrentUser.user)
  end

  # @return [Boolean] true if the current request has an API key
  def has_api_authentication?
    request.authorization.present? || params.has_key?(:login) || params.has_key?(:api_key)
  end

  private

  def set_statement_timeout
    timeout = CurrentUser.user.statement_timeout
    ActiveRecord::Base.connection.execute("SET statement_timeout = #{timeout}")
  end

  # Sets the current API user based on either the `login` + `api_key` URL params,
  # or HTTP Basic Auth.
  def load_session_for_api
    if request.authorization
      authenticate_basic_auth
    elsif params[:login].present? && params[:api_key].present?
      authenticate_api_key(params[:login], params[:api_key])
    else
      raise AuthenticationFailure, "Missing `login` or `api_key`"
    end
  end

  # Sets the current API user based on the HTTP Basic Auth params.
  def authenticate_basic_auth
    credentials = ::Base64.decode64(request.authorization.split(' ', 2).last || '')
    login, api_key = credentials.split(/:/, 2)
    DanbooruLogger.add_attributes("param", login: login)
    authenticate_api_key(login, api_key)
  end

  # Sets the current user if their API key is valid.
  # @param name [String] the user name
  # @param key [String] the API key
  # @raise AuthenticationFailure if the API key is invalid
  # @raise User::PrivilegeError if the API key doesn't have the required
  #   permissions for this endpoint
  def authenticate_api_key(name, key)
    user, api_key = User.find_by_name(name)&.authenticate_api_key(key)
    raise AuthenticationFailure, "Invalid API key" if user.blank?
    update_api_key(api_key)
    raise User::PrivilegeError if !api_key.has_permission?(request.remote_ip, request.params[:controller], request.params[:action])
    CurrentUser.user = user
  end

  # Set the current user based on the `user_id` session cookie.
  def load_session_user
    user = User.find_by_id(session[:user_id])
    return if user.nil?

    if user.is_deleted?
      logout(user)
    else
      CurrentUser.user = user
    end
  end

  def update_last_logged_in_at
    return if CurrentUser.is_anonymous?
    return if CurrentUser.last_logged_in_at && CurrentUser.last_logged_in_at > 1.hour.ago
    CurrentUser.user.update_attribute(:last_logged_in_at, Time.now)
  end

  def update_last_ip_addr
    return if CurrentUser.is_anonymous?
    return if CurrentUser.user.last_ip_addr == @request.remote_ip
    CurrentUser.user.update_attribute(:last_ip_addr, @request.remote_ip)
  end

  def update_api_key(api_key)
    api_key.increment!(:uses, touch: :last_used_at)
    api_key.update!(last_ip_address: request.remote_ip)
  end

  def set_time_zone
    Time.zone = CurrentUser.user.time_zone
  end

  def set_country
    CurrentUser.country = request.headers["CF-IPCountry"]
  end

  def set_safe_mode
    safe_mode = request.host.in?(Danbooru.config.safe_mode_hostnames) || params[:safe_mode].to_s.truthy? || CurrentUser.user.enable_safe_mode?
    CurrentUser.safe_mode = safe_mode
  end

  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Save-Data
  # https://www.keycdn.com/blog/save-data
  def set_save_data_mode
    save_data = params[:save_data].presence || request.cookies[:save_data].presence || request.headers["Save-Data"].presence || "false"
    CurrentUser.save_data = save_data.truthy?
  end

  def initialize_session_cookies
    session.options[:expire_after] = 20.years
    session[:started_at] ||= Time.now.utc.to_s
  end
end
