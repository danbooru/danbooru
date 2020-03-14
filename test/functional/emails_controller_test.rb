require "test_helper"

class EmailsControllerTest < ActionDispatch::IntegrationTest
  context "in all cases" do
    setup do
      @user = create(:user, email_address: build(:email_address, { address: "bob@ogres.net" }))
    end

    context "#edit" do
      should "render" do
        get_auth edit_user_email_path(@user), @user
        assert_response :success
      end
    end

    context "#create" do
      context "with the correct password" do
        should "work" do
          put_auth user_email_path(@user), @user, params: { user: { password: "password", email: "abc@ogres.net" }}

          assert_redirected_to(settings_path)
          assert_equal("abc@ogres.net", @user.reload.email_address.address)
        end
      end

      context "with the incorrect password" do
        should "not work" do
          put_auth user_email_path(@user), @user, params: { user: { password: "passwordx", email: "abc@ogres.net" }}

          assert_response :success
          assert_equal("bob@ogres.net", @user.reload.email_address.address)
        end
      end
    end
  end
end
