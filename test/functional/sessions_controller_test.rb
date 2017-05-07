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

      should "unban user if user has expired ban" do
        CurrentUser.scoped(@user, "127.0.0.1") do
          @banned = FactoryGirl.create(:banned_user, ban_duration: 3)
        end

        travel_to(4.days.from_now) do
          post :create, {name: @banned.name, password: "password"}
          SessionLoader.new(session, {}, request, {}).load

          assert_equal(@banned.id, session[:user_id])
          assert_equal(true, @banned.ban_expired?)
          assert_equal(false, @banned.reload.is_banned)
        end
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
