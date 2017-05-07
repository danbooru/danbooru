class SessionLoader
  class AuthenticationFailure < Exception ; end

  attr_reader :session, :cookies, :request, :params

  def initialize(session, cookies, request, params)
    @session = session
    @cookies = cookies
    @request = request
    @params = params
  end

  def load
    if session[:user_id]
      load_session_user
    elsif cookie_password_hash_valid?
      load_cookie_user
    else
      load_session_for_api
    end
    
    if CurrentUser.user
      CurrentUser.user.unban! if CurrentUser.user.ban_expired?
    else
      CurrentUser.user = AnonymousUser.new
    end

    update_last_logged_in_at
    update_last_ip_addr
    set_time_zone
    store_favorite_tags_in_cookies
    set_statement_timeout
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
    end
  end
  
  def authenticate_basic_auth
    credentials = ::Base64.decode64(request.authorization.split(' ', 2).last || '')
    login, api_key = credentials.split(/:/, 2)
    authenticate_api_key(login, api_key)
  end
  
  def authenticate_api_key(name, api_key)
    CurrentUser.ip_addr = request.remote_ip
    CurrentUser.user = User.authenticate_api_key(name, api_key)

    if CurrentUser.user.nil?
      raise AuthenticationFailure.new
    end
  end
  
  def authenticate_legacy_api_key(name, password_hash)
    CurrentUser.ip_addr = request.remote_ip
    CurrentUser.user = User.authenticate_hash(name, password_hash)

    if CurrentUser.user.nil?
      raise AuthenticationFailure.new
    end
  end

  def load_session_user
    CurrentUser.ip_addr = request.remote_ip
    CurrentUser.user = User.find_by_id(session[:user_id])
  end

  def load_cookie_user
    CurrentUser.user = User.find_by_name(cookies.signed[:user_name])
    CurrentUser.ip_addr = request.remote_ip
    session[:user_id] = CurrentUser.user.id
  end

  def cookie_password_hash_valid?
    cookies[:password_hash] && cookies.signed[:user_name] && User.authenticate_cookie_hash(cookies.signed[:user_name], cookies[:password_hash])
  end

  def store_favorite_tags_in_cookies
    if (cookies[:favorite_tags].blank? || cookies[:favorite_tags_with_categories].blank?) && CurrentUser.user.favorite_tags.present?
      favorite_tags = CurrentUser.user.favorite_tags.slice(0, 1024)
      cookies[:favorite_tags] = favorite_tags
      cookies[:favorite_tags_with_categories] = Tag.categories_for(favorite_tags.scan(/\S+/)).to_a.flatten.join(" ")
    end
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
end

