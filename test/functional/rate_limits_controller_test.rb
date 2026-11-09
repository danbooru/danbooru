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
        assert_select "tbody tr", count: 3 # 1 for @user, plus the 2 login creates: 1 for the IP and 1 for the session ID
      end

      should "show the user their own rate limits" do
        get_auth rate_limits_path, @user

        assert_response :success
        assert_select "tbody tr", count: 1 # @user's rate limit
      end

      should "not show users rate limits belonging to other users" do
        get_auth rate_limits_path, create(:user)

        assert_response :success
        assert_select "tbody tr", count: 0
      end
    end
  end
end
