class CurrentUser
  def self.scoped(user, ip_addr = "127.0.0.1")
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

  def self.as(user_or_id, &block)
    if user_or_id.is_a?(String) || user_or_id.is_a?(Integer)
      user = ::User.find(user_or_id)
    else
      user = user_or_id
    end

    scoped(user, &block)
  end

  def self.user
    RequestStore[:current_user]
  end

  def self.user=(user)
    RequestStore[:current_user] = user
  end

  def self.ip_addr
    RequestStore[:current_ip_addr]
  end

  def self.ip_addr=(ip_addr)
    RequestStore[:current_ip_addr] = ip_addr
  end

  def self.root_url
    RequestStore[:current_root_url] || "https://#{Danbooru.config.hostname}"
  end

  def self.root_url=(root_url)
    RequestStore[:current_root_url] = root_url
  end

  def self.id
    if user.nil?
      nil
    else
      user.id
    end
  end

  def self.name
    user.name
  end

  def self.safe_mode?
    RequestStore[:safe_mode]
  end

  def self.safe_mode=(safe_mode)
    RequestStore[:safe_mode] = safe_mode
  end

  def self.method_missing(method, *params, &block)
    user.__send__(method, *params, &block)
  end
end
