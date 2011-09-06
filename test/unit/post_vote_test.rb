require File.expand_path('../../test_helper',  __FILE__)

class PostVoteTest < ActiveSupport::TestCase
  setup do
    user = Factory.create(:user)
    CurrentUser.user = user
    CurrentUser.ip_addr = "127.0.0.1"
    MEMCACHE.flush_all
    
    @post = Factory.create(:post)
  end
  
  context "Voting for a post" do
    should "interpret up as +1 score" do
      vote = PostVote.create(:post_id => @post.id, :score => "up")
      assert_equal(1, vote.score)
    end
    
    should "interpret down as -1 score" do
      vote = PostVote.create(:post_id => @post.id, :score => "down")
      assert_equal(-1, vote.score)
    end
    
    should "not accept any other scores" do
      vote = PostVote.create(:post_id => @post.id, :score => "xxx")
      assert(vote.errors.any?)
    end
  end
end
