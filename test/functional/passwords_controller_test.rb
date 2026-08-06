require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  context "The passwords controller" do
    setup do
      @user = create(:user, password: "secure-current-pass-123")
    end

    context "edit action" do
      should "work for a user viewing their own change password page" do
        get_auth edit_user_password_path(@user), @user
        assert_response :success
      end

      should "not work for a user viewing another users's change password page" do
        get_auth edit_user_password_path(@user), create(:owner_user)
        assert_response 403
      end

      should "redirect to the login page for a logged out user" do
        get edit_password_path
        assert_redirected_to login_path(url: edit_password_path)
      end
    end

    context "/.well-known/change-password" do
      should "redirect to the /password/edit page" do
        get "/.well-known/change-password"
        assert_redirected_to edit_password_path
      end
    end

    context "update action" do
      should "update the password when given a valid old password" do
        put_auth user_password_path(@user), @user, params: { user: { current_password: "secure-current-pass-123", password: "secure-new-pass-456", password_confirmation: "secure-new-pass-456" }}

        assert_redirected_to @user
        assert_equal(false, @user.reload.authenticate_password("secure-current-pass-123"))
        assert_equal(@user, @user.authenticate_password("secure-new-pass-456"))
        assert_equal(true, @user.user_events.password_change.exists?(login_session_id: @user.login_sessions.last.login_id))
      end

      should "not allow users to change the password of other users" do
        @owner = create(:owner_user)
        put_auth user_password_path(@user), @owner, params: { user: { current_password: "secure-current-pass-123", password: "secure-new-pass-456", password_confirmation: "secure-new-pass-456" }}

        assert_response 403
        assert_equal(@user, @user.reload.authenticate_password("secure-current-pass-123"))
        assert_equal(false, @user.authenticate_password("secure-new-pass-456"))
        assert_equal(false, @user.user_events.password_change.exists?)
      end

      should "not update the password when given an invalid old password" do
        put_auth user_password_path(@user), @user, params: { user: { current_password: "3qoirjqe", password: "secure-new-pass-456", password_confirmation: "secure-new-pass-456" }}

        assert_response :success
        assert_equal(@user, @user.reload.authenticate_password("secure-current-pass-123"))
        assert_equal(false, @user.authenticate_password("secure-new-pass-456"))
        assert_equal(false, @user.user_events.password_change.exists?)
        assert_equal(true, @user.user_events.failed_reauthenticate.exists?(login_session_id: @user.login_sessions.last.login_id))
      end

      should "not update the password when password confirmation fails for the new password" do
        put_auth user_password_path(@user), @user, params: { user: { current_password: "secure-current-pass-123", password: "secure-new-pass-456", password_confirmation: "qerogijqe" }}

        assert_response :success
        assert_equal(@user, @user.reload.authenticate_password("secure-current-pass-123"))
        assert_equal(false, @user.authenticate_password("secure-new-pass-456"))
        assert_equal(false, @user.user_events.password_change.exists?)
      end

      context "for a user with 2FA enabled" do
        setup do
          @user = create(:user_with_2fa, password: "secure-current-pass-123")
        end

        should "change the user's password when the verification code is correct" do
          put_auth user_password_path(@user), @user, params: { user: { current_password: "secure-current-pass-123", password: "secure-new-pass-456", password_confirmation: "secure-new-pass-456", verification_code: @user.totp.code }}

          assert_redirected_to @user
          assert_equal(true, @user.reload.authenticate_password("secure-new-pass-456").present?)
          assert_equal(true, @user.user_events.password_change.exists?(login_session_id: @user.login_sessions.last.login_id))
        end

        should "not change the user's password when given a backup code" do
          backup_code = @user.backup_codes.first
          put_auth user_password_path(@user), @user, params: { user: { current_password: "secure-current-pass-123", password: "secure-new-pass-456", password_confirmation: "secure-new-pass-456", verification_code: backup_code }}

          assert_response :success
          assert_equal(true, @user.reload.authenticate_password("secure-current-pass-123").present?)
          assert_equal(false, @user.user_events.password_change.exists?)
          assert_equal(true, @user.backup_codes.include?(backup_code))
          assert_equal(true, @user.user_events.totp_failed_reauthenticate.exists?(login_session_id: @user.login_sessions.last.login_id))
        end

        should "not change the user's password when the verification code is incorrect" do
          put_auth user_password_path(@user), @user, params: { user: { current_password: "secure-current-pass-123", password: "secure-new-pass-456", password_confirmation: "secure-new-pass-456", verification_code: "wrong" }}

          assert_response :success
          assert_equal(true, @user.reload.authenticate_password("secure-current-pass-123").present?)
          assert_equal(false, @user.user_events.password_change.exists?)
          assert_equal(true, @user.user_events.totp_failed_reauthenticate.exists?(login_session_id: @user.login_sessions.last.login_id))
        end
      end
    end
  end
end
