require 'test_helper'

class PostVoteTest < ActiveSupport::TestCase
  context "A PostVote" do
    setup do
      @post = create(:post)
    end

    context "during validation" do
      subject { build(:post_vote, post: @post) }

      should validate_inclusion_of(:score).in_array([-1, 1]).with_message("must be 1 or -1")
    end

    context "creating" do
      context "an upvote" do
        should "increment the post's score" do
          vote = create(:post_vote, post: @post, score: 1)

          assert_equal(1, @post.reload.score)
          assert_equal(1, @post.up_score)
          assert_equal(0, @post.down_score)
          assert_equal(1, @post.votes.active.positive.count)
        end

        should "soft delete other votes" do
          @user = create(:user)
          vote1 = create(:post_vote, post: @post, user: @user, score: -1)
          vote2 = create(:post_vote, post: @post, user: @user, score: 1)

          assert_equal(1, @post.reload.score)
          assert_equal(1, @post.up_score)
          assert_equal(0, @post.down_score)
          assert_equal(1, @post.votes.active.positive.count)
          assert_equal(0, @post.votes.active.negative.count)
          assert_equal(true, vote1.reload.is_deleted?)
        end
      end

      context "a downvote" do
        should "decrement the post's score" do
          vote = create(:post_vote, post: @post, score: -1)

          assert_equal(-1, @post.reload.score)
          assert_equal(0, @post.up_score)
          assert_equal(-1, @post.down_score)
          assert_equal(1, @post.votes.active.negative.count)
        end

        should "soft delete other votes" do
          @user = create(:user)
          vote1 = create(:post_vote, post: @post, user: @user, score: 1)
          vote2 = create(:post_vote, post: @post, user: @user, score: -1)

          assert_equal(-1, @post.reload.score)
          assert_equal(0, @post.up_score)
          assert_equal(-1, @post.down_score)
          assert_equal(0, @post.votes.active.positive.count)
          assert_equal(1, @post.votes.active.negative.count)
          assert_equal(true, vote1.reload.is_deleted?)
        end
      end
    end

    context "soft deleting" do
      context "an upvote" do
        should "decrement the post's score" do
          vote = create(:post_vote, post: @post, score: 1)
          assert_equal(1, @post.reload.score)
          assert_equal(1, @post.up_score)
          assert_equal(0, @post.down_score)
          assert_equal(1, @post.votes.active.count)
          assert_equal(0, @post.votes.deleted.count)

          vote.soft_delete
          assert_equal(0, @post.reload.score)
          assert_equal(0, @post.up_score)
          assert_equal(0, @post.down_score)
          assert_equal(0, @post.votes.active.count)
          assert_equal(1, @post.votes.deleted.count)
        end
      end

      context "a downvote" do
        should "increment the post's score" do
          vote = create(:post_vote, post: @post, score: -1)
          assert_equal(-1, @post.reload.score)
          assert_equal(0, @post.up_score)
          assert_equal(-1, @post.down_score)
          assert_equal(1, @post.votes.active.count)
          assert_equal(0, @post.votes.deleted.count)

          vote.soft_delete
          assert_equal(0, @post.reload.score)
          assert_equal(0, @post.up_score)
          assert_equal(0, @post.down_score)
          assert_equal(0, @post.votes.active.count)
          assert_equal(1, @post.votes.deleted.count)
        end
      end
    end

    context "deleting a vote by another user" do
      should "leave a mod action" do
        admin = create(:admin_user, name: "admin")
        vote = create(:post_vote, post: @post, score: 1)

        vote.soft_delete!(updater: admin)
        assert_match(/deleted post vote #\d+ on post #\d+/, ModAction.post_vote_delete.last.description)
        assert_equal(vote, ModAction.post_vote_delete.last.subject)
        assert_equal(admin, ModAction.post_vote_delete.last.creator)
      end
    end

    context "undeleting a vote by another user" do
      setup do
        @admin = create(:admin_user, name: "admin")
        @vote = create(:post_vote, post: @post, score: 1)

        @vote.soft_delete!(updater: @admin)
        @vote.update!(is_deleted: false, updater: @admin)
      end

      should "restore the score" do
        assert_equal(1, @post.reload.score)
        assert_equal(1, @post.up_score)
        assert_equal(0, @post.down_score)
        assert_equal(1, @post.votes.active.count)
        assert_equal(0, @post.votes.deleted.count)
      end

      should "leave a mod action" do
        assert_match(/undeleted post vote #\d+ on post #\d+/, ModAction.post_vote_undelete.last.description)
        assert_equal(@vote, ModAction.post_vote_undelete.last.subject)
        assert_equal(@admin, ModAction.post_vote_undelete.last.creator)
      end
    end
  end
end
