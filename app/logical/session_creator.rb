class SessionCreator
  attr_reader :session, :cookies, :name, :password, :remember
  
  def initialize(session, cookies, name, password, remember)
    @session = session
    @cookies = cookies
    @name = name
    @password = password
    @remember = remember
  end
  
  def authenticate
    if User.authenticate(name, password)
      user = User.find_by_name(name)
      user.update_column(:last_logged_in_at, Time.now)
      
      if remember.present?
        cookies.permanent.signed[:user_name] = user.name
        cookies.permanent[:password_hash] = user.bcrypt_cookie_password_hash
      end
      
      session[:user_id] = user.id
      return true
    else
      return false
    end
  end
end
