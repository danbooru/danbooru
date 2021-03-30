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

      context "compact variant" do
        should "render" do
          get_auth comment_votes_path(variant: "compact"), create(:moderator_user)
          assert_response :success
        end
      end
    end

    context "create action" do
      setup do
        @user = create(:user)
        @comment = create(:comment)
      end

      should "not allow anonymous users to vote" do
        post comment_comment_votes_path(comment_id: @comment.id, score: "1"), xhr: true
        assert_response 403
      end

      should "allow Members to vote" do
        post_auth comment_comment_votes_path(comment_id: @comment.id, score: "1"), @user, xhr: true
        assert_response :success
      end

      should "create a upvote" do
        assert_difference("CommentVote.count", 1) do
          post_auth comment_comment_votes_path(comment_id: @comment.id, score: "1"), @user, xhr: true
        end

        assert_response :success
        assert_equal(1, @comment.reload.score)
      end

      should "create a downvote" do
        assert_difference("CommentVote.count", 1) do
          post_auth comment_comment_votes_path(comment_id: @comment.id, score: "-1"), @user, xhr: true
        end

        assert_response :success
        assert_equal(-1, @comment.reload.score)
      end

      should "ignore duplicate votes" do
        vote = create(:comment_vote, comment: @comment, user: @user, score: 1)
        assert_equal(1, vote.comment.reload.score)

        assert_difference("CommentVote.count", 1) do
          post_auth comment_comment_votes_path(comment_id: @comment.id, score: "1"), @user, xhr: true
        end

        assert_response :success
        assert_equal(1, @comment.reload.score)
        assert_equal(1, @comment.votes.active.count)
        assert_equal(1, @comment.votes.deleted.count)
      end

      should "automatically undo existing votes" do
        create(:comment_vote, comment: @comment, user: @user, score: -1)
        assert_equal(-1, @comment.reload.score)

        assert_difference("CommentVote.count", 1) do
          post_auth comment_comment_votes_path(comment_id: @comment.id, score: "1"), @user, xhr: true
        end

        assert_response :success
        assert_equal(1, @comment.reload.score)
        assert_equal(1, @comment.votes.active.count)
        assert_equal(1, @comment.votes.deleted.count)
      end

      should "not allow voting on deleted comments" do
        @comment.update!(is_deleted: true)

        assert_difference("CommentVote.count", 0) do
          post_auth comment_comment_votes_path(comment_id: @comment.id, score: "1"), @user, xhr: true
        end

        assert_response 403
        assert_equal(0, @comment.reload.score)
      end

      should "not update the comment's updated_at or updater_id" do
        assert_no_difference(["@comment.updater_id", "@comment.reload.updated_at"]) do
          assert_difference("CommentVote.count", 1) do
            post_auth comment_comment_votes_path(comment_id: @comment.id, score: "1"), @user, xhr: true

            assert_response :success
            assert_equal(1, @comment.reload.score)
          end
        end
      end
    end

    context "#destroy" do
      should "allow users to remove their own comment votes" do
        @vote = create(:comment_vote, user: @user)

        assert_difference("CommentVote.count", 0) do
          delete_auth comment_comment_votes_path(@vote.comment), @user, xhr: true
          assert_response :success
          assert_equal(true, @vote.reload.is_deleted?)
        end
      end

      should "not allow users to remove comment votes by other users" do
        @vote = create(:comment_vote)

        assert_difference("CommentVote.count", 0) do
          delete_auth comment_comment_votes_path(@vote.comment), @user, xhr: true
          assert_response 404
          assert_equal(false, @vote.reload.is_deleted?)
        end
      end

      context "deleting a vote on a comment that already has deleted votes" do
        setup do
          create(:comment_vote, comment: @comment, user: @user, score: 1, is_deleted: true)
          create(:comment_vote, comment: @comment, user: @user, score: -1, is_deleted: true)
        end

        should "delete the current active vote" do
          @vote = create(:comment_vote, comment: @comment, user: @user)
          delete_auth comment_comment_votes_path(@vote.comment), @user, xhr: true

          assert_response :success
          assert_equal(true, @vote.reload.is_deleted?)
        end
      end
    end
  end
end
