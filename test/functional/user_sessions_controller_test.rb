require 'test_helper'

class UserSessionsControllerTest < ActionDispatch::IntegrationTest
  context "The user sessions controller" do
    context "index action" do
      should "render for an admin" do
        get_auth user_sessions_path, create(:admin_user)
        assert_response :success
      end

      should "fail for a normal user" do
        get_auth user_sessions_path, create(:user)
        assert_response 403
      end
    end
  end
end
