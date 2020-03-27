class SessionLoader
  class AuthenticationFailure < StandardError; end

  attr_reader :session, :request, :params

  def initialize(request)
    @request = request
    @session = request.session
    @params = request.parameters
  end

  def login(name, password)
    user = User.find_by_name(name)&.authenticate_password(password)
    return nil unless user

    session[:user_id] = user.id
    user.update_column(:last_ip_addr, request.remote_ip)
    user
  end

  def load
    CurrentUser.user = User.anonymous
    CurrentUser.ip_addr = request.remote_ip

    if has_api_authentication?
      load_session_for_api
    elsif params[:signed_user_id]
      load_param_user(params[:signed_user_id])
    elsif session[:user_id]
      load_session_user
    end

    set_statement_timeout
    update_last_logged_in_at
    update_last_ip_addr
    set_time_zone
    set_safe_mode
    initialize_session_cookies
    CurrentUser.user.unban! if CurrentUser.user.ban_expired?
  ensure
    DanbooruLogger.add_session_attributes(request, session, CurrentUser.user)
  end

  def has_api_authentication?
    request.authorization.present? || params[:login].present? || params[:api_key].present?
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
    user = User.find_by_name(name)&.authenticate_api_key(api_key)
    raise AuthenticationFailure if user.blank?
    CurrentUser.user = user
  end

  def load_param_user(signed_user_id)
    session[:user_id] = Danbooru::MessageVerifier.new(:login).verify(signed_user_id)
    load_session_user
  end

  def load_session_user
    user = User.find_by_id(session[:user_id])
    CurrentUser.user = user if user
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

  def initialize_session_cookies
    session.options[:expire_after] = 20.years
    session[:started_at] ||= Time.now.utc.to_s
  end
end
