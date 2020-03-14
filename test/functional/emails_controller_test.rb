require "test_helper"

class EmailsControllerTest < ActionDispatch::IntegrationTest
  context "in all cases" do
    setup do
      @user = create(:user, email_address: build(:email_address, { address: "bob@ogres.net", is_verified: false }))
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
          assert_enqueued_email_with UserMailer, :email_change_confirmation, args: [@user]
        end
      end

      context "with the incorrect password" do
        should "not work" do
          put_auth user_email_path(@user), @user, params: { user: { password: "passwordx", email: "abc@ogres.net" }}

          assert_response :success
          assert_equal("bob@ogres.net", @user.reload.email_address.address)
          assert_no_emails
        end
      end
    end

    context "#verify" do
      context "with a correct verification key" do
        should "mark the email address as verified" do
          assert_equal(false, @user.reload.email_address.is_verified)
          get_auth verify_user_email_path(@user), @user, params: { email_verification_key: Danbooru::MessageVerifier.new(:email_verification_key).generate(@user.email_address.id) }

          assert_redirected_to @user
          assert_equal(true, @user.reload.email_address.is_verified)
        end
      end
    end
  end
end
