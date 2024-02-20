require "test_helper"

class TOTPControllerTest < ActionDispatch::IntegrationTest
  context "the TOTP controller" do
    context "edit action" do
      context "for a user with 2FA enabled" do
        should "work for the user" do
          @user = create(:user_with_2fa)
          get_auth edit_user_totp_path(user_id: @user.id), @user

          assert_response :success
        end

        should "not allow a user to view a different user's 2FA edit page" do
          @user = create(:user_with_2fa)
          get_auth edit_user_totp_path(user_id: @user.id), create(:user)

          assert_response 403
        end
      end

      context "for a user with 2FA disabled" do
        should "work for the user" do
          @user = create(:user)
          get_auth edit_user_totp_path(user_id: @user.id), @user

          assert_response :success
        end

        should "not allow a user to view a different user's 2FA edit page" do
          @user = create(:user)
          get_auth edit_user_totp_path(user_id: @user.id), create(:user)

          assert_response 403
        end
      end

      context "for a user who hasn't authenticated recently" do
        should "redirect to the confirm password page" do
          @user = create(:user)

          travel_to(1.day.ago) { login_as(@user) }
          get edit_user_totp_path(user_id: @user.id)

          assert_redirected_to confirm_password_session_path(url: edit_user_totp_path(user_id: @user.id))
        end
      end
    end

    context "update action" do
      context "when given the correct verification code" do
        should "allow a user to enable 2FA" do
          @user = create(:user)
          @totp = TOTP.new

          put_auth user_totp_path(user_id: @user), @user, params: { totp: { signed_secret: @totp.signed_secret, verification_code: @totp.code } }

          assert_redirected_to user_backup_codes_path(@user, url: settings_path)
          assert_equal(true, @user.reload.totp.present?)
          assert_equal(true, @user.totp_secret.present?)
          assert_equal(true, @user.backup_codes.present?)
          assert_equal(true, @user.user_events.totp_enable.exists?)
        end

        should "not allow a user to enable 2FA for another user" do
          @user = create(:user)
          @totp = TOTP.new

          put_auth user_totp_path(user_id: @user), create(:user), params: { totp: { signed_secret: @totp.signed_secret, verification_code: @totp.code } }

          assert_response 403
          assert_equal(false, @user.reload.totp.present?)
          assert_nil(@user.totp_secret)
          assert_nil(@user.backup_codes)
          assert_equal(false, @user.user_events.totp_enable.exists?)
        end

        should "redirect to the confirm password page if the user hasn't authenticated recently" do
          @user = create(:user)

          travel_to(1.day.ago) { login_as(@user) }
          put user_totp_path(user_id: @user.id)

          assert_redirected_to confirm_password_session_path(url: user_totp_path(user_id: @user.id))
          assert_equal(false, @user.reload.totp.present?)
          assert_nil(@user.totp_secret)
          assert_nil(@user.backup_codes)
          assert_equal(false, @user.user_events.totp_enable.exists?)
        end
      end

      context "when given an incorrect verification code" do
        should "not enable 2FA" do
          @user = create(:user)
          @totp = TOTP.new

          put_auth user_totp_path(user_id: @user), @user, params: { totp: { signed_secret: @totp.signed_secret, verification_code: "invalid" } }

          assert_response :success
          assert_equal(false, @user.reload.totp.present?)
          assert_nil(@user.totp_secret)
          assert_nil(@user.backup_codes)
          assert_equal(false, @user.user_events.totp_enable.exists?)
        end
      end
    end

    context "destroy action" do
      should "allow a user to disable 2FA" do
        @user = create(:user_with_2fa)

        delete_auth user_totp_path(user_id: @user), @user

        assert_redirected_to settings_path
        assert_equal(false, @user.reload.totp.present?)
        assert_nil(@user.totp_secret)
        assert_nil(@user.backup_codes)
        assert_equal(true, @user.user_events.totp_disable.exists?)
      end

      should "not allow a user to disable 2FA for another user" do
        @user = create(:user_with_2fa)

        delete_auth user_totp_path(user_id: @user), create(:user)

        assert_response 403
        assert_equal(true, @user.reload.totp.present?)
        assert_equal(true, @user.totp_secret.present?)
        assert_equal(true, @user.backup_codes.present?)
        assert_equal(false, @user.user_events.totp_disable.exists?)
      end

      should "redirect to the confirm password page if the user hasn't authenticated recently" do
        @user = create(:user_with_2fa)

        travel_to(1.day.ago) { login_as(@user) }
        delete user_totp_path(user_id: @user.id)

        assert_redirected_to confirm_password_session_path(url: user_totp_path(user_id: @user.id))
        assert_equal(true, @user.reload.totp.present?)
        assert_equal(true, @user.totp_secret.present?)
        assert_equal(true, @user.backup_codes.present?)
        assert_equal(false, @user.user_events.totp_disable.exists?)
      end
    end
  end
end
