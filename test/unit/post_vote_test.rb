require 'test_helper'

class PostVoteTest < ActiveSupport::TestCase
  def setup
    super

    @user = FactoryBot.create(:user)
    CurrentUser.user = @user
    CurrentUser.ip_addr = "127.0.0.1"

    @post = FactoryBot.create(:post)
  end

  context "Voting for a post" do
    should "interpret up as +1 score" do
      vote = PostVote.create(:post_id => @post.id, :vote => "up")
      assert_equal(1, vote.score)
    end

    should "interpret down as -1 score" do
      vote = PostVote.create(:post_id => @post.id, :vote => "down")
      assert_equal(-1, vote.score)
    end

    should "not accept any other scores" do
      vote = PostVote.create(:post_id => @post.id, :vote => "xxx")
      assert(vote.errors.any?)
    end

    should "increase the score of the post" do
      @post.votes.create(vote: "up")
      @post.reload

      assert_equal(1, @post.score)
      assert_equal(1, @post.up_score)
    end

    should "decrease the score of the post when removed" do
      @post.votes.create(vote: "up").destroy
      @post.reload

      assert_equal(0, @post.score)
      assert_equal(0, @post.up_score)
    end
  end
end
