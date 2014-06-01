module ApiLimiter
  def throttled?(ip_addr)
    key = "#{ip_addr}:#{Time.now.hour}"
    MEMCACHE.fetch(key, 1.hour, :raw => true) {0}
    MEMCACHE.incr(key).to_i > CurrentUser.user.api_hourly_limit
  end

  def remaining_hourly_limit(ip_addr)
    key = "#{ip_addr}:#{Time.now.hour}"
    requests = MEMCACHE.fetch(key, 1.hour, :raw => true) {0}.to_i
    CurrentUser.user.api_hourly_limit - requests
  end
  
  module_function :throttled?, :remaining_hourly_limit
end
