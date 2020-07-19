require 'test_helper'

class CommentVotesControllerTest < ActionDispatch::IntegrationTest
  context "A comment votes controller" do
    setup do
      CurrentUser.user = @user = create(:user, name: "cirno")
      CurrentUser.ip_addr = "127.0.0.1"
      @comment = create(:comment, creator: @user)
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "index action" do
      setup do
        @voter = create(:gold_user, name: "rumia")
        @vote = as (@voter) { create(:comment_vote, comment: @comment, user: @voter) }
        @negative_vote = create(:comment_vote, comment: @comment, score: -1)
        @unrelated_vote = create(:comment_vote)
      end

      context "as a user" do
        should "render" do
          get_auth comment_votes_path, @user
          assert_response :success
        end

        should respond_to_search({}).with { [] }
      end

      context "as a moderator" do
        setup do
          CurrentUser.user = create(:mod_user)
        end

        should respond_to_search({}).with { [@unrelated_vote, @negative_vote, @vote] }
        should respond_to_search(score: -1).with { @negative_vote }

        context "using includes" do
          should respond_to_search(comment: {creator_name: "cirno"}).with { [@negative_vote, @vote] }
          should respond_to_search(user_name: "rumia").with { @vote }
          should respond_to_search(user: {level: User::Levels::GOLD}).with { @vote }
        end
      end
    end

    context "#create.json" do
      should "create a vote" do
        assert_difference("CommentVote.count", 1) do
          post_auth comment_comment_votes_path(comment_id: @comment.id, score: "down"), @user, as: :json
          assert_response :success

          assert_equal(@comment.id, response.parsed_body["id"])
          assert_equal(-1, response.parsed_body["score"])
        end
      end

      should "fail silently on errors" do
        create(:comment_vote, user: @user, comment: @comment, score: -1)
        assert_difference("CommentVote.count", 0) do
          post_auth comment_comment_votes_path(comment_id: @comment.id, score: "down", format: "json"), @user
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
          post_auth comment_comment_votes_path(comment_id: @comment.id, format: "json", score: "down"), @user
          assert_response :success
        end
      end

      should "fail on errors" do
        create(:comment_vote, user: @user, comment: @comment, score: -1)
        assert_difference("CommentVote.count", 0) do
          post_auth comment_comment_votes_path(comment_id: @comment.id, :score => "down", format: "js"), @user
          assert_response 422
        end
      end
    end

    context "#destroy" do
      should "allow users to remove their own comment votes" do
        @vote = create(:comment_vote, user: @user)

        assert_difference("CommentVote.count", -1) do
          delete_auth comment_comment_votes_path(@vote.comment), @user
          assert_redirected_to @vote.comment
        end
      end

      should "not allow users to remove comment votes by other users" do
        @vote = create(:comment_vote)

        assert_difference("CommentVote.count", 0) do
          delete_auth comment_comment_votes_path(@vote.comment), @user
          assert_response 422
        end
      end
    end
  end
end
