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

    set_time_zone
  end

private
  
  def load_session_user
    CurrentUser.user = User.find_by_id(session[:user_id])
    CurrentUser.ip_addr = request.remote_ip
  end
  
  def load_cookie_user
    CurrentUser.user = User.find_by_name(cookies[:user_name])
    CurrentUser.ip_addr = request.remote_ip
  end
  
  def ban_expired?
    CurrentUser.user.is_banned? && CurrentUser.user.ban && CurrentUser.user.ban.expired?
  end
  
  def cookie_password_hash_valid?
    cookies[:cookie_password_hash] && User.authenticate_cookie_hash(cookies[:user_name], cookies[:cookie_password_hash])
  end
  
  def set_time_zone
    Time.zone = CurrentUser.user.time_zone
  end
end

