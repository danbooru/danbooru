require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  context "the sessions controller" do
    setup do
      @user = create(:user, password: "password")
    end

    context "new action" do
      should "render" do
        get new_session_path
        assert_response :success
      end
    end

    context "create action" do
      should "log the user in when given the correct password" do
        post session_path, params: { name: @user.name, password: "password" }

        assert_redirected_to posts_path
        assert_equal(@user.id, session[:user_id])
        assert_not_nil(@user.reload.last_ip_addr)
      end

      should "not log the user in when given an incorrect password" do
        post session_path, params: { name: @user.name, password: "wrong"}

        assert_response 401
        assert_nil(nil, session[:user_id])
      end

      should "redirect the user when given an url param" do
        post session_path, params: { name: @user.name, password: "password", url: tags_path }
        assert_redirected_to tags_path
      end

      should "not allow IP banned users to login" do
        @ip_ban = create(:ip_ban, category: :full, ip_addr: "1.2.3.4")
        post session_path, params: { name: @user.name, password: "password" }, headers: { REMOTE_ADDR: "1.2.3.4" }

        assert_response 403
        assert_not_equal(@user.id, session[:user_id])
        assert_equal(1, @ip_ban.reload.hit_count)
        assert(@ip_ban.last_hit_at > 1.minute.ago)
      end

      should "allow partial IP banned users to login" do
        @ip_ban = create(:ip_ban, category: :partial, ip_addr: "1.2.3.4")
        post session_path, params: { name: @user.name, password: "password" }, headers: { REMOTE_ADDR: "1.2.3.4" }

        assert_redirected_to posts_path
        assert_equal(@user.id, session[:user_id])
        assert_equal(0, @ip_ban.reload.hit_count)
        assert_nil(@ip_ban.last_hit_at)
      end

      should "ignore deleted IP bans when logging in" do
        @ip_ban = create(:ip_ban, is_deleted: true, category: :full, ip_addr: "1.2.3.4")
        post session_path, params: { name: @user.name, password: "password" }, headers: { REMOTE_ADDR: "1.2.3.4" }

        assert_redirected_to posts_path
        assert_equal(@user.id, session[:user_id])
        assert_equal(0, @ip_ban.reload.hit_count)
        assert_nil(@ip_ban.last_hit_at)
      end
    end

    context "destroy action" do
      should "clear the session" do
        delete_auth session_path, @user
        assert_redirected_to posts_path
        assert_nil(session[:user_id])
      end
    end

    context "sign_out action" do
      should "clear the session" do
        get_auth sign_out_session_path, @user
        assert_redirected_to posts_path
        assert_nil(session[:user_id])
      end
    end
  end
end
