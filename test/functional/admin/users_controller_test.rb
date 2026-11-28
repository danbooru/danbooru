require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  context "Admin::UsersController" do
    setup do
      @mod = create(:moderator_user)
      @user = create(:user)
      @admin = create(:admin_user)
    end

    context "#edit" do
      should "render for a mod" do
        get_auth edit_admin_user_path(@user), @mod
        assert_response :success
        assert_equal("no-store", response.headers["Cache-Control"])
      end

      should "render for a superadmin" do
        get_auth edit_admin_user_path(create(:builder_user)), create(:superadmin_user)
        assert_response :success
      end

      should "not render for a regular user" do
        get_auth edit_admin_user_path(@user), @user
        assert_response 403
      end

      should "show that a user with 2FA but no email address can't recover their account" do
        user = create(:user_with_2fa)
        get_auth edit_admin_user_path(user), @admin

        assert_response :success
        assert_select ".chip-red", text: "No email"
        assert_select "a[href='#{confirm_recover_user_backup_codes_path(user_id: user.id)}'][disabled]"
      end
    end

    context "#update" do
      should "not change the level if the moderator hasn't recently reauthenticated" do
        login_as(@mod, reauthenticate: true)
        travel_to 16.minutes.from_now do
          put admin_user_path(@user), params: { user: { level: User::Levels::GOLD }}
        end

        assert_redirected_to confirm_password_session_path(url: admin_user_path(@user))
        assert_equal(User::Levels::MEMBER, @user.reload.level)
        assert_equal(false, @user.mod_actions.user_level_change.exists?)
      end

      should "not allow the owner to promote a user to superadmin" do
        put_auth admin_user_path(@user), create(:superadmin_user), params: { user: { level: User::Levels::SUPERADMIN }}, reauthenticate: true

        assert_response 403
        assert_equal(User::Levels::MEMBER, @user.reload.level)
      end

      context "when a moderator is promoting a basic member" do
        should "allow promoting the user to gold" do
          put_auth admin_user_path(@user), @mod, params: { user: { level: "30" }}, reauthenticate: true

          assert_redirected_to(edit_admin_user_path(@user))
          assert_equal(30, @user.reload.level)
          assert_equal(true, @user.feedback.exists?)
          assert_equal(true, @user.dmails.received.exists?)
          assert_equal(true, @user.mod_actions.user_level_change.exists?)
          assert_match(%r{promoted "#{@user.name}":/users/#{@user.id} from Member to Gold}, ModAction.last.description)
          assert_equal(@user, ModAction.last.subject)
          assert_equal(@mod, ModAction.last.creator)
        end

        context "when promoting the user to an admin" do
          should "fail" do
            put_auth admin_user_path(@user), @mod, params: { user: { level: "50" }}, reauthenticate: true

            assert_response(403)
            assert_equal(20, @user.reload.level)
            assert_equal(false, @user.feedback.exists?)
            assert_equal(false, @user.dmails.received.exists?)
            assert_equal(false, @user.mod_actions.user_level_change.exists?)
          end
        end

        context "when the level is missing" do
          should "not demote the user to anonymous" do
            put_auth admin_user_path(@user), @mod, params: { user: { name: "foo" }}, reauthenticate: true

            assert_response(403)
            assert_equal(20, @user.reload.level)
            assert_equal(false, @user.mod_actions.user_level_change.exists?)
          end
        end

        context "when promoting the user to an invalid level" do
          should "fail" do
            put_auth admin_user_path(@user), @mod, params: { user: { level: "0" }}, reauthenticate: true

            assert_response(403)
            assert_equal(20, @user.reload.level)
            assert_equal(false, @user.feedback.exists?)
            assert_equal(false, @user.dmails.received.exists?)
            assert_equal(false, @user.mod_actions.user_level_change.exists?)
          end
        end
      end

      context "when a moderator is demoting an admin" do
        should "fail" do
          put_auth admin_user_path(@admin), @mod, params: { user: { level: "30" }}, reauthenticate: true

          assert_response(403)
          assert_equal(50, @admin.reload.level)
          assert_equal(false, @admin.feedback.exists?)
          assert_equal(false, @admin.dmails.received.exists?)
          assert_equal(false, @admin.mod_actions.user_level_change.exists?)
        end
      end

      context "when a non-moderator is trying to promote another user" do
        should "fail" do
          put_auth admin_user_path(@user), create(:approver_user), params: { user: { level: "30" }}, reauthenticate: true

          assert_response(403)
          assert_equal(20, @user.reload.level)
          assert_equal(false, @user.feedback.exists?)
          assert_equal(false, @user.dmails.received.exists?)
          assert_equal(false, @user.mod_actions.user_level_change.exists?)
        end
      end
    end
  end
end
