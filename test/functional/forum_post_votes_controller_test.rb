require 'test_helper'

class ForumPostVotesControllerTest < ActionDispatch::IntegrationTest
  context "The forum post votes controller" do
    setup do
      @user = create(:user)

      as(@user) do
        @forum_topic = create(:forum_topic)
        @forum_post = create(:forum_post, topic: @forum_topic)
      end
    end

    context "index action" do
      should "render" do
        @forum_post_vote = create(:forum_post_vote, creator: @user, forum_post: @forum_post)
        get forum_post_votes_path

        assert_response :success
      end
    end

    should "allow voting" do
      assert_difference("ForumPostVote.count") do
        post_auth forum_post_votes_path(format: :js), @user, params: { forum_post_id: @forum_post.id, forum_post_vote: { score: 1 }}
      end
      assert_response :success
    end

    context "when deleting" do
      should "allow removal" do
        @forum_post_vote = create(:forum_post_vote, creator: @user, forum_post: @forum_post)
        assert_difference("ForumPostVote.count", -1) do
          delete_auth forum_post_vote_path(@forum_post_vote.id, format: :js), @user
        end

        assert_response :success
      end
    end
  end
end
