require 'test_helper'

class CommentVotesControllerTest < ActionController::TestCase
  context "A comment votes controller" do
    setup do
      CurrentUser.user = @user = Factory.create(:user)
      CurrentUser.ip_addr = "127.0.0.1"
      Danbooru.config.stubs(:member_comment_time_threshold).returns(1.week.from_now)
      @comment = Factory.create(:comment)
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    should "create a vote" do
      assert_difference("CommentVote.count", 1) do
        post :create, {:format => "js", :comment_id => @comment.id, :score => 1}, {:user_id => @user.id}
        assert_response :success
      end
    end
    
    should "fail silently on errors" do
      Factory.create(:comment_vote, :comment => @comment)
      assert_difference("CommentVote.count", 0) do
        post :create, {:format => "js", :comment_id => @comment.id, :score => 1}, {:user_id => @user.id}
        assert_response :success
      end
    end
  end
end
