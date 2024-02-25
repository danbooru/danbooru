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
      context "for an account identified by an email address" do
        should "send a password reset email if the account exists and has a verified email address" do
          @user = create(:user, email_address: create(:email_address, address: "Foo.Bar+nospam@Googlemail.com", is_verified: true))
          post password_reset_path, params: { user: { name: "foobar@gmail.com" } }

          assert_redirected_to password_reset_path
          assert_equal(true, @user.user_events.password_reset_request.exists?)
          assert_enqueued_email_with UserMailer.with_request(request), :password_reset, args: [@user], queue: "default"
          perform_enqueued_jobs
          assert_performed_jobs(1, only: MailDeliveryJob)
        end

        should "send a password reset email if the account exists and has an unverified email address" do
          @user = create(:user, email_address: create(:email_address, address: "Foo.Bar+nospam@Googlemail.com", is_verified: false))
          post password_reset_path, params: { user: { name: "foobar@gmail.com" } }

          assert_redirected_to password_reset_path
          assert_equal(true, @user.user_events.password_reset_request.exists?)
          assert_enqueued_email_with UserMailer.with_request(request), :password_reset, args: [@user], queue: "default"
          perform_enqueued_jobs
          assert_performed_jobs(1, only: MailDeliveryJob)
        end

        should "not send an email if an account with the email doesn't exist" do
          post password_reset_path, params: { user: { name: "foobar@gmail.com" } }

          assert_redirected_to password_reset_path
          assert_no_enqueued_emails
          assert_equal(false, UserEvent.password_reset_request.exists?)
        end
      end

      context "for an account identified by a username" do
        should "send a password reset email if the account exists and has a verified email address" do
          @user = create(:user, email_address: create(:email_address, address: "Foo.Bar+nospam@Googlemail.com", is_verified: true))
          post password_reset_path, params: { user: { name: @user.name } }

          assert_redirected_to password_reset_path
          assert_equal(true, @user.user_events.password_reset_request.exists?)
          assert_enqueued_email_with UserMailer.with_request(request), :password_reset, args: [@user], queue: "default"
          perform_enqueued_jobs
          assert_performed_jobs(1, only: MailDeliveryJob)
        end

        should "send a password reset email if the account exists and has an unverified email address" do
          @user = create(:user, email_address: create(:email_address, address: "Foo.Bar+nospam@Googlemail.com", is_verified: false))
          post password_reset_path, params: { user: { name: @user.name } }

          assert_redirected_to password_reset_path
          assert_equal(true, @user.user_events.password_reset_request.exists?)
          assert_enqueued_email_with UserMailer.with_request(request), :password_reset, args: [@user], queue: "default"
          perform_enqueued_jobs
          assert_performed_jobs(1, only: MailDeliveryJob)
        end

        should "not send an email if the user doesn't have an email address" do
          @user = create(:user)
          post password_reset_path, params: { user: { name: @user.name } }

          assert_redirected_to password_reset_path
          assert_no_enqueued_emails
          assert_equal(true, @user.user_events.password_reset_request.exists?)
        end

        should "not send an email if the user does not exist" do
          post password_reset_path, params: { user: { name: "qoi23oti" } }

          assert_redirected_to password_reset_path
          assert_no_enqueued_emails
          assert_equal(false, UserEvent.password_reset_request.exists?)
        end
      end
    end

    context "edit action" do
      should "show the edit password form when given a valid signed_id" do
        @user = create(:user)
        get edit_password_reset_path(user: { signed_id: @user.signed_id(purpose: :password_reset) })

        assert_response :success
      end

      should "show the edit password form when a user with 2FA gives a valid signed_id" do
        @user = create(:user_with_2fa)
        get edit_password_reset_path(user: { signed_id: @user.signed_id(purpose: :password_reset) })

        assert_response :success
      end

      should "not show the edit password form when not given a signed_id" do
        @user = create(:user)
        get edit_password_reset_path

        assert_redirected_to password_reset_path
      end

      should "not show the edit password form when given an expired signed_id" do
        @user = create(:user)
        get edit_password_reset_path(user: { signed_id: @user.signed_id(purpose: :password_reset, expires_at: 1.minute.ago) })

        assert_redirected_to password_reset_path
      end

      should "not show the edit password form when given an invalid signed_id" do
        @user = create(:user)
        get edit_password_reset_path(user: { signed_id: "invalid" })

        assert_redirected_to password_reset_path
      end

      should "not show the edit password form when the user is already logged in as another user" do
        @user = create(:user)
        get_auth edit_password_reset_path(user: { signed_id: @user.signed_id(purpose: :password_reset) }), create(:user)

        assert_redirected_to profile_path
      end
    end

    context "update action" do
      context "for a user without 2FA enabled" do
        setup do
          @user = create(:user, password: "old_password")
        end

        should "change the user's password when given a valid new password" do
          put password_reset_path(user: { signed_id: @user.signed_id(purpose: :password_reset), password: "password", password_confirmation: "password" })

          assert_redirected_to @user
          assert_equal(@user.id, session[:user_id])
          assert_equal(true, @user.reload.authenticate_password("password").present?)
          assert_equal(true, @user.user_events.login.exists?)
          assert_equal(true, @user.user_events.password_reset.exists?)
        end

        should "not change the user's password when the passwords don't match" do
          put password_reset_path(user: { signed_id: @user.signed_id(purpose: :password_reset), password: "password", password_confirmation: "wrong" })

          assert_response :success
          assert_nil(session[:user_id])
          assert_equal(false, @user.authenticate_password("password").present?)
          assert_equal(false, @user.user_events.login.exists?)
          assert_equal(false, @user.user_events.password_reset.exists?)
        end

        should "not change the user's password when not given a signed_id" do
          put password_reset_path(user: { password: "password", password_confirmation: "password" })

          assert_redirected_to password_reset_path
          assert_nil(session[:user_id])
          assert_equal(false, @user.authenticate_password("password").present?)
          assert_equal(false, @user.user_events.login.exists?)
          assert_equal(false, @user.user_events.password_reset.exists?)
        end

        should "not change the user's password when given an expired signed_id" do
          put password_reset_path(user: { signed_id: @user.signed_id(expires_at: 1.minute.ago, purpose: :password_reset), password: "password", password_confirmation: "password" })

          assert_redirected_to password_reset_path
          assert_nil(session[:user_id])
          assert_equal(false, @user.authenticate_password("password").present?)
          assert_equal(false, @user.user_events.login.exists?)
          assert_equal(false, @user.user_events.password_reset.exists?)
        end

        should "not change the user's password when given an invalid signed_id" do
          put password_reset_path(user: { signed_id: "invalid", password: "password", password_confirmation: "password" })

          assert_redirected_to password_reset_path
          assert_nil(session[:user_id])
          assert_equal(false, @user.authenticate_password("password").present?)
          assert_equal(false, @user.user_events.login.exists?)
          assert_equal(false, @user.user_events.password_reset.exists?)
        end

        should "not change the user's password when the user is already logged in as another user" do
          @user2 = create(:user)
          put_auth password_reset_path(user: { signed_id: @user.signed_id(purpose: :password_reset), password: "password", password_confirmation: "password" }), @user2

          assert_redirected_to profile_path
          assert_equal(@user2.id, session[:user_id])
          assert_equal(false, @user.authenticate_password("password").present?)
          assert_equal(false, @user.user_events.login.exists?)
          assert_equal(false, @user.user_events.password_reset.exists?)
        end
      end

      context "for a user with 2FA enabled" do
        setup do
          @user = create(:user_with_2fa, password: "old_password")
        end

        should "change the user's password when the verification code is correct" do
          put password_reset_path(user: { signed_id: @user.signed_id(purpose: :password_reset), password: "password", password_confirmation: "password", verification_code: @user.totp.code })

          assert_redirected_to @user
          assert_equal(@user.id, session[:user_id])
          assert_equal(true, @user.reload.authenticate_password("password").present?)
          assert_equal(true, @user.user_events.login.exists?)
          assert_equal(true, @user.user_events.password_reset.exists?)
        end

        should "change the user's password when the backup code is correct" do
          backup_code = @user.backup_codes.first
          put password_reset_path(user: { signed_id: @user.signed_id(purpose: :password_reset), password: "password", password_confirmation: "password", verification_code: backup_code })

          assert_redirected_to @user
          assert_equal(@user.id, session[:user_id])
          assert_equal(true, @user.reload.authenticate_password("password").present?)
          assert_equal(true, @user.user_events.login.exists?)
          assert_equal(true, @user.user_events.password_reset.exists?)
          assert_equal(false, @user.backup_codes.include?(backup_code))
        end

        should "not change the user's password when the verification code is incorrect" do
          put password_reset_path(user: { signed_id: @user.signed_id(purpose: :password_reset), password: "password", password_confirmation: "password", verification_code: "wrong" })

          assert_response :success
          assert_nil(session[:user_id])
          assert_equal(false, @user.reload.authenticate_password("password").present?)
          assert_equal(false, @user.user_events.login.exists?)
          assert_equal(false, @user.user_events.password_reset.exists?)
        end

        should "not spend a backup code when the new password is invalid" do
          backup_code = @user.backup_codes.first
          put password_reset_path(user: { signed_id: @user.signed_id(purpose: :password_reset), password: "password", password_confirmation: "12345", verification_code: backup_code })

          assert_response :success
          assert_nil(session[:user_id])
          assert_equal(false, @user.reload.authenticate_password("password").present?)
          assert_equal(false, @user.user_events.login.exists?)
          assert_equal(false, @user.user_events.password_reset.exists?)
          assert_equal(true, @user.backup_codes.include?(backup_code))
        end
      end

      context "for a deleted user" do
        should "not change the user's password" do
          @user = create(:user, is_deleted: true, password: "old_password")
          put password_reset_path(user: { signed_id: @user.signed_id(purpose: :password_reset), password: "password", password_confirmation: "password" })

          assert_response :success
          assert_nil(session[:user_id])
          assert_equal(false, @user.reload.authenticate_password("password").present?)
          assert_equal(false, @user.user_events.login.exists?)
          assert_equal(false, @user.user_events.password_reset.exists?)
        end
      end
    end
  end
end
