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
          assert_equal("Backup codes regenerated", flash[:notice])
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
          assert_equal("Backup codes regenerated", flash[:notice])
        end

        should "not allow a user to regenerate a different user's backup codes" do
          @user = create(:user_with_2fa, backup_codes: [11111111, 22222222, 33333333])
          post_auth user_backup_codes_path(@user), create(:user)

          assert_response 403
          assert_equal([11111111, 22222222, 33333333], @user.backup_codes)
          assert_equal(false, @user.user_events.backup_code_generate.exists?)
          assert_nil(flash[:notice])
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

    context "confirm recover action" do
      context "for an admin recovering a member account" do
        should "show the confirm recover page" do
          @user = create(:user, :with_2fa, :with_email)
          get_auth confirm_recover_user_backup_codes_path(@user), create(:admin_user)

          assert_response :success
        end

        should "show the confirm recover page for a user without backup codes" do
          @user = create(:user, :with_email)
          get_auth confirm_recover_user_backup_codes_path(@user), create(:admin_user)

          assert_response :success
        end

        should "show the confirm recover page for a user without an email" do
          @user = create(:user, :with_2fa)
          get_auth confirm_recover_user_backup_codes_path(@user), create(:admin_user)

          assert_response :success
        end
      end

      context "for an admin recovering a moderator account" do
        should "not show the confirm recover page" do
          @user = create(:moderator_user, :with_2fa, :with_email)
          get_auth confirm_recover_user_backup_codes_path(@user), create(:admin_user)

          assert_response 403
        end
      end

      context "for a member recovering someone else's account" do
        should "not show the confirm recover page" do
          @user = create(:user, :with_2fa, :with_email)
          get_auth confirm_recover_user_backup_codes_path(@user), create(:user)

          assert_response 403
        end
      end

      context "for an admin who hasn't authenticated recently" do
        should "redirect to the confirm password page" do
          @user = create(:user, :with_2fa, :with_email)

          travel_to(1.day.ago) { login_as(create(:admin_user)) }
          get confirm_recover_user_backup_codes_path(@user)

          assert_redirected_to confirm_password_session_path(url: confirm_recover_user_backup_codes_path(@user))
        end
      end
    end

    context "recover action" do
      context "for an admin recovering a member account" do
        should "send the recovery email" do
          @admin = create(:admin_user)
          @user = create(:user, :with_2fa, :with_email)
          post_auth recover_user_backup_codes_path(@user), @admin

          assert_redirected_to edit_admin_user_path(@user)
          assert_equal("backup_code_send", ModAction.last.category)
          assert_equal(@admin, ModAction.last.creator)
          assert_equal(@user, ModAction.last.subject)
          assert_equal("sent backup code to user ##{@user.id}", ModAction.last.description)

          assert_enqueued_with(job: MailDeliveryJob, args: ->(args) { args[0..1] == %w[UserMailer send_backup_code] })
          perform_enqueued_jobs
          assert_performed_jobs(1, only: MailDeliveryJob)
        end

        should "fail for a user without backup codes" do
          @user = create(:user, :with_email)
          post_auth recover_user_backup_codes_path(@user), create(:admin_user)

          assert_response 406
          assert_equal(false, ModAction.backup_code_send.exists?)
          assert_no_enqueued_jobs
        end

        should "fail for a user without an email" do
          @user = create(:user, :with_2fa)
          post_auth recover_user_backup_codes_path(@user), create(:admin_user)

          assert_response 406
          assert_equal(false, ModAction.backup_code_send.exists?)
          assert_no_enqueued_jobs
        end
      end

      context "for an admin recovering a moderator account" do
        should "fail" do
          @user = create(:moderator_user, :with_2fa, :with_email)
          post_auth recover_user_backup_codes_path(@user), create(:admin_user)

          assert_response 403
          assert_equal(false, ModAction.backup_code_send.exists?)
          assert_no_enqueued_jobs
        end
      end

      context "for a member recovering someone else's account" do
        should "fail" do
          @user = create(:user, :with_2fa, :with_email)
          post_auth recover_user_backup_codes_path(@user), create(:user)

          assert_response 403
          assert_equal(false, ModAction.backup_code_send.exists?)
          assert_no_enqueued_jobs
        end
      end

      context "for an admin who hasn't authenticated recently" do
        should "redirect to the confirm password page" do
          @user = create(:user, :with_2fa, :with_email)

          travel_to(1.day.ago) { login_as(create(:admin_user)) }
          post recover_user_backup_codes_path(@user)

          assert_redirected_to confirm_password_session_path(url: recover_user_backup_codes_path(@user))
          assert_equal(false, ModAction.backup_code_send.exists?)
          assert_no_enqueued_jobs
        end
      end
    end
  end
end
