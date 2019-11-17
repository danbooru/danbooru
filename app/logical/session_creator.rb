class SessionCreator
  attr_reader :session, :name, :password, :ip_addr
  attr_reader :user

  def initialize(session, name, password, ip_addr)
    @session = session
    @name = name
    @password = password
    @ip_addr = ip_addr
  end

  def authenticate
    if User.authenticate(name, password)
      @user = User.find_by_name(name)

      session[:user_id] = @user.id
      @user.update_column(:last_ip_addr, ip_addr)
      return true
    else
      return false
    end
  end
end
