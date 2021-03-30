require 'test_helper'

class CommentVoteTest < ActiveSupport::TestCase
  context "A CommentVote" do
    setup do
      @user = create(:user)
      @comment = as(@user) { create(:comment) }
    end

    context "during validation" do
      subject { build(:comment_vote, comment: as(@user) { create(:comment) }) }

      should validate_inclusion_of(:score).in_array([-1, 1]).with_message("must be 1 or -1")
    end

    should "not allow creating duplicate active votes" do
      v1 = create(:comment_vote, comment: @comment, user: @user)
      v2 = build(:comment_vote, comment: @comment, user: @user)

      assert_raise(ActiveRecord::RecordNotUnique) do
        v2.save(validate: false)
      end
    end

    should "allow creating duplicate deleted votes" do
      v1 = create(:comment_vote, comment: @comment, user: @user)
      v2 = create(:comment_vote, comment: @comment, user: @user, is_deleted: true)
      v3 = create(:comment_vote, comment: @comment, user: @user, is_deleted: true)

      assert_equal(true, v1.valid?)
      assert_equal(true, v2.valid?)
      assert_equal(true, v3.valid?)
    end

    context "creating" do
      context "an upvote" do
        should "increment the comment's score" do
          vote = create(:comment_vote, comment: @comment, score: 1)

          assert_equal(1, @comment.reload.score)
        end
      end

      context "a downvote" do
        should "decrement the comment's score" do
          vote = create(:comment_vote, comment: @comment, score: -1)

          assert_equal(-1, @comment.reload.score)
        end
      end
    end

    context "soft deleting" do
      context "an upvote" do
        should "decrement the comment's score" do
          vote = create(:comment_vote, comment: @comment, score: 1)
          assert_equal(1, @comment.reload.score)

          vote.soft_delete(updater: vote.user)
          assert_equal(0, @comment.reload.score)
          assert_equal(true, vote.is_deleted?)
        end
      end

      context "a downvote" do
        should "increment the comment's score" do
          vote = create(:comment_vote, comment: @comment, score: -1)
          assert_equal(-1, @comment.reload.score)

          vote.soft_delete(updater: vote.user)
          assert_equal(0, @comment.reload.score)
          assert_equal(true, vote.is_deleted?)
        end
      end
    end
  end
end
