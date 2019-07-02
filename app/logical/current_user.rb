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

  def self.as_admin(&block)
    if block_given?
      scoped(::User.admins.first, "127.0.0.1", &block)
    else
      self.user = ::User.admins.first
      self.ip_addr = "127.0.0.1"
    end
  end

  def self.as_system(&block)
    if block_given?
      scoped(::User.system, "127.0.0.1", &block)
    else
      self.user = User.system
      self.ip_addr = "127.0.0.1"
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

  def self.root_url
    Thread.current[:current_root_url] || "https://#{Danbooru.config.hostname}"
  end

  def self.root_url=(root_url)
    Thread.current[:current_root_url] = root_url
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

  def self.admin_mode?
    Thread.current[:admin_mode]
  end

  def self.without_safe_mode
    prev = RequestStore[:safe_mode]
    RequestStore[:safe_mode] = false
    Thread.current[:admin_mode] = true
    yield
  ensure
    RequestStore[:safe_mode] = prev
    Thread.current[:admin_mode] = false
  end

  def self.set_safe_mode(req)
    RequestStore[:safe_mode] = Danbooru.config.enable_safe_mode?(req, CurrentUser.user)
  end

  def self.method_missing(method, *params, &block)
    user.__send__(method, *params, &block)
  end
end
