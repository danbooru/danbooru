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
          @user.reload
          assert_equal(30, @user.level)
          assert_equal(@mod.id, @user.inviter_id)
        end

        context "promoted to an admin" do
          should "fail" do
            put_auth admin_user_path(@user), @mod, params: {:user => {:level => "50"}}
            assert_response(403)
            @user.reload
            assert_equal(20, @user.level)
          end
        end
      end

      context "on an admin user" do
        should "fail" do
          put_auth admin_user_path(@admin), @mod, params: {:user => {:level => "30"}}
          assert_response(403)
          @admin.reload
          assert_equal(50, @admin.level)
        end
      end
    end
  end
end
