module ApiLimiter
  def self.idempotent?(method)
    case method
    when "POST", "PUT", "DELETE", "PATCH"
      false

    else
      true
    end
  end

  def self.ip_key(idempotent)
    "api/#{CurrentUser.ip_addr}/#{Time.now.hour}/#{idempotent}"
  end

  def self.user_key(idempotent)
    "api/#{CurrentUser.id}/#{Time.now.hour}/#{idempotent}"
  end

  def throttled?(http_method = "GET")
    idempotent = ApiLimiter.idempotent?(http_method)

    MEMCACHE.incr(self.ip_key(idempotent), 1, 1.hour, 0)
    MEMCACHE.incr(self.user_key(idempotent), 1, 1.hour, 0)

    self.remaining_hourly_limit(idempotent) <= 0
  end

  def remaining_hourly_limit(idempotent = true)
    requests_by_ip = MEMCACHE.fetch(self.ip_key(idempotent), 1.hour, :raw => true) {0}.to_i
    requests_by_user = MEMCACHE.fetch(self.user_key(idempotent), 1.hour, :raw => true) {0}.to_i
    requests = CurrentUser.is_anonymous? ? requests_by_ip : [requests_by_ip, requests_by_user].max

    CurrentUser.user.api_hourly_limit(idempotent) - requests
  end

  def limits
    {
      "X-Api-Limit-Read" => CurrentUser.api_hourly_limit(true).to_s,
      "X-Api-Limit-Write" => CurrentUser.api_hourly_limit(false).to_s,
      "X-Api-Limit-Read-Remaining" => ApiLimiter.remaining_hourly_limit(true).to_s,
      "X-Api-Limit-Write-Remaining" => ApiLimiter.remaining_hourly_limit(false).to_s,
      "X-Api-Limit-Reset-At" => Time.now.end_of_hour.to_i.to_s,
      "X-Api-Limit-Reset-In" => (Time.now.end_of_hour - Time.now).to_i.to_s
    }
  end
  
  module_function :limits, :throttled?, :remaining_hourly_limit
end
