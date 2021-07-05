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

  attr_reader :action, :keys, :cost, :rate, :burst

  def initialize(action, keys = ["*"], cost: 1, rate: 1, burst: 1)
    @action = action
    @keys = keys
    @cost = cost
    @rate = rate
    @burst = burst
  end

  # Create a RateLimiter object for the current controller, action, user, and
  # IP. A RateLimiter usually has two RateLimits, one for the user and one for
  # their IP. The action is limited if either the user or their IP are limited.
  #
  # @param controller_name [String] the current controller
  # @param action_name [String] the current controller action
  # @param user [User] the current user
  # @param ip_addr [String] the user's IP address
  # @return [RateLimit] the rate limit for the action
  def self.for_action(controller_name, action_name, user, ip_addr)
    action = "#{controller_name}:#{action_name}"
    keys = [(user.cache_key unless user.is_anonymous?), "ip/#{ip_addr.to_s}"].compact

    case action
    when "users:create"
      rate, burst = 1.0 / 5.minutes, 10
    when "emails:update", "sessions:create", "moderation_reports:create"
      rate, burst = 1.0 / 1.minute, 10
    when "dmails:create", "comments:create", "forum_posts:create", "forum_topics:create"
      rate, burst = 1.0 / 1.minute, 50
    when "comment_votes:create", "comment_votes:destroy", "post_votes:create",
         "post_votes:destroy", "favorites:create", "favorites:destroy", "post_disapprovals:create"
      rate, burst = 1.0 / 1.second, 200
    else
      rate = user.api_regen_multiplier
      burst = 200
    end

    RateLimiter.new(action, keys, rate: rate, burst: burst)
  end

  # @raise [RateLimitError] if the action is limited
  def limit!
    raise RateLimitError if limited?
  end

  # @return [Boolean] true if the action is limited for the user or their IP
  def limited?
    rate_limits.any?(&:limited?)
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
