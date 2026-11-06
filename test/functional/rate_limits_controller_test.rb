require "test_helper"

class RateLimitsControllerTest < ActionDispatch::IntegrationTest
  context "The rate limits controller" do
    context "index action" do
      setup do
        @user = create(:user)
        create(:rate_limit, key: @user.cache_key)
      end

      should "show all rate limits to the owner" do
        get_auth rate_limits_path, create(:owner_user)

        assert_response :success
        assert_select "tbody tr", count: 4 # 1 for @user, plus the 3 login creates: 1 for the IP, 1 for the session ID, and 1 for the user ID (from reauthenticating)
      end

      should "show the user their own rate limits" do
        get_auth rate_limits_path, @user

        assert_response :success
        assert_select "tbody tr", count: 2 # @user's rate limit, plus the one from reauthenticating at login
      end

      should "not show users rate limits belonging to other users" do
        get_auth rate_limits_path, create(:user)

        assert_response :success
        assert_select "tbody tr", count: 1 # only their own rate limit from reauthenticating at login
      end
    end
  end
end
