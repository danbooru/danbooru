module ApiLimiter
  def self.idempotent?(method)
    case method
    when "POST", "PUT", "DELETE", "PATCH"
      false

    else
      true
    end
  end

  def throttled?(user_key, http_method = "GET")
    idempotent = ApiLimiter.idempotent?(http_method)
    key = "api/#{user_key}/#{Time.now.hour}/#{idempotent}"
    MEMCACHE.fetch(key, 1.hour, :raw => true) {0}
    MEMCACHE.incr(key).to_i > CurrentUser.user.api_hourly_limit(idempotent)
  end

  def remaining_hourly_limit(user_key, idempotent = true)
    key = "api/#{user_key}/#{Time.now.hour}/#{idempotent}"
    requests = MEMCACHE.fetch(key, 1.hour, :raw => true) {0}.to_i
    CurrentUser.user.api_hourly_limit(idempotent) - requests
  end
  
  module_function :throttled?, :remaining_hourly_limit
end
