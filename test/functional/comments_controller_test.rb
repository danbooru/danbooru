require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  context "A comments controller" do
    setup do
      CurrentUser.user = Factory.create(:user)
      CurrentUser.ip_addr = "127.0.0.1"
      Danbooru.config.stubs(:member_comment_time_threshold).returns(1.week.from_now)
      @post = Factory.create(:post)
      @comment = Factory.create(:comment, :post => @post)
      @user = Factory.create(:moderator_user)
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "index action" do
      should "render by post" do
        get :index, {:group_by => "post"}
        assert_response :success
      end
      
      should "render by comment" do
        get :index, {:group_by => "comment"}
        assert_response :success
      end
    end
    
    context "update action" do
      should "update the comment" do
        post :update, {:id => @comment.id, :comment => {:body => "abc"}}, {:user_id => @comment.creator_id}
        assert_redirected_to post_path(@comment.post)
      end
    end
    
    context "create action"do
      should "create a comment" do
        assert_difference("Comment.count", 1) do
          post :create, {:comment => Factory.attributes_for(:comment, :post_id => @post.id)}, {:user_id => @user.id}
        end
        comment = Comment.last
        assert_redirected_to post_path(comment.post)
      end
    end
  end
end
