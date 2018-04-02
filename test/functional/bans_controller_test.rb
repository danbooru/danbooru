require 'test_helper'

class BansControllerTest < ActionDispatch::IntegrationTest
  context "A bans controller" do
    setup do
      @mod = create(:moderator_user)
      @user = create(:user)
      as(@mod) do
        @ban = create(:ban, user: @user)
      end
    end

    should "get the new page" do
      get_auth new_ban_path, @mod
      assert_response :success
    end

    should "get the edit page" do
      get_auth edit_ban_path(@ban.id), @mod
      assert_response :success
    end

    should "get the show page" do
      get_auth ban_path(@ban.id), @mod
      assert_response :success
    end

    should "get the index page" do
      get_auth bans_path, @mod
      assert_response :success
    end

    should "search" do
      get_auth bans_path(search: {user_name: @user.name}), @mod
      assert_response :success
    end

    should "create a ban" do
      assert_difference("Ban.count", 1) do
        post_auth bans_path, @mod, params: {ban: {duration: 60, reason: "xxx", user_id: @user.id}}
      end
      ban = Ban.last
      assert_redirected_to(ban_path(ban))
    end

    should "update a ban" do
      put_auth ban_path(@ban.id), @mod, params: {ban: {reason: "xxx", duration: 60}}
      @ban.reload
      assert_equal("xxx", @ban.reason)
      assert_redirected_to(ban_path(@ban))
    end

    should "destroy a ban" do
      assert_difference("Ban.count", -1) do
        delete_auth ban_path(@ban.id), @mod
      end
      assert_redirected_to(bans_path)
    end
  end
end
