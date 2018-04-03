require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  context "the sessions controller" do
    setup do
      @user = create(:user)
    end

    context "new action" do
      should "render" do
        get new_session_path
        assert_response :success
      end
    end

    context "create action" do
      should "create a new session" do
        post session_path, params: {:name => @user.name, :password => "password"}
        assert_redirected_to posts_path
        @user.reload
        assert_equal(@user.id, session[:user_id])
        assert_not_nil(@user.last_ip_addr)
      end
    end

    context "destroy action" do
      should "clear the session" do
        delete_auth session_path, @user
        assert_redirected_to posts_path
        assert_nil(session[:user_id])
      end
    end
  end
end
