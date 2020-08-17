require "test_helper"

class EmailsControllerTest < ActionDispatch::IntegrationTest
  include UsersHelper

  context "in all cases" do
    setup do
      @user = create(:user, email_address: build(:email_address, { address: "bob@ogres.net", is_verified: false }))
      @other_user = create(:user, email_address: build(:email_address, { address: "alice@ogres.net", is_verified: false }))
      @restricted_user = create(:user, requires_verification: true, is_verified: false)
    end

    context "#show" do
      should "render" do
        get_auth user_email_path(@user), @user, as: :json
        assert_response :success
      end

      should "not show email addresses to other users" do
        get_auth user_email_path(@user), @other_user, as: :json
        assert_response 403
      end
    end

    context "#edit" do
      context "for a user with an email address" do
        should "render" do
          get_auth edit_user_email_path(@user), @user
          assert_equal true, @user.email_address.present?
          assert_response :success
        end
      end

      context "for a user without an email address" do
        should "render" do
          @user.email_address.destroy!
          @user.reload_email_address
          get_auth edit_user_email_path(@user), @user

          assert_equal false, @user.email_address.present?
          assert_response :success
          assert_select "h1", text: "Add Email"
        end
      end

      context "for a restricted user" do
        should "render" do
          get_auth edit_user_email_path(@restricted_user), @restricted_user
          assert_response :success
        end
      end

      context "for an unauthorized user" do
        should "render" do
          get_auth edit_user_email_path(@user), @other_user
          assert_response 403
        end
      end
    end

    context "#update" do
      context "with the correct password" do
        should "update an existing address" do
          assert_difference("EmailAddress.count", 0) do
            put_auth user_email_path(@user), @user, params: { user: { password: "password", email: "abc@ogres.net" }}
          end

          assert_redirected_to(settings_path)
          assert_equal("abc@ogres.net", @user.reload.email_address.address)
          assert_equal(false, @user.email_address.is_verified)
          assert_enqueued_email_with UserMailer, :email_change_confirmation, args: [@user]
        end

        should "create a new address" do
          @user.email_address.destroy

          assert_difference("EmailAddress.count", 1) do
            put_auth user_email_path(@user), @user, params: { user: { password: "password", email: "abc@ogres.net" }}
          end

          assert_redirected_to(settings_path)
          assert_equal("abc@ogres.net", @user.reload.email_address.address)
          assert_equal(false, @user.reload.email_address.is_verified)
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
          get email_verification_url(@user)

          assert_redirected_to @user
          assert_equal(true, @user.reload.email_address.is_verified)
        end
      end

      context "with an incorrect verification key" do
        should "not mark the email address as verified" do
          get verify_user_email_path(@user, email_verification_key: @other_user.email_address.verification_key)

          assert_response 403
          assert_equal(false, @user.reload.email_address.is_verified)
        end
      end

      context "with a nondisposable email address" do
        should "mark the user as verified" do
          Danbooru.config.stubs(:email_domain_verification_list).returns(["gmail.com"])
          @user.email_address.update!(address: "test@gmail.com")
          get email_verification_url(@user)

          assert_redirected_to @user
          assert_equal(true, @user.reload.email_address.is_verified)
          assert_equal(true, @user.is_verified)
        end
      end

      context "with a disposable email address" do
        should "not mark the user as verified" do
          Danbooru.config.stubs(:email_domain_verification_list).returns(["gmail.com"])
          @user.email_address.update!(address: "test@mailinator.com")
          get email_verification_url(@user)

          assert_redirected_to @user
          assert_equal(true, @user.reload.email_address.is_verified)
          assert_equal(false, @user.is_verified)
        end
      end

      context "for a user without an email address" do
        should "redirect to the add email page" do
          @user.email_address.destroy!
          get_auth verify_user_email_path(@user), @user
          assert_redirected_to edit_user_email_path(@user)
        end
      end

      context "for a user with an unverified email address" do
        should "show the resend confirmation email page" do
          get_auth verify_user_email_path(@user), @user
          assert_response :success
        end
      end

      context "for an unauthorized user" do
        should "fail" do
          get_auth verify_user_email_path(@user), @other_user
          assert_response 403
        end
      end
    end

    context "#send_confirmation" do
      context "for an authorized user" do
        should "resend the confirmation email" do
          post_auth send_confirmation_user_email_path(@user), @user

          assert_redirected_to @user
          assert_enqueued_emails 1
        end
      end

      context "for an unauthorized user" do
        should "fail" do
          post_auth send_confirmation_user_email_path(@user), @other_user

          assert_response 403
          assert_no_enqueued_emails
        end
      end
    end
  end
end
