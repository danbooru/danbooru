require 'test_helper'

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
      end

      should "render for the owner" do
        get_auth edit_admin_user_path(create(:builder_user)), create(:owner_user)
        assert_response :success
      end

      should "not render for a regular user" do
        get_auth edit_admin_user_path(@user), @user
        assert_response 403
      end
    end

    context "#update" do
      context "when a moderator is promoting a basic member" do
        should "allow promoting the user to gold" do
          put_auth admin_user_path(@user), @mod, params: {:user => {:level => "30"}}

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
            put_auth admin_user_path(@user), @mod, params: {:user => {:level => "50"}}

            assert_response(403)
            assert_equal(20, @user.reload.level)
            assert_equal(false, @user.feedback.exists?)
            assert_equal(false, @user.dmails.received.exists?)
            assert_equal(false, @user.mod_actions.user_level_change.exists?)
          end
        end

        context "when promoting the user to an invalid level" do
          should "fail" do
            put_auth admin_user_path(@user), @mod, params: { user: { level: "0" }}

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
          put_auth admin_user_path(@admin), @mod, params: {:user => {:level => "30"}}

          assert_response(403)
          assert_equal(50, @admin.reload.level)
          assert_equal(false, @admin.feedback.exists?)
          assert_equal(false, @admin.dmails.received.exists?)
          assert_equal(false, @admin.mod_actions.user_level_change.exists?)
        end
      end

      context "when a non-moderator is trying to promote another user" do
        should "fail" do
          put_auth admin_user_path(@user), create(:approver_user), params: { user: { level: "30" } }

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
