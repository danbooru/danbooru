class SessionCreator
  attr_reader :session, :cookies, :name, :password, :ip_addr, :remember, :secure

  def initialize(session, cookies, name, password, ip_addr, remember = false, secure = false)
    @session = session
    @cookies = cookies
    @name = name
    @password = password
    @ip_addr = ip_addr
    @remember = remember
    @secure = secure
  end

  def authenticate
    if User.authenticate(name, password)
      user = User.find_by_name(name)

      if remember.present?
        cookies.permanent.signed[:user_name] = {
          :value => user.name,
          :secure => secure,
          :httponly => true
        }
        cookies.permanent[:password_hash] = {
          :value => user.bcrypt_cookie_password_hash,
          :secure => secure,
          :httponly => true
        }
      end

      session[:user_id] = user.id
      user.update_column(:last_ip_addr, ip_addr)
      return true
    else
      return false
    end
  end
end
