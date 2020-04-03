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

    context "new action" do
      should "render" do
        get_auth new_ban_path, @mod
        assert_response :success
      end
    end

    context "edit action" do
      should "render" do
        get_auth edit_ban_path(@ban.id), @mod
        assert_response :success
      end
    end

    context "show action" do
      should "render" do
        get_auth ban_path(@ban.id), @mod
        assert_response :success
      end
    end

    context "index action" do
      should "render" do
        get_auth bans_path, @mod
        assert_response :success
      end
    end

    context "search action" do
      should "render" do
        get_auth bans_path(search: {user_name: @user.name}), @mod
        assert_response :success
      end
    end

    context "create action" do
      should "allow mods to ban members" do
        assert_difference("Ban.count", 1) do
          post_auth bans_path, @mod, params: { ban: { duration: 60, reason: "xxx", user_id: @user.id }}

          assert_redirected_to bans_path
          assert_equal(true, @user.reload.is_banned?)
        end
      end

      should "not allow mods to ban admins" do
        assert_difference("Ban.count", 0) do
          @admin = create(:admin_user)
          post_auth bans_path, @mod, params: { ban: { duration: 60, reason: "xxx", user_id: @admin.id }}

          assert_response 403
          assert_equal(false, @admin.reload.is_banned?)
        end
      end

      should "not allow mods to ban other mods" do
        assert_difference("Ban.count", 0) do
          @mod2 = create(:mod_user)
          post_auth bans_path, @mod, params: { ban: { duration: 60, reason: "xxx", user_id: @mod2.id }}

          assert_response 403
          assert_equal(false, @mod2.reload.is_banned?)
        end
      end

      should "not allow regular users to ban anyone" do
        assert_difference("Ban.count", 0) do
          post_auth bans_path, @user, params: { ban: { duration: 60, reason: "xxx", user_id: @mod.id }}

          assert_response 403
          assert_equal(false, @mod.reload.is_banned?)
        end
      end
    end

    context "update action" do
      should "update a ban" do
        put_auth ban_path(@ban.id), @mod, params: {ban: {reason: "xxx", duration: 60}}
        assert_equal("xxx", @ban.reload.reason)
        assert_redirected_to(ban_path(@ban))
      end
    end

    context "destroy action" do
      should "destroy a ban" do
        assert_difference("Ban.count", -1) do
          delete_auth ban_path(@ban.id), @mod
          assert_redirected_to bans_path
        end
      end
    end
  end
end
