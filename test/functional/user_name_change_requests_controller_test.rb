require 'test_helper'

class UserNameChangeRequestsControllerTest < ActionDispatch::IntegrationTest
  context "The user name change requests controller" do
    setup do
      @user = create(:member_user)
      @admin = create(:admin_user)
    end

    context "new action" do
      should "render" do
        get_auth change_name_user_path(@user), @user
        assert_response :success
      end

      should "render when the current user's name is invalid" do
        @user.update_columns(name: "foo__bar")
        get_auth change_name_user_path(@user), @user

        assert_response :success
      end
    end

    context "create action" do
      should "work for a user changing their own name" do
        post_auth user_name_change_requests_path, @user, params: { user_name_change_request: { user_id: @user.id, desired_name: "zun" }}

        assert_redirected_to @user
        assert_equal("zun", @user.reload.name)

        assert_equal(0, ModAction.user_name_change.count)
        assert_equal(0, @user.dmails.received.count)
      end

      should "work for a moderator changing a regular user's name" do
        @user = create(:user, name: "bkub")
        @mod = create(:moderator_user)
        post_auth user_name_change_requests_path, @mod, params: { user_name_change_request: { user_id: @user.id, desired_name: "zun" }}

        assert_redirected_to @user
        assert_equal("zun", @user.reload.name)

        assert_equal("user_name_change", ModAction.last.category)
        assert_equal(@mod, ModAction.last.creator)
        assert_equal(@user, ModAction.last.subject)
        assert_equal("changed user ##{@user.id}'s name from bkub to zun", ModAction.last.description)

        assert_equal(1, @user.dmails.received.count)
        assert_equal("Your username has been changed", @user.dmails.received.last.title)
        assert_no_enqueued_emails
      end

      should "fail if the new name is invalid" do
        assert_no_changes(-> { @user.reload.name }) do
          post_auth user_name_change_requests_path, @user, params: { user_name_change_request: { user_id: @user.id, desired_name: "foo__bar" }}

          assert_response :success
        end
      end

      should "fail for a regular user trying to change another user's name" do
        @user = create(:user, name: "bkub")
        post_auth user_name_change_requests_path, create(:builder_user), params: { user_name_change_request: { user_id: @user.id, desired_name: "zun" }}

        assert_response 403
        assert_equal("bkub", @user.reload.name)
      end

      should "fail for a moderator trying to change the name of someone above Builder level" do
        @user = create(:moderator_user, name: "mod")
        post_auth user_name_change_requests_path, create(:moderator_user), params: { user_name_change_request: { user_id: @user.id, desired_name: "zun" }}

        assert_response 403
        assert_equal("mod", @user.reload.name)
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
