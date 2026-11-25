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

      should "not count banned artist edits for anonymous users" do
        @banned_editor = create(:user)
        as(@banned_editor) { create(:artist, is_banned: true) }

        get moderator_dashboard_path
        assert_response :success
        assert_select "a[href=?]", artist_versions_path(search: { updater_id: @banned_editor.id }), count: 0

        get_auth moderator_dashboard_path, @user
        assert_response :success
        assert_select "a[href=?]", artist_versions_path(search: { updater_id: @banned_editor.id }), count: 1
      end

      should "not show deleted comments to non-moderators" do
        @deleted_comment = as(@user) { create(:comment, post: @post, body: "secret_comment_body", is_deleted: true) }
        create_list(:comment_vote, 3, score: -1, comment: @deleted_comment)

        get moderator_dashboard_path
        assert_response :success
        assert_no_match(/secret_comment_body/, response.body)

        get_auth moderator_dashboard_path, @user
        assert_response :success
        assert_no_match(/secret_comment_body/, response.body)

        get_auth moderator_dashboard_path, @admin
        assert_response :success
        assert_match(/secret_comment_body/, response.body)
      end
    end
  end
end
