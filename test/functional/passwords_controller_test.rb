require 'test_helper'

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  context "The passwords controller" do
    setup do
      @user = create(:user, password: "12345")
    end

    context "edit action" do
      should "work" do
        get_auth edit_user_password_path(@user), @user
        assert_response :success
      end
    end

    context "update action" do
      should "work" do
        put_auth user_password_path(@user), @user, params: { user: { old_password: "12345", password: "abcde", password_confirmation: "abcde" } }

        assert_redirected_to user_path(@user)
        assert_equal(nil, User.authenticate(@user.name, "12345"))
        assert_equal(@user, User.authenticate(@user.name, "abcde"))
      end
    end
  end
end
