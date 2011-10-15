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
        cookies[:user_name] = {:expires => 1.year.from_now, :value => user.name}
        cookies[:cookie_password_hash] = {:expires => 1.year.from_now, :value => user.cookie_password_hash}
      end
      
      session[:user_id] = user.id
      return true
    else
      return false
    end
  end
end
