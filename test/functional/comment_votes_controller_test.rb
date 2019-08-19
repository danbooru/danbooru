require 'test_helper'

class CommentVotesControllerTest < ActionDispatch::IntegrationTest
  context "A comment votes controller" do
    setup do
      CurrentUser.user = @user = create(:user)
      CurrentUser.ip_addr = "127.0.0.1"
      Danbooru.config.stubs(:member_comment_time_threshold).returns(1.week.from_now)
      @comment = create(:comment)
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "#create.json" do
      should "create a vote" do
        assert_difference("CommentVote.count", 1) do
          post_auth comment_votes_path(comment_id: @comment.id, score: "down", format: "json"), @user
          assert_response :success

          comment = JSON.parse(@response.body)
          assert_equal(@comment.id, comment["id"])
          assert_equal(-1, comment["score"])
        end
      end

      should "fail silently on errors" do
        create(:comment_vote, comment: @comment, score: -1)
        assert_difference("CommentVote.count", 0) do
          post_auth comment_votes_path(comment_id: @comment.id, score: "down", format: "json"), @user
          assert_response 422

          comment = JSON.parse(@response.body)
          assert_equal(false, comment["success"])
          assert_equal("Validation failed: You have already voted for this comment", comment["message"])
        end
      end
    end

    context "#create.js" do
      should "create a vote" do
        assert_difference("CommentVote.count", 1) do
          post_auth comment_votes_path(comment_id: @comment.id, format: "json", score: "down"), @user
          assert_response :success
        end
      end

      should "fail on errors" do
        create(:comment_vote, :comment => @comment, :score => -1)
        assert_difference("CommentVote.count", 0) do
          post_auth comment_votes_path(comment_id: @comment.id, :score => "down", format: "js"), @user
          assert_response 422
        end
      end
    end
  end
end
