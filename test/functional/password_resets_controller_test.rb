require 'test_helper'

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  context "The passwords resets controller" do
    setup do
      @user = create(:user)
    end

    context "show action" do
      should "work" do
        get password_reset_path
        assert_response :success
      end
    end

    context "create action" do
      should "work" do
        post password_reset_path, params: { user: { name: @user.name } }

        assert_redirected_to new_session_path
        assert_enqueued_email_with UserMailer, :password_reset, args: [@user]
      end
    end
  end
end
