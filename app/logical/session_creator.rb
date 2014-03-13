class SessionCreator
  attr_reader :session, :cookies, :name, :password, :remember, :secure

  def initialize(session, cookies, name, password, remember = false, secure = false)
    @session = session
    @cookies = cookies
    @name = name
    @password = password
    @remember = remember
    @secure = secure
  end

  def authenticate
    if User.authenticate(name, password)
      user = User.find_by_name(name)

      if remember.present?
        cookies.permanent.signed[:user_name] = {
          :value => user.name,
          :secure => secure
        }
        cookies.permanent[:password_hash] = {
          :value => user.bcrypt_cookie_password_hash,
          :secure => secure,
          :httponly => true
        }
      end

      session[:user_id] = user.id
      return true
    else
      return false
    end
  end
end
