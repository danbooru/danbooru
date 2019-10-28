require 'test_helper'

class ForumPostVotesControllerTest < ActionDispatch::IntegrationTest
  context "The forum post votes controller" do
    setup do
      @user = create(:user)

      as(@user) do
        @forum_topic = create(:forum_topic)
        @forum_post = create(:forum_post, topic: @forum_topic)
        @forum_post_vote = create(:forum_post_vote, creator: @user, forum_post: @forum_post)
      end
    end

    context "index action" do
      should "render" do
        get forum_post_votes_path
        assert_response :success
      end
    end
  end
end
