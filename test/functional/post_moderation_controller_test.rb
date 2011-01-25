require "test_helper"

class PostModerationControllerTest < ActionController::TestCase
  context "The post moderation controller" do
    setup do
      @mod = Factory.create(:moderator_user)
      CurrentUser.user = @mod
      CurrentUser.ip_addr = "127.0.0.1"
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "moderate action" do
      setup do
        @post = Factory.create(:post, :is_pending => true)
      end
      
      should "list all pending posts" do
        get :moderate, {}, {:user_id => @mod.id}
        assert_response :success
      end
    end
    
    context "approve action" do
      setup do
        @post = Factory.create(:post, :is_pending => true)
      end
      
      should "approve a post" do
        post :approve, {:post_id => @post.id}, {:user_id => @mod.id}
        @post.reload
        assert(!@post.is_pending?)
      end
    end
    
    context "disapprove action" do
      setup do
        @post = Factory.create(:post, :is_pending => true)
      end

      should "disapprove a post" do
        assert_difference("PostDisapproval.count", 1) do
          post :disapprove, {:post_id => @post.id}, {:user_id => @mod.id}
        end
      end
    end
  end
end
