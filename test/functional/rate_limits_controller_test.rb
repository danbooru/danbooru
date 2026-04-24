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
        assert_select "tbody tr", count: 3 # the login action creates 3 rate limits: 1 for the IP, 1 for the user ID, and 1 for the session ID
      end

      should "show the user their own rate limits" do
        get_auth rate_limits_path, @user

        assert_response :success
        assert_select "tbody tr", count: 1
      end

      should "not show users rate limits belonging to other users" do
        get_auth rate_limits_path, create(:user)

        assert_response :success
        assert_select "tbody tr", count: 0
      end

      should "render humanized action names and status pills" do
        create(:rate_limit, action: "posts:create", key: @user.cache_key, points: 40)
        create(:rate_limit, action: "notes:write:post-1", key: @user.cache_key, points: -1, limited: true)

        get_auth rate_limits_path, @user

        assert_response :success
        assert_select "td", text: /Posts: create/
        assert_select "td", text: /Notes: write/
        assert_select ".chip-green", text: "OK"
        assert_select ".chip-red", text: "Limited"
      end
    end
  end
end
