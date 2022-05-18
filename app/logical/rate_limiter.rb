# frozen_string_literal: true

# A RateLimiter handles HTTP rate limits for controller actions. Rate limits are
# based on the user, the user's IP, and the controller action.
#
# A RateLimiter is backed by RateLimit objects stored in the database, which
# track the rate limits with a token bucket algorithm. A RateLimiter object
# usually has two RateLimits, one for the current user and one for their IP.
#
# @see RateLimit
# @see ApplicationController#check_rate_limit
# @see https://en.wikipedia.org/wiki/Token_bucket
class RateLimiter
  class RateLimitError < StandardError; end

  attr_reader :action, :keys, :cost, :rate, :burst, :enabled
  alias_method :enabled?, :enabled

  def initialize(action, keys = ["*"], cost: 1, rate: 1, burst: 1, enabled: Danbooru.config.rate_limits_enabled?.to_s.truthy?)
    @action = action
    @keys = keys
    @cost = cost
    @rate = rate
    @burst = burst
    @enabled = enabled
  end

  # Create a RateLimiter object for the given action. A RateLimiter usually has
  # two RateLimits, one for the user and one for their IP. The action is
  # limited if either the user or their IP are limited.
  #
  # @param action [String] An identifier for the action being rate limited.
  # @param rate [Float] The rate limit, in actions per second.
  # @param burst [Float] The burst limit (the maximum number of actions you can
  #   perform in one burst before being rate limited).
  # @param user [User] The current user.
  # @param ip_addr [String] The user's IP address.
  # @return [RateLimit] The rate limit for the action.
  def self.build(action:, rate:, burst:, user:, ip_addr:)
    keys = [(user.cache_key unless user.is_anonymous?), "ip/#{ip_addr.to_s}"].compact
    RateLimiter.new(action, keys, rate: rate, burst: burst)
  end

  # @raise [RateLimitError] if the action is limited
  def limit!
    raise RateLimitError if limited?
  end

  # @return [Boolean] true if the action is limited for the user or their IP
  def limited?
    enabled? && rate_limits.any?(&:limited?)
  end

  def as_json(options = {})
    hash = rate_limits.map { |limit| [limit.key, limit.points] }.to_h
    super(options).except("keys", "rate_limits").merge(limits: hash)
  end

  # Update or create the rate limits associated with this action.
  def rate_limits
    @rate_limits ||= RateLimit.create_or_update!(action: action, keys: keys, cost: cost, rate: rate, burst: burst)
  end
end
