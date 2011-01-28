require "test_helper"

class PostsControllerTest < ActionController::TestCase
  context "The posts controller" do
    setup do
      @user = Factory.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      @post = Factory.create(:post, :uploader_id => @user.id, :tag_string => "aaa")
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "index action" do
      should "render" do
        get :index
        assert_response :success
      end
      
      context "with a search" do
        should "render" do
          get :index, {:tags => "aaa"}
          assert_response :success
        end
      end
    end
    
    context "show action" do
      should "render" do
        get :show, {:id => @post.id}
        assert_response :success
      end
    end
    
    context "update action" do
      should "work" do
        post :update, {:id => @post.id, :post => {:tag_string => "bbb"}}, {:user_id => @user.id}
        assert_redirected_to post_path(@post)
        
        @post.reload
        assert_equal("bbb", @post.tag_string)
      end
    end
    
    context "revert action" do
      setup do
        @post.update_attributes(:tag_string => "zzz")
      end
      
      should "work" do
        @version = @post.versions(true).first
        assert_equal("aaa", @version.add_tags)
        post :revert, {:id => @post.id, :version_id => @version.id}, {:user_id => @user.id}
        assert_redirected_to post_path(@post)
        @post.reload
        assert_equal("aaa", @post.tag_string)
      end
    end
  end
end
