require 'test_helper'

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  context "The passwords resets controller" do
    context "show action" do
      should "work" do
        get password_reset_path
        assert_response :success
      end
    end

    context "create action" do
      should "should send a password reset email if the user has a verified email address" do
        @user = create(:user, email_address: build(:email_address))
        post password_reset_path, params: { user: { name: @user.name } }

        assert_redirected_to new_session_path
        assert_enqueued_email_with UserMailer, :password_reset, args: [@user]
      end

      should "should fail if the user doesn't have a verified email address" do
        @user = create(:user)
        post password_reset_path, params: { user: { name: @user.name } }

        assert_redirected_to @user
        assert_no_enqueued_emails
      end

      should "fail if the user does not exist" do
        post password_reset_path, params: { user: { name: "qoi23oti" } }

        assert_redirected_to password_reset_path
      end
    end
  end
end
