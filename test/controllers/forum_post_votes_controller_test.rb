require 'test_helper'

class ForumPostVotesControllerTest < ActionDispatch::IntegrationTest
  context "The forum post votes controller" do
    setup do
      @user = create(:user)

      as_user do
        @forum_topic = create(:forum_topic)
        @forum_post = create(:forum_post, topic: @forum_topic)
      end
    end

    should "allow voting" do
      assert_difference("ForumPostVote.count") do
        post_auth forum_post_votes_path(forum_post_id: @forum_post.id), @user, params: {forum_post_vote: {score: 1}, format: "js"}
      end
      assert_response :success
    end

    context "when deleting" do
      setup do
        as_user do
          @forum_post_vote = @forum_post.votes.create(score: 1)
        end
      end

      should "allow removal" do
        assert_difference("ForumPostVote.count", -1) do
          delete_auth forum_post_votes_path(forum_post_id: @forum_post.id), @user, params: {format: "js"}
        end
        assert_response :success
      end
    end
  end
end
