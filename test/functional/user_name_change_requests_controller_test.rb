require 'test_helper'

class UserNameChangeRequestsControllerTest < ActionDispatch::IntegrationTest
  context "The user name change requests controller" do
    setup do
      @user = create(:member_user)
      @admin = create(:admin_user)
    end

    context "new action" do
      should "render" do
        get_auth new_user_name_change_request_path, @user
        assert_response :success
      end
    end

    context "create action" do
      should "work" do
        post_auth user_name_change_requests_path, @user, params: { user_name_change_request: { desired_name: "zun", desired_name_confirmation: "zun" }}

        assert_redirected_to profile_path
        assert_equal("zun", @user.reload.name)
      end
    end

    context "show action" do
      setup do
        @change_request = as(@user) { create(:user_name_change_request, user_id: @user.id) }
        @user.update!(name: "user_#{@user.id}")
      end

      should "render" do
        get_auth user_name_change_request_path(@change_request), @admin
        assert_response :success
      end

      context "when the current user is not an admin, doesn't own the request, and the other user is deleted" do
        should "fail" do
          @another_user = create(:user)
          get_auth user_name_change_request_path(@change_request), @another_user
          assert_response :forbidden
        end
      end
    end

    context "index action" do
      should "allows members to see name changes" do
        create(:user_name_change_request)
        get_auth user_name_change_requests_path, @user

        assert_response :success
        assert_select "table tbody tr", 1
      end

      should "not allow anonymous users to see name changes" do
        create(:user_name_change_request)
        get user_name_change_requests_path

        assert_response 403
      end
    end
  end
end
