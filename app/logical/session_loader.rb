class SessionLoader
  class AuthenticationFailure < Exception ; end

  attr_reader :session, :cookies, :request, :params

  def initialize(request)
    @request = request
    @session = request.session
    @cookies = request.cookie_jar
    @params = request.parameters
  end

  def load
    CurrentUser.user = User.anonymous
    CurrentUser.ip_addr = request.remote_ip

    if has_api_authentication?
      load_session_for_api
    elsif session[:user_id]
      load_session_user
    elsif cookie_password_hash_valid?
      load_cookie_user
    end

    set_statement_timeout
    update_last_logged_in_at
    update_last_ip_addr
    set_time_zone
    set_safe_mode
    set_started_at_session
    CurrentUser.user.unban! if CurrentUser.user.ban_expired?
  ensure
    DanbooruLogger.add_session_attributes(request, session, CurrentUser.user)
  end

  def has_api_authentication?
    request.authorization.present? || params[:login].present? || params[:api_key].present? || params[:password_hash].present?
  end

private

  def set_statement_timeout
    timeout = CurrentUser.user.statement_timeout
    ActiveRecord::Base.connection.execute("set statement_timeout = #{timeout}")
  end

  def load_session_for_api
    if request.authorization
      authenticate_basic_auth
    elsif params[:login].present? && params[:api_key].present?
      authenticate_api_key(params[:login], params[:api_key])
    elsif params[:login].present? && params[:password_hash].present?
      authenticate_legacy_api_key(params[:login], params[:password_hash])
    else
      raise AuthenticationFailure
    end
  end

  def authenticate_basic_auth
    credentials = ::Base64.decode64(request.authorization.split(' ', 2).last || '')
    login, api_key = credentials.split(/:/, 2)
    DanbooruLogger.add_attributes("request.params", login: login)
    authenticate_api_key(login, api_key)
  end

  def authenticate_api_key(name, api_key)
    CurrentUser.user = User.authenticate_api_key(name, api_key)

    if CurrentUser.user.nil?
      raise AuthenticationFailure.new
    end
  end

  def authenticate_legacy_api_key(name, password_hash)
    CurrentUser.user = User.authenticate_hash(name, password_hash)

    if CurrentUser.user.nil?
      raise AuthenticationFailure.new
    end
  end

  def load_session_user
    user = User.find_by_id(session[:user_id])
    CurrentUser.user = user if user
  end

  def load_cookie_user
    CurrentUser.user = User.find_by_name(cookies.signed[:user_name])
    session[:user_id] = CurrentUser.user.id
  end

  def cookie_password_hash_valid?
    cookies[:password_hash] && cookies.signed[:user_name] && User.authenticate_cookie_hash(cookies.signed[:user_name], cookies[:password_hash])
  end

  def update_last_logged_in_at
    return if CurrentUser.is_anonymous?
    return if CurrentUser.last_logged_in_at && CurrentUser.last_logged_in_at > 1.week.ago
    CurrentUser.user.update_attribute(:last_logged_in_at, Time.now)
  end

  def update_last_ip_addr
    return if CurrentUser.is_anonymous?
    return if CurrentUser.user.last_ip_addr == @request.remote_ip
    CurrentUser.user.update_attribute(:last_ip_addr, @request.remote_ip)
  end

  def set_time_zone
    Time.zone = CurrentUser.user.time_zone
  end

  def set_safe_mode
    safe_mode = request.host.match?(/safebooru/i) || params[:safe_mode].to_s.truthy? || CurrentUser.user.enable_safe_mode?
    CurrentUser.safe_mode = safe_mode
  end

  def set_started_at_session
    if session[:started_at].blank?
      session[:started_at] = Time.now.utc.to_s
    end
  end
end
