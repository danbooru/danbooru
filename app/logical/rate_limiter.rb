class RateLimiter
  class RateLimitError < StandardError; end

  attr_reader :action, :keys, :cost, :rate, :burst

  def initialize(action, keys = ["*"], cost: 1, rate: 1, burst: 1)
    @action = action
    @keys = keys
    @cost = cost
    @rate = rate
    @burst = burst
  end

  def limit!
    raise RateLimitError if limited?
  end

  def limited?
    rate_limits.any?(&:limited?)
  end

  def as_json(options = {})
    hash = rate_limits.map { |limit| [limit.key, limit.points] }.to_h
    super(options).except("keys", "rate_limits").merge(limits: hash)
  end

  def rate_limits
    @rate_limits ||= RateLimit.create_or_update!(action: action, keys: keys, cost: cost, rate: rate, burst: burst)
  end
end
