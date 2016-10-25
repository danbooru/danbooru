require 'test_helper'

class ApiLimiterTest < ActiveSupport::TestCase
  context "for reads" do
    context "for an anonymous user" do
      setup do
        @count = 5
        @user = AnonymousUser.new
        CurrentUser.user = @user
      end

      should "respect api limits" do
        @user.expects(:api_hourly_limit).with(true).times(@count + 1).returns(@count)

        @count.times do
          assert_equal(false, ApiLimiter.throttled?(CurrentUser.id || "127.0.0.1", "GET"))
        end

        assert_equal(true, ApiLimiter.throttled?(CurrentUser.id || "127.0.0.1", "GET"))
      end
    end
  end

  context "for writes" do
    context "for an anonymous user" do
      setup do
        @count = 5
        @user = AnonymousUser.new
        CurrentUser.user = @user
      end

      should "respect api limits" do
        @user.expects(:api_hourly_limit).with(false).times(@count + 1).returns(@count)

        @count.times do
          assert_equal(false, ApiLimiter.throttled?(CurrentUser.id || "127.0.0.1", "POST"))
        end

        assert_equal(true, ApiLimiter.throttled?(CurrentUser.id || "127.0.0.1", "POST"))
      end
    end
  end
end
