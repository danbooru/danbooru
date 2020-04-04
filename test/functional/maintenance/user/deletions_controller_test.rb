require "test_helper"

module Maintenance
  module User
    class DeletionsControllerTest < ActionDispatch::IntegrationTest
      context "in all cases" do
        setup do
          @user = create(:user)
        end

        context "#show" do
          should "render" do
            get_auth maintenance_user_deletion_path, @user
            assert_response :success
          end
        end

        context "#destroy" do
          should "delete the user when given the correct password" do
            delete_auth maintenance_user_deletion_path, @user, params: { user: { password: "password" }}
            assert_redirected_to posts_path
            assert_equal(true, @user.reload.is_deleted?)
            assert_equal("Your account has been deactivated", flash[:notice])
            assert_nil(session[:user_id])
          end

          should "not delete the user when given an incorrect password" do
            delete_auth maintenance_user_deletion_path, @user, params: { user: { password: "hunter2" }}
            assert_redirected_to maintenance_user_deletion_path
            assert_equal(false, @user.reload.is_deleted?)
            assert_equal("Password is incorrect", flash[:notice])
            assert_equal(@user.id, session[:user_id])
          end
        end
      end
    end
  end
end
