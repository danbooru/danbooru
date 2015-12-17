require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  context "the sessions controller" do
    setup do
      @user = FactoryGirl.create(:user)
    end

    context "new action" do
      should "render" do
        get :new
        assert_response :success
      end
    end

    context "create action" do
      should "create a new session" do
        post :create, {:name => @user.name, :password => "password"}
        assert_redirected_to posts_path
        @user.reload
        assert_equal(@user.id, session[:user_id])
        assert_not_nil(@user.last_ip_addr)
      end
    end

    context "destroy action" do
      setup do
        CurrentUser.user = @user
        CurrentUser.ip_addr = "127.0.0.1"
      end

      teardown do
        CurrentUser.user = nil
        CurrentUser.ip_addr = nil
      end

      should "clear the session" do
        post :destroy, {}, {:user_id => @user.id}
        assert_redirected_to posts_path
        assert_nil(session[:user_id])
      end
    end
  end
end
