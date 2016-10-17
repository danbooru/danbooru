module ApiLimiter
  def idempotent?(method)
    case method
    when "POST", "PUT", "DELETE"
      false

    else
      true
    end
  end

  def throttled?(ip_addr, http_method = "GET")
    idempotent = idempotent?(http_method)
    key = "api/#{ip_addr}/#{Time.now.hour}/#{idempotent}"
    MEMCACHE.fetch(key, 1.hour, :raw => true) {0}
    MEMCACHE.incr(key).to_i > CurrentUser.user.api_hourly_limit(idempotent)
  end

  def remaining_hourly_limit(ip_addr, idempotent = true)
    key = "api/#{ip_addr}/#{Time.now.hour}/#{idempotent}"
    requests = MEMCACHE.fetch(key, 1.hour, :raw => true) {0}.to_i
    CurrentUser.user.api_hourly_limit - requests
  end
  
  module_function :throttled?, :idempotent?, :remaining_hourly_limit
end
