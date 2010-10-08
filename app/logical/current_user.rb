class CurrentUser
  def self.scoped(user, ip_addr)
    old_user = self.user
    old_ip_addr = self.ip_addr
    
    self.user = user
    self.ip_addr = ip_addr
    
    begin
      yield
    ensure
      self.user = old_user
      self.ip_addr = old_ip_addr
    end
  end

  def self.user=(user)
    Thread.current[:current_user] = user
  end
  
  def self.ip_addr=(ip_addr)
    Thread.current[:current_ip_addr] = ip_addr
  end
  
  def self.user
    Thread.current[:current_user]
  end
  
  def self.ip_addr
    Thread.current[:current_ip_addr]
  end
end
