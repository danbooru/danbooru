require 'test_helper'

class RateLimitTest < ActiveSupport::TestCase
  context "RateLimit: " do
    context "#limit! method" do
      should "create a new rate limit object if none exists, or update it if it already exists" do
        assert_difference("RateLimit.count", 1) do
          RateLimiter.new("write", ["users/1"]).limited?
        end

        assert_difference("RateLimit.count", 0) do
          RateLimiter.new("write", ["users/1"]).limited?
        end

        assert_difference("RateLimit.count", 1) do
          RateLimiter.new("write", ["users/1", "ip/1.2.3.4"]).limited?
        end

        assert_difference("RateLimit.count", 0) do
          RateLimiter.new("write", ["users/1", "ip/1.2.3.4"]).limited?
        end
      end

      should "include the cost of the first action when initializing the limit" do
        limiter = RateLimiter.new("write", ["users/1"], burst: 10, cost: 1)
        assert_equal(9, limiter.rate_limits.first.points)
      end

      should "be limited if the point count is negative" do
        freeze_time
        create(:rate_limit, action: "write", key: "users/1", points: -1)
        limiter = RateLimiter.new("write", ["users/1"], cost: 1)

        assert_equal(true, limiter.limited?)
        assert_equal(-1, limiter.rate_limits.first.points)
      end

      should "not be limited if the point count was positive before the action" do
        freeze_time
        create(:rate_limit, action: "write", key: "users/1", points: 0.01)
        limiter = RateLimiter.new("write", ["users/1"], cost: 1)

        assert_equal(false, limiter.limited?)
        assert_equal(-0.99, limiter.rate_limits.first.points)
      end

      should "refill the points at the correct rate" do
        freeze_time
        create(:rate_limit, action: "write", key: "users/1", points: -2)

        limiter = RateLimiter.new("write", ["users/1"], cost: 1, rate: 1, burst: 10)
        assert_equal(true, limiter.limited?)
        assert_equal(-2, limiter.rate_limits.first.points)

        travel 1.second
        limiter = RateLimiter.new("write", ["users/1"], cost: 1, rate: 1, burst: 10)
        assert_equal(true, limiter.limited?)
        assert_equal(-1, limiter.rate_limits.first.points)

        travel 5.second
        limiter = RateLimiter.new("write", ["users/1"], cost: 1, rate: 1, burst: 10)
        assert_equal(false, limiter.limited?)
        assert_equal(3, limiter.rate_limits.first.points)

        travel 60.second
        limiter = RateLimiter.new("write", ["users/1"], cost: 1, rate: 1, burst: 10)
        assert_equal(false, limiter.limited?)
        assert_equal(9, limiter.rate_limits.first.points)
      end
    end
  end
end
