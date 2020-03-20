require 'test_helper'

class ForumPostVotesControllerTest < ActionDispatch::IntegrationTest
  context "The forum post votes controller" do
    setup do
      @user = create(:user)
      @other_user = create(:user)

      as(@user) do
        @forum_topic = create(:forum_topic)
        @forum_post = create(:forum_post, topic: @forum_topic)
        @bulk_update_request = create(:bulk_update_request, forum_post: @forum_post)
      end
    end

    context "index action" do
      should "render" do
        @forum_post_vote = create(:forum_post_vote, creator: @user, forum_post: @forum_post)
        get forum_post_votes_path
        assert_response :success
      end
    end

    context "create action" do
      should "allow members to vote" do
        assert_difference("ForumPostVote.count", 1) do
          post_auth forum_post_votes_path(format: :js), @user, params: { forum_post_id: @forum_post.id, forum_post_vote: { score: 1 }}
          assert_response :success
        end
      end

      should "not allow privileged users to vote on private forum posts" do
        as(@user) { @forum_post.topic.update!(min_level: User::Levels::ADMIN) }
        assert_difference("ForumPostVote.count", 0) do
          post_auth forum_post_votes_path(format: :js), @user, params: { forum_post_id: @forum_post.id, forum_post_vote: { score: 1 }}
          assert_response 403
        end
      end
    end

    context "destroy action" do
      setup do
        @forum_post_vote = create(:forum_post_vote, creator: @user, forum_post: @forum_post)
      end

      should "allow members to destroy their own votes" do
        assert_difference("ForumPostVote.count", -1) do
          delete_auth forum_post_vote_path(@forum_post_vote.id, format: :js), @user
          assert_response :success
        end
      end

      should "not allow members to destroy other people's votes" do
        assert_difference("ForumPostVote.count", 0) do
          delete_auth forum_post_vote_path(@forum_post_vote.id, format: :js), @other_user
          assert_response 403
        end
      end
    end
  end
end
