require "test_helper"

class BackupCodesControllerTest < ActionDispatch::IntegrationTest
  context "The backup codes controller" do
    context "index action" do
      context "for a user without backup codes" do
        should "generate new backup codes for the user automatically" do
          @user = create(:user)
          get_auth user_backup_codes_path(@user), @user

          assert_response :success
          assert_equal(3, @user.reload.backup_codes.size)
          assert_equal(true, @user.user_events.backup_code_generate.exists?)
        end

        should "not allow a user to view a different user's backup codes" do
          @user = create(:user)
          get_auth user_backup_codes_path(@user), create(:user)

          assert_response 403
          assert_nil(@user.reload.backup_codes)
          assert_equal(false, @user.user_events.backup_code_generate.exists?)
        end
      end

      context "after enabling 2FA" do
        should "work" do
          @user = create(:user_with_2fa)
          get_auth user_backup_codes_path(@user, url: settings_path), @user

          assert_response :success
        end
      end

      context "for a user with backup codes" do
        should "show the user's existing backup codes" do
          @user = create(:user_with_2fa, backup_codes: [11111111, 22222222, 33333333])
          get_auth user_backup_codes_path(@user), @user

          assert_response :success
          assert_equal(true, @user.reload.backup_codes.present?)
          assert_equal(false, @user.user_events.backup_code_generate.exists?)
          assert_equal([11111111, 22222222, 33333333], @user.backup_codes)
        end
      end

      context "for a user who hasn't authenticated recently" do
        should "redirect to the confirm password page" do
          @user = create(:user_with_2fa)

          travel_to(1.day.ago) { login_as(@user) }
          get user_backup_codes_path(@user)

          assert_redirected_to confirm_password_session_path(url: user_backup_codes_path(@user))
        end
      end
    end

    context "create action" do
      context "for a user without backup codes" do
        should "generate new backup codes" do
          @user = create(:user)
          post_auth user_backup_codes_path(@user), @user

          assert_redirected_to user_backup_codes_path(@user)
          assert_equal(3, @user.reload.backup_codes.size)
          assert_equal("backup_code_generate", @user.user_events.last.category)
        end
      end

      context "for a user with backup codes" do
        should "regenerate the user's backup codes" do
          @user = create(:user_with_2fa, backup_codes: [11111111, 22222222, 33333333])
          post_auth user_backup_codes_path(@user), @user

          assert_redirected_to user_backup_codes_path(@user)
          assert_equal(3, @user.reload.backup_codes.size)
          assert_equal(true, @user.backup_codes.all? { |code| code.to_s.rjust(User::BACKUP_CODE_LENGTH, "0").match?(/\A\d{8}\z/) })
          assert_not_equal([11111111, 22222222, 33333333], @user.backup_codes)
          assert_equal("backup_code_generate", @user.user_events.last.category)
        end

        should "not allow a user to regenerate a different user's backup codes" do
          @user = create(:user_with_2fa, backup_codes: [11111111, 22222222, 33333333])
          post_auth user_backup_codes_path(@user), create(:user)

          assert_response 403
          assert_equal([11111111, 22222222, 33333333], @user.backup_codes)
          assert_equal(false, @user.user_events.backup_code_generate.exists?)
        end
      end

      context "for a user who hasn't authenticated recently" do
        should "redirect to the confirm password page" do
          @user = create(:user_with_2fa)

          travel_to(1.day.ago) { login_as(@user) }
          post user_backup_codes_path(@user)

          assert_redirected_to confirm_password_session_path(url: user_backup_codes_path(@user))
        end
      end
    end
  end
end
