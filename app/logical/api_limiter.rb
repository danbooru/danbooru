module ApiLimiter
  def throttled?(ip_addr)
    key = "#{ip_addr}:#{Time.now.hour}"
    MEMCACHE.fetch(key, 1.hour, true) {0}
    MEMCACHE.incr(key).to_i > CurrentUser.user.api_hourly_limit
  end
  
  module_function :throttled?
end
