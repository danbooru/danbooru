class CurrentUser
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
