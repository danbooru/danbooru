require 'test_helper'

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
    end
  end
end
