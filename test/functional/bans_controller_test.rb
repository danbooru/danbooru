require 'test_helper'

class BansControllerTest < ActionDispatch::IntegrationTest
  context "A bans controller" do
    setup do
      @mod = create(:moderator_user, name: "danbo")
      @admin = create(:admin_user)
      @user = create(:member_user, id: 999, name: "cirno")

      as(@mod) { @ban = create(:ban, reason: "blah", user: @user, banner: @mod) }
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
      setup do
        as(@admin) { @admin_ban = create(:ban, user: build(:builder_user), banner: @admin, expires_at: 1.day.ago ) }
      end

      should "render" do
        get bans_path
        assert_response :success
      end

      should respond_to_search({}).with { [@admin_ban, @ban] }
      should respond_to_search(reason_matches: "blah").with { @ban }
      should respond_to_search(expired: "true").with { @admin_ban }

      context "using includes" do
        should respond_to_search(banner_name: "danbo").with { @ban }
        should respond_to_search(banner: {level: User::Levels::ADMIN}).with { @admin_ban }
        should respond_to_search(user_id: 999).with { @ban }
        should respond_to_search(user: {name: "cirno"}).with { @ban }
        should respond_to_search(user: {level: User::Levels::BUILDER}).with { @admin_ban }
      end
    end

    context "create action" do
      should "allow mods to ban members" do
        assert_difference("Ban.count", 1) do
          @user = create(:user)
          post_auth bans_path, @mod, params: { ban: { duration: 60, reason: "xxx", user_id: @user.id }}

          assert_redirected_to bans_path
          assert_equal(true, @user.reload.is_banned?)
        end
      end

      should "not allow mods to ban admins" do
        assert_difference("Ban.count", 0) do
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
          @user = create(:user)
          post_auth bans_path, @user, params: { ban: { duration: 60, reason: "xxx", user_id: @mod.id }}

          assert_response 403
          assert_equal(false, @mod.reload.is_banned?)
        end
      end

      should "not allow users to be double banned" do
        assert_difference("Ban.count", 0) do
          post_auth bans_path, @mod, params: { ban: { duration: 60, reason: "xxx", user_id: @ban.user.id }}
          assert_response :success
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
