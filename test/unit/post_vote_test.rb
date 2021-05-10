require 'test_helper'

class PostVoteTest < ActiveSupport::TestCase
  context "A PostVote" do
    setup do
      @post = create(:post)
    end

    context "during validation" do
      subject { build(:post_vote, post: @post) }

      should validate_uniqueness_of(:user_id).scoped_to(:post_id).with_message("have already voted for this post")
      should validate_inclusion_of(:score).in_array([-1, 1]).with_message("must be 1 or -1")
    end

    context "creating" do
      context "an upvote" do
        should "increment the post's score" do
          vote = create(:post_vote, post: @post, score: 1)

          assert_equal(1, @post.reload.score)
          assert_equal(1, @post.up_score)
          assert_equal(0, @post.down_score)
          assert_equal(1, @post.votes.positive.count)
        end
      end

      context "a downvote" do
        should "decrement the post's score" do
          vote = create(:post_vote, post: @post, score: -1)

          assert_equal(-1, @post.reload.score)
          assert_equal(0, @post.up_score)
          assert_equal(-1, @post.down_score)
          assert_equal(1, @post.votes.negative.count)
        end
      end
    end

    context "destroying" do
      context "an upvote" do
        should "decrement the post's score" do
          vote = create(:post_vote, post: @post, score: 1)
          assert_equal(1, @post.reload.score)
          assert_equal(1, @post.up_score)
          assert_equal(0, @post.down_score)
          assert_equal(1, @post.votes.count)

          vote.destroy
          assert_equal(0, @post.reload.score)
          assert_equal(0, @post.up_score)
          assert_equal(0, @post.down_score)
          assert_equal(0, @post.votes.count)
        end
      end

      context "a downvote" do
        should "increment the post's score" do
          vote = create(:post_vote, post: @post, score: -1)
          assert_equal(-1, @post.reload.score)
          assert_equal(0, @post.up_score)
          assert_equal(-1, @post.down_score)
          assert_equal(1, @post.votes.count)

          vote.destroy
          assert_equal(0, @post.reload.score)
          assert_equal(0, @post.up_score)
          assert_equal(0, @post.down_score)
          assert_equal(0, @post.votes.count)
        end
      end
    end
  end
end
