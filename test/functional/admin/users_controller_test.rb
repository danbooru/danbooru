require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase
  context "Admin::UsersController" do
    setup do
      @mod = FactoryGirl.create(:moderator_user)
      CurrentUser.user = @mod
      CurrentUser.ip_addr = "127.0.0.1"
      @user = FactoryGirl.create(:user)
      @admin = FactoryGirl.create(:admin_user)
    end

    context "#edit" do
      should "render" do
        get :edit, {:id => @user.id}, {:user_id => @mod.id}
        assert_response :success
      end
    end

    context "#update" do
      context "on a basic user" do
        should "succeed" do
          put :update, {:id => @user.id, :user => {:level => "30"}}, {:user_id => @mod.id}
          assert_redirected_to(edit_admin_user_path(@user))
          @user.reload
          assert_equal(30, @user.level)
          assert_equal(@mod.id, @user.inviter_id)
        end

        context "promoted to an admin" do
          should "fail" do
            put :update, {:id => @user.id, :user => {:level => "50"}}, {:user_id => @mod.id}
            assert_redirected_to(new_session_path)
            @user.reload
            assert_equal(20, @user.level)
          end
        end
      end

      context "on an admin user" do
        should "fail" do
          put :update, {:id => @admin.id, :user => {:level => "30"}}
          assert_redirected_to new_session_path
          @admin.reload
          assert_equal(50, @admin.level)
        end
      end
    end
  end
end
