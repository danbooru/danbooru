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
          assert_equal(true, @user.user_events.password_reset.exists?)
          assert_enqueued_email_with UserMailer.with_request(request), :password_reset, args: [@user], queue: "default"
          perform_enqueued_jobs
          assert_performed_jobs(1, only: MailDeliveryJob)
        end

        should "send a password reset email if the account exists and has an unverified email address" do
          @user = create(:user, email_address: create(:email_address, address: "Foo.Bar+nospam@Googlemail.com", is_verified: false))
          post password_reset_path, params: { user: { name: "foobar@gmail.com" } }

          assert_redirected_to password_reset_path
          assert_equal(true, @user.user_events.password_reset.exists?)
          assert_enqueued_email_with UserMailer.with_request(request), :password_reset, args: [@user], queue: "default"
          perform_enqueued_jobs
          assert_performed_jobs(1, only: MailDeliveryJob)
        end

        should "not send an email if an account with the email doesn't exist" do
          post password_reset_path, params: { user: { name: "foobar@gmail.com" } }

          assert_redirected_to password_reset_path
          assert_no_enqueued_emails
          assert_equal(false, UserEvent.password_reset.exists?)
        end
      end

      context "for an account identified by a username" do
        should "send a password reset email if the account exists and has a verified email address" do
          @user = create(:user, email_address: create(:email_address, address: "Foo.Bar+nospam@Googlemail.com", is_verified: true))
          post password_reset_path, params: { user: { name: @user.name } }

          assert_redirected_to password_reset_path
          assert_equal(true, @user.user_events.password_reset.exists?)
          assert_enqueued_email_with UserMailer.with_request(request), :password_reset, args: [@user], queue: "default"
          perform_enqueued_jobs
          assert_performed_jobs(1, only: MailDeliveryJob)
        end

        should "send a password reset email if the account exists and has an unverified email address" do
          @user = create(:user, email_address: create(:email_address, address: "Foo.Bar+nospam@Googlemail.com", is_verified: false))
          post password_reset_path, params: { user: { name: @user.name } }

          assert_redirected_to password_reset_path
          assert_equal(true, @user.user_events.password_reset.exists?)
          assert_enqueued_email_with UserMailer.with_request(request), :password_reset, args: [@user], queue: "default"
          perform_enqueued_jobs
          assert_performed_jobs(1, only: MailDeliveryJob)
        end

        should "not send an email if the user doesn't have an email address" do
          @user = create(:user)
          post password_reset_path, params: { user: { name: @user.name } }

          assert_redirected_to password_reset_path
          assert_no_enqueued_emails
          assert_equal(true, @user.user_events.password_reset.exists?)
        end

        should "not send an email if the user does not exist" do
          post password_reset_path, params: { user: { name: "qoi23oti" } }

          assert_redirected_to password_reset_path
          assert_no_enqueued_emails
          assert_equal(false, UserEvent.password_reset.exists?)
        end
      end
    end
  end
end
