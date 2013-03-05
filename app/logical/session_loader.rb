class SessionLoader
  attr_reader :session, :cookies, :request
  
  def initialize(session, cookies, request)
    @session = session
    @cookies = cookies
    @request = request
  end
  
  def load
    if session[:user_id]
      load_session_user
    elsif cookie_password_hash_valid?
      load_cookie_user
    end
    
    if CurrentUser.user
      CurrentUser.user.unban! if ban_expired?
    else
      CurrentUser.user = AnonymousUser.new
    end
    
    update_last_logged_in_at
    set_time_zone
  end

private
  
  def load_session_user
    CurrentUser.user = User.find_by_id(session[:user_id])
    CurrentUser.ip_addr = request.remote_ip
  end
  
  def load_cookie_user
    CurrentUser.user = User.find_by_name(cookies.signed[:user_name])
    CurrentUser.ip_addr = request.remote_ip
  end
  
  def ban_expired?
    CurrentUser.user.is_banned? && CurrentUser.user.ban && CurrentUser.user.ban.expired?
  end
  
  def cookie_password_hash_valid?
    cookies[:password_hash] && User.authenticate_cookie_hash(cookies.signed[:user_name], cookies[:password_hash])
  end
  
  def update_last_logged_in_at
    return if CurrentUser.is_anonymous?
    return if CurrentUser.last_logged_in_at && CurrentUser.last_logged_in_at > 1.week.ago
    CurrentUser.user.update_attribute(:last_logged_in_at, Time.now)
  end
  
  def set_time_zone
    Time.zone = CurrentUser.user.time_zone
  end
end

