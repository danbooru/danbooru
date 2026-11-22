require "test_helper"

class ModeratorDashboardControllerTest < ActionDispatch::IntegrationTest
  context "The moderator dashboard controller" do
    context "show action" do
      setup do
        @user = create(:user)
        @admin = create(:admin_user)
        @mod_action = create(:mod_action)
        @feedback = create(:user_feedback)
        @wiki_page = as(@user) { create(:wiki_page) }
        @post = as(@user) { create(:post) }
        @note = as(@user) { create(:note, post: @post) }
        @artist = as(@user) { create(:artist) }
        @comment = as(@user) { create(:comment, post: @post) }
        @comment_vote = create(:comment_vote, score: -1, comment: @comment)
      end

      should "render" do
        get_auth moderator_dashboard_path, @admin
        assert_response :success
      end

      should "render with search params" do
        get_auth moderator_dashboard_path, @admin, params: { search: { min_date: 1.day.ago.to_date, max_level: User::Levels::BUILDER }}
        assert_response :success
      end

      should "ignore unknown search params" do
        get_auth moderator_dashboard_path, @admin, params: { search: { foo: "x" }}
        assert_response :success
      end

      should "not show moderator-only mod actions to members" do
        create(:mod_action, category: "email_address_update", description: "changed email for secret_user_name")

        get_auth moderator_dashboard_path, @user
        assert_response :success
        assert_no_match(/secret_user_name/, response.body)

        get_auth moderator_dashboard_path, @admin
        assert_match(/secret_user_name/, response.body)
      end
    end
  end
end
