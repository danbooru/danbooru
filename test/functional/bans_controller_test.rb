require 'test_helper'

class BansControllerTest < ActionDispatch::IntegrationTest
  context "A bans controller" do
    context "new action" do
      should "render" do
        @mod = create(:mod_user)

        get_auth new_ban_path, @mod
        assert_response :success
      end
    end

    context "edit action" do
      should "render" do
        @mod = create(:mod_user)
        @ban = create(:ban)

        get_auth edit_ban_path(@ban.id), @mod
        assert_response :success
      end
    end

    context "show action" do
      should "render" do
        @ban = create(:ban)

        get ban_path(@ban)
        assert_response :success
      end
    end

    context "index action" do
      setup do
        @mod = create(:mod_user, name: "mod")
        @ban1 = create(:ban, created_at: 1.week.ago, duration: 1.day)
        @ban2 = create(:ban, user: build(:builder_user), reason: "blah", banner: @mod, duration: 100.years)
      end

      should "render" do
        get bans_path
        assert_response :success
      end

      should respond_to_search({}).with { [@ban2, @ban1] }
      should respond_to_search(reason_matches: "blah").with { @ban2 }
      should respond_to_search(expired: "false").with { @ban2 }
      should respond_to_search(duration: "<1w").with { @ban1 }

      should respond_to_search(banner_name: "mod").with { @ban2 }
      should respond_to_search(banner: { level: User::Levels::MODERATOR }).with { @ban2 }
    end

    context "create action" do
      should "allow mods to ban members" do
        assert_difference("Ban.count", 1) do
          @user = create(:user)
          @mod = create(:mod_user)
          post_auth bans_path, @mod, params: { ban: { duration: 1.day.iso8601, reason: "xxx", user_id: @user.id }}

          assert_redirected_to bans_path
          assert_equal(true, @user.reload.is_banned?)
          assert_match(/banned <@#{@user.name}> 1 day: xxx/, ModAction.last.description)
          assert_equal(@user, ModAction.last.subject)
          assert_equal(@mod, ModAction.last.creator)
        end
      end

      should "not allow mods to ban admins" do
        assert_difference("Ban.count", 0) do
          @admin = create(:admin_user)
          @mod = create(:mod_user)
          post_auth bans_path, @mod, params: { ban: { duration: 1.day.iso8601, reason: "xxx", user_id: @admin.id }}

          assert_response 403
          assert_equal(false, @admin.reload.is_banned?)
        end
      end

      should "not allow mods to ban other mods" do
        assert_difference("Ban.count", 0) do
          @mod = create(:mod_user)
          @mod2 = create(:mod_user)
          post_auth bans_path, @mod, params: { ban: { duration: 1.day.iso8601, reason: "xxx", user_id: @mod2.id }}

          assert_response 403
          assert_equal(false, @mod2.reload.is_banned?)
        end
      end

      should "not allow regular users to ban anyone" do
        assert_difference("Ban.count", 0) do
          @user = create(:user)
          @mod = create(:mod_user)
          post_auth bans_path, @user, params: { ban: { duration: 1.day.iso8601, reason: "xxx", user_id: @mod.id }}

          assert_response 403
          assert_equal(false, @mod.reload.is_banned?)
        end
      end

      should "not allow users to be double banned" do
        @ban = create(:ban, duration: 1.week)
        @mod = create(:mod_user)

        assert_difference("Ban.count", 0) do
          post_auth bans_path, @mod, params: { ban: { duration: 1.day.iso8601, reason: "xxx", user_id: @ban.user.id }}
          assert_response :success
        end
      end

      should "not raise an exception on a blank username" do
        @mod = create(:mod_user)
        post_auth bans_path, @mod, params: {}
        assert_response :success
      end
    end

    context "update action" do
      should "update a ban" do
        @ban = create(:ban)
        @mod = create(:mod_user)
        put_auth ban_path(@ban.id), @mod, params: {ban: {reason: "xxx", duration: 1.day.iso8601}}

        assert_equal("xxx", @ban.reload.reason)
        assert_redirected_to(ban_path(@ban))
      end
    end

    context "destroy action" do
      should "destroy a ban" do
        @ban = create(:ban)
        @mod = create(:mod_user)

        assert_difference("Ban.count", -1) do
          delete_auth ban_path(@ban.id), @mod

          assert_redirected_to bans_path
          assert_match(/unbanned <@#{@ban.user.name}>/, ModAction.last.description)
          assert_equal(@ban.user, ModAction.last.subject)
          assert_equal(@mod, ModAction.last.creator)
        end
      end
    end
  end
end
