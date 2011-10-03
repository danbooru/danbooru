require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  context "A comment" do
    setup do
      user = Factory.create(:user)
      CurrentUser.user = user
      CurrentUser.ip_addr = "127.0.0.1"
      MEMCACHE.flush_all
      Danbooru.config.stubs(:member_comment_limit).returns(100)
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    should "be created" do
      comment = Factory.build(:comment)
      comment.save
      assert(comment.errors.empty?, comment.errors.full_messages.join(", "))
    end
    
    should "not bump the parent post" do
      post = Factory.create(:post)
      comment = Factory.create(:comment, :do_not_bump_post => "1", :post => post)
      post.reload
      assert_nil(post.last_commented_at)

      comment = Factory.create(:comment, :post => post)
      post.reload
      assert_not_nil(post.last_commented_at)
    end
    
    should "not update the post after exceeding the threshold" do
      Danbooru.config.stubs(:comment_threshold).returns(1)
      p = Factory.create(:post)
      c1 = Factory.create(:comment, :post => p)
      sleep 1
      c2 = Factory.create(:comment, :post => p)
      p.reload
      assert_equal(c1.created_at.to_s, p.last_commented_at.to_s)
    end
    
    should "not allow duplicate votes" do
      user = Factory.create(:user)
      post = Factory.create(:post)
      c1 = Factory.create(:comment, :post => post)
      comment_vote = c1.vote!(true)
      assert_equal([], comment_vote.errors.full_messages)
      comment_vote = c1.vote!(true)
      assert_equal(["User has already voted for this comment"], comment_vote.errors.full_messages)
      assert_equal(1, CommentVote.count)
    
      c2 = Factory.create(:comment, :post => post)
      comment_vote = c2.vote!(true)
      assert_equal([], comment_vote.errors.full_messages)
      assert_equal(2, CommentVote.count)
    end
    
    should "be searchable" do
      c1 = Factory.create(:comment, :body => "aaa bbb ccc")
      c2 = Factory.create(:comment, :body => "aaa ddd")
      c3 = Factory.create(:comment, :body => "eee")
    
      matches = Comment.body_matches("aaa")
      assert_equal(2, matches.count)
      assert_equal(c2.id, matches.all[0].id)
      assert_equal(c1.id, matches.all[1].id)
    end
  end
end
