require 'test_helper'

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  context "Admin::UsersController" do
    setup do
      @mod = create(:moderator_user)
      @user = create(:user)
      @admin = create(:admin_user)
    end

    context "#edit" do
      should "render" do
        get_auth edit_admin_user_path(@user), @mod
        assert_response :success
      end
    end

    context "#update" do
      context "on a basic user" do
        should "succeed" do
          put_auth admin_user_path(@user), @mod, params: {:user => {:level => "30"}}
          assert_redirected_to(edit_admin_user_path(@user))
          assert_equal(30, @user.reload.level)
          assert_equal(@mod.id, @user.inviter_id)
        end

        should "promote the user to unrestricted uploads" do
          put_auth admin_user_path(@user), @mod, params: { user: { level: User::Levels::BUILDER, can_upload_free: true }}

          assert_redirected_to(edit_admin_user_path(@user.reload))
          assert_equal(true, @user.is_builder?)
          assert_equal(true, @user.can_upload_free?)
          assert_equal(false, @user.can_approve_posts?)
        end

        should "promote the user to approver" do
          put_auth admin_user_path(@user), @mod, params: { user: { level: User::Levels::BUILDER, can_approve_posts: true }}

          assert_redirected_to(edit_admin_user_path(@user.reload))
          assert_equal(true, @user.is_builder?)
          assert_equal(false, @user.can_upload_free?)
          assert_equal(true, @user.can_approve_posts?)
        end

        context "promoted to an admin" do
          should "fail" do
            put_auth admin_user_path(@user), @mod, params: {:user => {:level => "50"}}
            assert_response(403)
            assert_equal(20, @user.reload.level)
          end
        end
      end

      context "on an admin user" do
        should "fail" do
          put_auth admin_user_path(@admin), @mod, params: {:user => {:level => "30"}}
          assert_response(403)
          assert_equal(50, @admin.reload.level)
        end
      end
    end
  end
end
