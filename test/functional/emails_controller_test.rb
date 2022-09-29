require "test_helper"

class EmailsControllerTest < ActionDispatch::IntegrationTest
  include UsersHelper

  context "in all cases" do
    setup do
      @user = create(:user, email_address: build(:email_address, { address: "bob@ogres.net", is_verified: false }))
      @other_user = create(:user, email_address: build(:email_address, { address: "alice@ogres.net", is_verified: false }))
      @restricted_user = create(:restricted_user, email_address: build(:email_address, { is_verified: false }))
    end

    context "#index" do
      should "not let regular users see emails belonging to other users" do
        get_auth emails_path, @user
        assert_response 403
      end

      should "let mods see emails belonging to themselves and all users below mod level" do
        @mod1 = create(:moderator_user, email_address: build(:email_address))
        @mod2 = create(:moderator_user, email_address: build(:email_address))

        get_auth emails_path, @mod1

        assert_response :success
        assert_select "#email-address-#{@user.email_address.id}", count: 1
        assert_select "#email-address-#{@other_user.email_address.id}", count: 1
        assert_select "#email-address-#{@mod1.email_address.id}", count: 1
        assert_select "#email-address-#{@mod2.email_address.id}", count: 0
      end
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
      context "for a user who hasn't recently authenticated" do
        should "redirect to the confirm password page" do
          post session_path, params: { name: @user.name, password: @user.password }
          travel_to 2.hours.from_now do
            get edit_user_email_path(@user)
          end

          assert_redirected_to confirm_password_session_path(url: edit_user_email_path(@user.id))
        end
      end

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
          assert_select "h1", text: "Change Email"
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
      context "for a user who hasn't recently authenticated" do
        should "redirect to the confirm password page" do
          post session_path, params: { name: @user.name, password: @user.password }
          travel_to 2.hours.from_now do
            put user_email_path(@user), params: { user: { email: "abc@ogres.net" }}
          end

          assert_redirected_to confirm_password_session_path(url: user_email_path(@user.id))
          assert_equal("bob@ogres.net", @user.reload.email_address.address)
          assert_no_emails
          assert_equal(false, @user.user_events.email_change.exists?)
        end
      end

      context "with the correct password" do
        should "update an existing address" do
          assert_difference("EmailAddress.count", 0) do
            put_auth user_email_path(@user), @user, params: { user: { email: "abc@ogres.net" }}
          end

          assert_redirected_to(settings_path)
          assert_equal("abc@ogres.net", @user.reload.email_address.address)
          assert_equal(false, @user.email_address.is_verified)
          assert_equal(true, @user.user_events.email_change.exists?)

          perform_enqueued_jobs
          assert_performed_jobs(1, only: MailDeliveryJob)
          # assert_enqueued_email_with UserMailer.with_request(request), :email_change_confirmation, args: [@user], queue: "default"
        end

        should "create a new address" do
          @user.email_address.destroy

          assert_difference("EmailAddress.count", 1) do
            put_auth user_email_path(@user), @user, params: { user: { email: "abc@ogres.net" }}
          end

          assert_redirected_to(settings_path)
          assert_equal("abc@ogres.net", @user.reload.email_address.address)
          assert_equal(false, @user.reload.email_address.is_verified)
          assert_equal(true, @user.user_events.email_change.exists?)

          perform_enqueued_jobs
          assert_performed_jobs(1, only: MailDeliveryJob)
          # assert_enqueued_email_with UserMailer.with_request(request), :email_change_confirmation, args: [@user], queue: "default"
        end

        should "not allow banned users to change their email address" do
          create(:ban, user: @user, duration: 1.week)
          put_auth user_email_path(@user), @user, params: { user: { email: "abc@ogres.net" }}

          assert_response 403
          assert_equal("bob@ogres.net", @user.reload.email_address.address)
          assert_no_emails
          assert_equal(false, @user.user_events.email_change.exists?)
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

      context "for a Restricted user" do
        context "with a nondisposable email address" do
          should "unrestrict the user's account" do
            @restricted_user.email_address.update!(address: "test@gmail.com")

            get email_verification_url(@restricted_user)

            assert_redirected_to @restricted_user
            assert_equal(true, @restricted_user.reload.email_address.is_verified)
            assert_equal(false, @restricted_user.is_restricted?)
            assert_equal(true, @restricted_user.is_member?)
          end
        end

        context "with a disposable email address" do
          should "leave the user's account restricted" do
            @restricted_user.email_address.update!(address: "test@mailinator.com")

            get email_verification_url(@restricted_user)

            assert_redirected_to @restricted_user
            assert_equal(true, @restricted_user.reload.email_address.is_verified)
            assert_equal(true, @restricted_user.is_restricted?)
            assert_equal(false, @restricted_user.is_member?)
          end
        end
      end

      context "for a Gold user" do
        should "not change the user's level" do
          @user = create(:gold_user, email_address: build(:email_address, { address: "test@gmail.com", is_verified: false }))
          get email_verification_url(@user)

          assert_redirected_to @user
          assert_equal(true, @user.reload.email_address.is_verified)
          assert_equal(false, @user.is_restricted?)
          assert_equal(true, @user.is_gold?)
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
