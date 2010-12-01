require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  context "A comments controller" do
    setup do
      CurrentUser.user = Factory.create(:user)
      CurrentUser.ip_addr = "127.0.0.1"
      @comment = Factory.create(:comment)
      @user = Factory.create(:moderator_user)
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    should "render the index page" do
      get :index
      assert_response :success
    end
    
    should "update a comment" do
      post :update, {:id => @comment.id, :comment => {:body => "abc"}}, {:user_id => @comment.creator_id}
      assert_redirected_to comment_path(@comment)
    end
    
    should "create a comment" do
      p = Factory.create(:post)
      assert_difference("Comment.count", 1) do
        post :create, {:comment => Factory.attributes_for(:comment, :post_id => p.id)}, {:user_id => @user.id}
      end
      comment = Comment.last
      assert_redirected_to post_path(comment.post)
    end
  end
end
