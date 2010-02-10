require File.dirname(__FILE__) + '/../test_helper'

class PostTest < ActiveSupport::TestCase
  context "During moderation a post" do
    setup do
      @post = Factory.create(:post)
      @user = Factory.create(:user)
    end
    
    should "be unapproved once and only once" do
      @post.unapprove!("bad", @user, "127.0.0.1")
      assert(@post.is_flagged?, "Post should be flagged.")
      assert_not_nil(@post.unapproval, "Post should have an unapproval record.")
      assert_equal("bad", @post.unapproval.reason)
      
      assert_raise(Unapproval::Error) {@post.unapprove!("bad", @user, "127.0.0.1")}
    end
    
    should "not unapprove if no reason is given" do
      assert_raise(Unapproval::Error) {@post.unapprove!("", @user, "127.0.0.1")}
    end
    
    should "be deleted" do
      @post.delete!
      assert(@post.is_deleted?, "Post should be deleted.")
    end
    
    should "be approved" do
      @post.approve!
      assert(!@post.is_pending?, "Post should not be pending.")
      
      @deleted_post = Factory.create(:post, :is_deleted => true)
      @deleted_post.approve!
      assert(!@post.is_deleted?, "Post should not be deleted.")
    end
  end
end
